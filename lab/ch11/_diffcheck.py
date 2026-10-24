# -*- coding: utf-8 -*-
import io
import re
import os

OUT = r'D:\qiand-life\1-projects\xr-knowledge-suite\output\xr-know-019\chapters\chapter-011.verify.md'
BASE = r'D:\qiand-life\1-projects\xr-knowledge-suite\output\xr-know-019\lab\ch11'

back = io.open(OUT, encoding='utf-8').read()
found = re.findall(r'```text\n(.*?)\n```', back, re.S)
print('found blocks:', len(found))
names = [
    'logs_analyze_final.txt',
    'anim_lab/test/receipts/receipt_11_1.txt',
    'anim_lab/test/receipts/receipt_11_2.txt',
    '_receipts_windows/run_hero_excerpt.txt',
    'anim_lab/test/receipts/receipt_11_4.txt',
    'anim_lab/test/receipts/receipt_11_5.txt',
    'anim_lab/test/receipts/receipt_11_6.txt',
    '_receipts_windows/run_leak_excerpt.txt',
    '_receipts_windows/run_fixed_excerpt.txt',
    'logs_test_final.txt',
]
bad = 0
for i, (f, n) in enumerate(zip(found, names)):
    c = io.open(os.path.join(BASE, n.replace('/', os.sep)), encoding='utf-8').read().rstrip('\n')
    if f.rstrip('\n') != c:
        bad += 1
        print('MISMATCH at', i, n)
        fl, cl = f.splitlines(), c.splitlines()
        print(' line counts md/src:', len(fl), len(cl))
        for a, b in zip(fl, cl):
            if a != b:
                print('  md :', repr(a))
                print('  src:', repr(b))
                break
print('RESULT:', 'PASS' if bad == 0 and len(found) == len(names) else 'FAIL')
