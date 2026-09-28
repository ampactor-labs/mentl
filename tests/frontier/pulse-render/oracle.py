#!/usr/bin/env python3
"""The Pulse render's oracle: reads the WAV the program wrote and checks what
the score says must be in it, independently of the medium that made it.

  python3 oracle.py out.wav

Exit 0 when every check holds, 1 otherwise; one line per check either way.

What it checks, and why each is the program's own claim:
  - the RIFF/WAVE header: PCM, 2 channels, 48,000 Hz, 16 bits, block align 4,
    and a data chunk of exactly frames x 4 bytes for ten seconds;
  - loudness: each channel's RMS inside [0.05, 0.5] — a render that is
    silent, or that clips, fails;
  - no full-scale sample: the soft clip keeps every sample strictly inside
    the unit range, so |sample| < 32767;
  - the score is in the file: for each of the eight notes, the power at the
    lead's own pitch stands at least 20 dB above the median power at the
    score's other pitches, measured over that note's window.
"""
import math
import struct
import sys

RATE = 48000
SECONDS = 10
NOTES = [220.0, 261.63, 329.63, 440.0, 392.0, 329.63, 293.66, 261.63]


def goertzel(xs, freq):
    w = 2 * math.pi * freq / RATE
    c = 2 * math.cos(w)
    s1 = s2 = 0.0
    for v in xs:
        s0 = v + c * s1 - s2
        s2, s1 = s1, s0
    return s1 * s1 + s2 * s2 - c * s1 * s2


def main(path):
    data = open(path, "rb").read()
    results = []

    def check(ok, what):
        results.append(ok)
        print(("PASS " if ok else "FAIL ") + what)

    frames = RATE * SECONDS
    header_ok = (
        len(data) >= 44
        and data[0:4] == b"RIFF"
        and data[8:12] == b"WAVE"
        and data[12:16] == b"fmt "
        and data[36:40] == b"data"
    )
    check(header_ok, "RIFF/WAVE/fmt/data tags")
    if not header_ok:
        return 1
    fmt = struct.unpack("<IHHIIHH", data[16:36])
    check(fmt == (16, 1, 2, RATE, RATE * 4, 4, 16), "fmt chunk: PCM, 2 ch, 48000 Hz, 16 bit (got %r)" % (fmt,))
    size = struct.unpack("<I", data[40:44])[0]
    check(size == frames * 4 and len(data) == 44 + size, "data chunk: %d frames x 4 bytes (got %d, file %d)" % (frames, size, len(data)))
    n = (len(data) - 44) // 4
    left = []
    right = []
    peak = 0
    for i in range(n):
        l, r = struct.unpack_from("<hh", data, 44 + 4 * i)
        peak = max(peak, abs(l), abs(r))
        left.append(l / 32767.0)
        right.append(r / 32767.0)
    for name, ch in (("left", left), ("right", right)):
        rms = math.sqrt(sum(v * v for v in ch) / max(1, len(ch)))
        check(0.05 <= rms <= 0.5, "%s RMS %.4f inside [0.05, 0.5]" % (name, rms))
    check(peak < 32767, "no full-scale sample (peak %d)" % peak)
    mono = [(a + b) / 2 for a, b in zip(left, right)]
    per_note = frames // len(NOTES)
    probes = sorted(set(NOTES))
    for k, own in enumerate(NOTES):
        window = mono[k * per_note + RATE // 10 : k * per_note + RATE // 10 + RATE]
        power = {p: 10 * math.log10(goertzel(window, p) + 1e-12) for p in probes}
        others = sorted(v for p, v in power.items() if p != own)
        margin = power[own] - others[len(others) // 2]
        check(margin >= 20.0, "note %d: %.2f Hz stands %.1f dB over the score's other pitches" % (k, own, margin))
    return 0 if all(results) else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
