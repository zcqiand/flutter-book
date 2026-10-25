// ===== 时间线排序：ISO 字符串字典序即时序 =====
    final ordered = history.toList()
      ..sort((a, b) => b.at.compareTo(a.at)); // at 为 ISO 字符串，字典序即时序

// ===== 样品区：ext 补录入口与键名展示 =====
        for (final s in samples)
          ListTile(
            title: Text(s.sampleCode),
            subtitle: s.ext.isEmpty ? null : Text(s.ext.keys.join('、')),
            // ext 补录入口（M03.F01.I07）：点样品进补录页；保存成功回详情
            // 重载（SampleExtPage 监听 Saved 态自行 pop + 触发 load）。
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => SampleExtPage(
                  sample: s,
                  categoryCode: receipt.categoryCode,
                ),
              ),
            ),
          ),

// ===== 流程历史时间线 =====
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('流程历史', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        if (ordered.isEmpty)
          const Padding(padding: EdgeInsets.all(16), child: Text('暂无流转记录'))
        else
          for (final e in ordered)
            ListTile(
              title: Text(flowActionLabel(e.action)),
              subtitle: Text(
                '${flowStatusLabel(e.from)} → ${flowStatusLabel(e.to)} · ${e.operator_}',
              ),
              trailing: Text(e.at),
            ),