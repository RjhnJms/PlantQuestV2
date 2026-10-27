"""Makes PlantQuest's background music samples (original, generated here,
so there is nothing to license). Soft marimba to match the Wooden sounds.

Run:  python tool/make_music.py [out_dir]
Writes 22.05 kHz mono 16-bit WAV loops that repeat without a seam.
"""

import sys
import wave
from pathlib import Path

import numpy as np

RATE = 22050
RNG = np.random.default_rng(7)

NOTE = {n: i for i, n in enumerate(["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"])}


def hz(name):
    """'A4' -> 440.0"""
    pitch, octave = name[:-1], int(name[-1])
    midi = NOTE[pitch] + 12 * (octave + 1)
    return 440.0 * 2 ** ((midi - 69) / 12)


def marimba(freq, length=1.6, vel=1.0, bright=1.0):
    """A struck wooden bar: fundamental plus the bar's high partials, which
    fade fast, and a tiny mallet knock."""
    t = np.arange(int(length * RATE)) / RATE
    tone = np.sin(2 * np.pi * freq * t) * np.exp(-t * 3.2)
    tone += 0.35 * bright * np.sin(2 * np.pi * freq * 3.93 * t) * np.exp(-t * 14)
    tone += 0.12 * bright * np.sin(2 * np.pi * freq * 9.2 * t) * np.exp(-t * 30)
    knock = RNG.normal(0, 1, len(t)) * np.exp(-t * 400) * 0.08
    attack = np.minimum(t / 0.004, 1)
    return (tone + knock) * attack * vel


def bass(freq, length=1.2, vel=1.0):
    """A round wooden bass (low marimba bar)."""
    t = np.arange(int(length * RATE)) / RATE
    tone = np.sin(2 * np.pi * freq * t) + 0.25 * np.sin(2 * np.pi * freq * 2 * t)
    return tone * np.exp(-t * 2.2) * np.minimum(t / 0.01, 1) * vel


def pad(freqs, length, vel=1.0):
    """A soft held chord (like a breathy reed organ) that fills the space
    between marimba notes."""
    t = np.arange(int(length * RATE)) / RATE
    env = np.minimum(t / 0.6, 1) * np.minimum((t[-1] - t) / 0.8, 1)
    tone = sum(np.sin(2 * np.pi * f * t) + 0.15 * np.sin(2 * np.pi * f * 2 * t) for f in freqs)
    wobble = 1 + 0.04 * np.sin(2 * np.pi * 0.25 * t)
    return tone * env * wobble * 0.12 * vel


def shaker(vel=1.0):
    """A soft seed shaker: brushed noise."""
    n = int(0.09 * RATE)
    t = np.arange(n) / RATE
    noise = RNG.normal(0, 1, n)
    noise = np.diff(noise, prepend=0)  # thinner, higher
    return noise * np.sin(np.pi * t / t[-1]) ** 2 * 0.12 * vel


def reverb(x):
    """A small warm room: a few blended echoes."""
    out = x.copy()
    for delay, gain in [(0.031, 0.32), (0.047, 0.26), (0.071, 0.2), (0.113, 0.14), (0.173, 0.09)]:
        d = int(delay * RATE)
        for _ in range(3):
            out[d:] += out[:-d] * gain * 0.5
    return out


class Song:
    def __init__(self, bpm, bars, beats=4):
        self.beat = 60 / bpm
        self.length = bars * beats * self.beat
        n = int(self.length * RATE)
        self.n = n
        self.buf = np.zeros(n * 2 + RATE * 4)  # two passes + tails

    def add(self, at_beats, sound):
        # Each sound goes in both passes so the second pass already carries
        # the first pass's tails: that pass is the seamless loop.
        at_beats %= self.length / self.beat  # a pickup before beat 0 wraps to the end
        for p in range(2):
            i = int((at_beats * self.beat) * RATE) + p * self.n
            self.buf[i : i + len(sound)] += sound

    def render(self, volume):
        mix = reverb(self.buf)[self.n : 2 * self.n]
        mix = np.tanh(mix * 1.2) / 1.2  # gentle glue, no harsh peaks
        mix *= volume / max(1e-9, np.max(np.abs(mix)))
        return mix


CHORDS = {
    "F": ["F", "A", "C"],
    "Dm": ["D", "F", "A"],
    "Bb": ["A#", "D", "F"],
    "C": ["C", "E", "G"],
    "Am": ["A", "C", "E"],
    "G": ["G", "B", "D"],
    "Em": ["E", "G", "B"],
    "Gm": ["G", "A#", "D"],
}


def melody_line(song, chords, scale, octave, rhythm, vel, start=0, seed=1, rest=0.2):
    """An original tune: chord tones on strong beats, small steps between,
    each phrase of 4 bars ends on a chord tone."""
    rng = np.random.default_rng(seed)
    idx = len(scale) // 2
    beat = start
    for bar, chord in enumerate(chords):
        pos = 0.0
        for dur in rhythm[bar % len(rhythm)]:
            if rng.random() < rest and pos > 0:
                pos += dur
                continue
            strong = pos in (0.0, 2.0)
            if strong or (bar % 4 == 3 and pos + dur >= 4):
                tones = [i for i, n in enumerate(scale) if n[:-1] in CHORDS[chord]]
                idx = min(tones, key=lambda i: abs(i - idx))
            else:
                idx = int(np.clip(idx + rng.choice([-2, -1, -1, 1, 1, 2]), 0, len(scale) - 1))
            song.add(beat + bar * 4 + pos, marimba(hz(scale[idx]), length=1.4 + dur * song.beat, vel=vel))
            pos += dur


