/// 列表页：等详情页回传收藏结果后局部刷新
class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  // 数据写死在内存里，教学自包含：不依赖网络与数据库
  final List<Item> _items = const <Item>[
    Item(id: 1, title: 'Navigator 路由基础'),
    Item(id: 2, title: '页面栈与返回值'),
    Item(id: 3, title: '命名路由与路由表'),
  ];

  // 用 Set 而非 List 存收藏 id：contains 是 O(1)，条目多了也不拖慢每次重建
  final Set<int> _favoriteIds = <int>{};

  Future<void> _openDetail(Item item) async {
    // 构造参数直传是主式：类型安全、编译期查错、IDE 可补全；
    // RouteSettings.arguments 走 Object? 强转，错类型要到运行期才炸
    final bool? result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => DetailPage(
          item: item,
          isFavorite: _favoriteIds.contains(item.id),
        ),
      ),
    );
    // result 为 null 说明用户按系统返回键退出，视为「没改收藏」，不触发刷新
    if (result != null) {
      setState(() {
        if (result) {
          _favoriteIds.add(item.id);
        } else {
          _favoriteIds.remove(item.id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('列表')),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int index) {
          final Item item = _items[index];
          return ListTile(
            leading: _favoriteIds.contains(item.id)
                ? const Icon(Icons.favorite, color: Colors.red)
                : const Icon(Icons.favorite_border),
            title: Text(item.title),
            subtitle: Text('id: ${item.id}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openDetail(item),
          );
        },
      ),
    );
  }
}

/// 详情页：参数从构造函数进来，收藏结果经 pop 带回
class DetailPage extends StatefulWidget {
  const DetailPage({
    super.key,
    required this.item,
    required this.isFavorite,
  });

  final Item item;
  final bool isFavorite;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    // 构造参数拷进可变状态：详情页内允许先切换，点了「保存并返回」才回传
    _isFavorite = widget.isFavorite;
  }

  void _saveAndPop() {
    // pop 带回最新收藏态；列表页 await 的 Future 在这一刻 complete
    Navigator.of(context).pop(_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('条目 id：${widget.item.id}'),
            const SizedBox(height: 8),
            Text('标题：${widget.item.title}'),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () => setState(() => _isFavorite = !_isFavorite),
              child: Text(_isFavorite ? '已收藏（点此取消）' : '未收藏（点此收藏）'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saveAndPop,
              child: const Text('保存并返回列表'),
            ),
          ],
        ),
      ),
    );
  }
}