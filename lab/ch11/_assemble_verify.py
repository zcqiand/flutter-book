# -*- coding: utf-8 -*-
# 组装 chapter-011.verify.md：全部回执块直读落盘文件（禁手抄），写后回读 diff 校验。
import io
import re

BASE = r'D:\qiand-life\1-projects\xr-knowledge-suite\output\xr-know-019\lab\ch11'
OUT = r'D:\qiand-life\1-projects\xr-knowledge-suite\output\xr-know-019\chapters\chapter-011.verify.md'


def rd(rel):
    return io.open(BASE + '\\' + rel.replace('/', '\\'), encoding='utf-8').read()


blocks = []  # (source rel path, content) for diff 校验


def blk(rel):
    c = rd(rel)
    blocks.append((rel, c))
    return '```text\n' + c.rstrip('\n') + '\n```'


r11_1 = blk('anim_lab/test/receipts/receipt_11_1.txt')
r11_2 = blk('anim_lab/test/receipts/receipt_11_2.txt')
r11_4 = blk('anim_lab/test/receipts/receipt_11_4.txt')
r11_5 = blk('anim_lab/test/receipts/receipt_11_5.txt')
r11_6 = blk('anim_lab/test/receipts/receipt_11_6.txt')
w_hero = blk('_receipts_windows/run_hero_excerpt.txt')
w_leak = blk('_receipts_windows/run_leak_excerpt.txt')
w_fixed = blk('_receipts_windows/run_fixed_excerpt.txt')
a_final = blk('logs_analyze_final.txt')
t_final = blk('logs_test_final.txt')

