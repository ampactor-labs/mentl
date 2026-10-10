#!/usr/bin/env python3
"""tools/residue-truth.py — RESIDUE's peers held to the docs and the artifact.

RESIDUE.md is the one home of every named gap (PLAN §7: "a gap not in
RESIDUE.md does not exist"). Three claims that sentence makes are
checkable, so they are checked, at every verify, zero-tolerance:

  1. Every peer the read-path docs cite (PLAN, CLAUDE, SYNTAX, RESIDUE,
     LEDGER) is a RESIDUE entry header, ``### `Hβ.x` — STATUS``. A name
     cited in prose with no entry is a gap that lives only in a sentence.
  2. Every entry's STATUS comes from one closed vocabulary — OPEN,
     CLOSED <date>, RETRACTED [<date>], SUPERSEDED → <peer or PLAN §> —
     and every peer LEDGER records as CLOSED, RESOLVED or RETRACTED is
     not OPEN here. The ledger is history read newest first, so its first
     status-bearing mention of a peer is the peer's latest state.
  3. Every code name an OPEN entry backticks resolves: to a declaration
     the medium lists (`mentl query src/main.mn decls`), to a path on
     disk, or to the entry's own `Builds:` line — the names a design
     promises to mint. A CLOSED entry is history and is exempt; an open
     one may not lean on vocabulary the artifact deleted.

Born 2026-10-06 (the §0.3 integration), seen RED on the tree it was
written against before the sweep turned it green. It is the comment-ref
gate generalized to doc anchors — the queued absorption CLAUDE.md ⟳ names.

usage: residue-truth.py [--vocab FILE] [--list]
  --vocab FILE  read the declared names from FILE (one per line) instead of
                asking the medium; for measuring a tree before its boot moves
  --text FILE   with --vocab: a saved `text $` / `text _` answer (repeatable)
  --list        print every finding (the default prints the counts and the
                first twenty of each check)
"""
import glob, os, re, subprocess, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
os.chdir(ROOT)

PEER = re.compile(r'Hβ\.[A-Za-z0-9_-]+(?:\.[A-Za-z0-9_-]+)+')
HEADER = re.compile(r'^### `(Hβ\.[^`]+)` — (.+)$', re.M)
STATUS = re.compile(r'^(OPEN'
                    r'|CLOSED \d{4}-\d{2}-\d{2}'
                    r'|RETRACTED(?: \d{4}-\d{2}-\d{2})?'
                    r'|SUPERSEDED → (?:`Hβ\.[^`]+`|PLAN §\S.*))$')
LEDGER_CLOSE = re.compile(
    r'`(Hβ\.[^`]+)`[\s,:;()—-]{0,6}(CLOSED|RESOLVED|RETRACTED)\b'
    r'|\b(CLOSED|RESOLVED|RETRACTED)\b[\s:(—-]{0,6}`(Hβ\.[^`]+)`')
DOCS = ['PLAN.md', 'CLAUDE.md', 'docs/SYNTAX.md', 'RESIDUE.md', 'LEDGER.md']

args = sys.argv[1:]
show_all = '--list' in args
vocab_file = args[args.index('--vocab') + 1] if '--vocab' in args else None
text_files = [args[i + 1] for i, a in enumerate(args) if a == '--text']

residue = open('RESIDUE.md').read()
entries = {}            # name -> (status, body)
order = []
spans = [(m.start(), m.end(), m.group(1), m.group(2)) for m in HEADER.finditer(residue)]
for i, (s, e, name, status) in enumerate(spans):
    end = spans[i + 1][0] if i + 1 < len(spans) else len(residue)
    body = residue[e:end]
    if name in entries:
        entries[name + ' (duplicate)'] = (status, body)
    entries.setdefault(name, (status, body))
    order.append(name)

findings = {1: [], 2: [], 3: []}

