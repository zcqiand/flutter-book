// 小改一：ValueKey 挂业务唯一值（人名），不挂 index——
// 列表一重排 index 自己就在变，挂 index 等于把「位置」又挂了一遍；
// ValueKey 先消掉「按位顶替」：勾不再扣给顶上来的无辜者
itemBuilder: (BuildContext context, int index) {
  return _CheckRow(
    key: ValueKey<String>(_names[index]),
    name: _names[index],
  );
}

// 小改二：findChildIndexCallback 告诉列表「人挪到了哪一行」——
// ListView.builder 按槽位（index）存续每行的 State，删掉头部数据后，
// 光有 ValueKey 只能消冤枉、勾不迁移；把旧 key 的人在新名单里的新位置报回去，
// 旧 State 才跟着人搬家，勾选真正跟人走
child: ListView.builder(
  findChildIndexCallback: (Key key) {
    // 这个人如今搬到第几行：按 key 里的人名在新名单查位，查无此人报 -1
    final ValueKey<String> valueKey = key as ValueKey<String>;
    return _names.indexOf(valueKey.value);
  },
  itemCount: _names.length,
  itemBuilder: (BuildContext context, int index) {
    return _CheckRow(
      key: ValueKey<String>(_names[index]),
      name: _names[index],
    );
  },
)