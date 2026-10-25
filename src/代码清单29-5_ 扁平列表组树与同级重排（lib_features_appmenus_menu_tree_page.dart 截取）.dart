  /// 扁平 → DFS 序 (menu, depth)。根 = parentId 零 UUID。
  List<(SysMenu, int)> _dfs(BuiltList<SysMenu> items) {
    final byParent = <String, List<SysMenu>>{};
    for (final m in items) {
      byParent.putIfAbsent(m.parentId, () => []).add(m);
    }
    for (final list in byParent.values) {
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }
    final out = <(SysMenu, int)>[];
    void walk(String parentId, int depth) {
      for (final m in byParent[parentId] ?? const <SysMenu>[]) {
        out.add((m, depth));
        walk(m.id, depth + 1);
      }
    }

    walk(kMenuRootParentId, 0);
    // 防御：孤儿节点（父不在集中）挂尾，不静默丢行。
    final seen = out.map((e) => e.$1.id).toSet();
    for (final m in items) {
      if (!seen.contains(m.id)) out.add((m, 0));
    }
    return out;
  }

  /// 同级序列（含自身，按 sortOrder）——I06 上移/下移的全量 orderedMenuIds。
  BuiltList<String> _siblingIds(BuiltList<SysMenu> items, SysMenu m) {
    final siblings = items.where((x) => x.parentId == m.parentId).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return BuiltList<String>(siblings.map((x) => x.id));
  }

  Future<void> _reorder(SysMenu m, int shift) async {
    final state = ref.read(menuTreeControllerProvider(widget.clientId));
    if (state is! MenuTreeLoaded) return;
    final ids = _siblingIds(state.items, m);
    final idx = ids.indexOf(m.id);
    final target = idx + shift;
    if (target < 0 || target >= ids.length) return; // 已在端头
    final next = ids.rebuild((b) {
      final id = b.removeAt(idx);
      b.insert(target, id);
    });
    final ok = await ref
        .read(menuTreeControllerProvider(widget.clientId).notifier)
        .reorder(m.id, next);
    if (!mounted) return;
    _toast(ok ? '排序已更新' : '排序失败，请重试');
  }