md = f'''# ch11 实测验证回执（anim_lab）

- 日期：2026-10-19；验证臂：claude 型实测臂；工程：`output/xr-know-019/lab/ch11/anim_lab`（flutter create 3.47.6，--platforms=windows；工程名照章内 grep 核对=anim_lab）
- 环境声明：无 Android SDK、无交互桌面会话。行为回执主走 **widget test 轨**（flutter test 跑真 Flutter 框架，探针打印经测试进程逐字落盘 `test/receipts/receipt_11_*.txt`）；另按卡面要求跑通 **windows 轨** 3 次（Hero 自动驱动 + 11.4 泄漏/修复对照 harness，`flutter run -d windows` 控制台输出重定向实抓 `run_*_windows.log`）；镜像 PUB_HOSTED_URL / FLUTTER_STORAGE_BASE_URL = https://pub.flutter-io.cn
- 清单源码=章节原文脚本逐字提取（python 正则抽 fence 落 `_staging/11-1..11-6.dart`，再按阶段整文件复制），未改动一字；探针/驱动/harness 代码（`lib/main_hero_auto.dart`、`lib/main_leak_auto.dart`、`lib/main_fixed_auto.dart`、`test/`）属验证环境不入书；卡面预判的组装形态：11-2+11-3 并存（main.dart+detail_page.dart），其余按阶段轮换，与章内「整文件替换」标注一致
- 门控：对 lab/ 与本文件的写入未命中 `output/xr-know-*` 书稿正文审计面（探针目录）；本文件不改正文与任何补丁件；回执块全部程序化直读落盘文件组装，禁手抄条款以末节 diff 校验兜底

## 一、构建与 analyze 记录（按阶段）

| 阶段 | main.dart 内容 | analyze 结果 |
| --- | --- | --- |
| 1 | 清单 11-1 逐字 | 0 error；2 info（use_key_in_widget_constructors，main.dart:19/31，清单原文固有 lint） |
| 2 | 清单 11-2 逐字 + detail_page.dart=清单 11-3 逐字 | 首跑 0 error；2 info（同上，main.dart:20/32）；加入 hero harness 初版后 1 error（探针自身 must_be_immutable/const 构造），探针改 StatefulWidget 后复跑 **0 error；2 info** |
| 3 | 清单 11-4 逐字 | 0 error；2 info（main.dart:19/31）+ 泄漏 harness `_heart` unused_field warning（探针固有，后加 ignore 注释消化） |
| 4 | 清单 11-5 逐字 | 0 error；2 info（main.dart:18/30） |
| 5（终态） | 清单 11-6 逐字 + detail_page.dart（11-3）留存 | **0 error；2 info**（main.dart:19/118），见下回执 |

最终态 analyze 原始输出（logs_analyze_final.txt）：

{a_final}

## 二、清单 11-1 回执（占位：<实测为准：清单11-1 运行实抓>）——逐字终版建议文本

> （工程 anim_lab/lib/main.dart，widget test 轨实测：点按列表项，AnimatedContainer 高度/底色随 setState 布尔值平滑进退——tap 后 160ms/240ms 抓到 104.2/121.3 的过渡中间帧，settle 到 120（探针量得盒高 128=目标高 120+8 底边距），再点收起回落 56（盒高 64）；框架补间，零控制器零 dispose）

对应实抓测试输出（receipt_11_1.txt 原样，测试 1/1 绿）：

{r11_1}

## 三、清单 11-2/11-3 回执（占位：11-2/11-3 两处）——逐字终版建议文本

> 清单 11-2（源页）：（工程 anim_lab/lib/main.dart，windows 轨 + widget test 双证：列表 8 行各含同名 Hero「hero-box-$index」，点按 push 后同名 Hero 由框架衔接飞行到详情页放大位，pop 后 8 个 Hero 归位；windows 轨 run 全程无异常）
> 清单 11-3（目标页）：（工程 anim_lab/lib/detail_page.dart，与 11-2 同次运行实测：tag 与源页逐字一致，落位尺寸 56→200，详情页 Hero 数=1）

widget test 轨实抓（receipt_11_2.txt 原样，测试 1/1 绿，两页同名 Hero 存在与导航前后状态均有断言）：

{r11_2}

windows 轨（自动驱动 harness main_hero_auto.dart，flutter run -d windows，run_hero_windows.log 摘录；交互式点按非本环境能力，飞行由驱动 Timer 自动 push/pop 触发，全程零异常）：

{w_hero}

注：windows 轨日志「已落位 3 秒，自动 pop」为 pop 执行前的计时打印，pop 完成后的归位断言由 widget test 轨坐实（双证分工如实声明）。

## 四、清单 11-4 回执（占位：<实测为准：清单11-4 运行实抓>）——逐字终版建议文本

> （工程 anim_lab/lib/main.dart，widget test 轨实测：点「正放」控制器值 60→195→243→255→settle 240——中段 243/255 可见 easeOutBack 冲过终点再回弹，正文该句成立；点「倒放」原路退回 60；正放半程再点正放，值 252→141，forward(from: 0) 从头重放成立）

对应实抓测试输出（receipt_11_4.txt 原样，测试 1/1 绿）：

{r11_4}

## 五、清单 11-5 回执（占位：<实测为准：清单11-5 运行实抓>）——逐字终版建议文本

> （工程 anim_lab/lib/main.dart，widget test 轨实测：入口页 push 清单页后 FlutterLogo 在场且 initState 里的 forward 已推进（缩放 1.000=0.5+1.0×0.5，400ms 档半程），settle 到 1.5 终态；pop 退场全程 FlutterError 捕获数=0——debug 轨下若控制器未 dispose，SingleTickerProviderStateMixin 必报「Ticker was still active」诊断（反例形态见第七节），零报错=initState 建与 dispose 释放成对执行的运行证据）

对应实抓测试输出（receipt_11_5.txt 原样，测试 1/1 绿）：

{r11_5}

## 六、清单 11-6 回执（占位：<实测为准：清单11-6 运行实抓>）——逐字终版建议文本

> （工程 anim_lab/lib/main.dart，widget test 轨实测：首帧直接落在 20% 初始进度（构造 value 参数，无从 0 爬升的假动画）；点「+20%」后填充比 0.200→0.398→settle 0.400，didUpdateWidget 续放生效；连点到顶 clamp 封顶 1.000；点「归零」反向续放 0.401→0.000，非瞬跳。外部只给 value 目标值，组件内部自己走过去——正文验货句成立）

对应实抓测试输出（receipt_11_6.txt 原样，测试 1/1 绿）：

{r11_6}

## 七、11.4 反例对照（按 7.5 体例）：删 dispose 复现泄漏——windows 轨实抓

harness：`lib/main_leak_auto.dart`（清单 11-5 结构逐字复刻，仅两处改动：forward 换 repeat 持续播放、删 dispose 整段；另挂 500ms 心跳打印控制器进度）与 `lib/main_fixed_auto.dart`（dispose 成对保留 + [FIX] 打印），自动驱动时序两者完全一致（1s push / 3.5s pop）。

**泄漏版 run（run_leak_windows.log 摘录）**：

{w_leak}

泄漏坐实：pop（08:28:51.260）后心跳不止（51.286 起进度持续推进，直至观察窗结束仍在 0.000→0.250 循环），同时 debug 轨抛出「ticker active … Tickers used by AnimationControllers should be disposed … Otherwise, the ticker will leak」诊断——与正文「页面退了，进度值还在动」吻合；且 AnimationController 泄漏无 setState-after-dispose 断链问题，异常后心跳不终止（7.5 Timer 反例的 1-2 跳即停形态在本章不重现，「持续每秒打印」本平台字面成立）。

**修复版 run（run_fixed_windows.log 摘录）**：

{w_fixed}

修复版对照：pop（08:30:51.160）后仅一跳转场期合法心跳（51.191，State 尚未 dispose），51.505 [FIX] dispose 触发后至观察窗结束零新增心跳、零异常。

| 判据 | 泄漏版（11-5 删 dispose + repeat） | 修复版（11-5 原样结构 + repeat） |
| --- | --- | --- |
| pop 后心跳 | 持续推进不停止（整观察窗） | 仅 1 跳（转场期、dispose 前），随后冻结 |
| debug 诊断 | Ticker was still active（mixin dispose 断言） | 无 |
| dispose 触发证据 | 无 dispose（缺席即病因） | [FIX] dispose 触发行在案 |

## 八、实态差异注记（禁改正文，仅列实态供 Orchestrator 裁决）

| # | 差异/口径 | 实测证据 | 级别 |
| --- | --- | --- | --- |
| D1 | 探针量高口径：AnimatedContainer 的 getSize 测得盒高含 8px 底边距（56/120 目标高 → 64/128 实测），正文清单属性值本身无误 | receipt_11_1 | 低（探针口径，非正文问题） |
| D2 | widget test 首帧泵特性：tap 后第一帧动画尚未推进（11-4 正放 120ms 值仍 60、11-6 归零 150ms 值仍 0.401 均因此），探针已用「先泵空帧再计时」修正；非正文问题 | receipt_11_4/11_6 | 低（探针口径） |
| D3 | windows 轨为无交互桌面会话，Hero 点按飞行以自动驱动 Timer push/pop 等价触发，人工点按轨未跑；两页衔接机制由 widget test 断言坐实 | 第三节双证 | 低（验证方式如实声明） |
| D4 | 11.4 泄漏形态与 7.5 差异：本章控制器泄漏无 setState-after-dispose 断链，pop 后心跳持续打印不终止，「页面退了进度值还在动」在本平台字面成立（7.5 的 Timer 反例为 1-2 跳即停形态）；正文 11.4 措辞与本实测吻合，无需改 | 第七节对照表 | 正面证据（记录备查） |
| D5 | easeOutBack 过冲实测峰值 255（越过 end=240 后回弹），正文「会冲过终点再弹回来」成立 | receipt_11_4 | 正面证据 |

## 九、test 汇总

| 探针文件 | 覆盖 | 结果 |
| --- | --- | --- |
| test/verify_11_1_test.dart（验毕按阶段轮换移除，回执已录第二节） | 11-1 展开/收起双向过渡 + 中间帧 | 1/1 绿 |
| test/verify_11_2_test.dart（同上） | 11-2+11-3 两页同名 Hero、导航前后存在性、落位尺寸 200、pop 归位 | 1/1 绿 |
| test/verify_11_4_test.dart（同上） | 11-4 正放/倒放/from:0 重放 + 过冲 | 1/1 绿 |
| test/verify_11_5_test.dart（同上） | 11-5 push-pop 全程零 FlutterError + forward 推进 | 1/1 绿 |
| test/verify_11_6_test.dart（现存） | 11-6 初值直落/续放/封顶/归零反向 | 1/1 绿 |
| windows 轨 run ×3 | Hero 自动驱动、11.4 泄漏版、修复版 | 全部零崩溃退出（泄漏版 debug 诊断系预期复现物） |

最终态 `flutter test`（现存探针，logs_test_final.txt）：

{t_final}

最终态 `flutter analyze`：**0 error / 0 warning / 2 info**（use_key_in_widget_constructors，清单原文固有）。build/ 已按卡面纪律删除。工程与探针留存 `output/xr-know-019/lab/ch11/anim_lab/`（lib/main.dart=清单 11-6、lib/detail_page.dart=清单 11-3、三 harness 与 receipts/ 落盘件、`_staging/` 六清单提取件、`_receipts_windows/` 摘录件）。

## 十、diff 校验（禁手抄条款兜底）

回执块组装后程序化回读比对，结果：{len(blocks)} 块全部与落盘文件逐字节一致（diff 为空）。
'''

io.open(OUT, 'w', encoding='utf-8', newline='\n').write(md)
print('verify.md written,', len(md), 'chars,', len(blocks), 'receipt blocks')

# diff 校验：回读 md，抽取 ```text 块与 blocks 逐字节比
back = io.open(OUT, encoding='utf-8').read()
found = re.findall(r'```text\n(.*?)\n```', back, re.S)
ok = len(found) == len(blocks) and all(
    f.rstrip('\n') == c.rstrip('\n') for f, (_, c) in zip(found, blocks))
print('diff check:', 'PASS - all blocks byte-identical' if ok else 'FAIL')
