"""Makes My Garden's nature sounds (copied into assets/sounds/garden/) (original, generated here, so there is
nothing to license): rain, birds, a breeze and the rainbow chime. Plus two
short mixes with the garden music, to hear them together.

Run:  python tool/make_garden_sounds.py [out_dir]
Writes 22.05 kHz mono 16-bit WAVs; the loops repeat without a seam.
"""

import sys
import wave
from pathlib import Path

import numpy as np

RATE = 22050
RNG = np.random.default_rng(11)


def lowpass(x, cutoff):
    """A gentle one-pole low-pass filter."""
    a = np.exp(-2 * np.pi * cutoff / RATE)
    y = np.empty_like(x)
    acc = 0.0
    for i, v in enumerate(x):
        acc = (1 - a) * v + a * acc
        y[i] = acc
    return y


def seamless(x, fade=1.0):
    """Folds the last [fade] seconds over the start so the loop has no click."""
    n = int(fade * RATE)
    head, tail = x[:n].copy(), x[-n:]
    ramp = np.linspace(0, 1, n)
    head = head * ramp + tail * (1 - ramp)
    return np.concatenate([head, x[n:-n]])


def normalise(x, peak=0.8):
    return x / (np.max(np.abs(x)) + 1e-9) * peak


def rain(seconds=14):
    """Soft rain on leaves: hushed filtered noise with little drops."""
    n = int((seconds + 1) * RATE)
    hush = lowpass(RNG.normal(0, 1, n), 1800) * 0.9 + lowpass(RNG.normal(0, 1, n), 5000) * 0.25
    # Slow breathing in the rain's strength.
    t = np.arange(n) / RATE
    hush *= 0.85 + 0.15 * np.sin(2 * np.pi * t / 7)
    drops = np.zeros(n)
    for _ in range(int(seconds * 9)):
        start = RNG.integers(0, n - 4000)
        f = RNG.uniform(1400, 3200)
        d = np.arange(int(0.05 * RATE)) / RATE
        drops[start : start + len(d)] += np.sin(2 * np.pi * f * d * (1 - d * 4)) * np.exp(-d * 90) * RNG.uniform(0.2, 0.6)
    return normalise(seamless(hush * 0.6 + drops), 0.7)


def chirp(f0, f1, length, vib=0.0):
    t = np.arange(int(length * RATE)) / RATE
    f = np.linspace(f0, f1, len(t)) * (1 + vib * np.sin(2 * np.pi * 30 * t))
    phase = 2 * np.pi * np.cumsum(f) / RATE
    env = np.sin(np.pi * t / length) ** 2
    return np.sin(phase) * env


def birds(seconds=18):
    """A few small birds calling now and then, over a faint breeze."""
    n = int((seconds + 1) * RATE)
    out = lowpass(RNG.normal(0, 1, n), 500) * 0.15
    t = 0.6
    while t < seconds:
        kind = RNG.integers(0, 3)
        if kind == 0:  # a quick "tweet-tweet"
            notes = [chirp(2600, 3800, 0.07) for _ in range(RNG.integers(2, 4))]
            gap = 0.11
        elif kind == 1:  # a falling whistle
            notes = [chirp(4200, 2500, 0.22, vib=0.02)]
            gap = 0.0
        else:  # a little trill
            notes = [chirp(3100, 3300, 0.035) for _ in range(6)]
            gap = 0.045
        at = int(t * RATE)
        vol = RNG.uniform(0.3, 0.7)
        for note in notes:
            end = min(at + len(note), n)
            out[at:end] += note[: end - at] * vol
            at += len(note) + int(gap * RATE)
        t += RNG.uniform(1.2, 3.2)
    return normalise(seamless(out), 0.55)


def breeze(seconds=14):
    """Wind in the trees: soft noise that swells and settles."""
    n = int((seconds + 1) * RATE)
    t = np.arange(n) / RATE
    wind = lowpass(RNG.normal(0, 1, n), 700)
    swell = 0.4 + 0.6 * (0.5 + 0.5 * np.sin(2 * np.pi * t / 6.5)) * (0.7 + 0.3 * np.sin(2 * np.pi * t / 2.3))
    return normalise(seamless(wind * swell), 0.45)


def bell(freq, length=1.6):
    t = np.arange(int(length * RATE)) / RATE
    tone = np.sin(2 * np.pi * freq * t) + 0.4 * np.sin(2 * np.pi * freq * 2.76 * t) * np.exp(-t * 6)
    return tone * np.exp(-t * 3.5) * np.minimum(t / 0.003, 1)


def rainbow_chime():
    """Four rising bells, like the colours arriving one by one."""
    out = np.zeros(int(2.6 * RATE))
    for i, f in enumerate([1046.5, 1318.5, 1568.0, 2093.0]):
        b = bell(f) * (0.9 - i * 0.1)
        at = int(i * 0.14 * RATE)
        out[at : at + len(b)] += b[: len(out) - at]
    return normalise(out, 0.7)


def read(path):
    with wave.open(str(path)) as w:
        data = np.frombuffer(w.readframes(w.getnframes()), dtype="<i2").astype(np.float64) / 32767
    return data


def mix(music, nature, music_level, nature_level, seconds=20):
    n = int(seconds * RATE)
    m = np.resize(music, n) * music_level
    s = np.resize(nature, n) * nature_level
    out = m + s
    fade = int(1.5 * RATE)
    out[:fade] *= np.linspace(0, 1, fade)
    out[-fade:] *= np.linspace(1, 0, fade)
    return out


def write(path, samples):
    data = (np.clip(samples, -1, 1) * 32767).astype("<i2").tobytes()
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(data)


if __name__ == "__main__":
    out = Path(sys.argv[1] if len(sys.argv) > 1 else "docs/previews/garden-sounds")
    out.mkdir(parents=True, exist_ok=True)
    sounds = {"rain": rain(), "birds": birds(), "breeze": breeze(), "rainbow": rainbow_chime()}
    for name, s in sounds.items():
        write(out / f"{name}.wav", s)
    music = read(Path("assets/music/bahay_kubo_morning.wav"))
    # The music a little quieter in the garden (0.35 → 0.25), nature under it.
    write(out / "mix-rainy.wav", mix(music, sounds["rain"], 0.25 / 0.35 * 0.8, 0.45))
    sunny = sounds["birds"] + np.resize(sounds["breeze"], len(sounds["birds"])) * 0.6
    write(out / "mix-sunny.wav", mix(music, sunny, 0.25 / 0.35 * 0.8, 0.5))
    print("ok", ", ".join(sorted(p.name for p in out.glob("*.wav"))))