# ── 1 · every cited peer is an entry header ────────────────────────────
for doc in DOCS:
    doc_lines = open(doc).read().split('\n')
    for ln, line in enumerate(doc_lines, 1):
        for m in PEER.finditer(line):
            name = m.group(0)
            # prose wraps a long name at its hyphen: `Hβ.x.long-` / `name`
            if name.endswith('-') and m.end() == len(line.rstrip().rstrip('`')) and ln < len(doc_lines):
                rest = re.match(r'\s*([A-Za-z0-9_-]+)', doc_lines[ln])
                if rest:
                    name += rest.group(1)
            if name not in entries:
                findings[1].append(f'{doc}:{ln}: {name}')

# ── 2 · the closed status vocabulary, and the ledger's closures ────────
seen = set()
for name in order:
    if name in seen:
        findings[2].append(f'{name}: two entry headers')
    seen.add(name)
    status = entries[name][0]
    if not STATUS.match(status):
        findings[2].append(f'{name}: status "{status}" is outside the vocabulary')
for line in residue.split('\n'):
    if line.startswith('### ') and not line.startswith('### `Hβ.'):
        findings[2].append(f'a ### heading that is not an entry: {line[:70]}')
latest = {}
for m in LEDGER_CLOSE.finditer(open('LEDGER.md').read()):
    name = m.group(1) or m.group(4)
    word = m.group(2) or m.group(3)
    latest.setdefault(name, word)
for name, word in sorted(latest.items()):
    if name not in entries:
        continue          # check 1 reports the missing header
    status = entries[name][0]
    if word in ('CLOSED', 'RESOLVED') and status.startswith('OPEN'):
        findings[2].append(f'{name}: LEDGER records it {word}, RESIDUE says {status}')
    if word == 'RETRACTED' and not status.startswith(('RETRACTED', 'SUPERSEDED')):
        findings[2].append(f'{name}: LEDGER records it RETRACTED, RESIDUE says {status}')

# ── 3 · an open entry's code names resolve ─────────────────────────────
def declared_names():
    """Every name the compiler's link declares (`decls`: declarations with
    their constructors, operations and state fields), and every word the
    emitter writes into the programs it emits and the names the compiler
    registers by string (`text $` and `text _`: the string literals, read for
    their identifiers — a WAT name like `$yield_flag` is vocabulary of the
    emitted program, and a primitive like `tangent_of` is registered by its
    spelling until it has a declaration of its own), and the board's keys."""
    if vocab_file:
        names = {l.strip() for l in open(vocab_file) if l.strip()}
        for tf in text_files:
            names |= literal_words(open(tf).read())
        return names | baseline_keys() | tool_functions()
    decls = subprocess.run(['mentl', 'query', 'src/main.mn', 'decls'],
                           capture_output=True, text=True).stdout
    names = decl_words(decls)
    if not names:
        return names
    # Every other program the repository ships is vocabulary too: each
    # example, and each library module the compiler's link does not reach
    # (a module is judged on its own link, so it answers for itself).
    linked = set(re.findall(r'\sat (\S+?):\d+:', decls))
    others = [p for p in sorted(glob.glob('examples/**/main.mn', recursive=True))]
    others += [p for p in sorted(glob.glob('lib/**/*.mn', recursive=True))
               if p[len('lib/'):-len('.mn')] not in linked]
    for prog in others:
        answer = subprocess.run(['mentl', 'query', prog, 'decls'],
                                capture_output=True, text=True).stdout
        names |= decl_words(answer)
    for needle in ('text $', 'text _'):
        answer = subprocess.run(['mentl', 'query', 'src/main.mn', needle],
                                capture_output=True, text=True).stdout
        names |= literal_words(answer)
    return names | baseline_keys() | tool_functions()

def tool_functions():
    """The gates and scaffolds are part of the artifact: a function a tools/
    script declares (`run_pulse_render`, a frontier leg) is a name too."""
    names = set()
    for p in glob.glob('tools/*.sh'):
        names |= set(re.findall(r'^\s*(\w+)\s*\(\)\s*\{', open(p).read(), re.M))
    return names

def baseline_keys():
    """The ratchet keys tools/verify-baseline.txt holds: a bound's name is
    the board's vocabulary, read where it lives."""
    keys = set()
    if os.path.exists('tools/verify-baseline.txt'):
        for l in open('tools/verify-baseline.txt'):
            m = re.match(r'\s*([A-Za-z_][A-Za-z0-9_]*)\s*[:=]', l)
            if m:
                keys.add(m.group(1))
    return keys

