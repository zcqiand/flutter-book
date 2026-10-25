// ===== 保存：Form 总闸 + 逐控件收值 =====
              FilledButton(
                onPressed: () {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  ref
                      .read(sampleExtControllerProvider.notifier)
                      .save(
                        sample: widget.sample,
                        values: {
                          for (final e in _controllers.entries)
                            e.key: e.value.text,
                        },
                      );
                },
                child: const Text('保存'),
              ),

// ===== 按字段定义生成控件 =====
  Widget _field(BuildContext context, ExtFieldDef d, SampleExtReady ready) {
    final initial = ready.originalExt[d.key] ?? '';
    final hasError = ready.errors.contains(d.key);
    final decoration = InputDecoration(
      labelText: (d.required_ ?? false) ? '${d.label} *' : d.label,
      errorText: hasError ? '必填' : null,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      // ExtFieldDefType 是 EnumClass 非 sealed：编译器不认穷举，未知值
      // fail-fast（ReceiptResult._resultLabel 同款）。
      child: switch (d.type) {
        ExtFieldDefType.text => TextFormField(
          key: ValueKey('ext-${d.key}'),
          controller: _ctrl(d.key, initial),
          decoration: decoration,
          validator: (v) =>
              ((d.required_ ?? false) && (v == null || v.trim().isEmpty))
              ? '必填'
              : null,
        ),
        ExtFieldDefType.number => TextFormField(
          key: ValueKey('ext-${d.key}'),
          controller: _ctrl(d.key, initial),
          decoration: decoration,
          keyboardType: TextInputType.number,
          validator: (v) {
            final t = v?.trim() ?? '';
            if ((d.required_ ?? false) && t.isEmpty) return '必填';
            if (t.isNotEmpty && num.tryParse(t) == null) return '须为数字';
            return null;
          },
        ),
        ExtFieldDefType.date => TextFormField(
          key: ValueKey('ext-${d.key}'),
          controller: _ctrl(d.key, initial),
          decoration: decoration,
          readOnly: true,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              _ctrl(d.key, initial).text =
                  '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
            }
          },
        ),
        ExtFieldDefType.select => DropdownButtonFormField<String>(
          key: ValueKey('ext-${d.key}'),
          // ……（节略：value 废弃注记一行，见仓内原文）
          initialValue: ready.originalExt[d.key],
          decoration: decoration,
          // BuiltList 默认工厂非 const（built_collection 5.1.2 现实）。
          items: (d.options ?? BuiltList<String>())
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) => _ctrl(d.key, initial).text = v ?? '',
          validator: (v) => ((d.required_ ?? false) && (v == null || v.isEmpty))
              ? '必填'
              : null,
        ),
        _ => throw ArgumentError('未知 ExtFieldDefType: ${d.type.name}'),
      },
    );
  }