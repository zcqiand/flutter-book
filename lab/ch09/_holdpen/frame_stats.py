# -*- coding: utf-8 -*-
# 验证环境脚本（不入书）：按时间戳解析 FRAMETIMING 探针行，统计表9-1 三指标
# 用法: python frame_stats2.py <log>
import sys, re

path = sys.argv[1]
txt = open(path, encoding='utf-8', errors='replace').read()
frames = []  # (vsyncUs, spanMs)
starts, ends = [], []
for ln in txt.splitlines():
    m = re.search(r'FRAMETIMING vsyncUs=(\d+) totalSpanMs=([0-9.]+)', ln)
    if m:
        frames.append((int(m.group(1)), float(m.group(2))))
        continue
    m = re.search(r'COMPUTE_START atUs=(\d+)', ln)
    if m:
        starts.append(int(m.group(1)))
        continue
    m = re.search(r'COMPUTE_END atUs=(\d+)', ln)
    if m:
        ends.append(int(m.group(1)))

print('computes=%d frames_total=%d' % (len(starts), len(frames)))
if not starts or not ends:
    sys.exit('missing compute markers')

s0, e0 = starts[0], ends[0]
dur_s = (e0 - s0) / 1e6
win = [(v, s) for v, s in frames if s0 <= v <= e0 + 500000]
print('compute_window=%.2fs frames_in_window=%d' % (dur_s, len(win)))
if win:
    spans = [s for _, s in win]
    avg = sum(spans) / len(spans)
    worst = max(spans)
    drops = sum(1 for x in spans if x > 16.0)
    print('WIN avg=%.1fms worst=%.1fms drop_gt16=%d (%.1f%%)' % (
        avg, worst, drops, 100.0 * drops / len(spans)))
# 冻结空档：相邻帧 vsync 间隔 > 250ms 记一次长档
gaps = []
prev = None
for v, _ in win:
    if prev is not None and v - prev > 250000:
        gaps.append((v - prev) / 1e6)
    prev = v
print('gaps_gt_250ms=%s' % (['%.2f' % g for g in gaps],))
# 全程参考
if frames:
    spans_all = [s for _, s in frames]
    drops_all = sum(1 for x in spans_all if x > 16.0)
    print('ALL n=%d avg=%.1f worst=%.1f drops=%d' % (
        len(spans_all), sum(spans_all) / len(spans_all), max(spans_all), drops_all))
