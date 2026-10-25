// 式一：参数位三元——同一个参数在两个值之间二选一
Icon(
  // UI=f(state)：图标画成哪一副面孔，由 isOnline 这一个布尔说了算
  isOnline ? Icons.wifi : Icons.wifi_off,
  // 无障碍标签同样按状态二选一，参数位三元一行写完
  semanticLabel: isOnline ? '网络已连接' : '网络已断开',
)

// 式二：collection-if——按条件决定列表里「要不要这一项」
children: [
  const ListTile(title: Text('收货地址')),
  // 没填地址时，副标题这一项整个不进组件列表，
  // 而不是塞一个空字符串占位——要不要，让条件说了算
  if (_address.isNotEmpty) Text(_address),
]

// 式三：collection-if-else + spread——条件先挑出一组，spread 再摊平
children: [
  const ListTile(title: Text('设置')),
  // if-else 在两份名单里二选一，...[ ] 把选中的名单摊平成平级项；
  // 已登录给用户条目、未登录给入口条目，两组互斥，build 按状态二选一
  if (_loggedIn)
    ...[
      const ListTile(title: Text('个人主页')),
      const ListTile(title: Text('我的订单')),
    ]
  else
    ...[
      const ListTile(title: Text('登录')),
      const ListTile(title: Text('注册')),
    ],
]