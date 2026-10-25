// ……（节略：sheet 骨架与样品/参数选择器、三个文本输入行，见仓内原文）
          // verdict 选择器（I03 改判）：改值入 state 随保存请求体提交；
          // 「未判定」= null 语义（Q3 裁定：不走专用 setVerdict 端点）。
          DropdownButtonFormField<String>(
            key: ValueKey(
              'verdict#${s.selectedSampleId}#${s.selectedParameterCode}#${s.verdict}',
            ),
            initialValue: s.verdict ?? '未判定',
            decoration: const InputDecoration(
              labelText: '判定',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: '合格', child: Text('合格')),
              DropdownMenuItem(value: '不合格', child: Text('不合格')),
              DropdownMenuItem(value: '未判定', child: Text('未判定')),
            ],
            onChanged: saving
                ? null
                : (v) {
                    if (v == null || v == '未判定') {
                      notifier.updateForm(clearVerdict: true);
                    } else {
                      notifier.updateForm(verdict: v);
                    }
                  },
          ),
// ……（节略：formError 上屏位与保存按钮，见仓内原文）