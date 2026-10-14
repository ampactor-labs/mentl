#!/usr/bin/env python3
"""Summarize a wasmtime guest profile (`--profile=guest,<json>,<interval>`).

    python3 tools/guest-profile.py <profile.json> [TOP]        self and inclusive time per function
    python3 tools/guest-profile.py <profile.json> --callers FN [TOP]
                                                               who calls FN, three frames deep

A sample's stack is walked once; a function counts once per sample for its
inclusive share however many frames it holds. Tail calls leave no frame, so a
self-recursive walk shows as its caller.
"""
import collections
import json
import sys


def load(path):
    d = json.load(open(path))
    th = d['threads'][0]
    st = th.get('stringArray') or th.get('stringTable') or d.get('shared', {}).get('stringArray')

    def col(t, n):
        if 'schema' in t:
            i = t['schema'][n]
            return [r[i] if r is not None else None for r in t['data']]
        return t[n]

    prefix = col(th['stackTable'], 'prefix')
    frame = col(th['stackTable'], 'frame')
    func = col(th['frameTable'], 'func')
    names = [st[i] for i in col(th['funcTable'], 'name')]
    memo = {}

    def chain(stack):
        if stack not in memo:
            out = []
            s = stack
            while s is not None:
                out.append(names[func[frame[s]]])
                s = prefix[s]
            memo[stack] = out
        return memo[stack]

    stacks = [chain(s) for s in col(th['samples'], 'stack') if s is not None]
    return stacks


def summary(stacks, top):
    self_c = collections.Counter(c[0] for c in stacks)
    incl = collections.Counter()
    for c in stacks:
        incl.update(set(c))
    n = len(stacks)
    print(f'samples {n}')
    print('--- self')
    for f, k in self_c.most_common(top):
        print(f'{100 * k / n:6.2f}% {f}')
    print('--- inclusive')
    for f, k in incl.most_common(top):
        print(f'{100 * k / n:6.2f}% {f}')


def callers(stacks, target, top):
    par = collections.Counter()
    hits = 0
    for c in stacks:
        if c[0] != target:
            continue
        hits += 1
        k = 1
        while k < len(c) and c[k] == target:
            k += 1
        if k < len(c):
            par[' <- '.join(c[k:k + 3])] += 1
    print(f'{target}: {hits} self sample(s)')
    for p, k in par.most_common(top):
        print(f'{k:6d} {p}')


def main():
    args = sys.argv[1:]
    if not args:
        print(__doc__.strip())
        sys.exit(2)
    stacks = load(args[0])
    if len(args) >= 3 and args[1] == '--callers':
        callers(stacks, args[2], int(args[3]) if len(args) > 3 else 20)
    else:
        summary(stacks, int(args[1]) if len(args) > 1 else 40)


main()
