"""Turn a downloaded stock clip into Listen's two cuts (see VIDEO_SOURCES.md, VIDEO_VISUALS.md).

  python prepare-scene-clip.py <source.mp4> <out-dir> <name> [--start S] [--duration D]

Writes <out-dir>/scene-<name>-sharp.mp4 and scene-<name>-blur.mp4:
- trimmed to [start, start + duration] (duration capped at 12 s),
- cover-fitted to 1080x1920 portrait at 30 fps, muted,
- made to loop seamlessly: the last second cross-fades into the first, so the cut at the loop
  point disappears,
- the blurred cut carries BitChord's progressive blur (sharp to 40% of the height, heavy blur from
  72%), the same ramp as bake-listen-blur.py.

Needs: pip install opencv-python numpy imageio-ffmpeg
"""
import argparse
import subprocess

import cv2
import imageio_ffmpeg
import numpy as np

W, H, FPS = 1080, 1920, 30
FADE_S = 1.0
MAX_S = 12.0


def cover(frame):
    h, w = frame.shape[:2]
    s = max(W / w, H / h)
    nw, nh = int(round(w * s)), int(round(h * s))
    f = cv2.resize(frame, (nw, nh), interpolation=cv2.INTER_AREA if s < 1 else cv2.INTER_CUBIC)
    x, y = (nw - W) // 2, (nh - H) // 2
    return f[y:y + H, x:x + W]


def read_segment(path, start, duration):
    c = cv2.VideoCapture(path)
    src_fps = c.get(cv2.CAP_PROP_FPS)
    total = c.get(cv2.CAP_PROP_FRAME_COUNT) / src_fps
    duration = min(duration or total - start, total - start, MAX_S)
    # Read sequentially and resample to 30 fps by timestamp (seeking per frame is slow).
    frames, want, idx = [], 0, 0
    c.set(cv2.CAP_PROP_POS_MSEC, start * 1000)
    first = int(round(start * src_fps))
    n_out = int(duration * FPS)
    last = None
    while len(frames) < n_out:
        ok, f = c.read()
        if not ok:
            break
        t = (first + idx) / src_fps - start
        idx += 1
        last = f
        while len(frames) < n_out and want / FPS <= t + 1e-6:
            frames.append(cover(f))
            want += 1
    return frames


def seamless(frames):
    """Cross-fade the last FADE_S into the first FADE_S; the result loops without a jump."""
    n = int(FADE_S * FPS)
    if len(frames) <= 2 * n:
        return frames
    head, body, tail = frames[:n], frames[n:-n], frames[-n:]
    blend = [
        cv2.addWeighted(tail[k], 1 - (k + 1) / (n + 1), head[k], (k + 1) / (n + 1), 0)
        for k in range(n)
    ]
    # Playback: body → blend (tail turning into head) → loops back to body, which follows head.
    return body + blend


def ramps():
    y = (np.arange(H) / H)[:, None, None]

    def smooth(a, b):
        t = np.clip((y - a) / (b - a), 0, 1)
        return (t * t * (3 - 2 * t)).astype(np.float32)

    return smooth(0.40, 0.56), smooth(0.54, 0.72)


def blurred(frame, a1, a2):
    small = cv2.resize(frame, (W // 4, H // 4), interpolation=cv2.INTER_AREA)
    b1 = cv2.resize(cv2.GaussianBlur(small, (0, 0), 1.6 * 1.5), (W, H)).astype(np.float32)
    b2 = cv2.resize(cv2.GaussianBlur(small, (0, 0), 5.0 * 1.5), (W, H)).astype(np.float32)
    f = frame.astype(np.float32)
    mid = f + (b1 - f) * a1
    return np.clip(mid + (b2 - mid) * a2, 0, 255).astype(np.uint8)


def encode(frames, out, fn=None):
    p = subprocess.Popen(
        [imageio_ffmpeg.get_ffmpeg_exe(), '-y', '-loglevel', 'error', '-f', 'rawvideo', '-pix_fmt', 'bgr24',
         '-s', f'{W}x{H}', '-r', str(FPS), '-i', '-', '-c:v', 'libx264', '-preset', 'slow', '-crf', '22',
         '-pix_fmt', 'yuv420p', '-movflags', '+faststart', '-an', out],
        stdin=subprocess.PIPE)
    for f in frames:
        p.stdin.write((fn(f) if fn else f).tobytes())
    p.stdin.close()
    p.wait()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('src')
    ap.add_argument('out_dir')
    ap.add_argument('name')
    ap.add_argument('--start', type=float, default=0)
    ap.add_argument('--duration', type=float, default=0)
    a = ap.parse_args()
    frames = seamless(read_segment(a.src, a.start, a.duration))
    a1, a2 = ramps()
    encode(frames, f'{a.out_dir}/scene-{a.name}-sharp.mp4')
    encode(frames, f'{a.out_dir}/scene-{a.name}-blur.mp4', lambda f: blurred(f, a1, a2))
    print(a.name, len(frames) / FPS, 's')


if __name__ == '__main__':
    main()