def scale_from(names, octaves):
    return [f"{n}{o}" for o in octaves for n in names]


def bahay_kubo_morning():
    """Slow, warm: marimba tune over rolled chords and a soft bass."""
    s = Song(bpm=84, bars=24)
    prog = ["F", "Dm", "Bb", "C"] * 2 + ["Dm", "Bb", "F", "C"] * 2 + ["Bb", "C", "Am", "Dm", "Bb", "C", "F", "F"]
    for bar, ch in enumerate(prog):
        root = CHORDS[ch][0]
        s.add(bar * 4, bass(hz(f"{root}2"), 2.2, 0.9))
        s.add(bar * 4 + 2.5, bass(hz(f"{root}2"), 1.2, 0.5))
        for k, n in enumerate(CHORDS[ch]):  # a soft roll on beat 1 and 3
            s.add(bar * 4 + k * 0.12, marimba(hz(f"{n}4"), 1.8, 0.28, bright=0.6))
            s.add(bar * 4 + 2 + k * 0.12, marimba(hz(f"{n}4"), 1.6, 0.2, bright=0.6))
    rhythm = [[1, 1, 1.5, 0.5], [1.5, 0.5, 2], [1, 0.5, 0.5, 1, 1], [2, 1, 1]]
    melody_line(s, prog, scale_from(["F", "G", "A", "C", "D"], [5]) + ["F6"], 5, rhythm, 0.55, seed=3)
    return s.render(0.8)


def garden_stroll():
    """Brighter and bouncier: walking bass, marimba arpeggios, shaker."""
    s = Song(bpm=100, bars=32)
    prog = (["C", "Am", "F", "G"] * 4) + (["F", "G", "Em", "Am"] * 2) + (["F", "G", "C", "C"] * 2)
    for bar, ch in enumerate(prog):
        notes = CHORDS[ch]
        root = notes[0]
        for b, n in enumerate([root, notes[2], root, notes[1]]):
            s.add(bar * 4 + b, bass(hz(f"{n}2"), 0.8, 0.7 if b % 2 == 0 else 0.5))
        arp = [notes[0], notes[1], notes[2], notes[1]] * 2
        for e, n in enumerate(arp):  # eighth-note arpeggio
            s.add(bar * 4 + e * 0.5, marimba(hz(f"{n}4"), 0.9, 0.22 if e % 2 else 0.3, bright=0.8))
        for e in range(8):
            s.add(bar * 4 + e * 0.5, shaker(1.0 if e % 2 else 0.55))
    rhythm = [[0.5, 0.5, 1, 1, 1], [1, 0.5, 0.5, 2], [0.5, 0.5, 0.5, 0.5, 1, 1], [1.5, 0.5, 1, 1]]
    melody_line(s, prog, scale_from(["C", "D", "E", "G", "A"], [5]) + ["C6", "D6"], 5, rhythm, 0.5, seed=11, rest=0.15)
    return s.render(0.8)


def quiet_focus():
    """Very soft and sparse, for quizzes: slow chords and a few high notes."""
    s = Song(bpm=70, bars=16)
    prog = ["C", "Am", "F", "G", "C", "Em", "F", "G"] * 2
    rng = np.random.default_rng(5)
    for bar, ch in enumerate(prog):
        notes = CHORDS[ch]
        s.add(bar * 4, bass(hz(f"{notes[0]}2"), 3.5, 0.45))
        s.add(bar * 4 - 0.25, pad([hz(f"{n}3") for n in notes], 4.6 * s.beat, 0.9))
        for k, n in enumerate(notes):
            s.add(bar * 4 + k * 0.33, marimba(hz(f"{n}4"), 3.0, 0.2, bright=0.4))
        if bar % 2 == 1:
            high = rng.choice(notes)
            s.add(bar * 4 + 2.5, marimba(hz(f"{high}5"), 2.5, 0.22, bright=0.5))
    return s.render(0.55)


def write(path, samples):
    data = (np.clip(samples, -1, 1) * 32767).astype("<i2").tobytes()
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(data)


if __name__ == "__main__":
    out = Path(sys.argv[1] if len(sys.argv) > 1 else "docs/previews/music")
    out.mkdir(parents=True, exist_ok=True)
    for name, make in [
        ("1-bahay-kubo-morning", bahay_kubo_morning),
        ("2-garden-stroll", garden_stroll),
        ("3-quiet-focus", quiet_focus),
    ]:
        samples = make()
        write(out / f"{name}.wav", samples)
        print(f"{name}: {len(samples) / RATE:.1f}s, {(out / f'{name}.wav').stat().st_size / 1e6:.1f} MB")
