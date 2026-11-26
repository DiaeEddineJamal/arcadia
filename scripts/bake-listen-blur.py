"""Bake Listen's progressive blur into a scene clip (see VIDEO_VISUALS.md).

Usage: python bake-listen-blur.py <source.mp4> <out.mp4>
Needs: pip install opencv-python numpy imageio-ffmpeg
"""
import cv2, numpy as np, subprocess, sys, os, shutil
import imageio_ffmpeg
FF = imageio_ffmpeg.get_ffmpeg_exe()
src, dst = sys.argv[1], sys.argv[2]
c = cv2.VideoCapture(src)
w, h, fps = int(c.get(3)), int(c.get(4)), c.get(5)
y = (np.arange(h) / h)[:, None, None]
def smooth(a, b, x):
    t = np.clip((x - a) / (b - a), 0, 1); return t * t * (3 - 2 * t)
a1 = smooth(0.40, 0.56, y).astype(np.float32)
a2 = smooth(0.54, 0.72, y).astype(np.float32)
p = subprocess.Popen([FF, '-y', '-loglevel', 'error', '-f', 'rawvideo', '-pix_fmt', 'bgr24', '-s', f'{w}x{h}', '-r', f'{fps:.3f}',
                      '-i', '-', '-c:v', 'libx264', '-preset', 'medium', '-crf', '20', '-pix_fmt', 'yuv420p',
                      '-movflags', '+faststart', '-an', dst], stdin=subprocess.PIPE)
while True:
    ok, f = c.read()
    if not ok: break
    ff = f.astype(np.float32)
    small = cv2.resize(f, (w // 4, h // 4), interpolation=cv2.INTER_AREA)
    b1 = cv2.resize(cv2.GaussianBlur(small, (0, 0), 1.6), (w, h), interpolation=cv2.INTER_LINEAR).astype(np.float32)
    b2 = cv2.resize(cv2.GaussianBlur(small, (0, 0), 5.0), (w, h), interpolation=cv2.INTER_LINEAR).astype(np.float32)
    mid = ff + (b1 - ff) * a1
    out = mid + (b2 - mid) * a2
    p.stdin.write(np.clip(out, 0, 255).astype(np.uint8).tobytes())
p.stdin.close(); p.wait()
print(os.path.basename(dst), os.path.getsize(dst))