def decl_words(answer):
    """The names a `decls` answer lists, one per located line."""
    return {m.group(1) for m in re.finditer(r'^\s+(\S+)\s+at\s', answer, re.M)}

def literal_words(answer):
    """The identifiers inside every string literal a `text` answer locates:
    the facet answers each literal's site, and the words are read there."""
    words = set()
    cache = {}
    for m in re.finditer(r'at (\S+?):(\d+):(\d+)-(\d+):(\d+)', answer):
        mod, l1, c1, l2, c2 = m.group(1), *map(int, m.groups()[1:])
        path = next((p for p in (f'src/{mod}.mn', f'lib/{mod}.mn') if os.path.exists(p)), None)
        if not path:
            continue
        if path not in cache:
            cache[path] = open(path).read().split('\n')
        src = cache[path]
        if l1 == l2:
            text = src[l1 - 1][c1 - 1:c2]
        else:
            text = '\n'.join([src[l1 - 1][c1 - 1:]] + src[l1:l2 - 1] + [src[l2 - 1][:c2]])
        words |= set(re.findall(r'\$?[A-Za-z_][A-Za-z0-9_]*', text))
    return words

CODE = re.compile(r'^\$?[A-Za-z_][A-Za-z0-9_]*$')
DIAG = re.compile(r'^([EWTP])_([A-Za-z0-9]+)$')
PATH = re.compile(r'^[A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.*-]+)+(?::\d+(?:[-–]\d+)?)?/?$')

def code_looking(tok):
    t = tok.lstrip('$')
    return tok.startswith('$') or '_' in t or re.search(r'[a-z][A-Z]', t) is not None

vocab = declared_names()
if not vocab:
    findings[3].append('the declared-name roster came back empty — the check cannot fail, so it fails')
for name in order:
    status, body = entries[name]
    if not status.startswith('OPEN'):
        continue
    # the Builds paragraph may wrap: it runs to the next blank line
    builds = set()
    for bl in re.findall(r'^\*\*Builds:\*\*(.*?)(?:\n[ \t]*\n|\Z)', body, re.M | re.S):
        builds |= set(re.findall(r'`([^`]+)`', bl))
    for tok in re.findall(r'`([^`\n]+)`', body):
        tok = tok.strip()
        # a leading underscore marks a fragment (`_row`, the suffix) or a
        # local the emitter mints (`__state`) — neither is a declaration
        # a trailing underscore marks a prefix (`fs_`, `E_`), and `Name/2` is
        # a facet's name-and-arity answer — neither is a reference
        if tok in builds or tok.startswith(('Hβ.', '_')) or tok.endswith('_') \
                or re.match(r'^[A-Za-z_]\w*/\d+$', tok):
            continue
        if PATH.match(tok):
            path = re.sub(r':\d+(?:[-–]\d+)?$', '', tok)
            if '*' in path or any(os.path.exists(c) for c in
                                  (path, path + '.mn', f'src/{path}.mn', f'lib/{path}.mn')):
                continue
            findings[3].append(f'{name}: `{tok}` — no such path')
            continue
        if not CODE.match(tok) or not code_looking(tok):
            continue
        d = DIAG.match(tok)
        key = d.group(1) + d.group(2) if d else tok
        if key in vocab or tok in vocab or tok.lstrip('$') in vocab:
            continue
        findings[3].append(f'{name}: `{tok}` resolves to no declaration')

labels = {1: 'cited peers with no entry', 2: 'statuses and ledger closures',
          3: 'open entries leaning on names the artifact does not declare'}
fail = 0
for k in (1, 2, 3):
    fs = findings[k]
    if fs:
        fail = 1
        print(f'residue-truth: check {k} ({labels[k]}): {len(fs)}')
        for f in (fs if show_all else fs[:20]):
            print(f'  {f}')
        if not show_all and len(fs) > 20:
            print(f'  … {len(fs) - 20} more (--list prints them all)')
if not fail:
    print(f'residue-truth: {len(order)} entries — every cited peer is homed, every status is in the vocabulary, every open entry names live code')
sys.exit(fail)
