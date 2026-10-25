// 小改一处：Column 里给 ListView 外面包一层 Expanded。
// 正文 8.5：视口要先有一块有界的「地盘」才能在界内滚动——
// Expanded 把 Column 分下来的剩余高度交给 ListView，
// 「无限高」从此改写成「这块地有多高就滚多远」
body: Column(
  children: <Widget>[
    const Text('今日病例列表'),
    Expanded(
      child: ListView(
        children: const <Widget>[
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('病例一：Row 溢出 160 像素'),
          ),
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text('病例二：Expanded 压扁兄弟'),
          ),
          ListTile(
            leading: Icon(Icons.biotech),
            title: Text('病例三：视口拿到无界高度'),
          ),
        ],
      ),
    ),
  ],
)

// 边界一句：给 ListView 设 shrinkWrap: true 也能跟着内容收缩、暂渡难关，
// 但它放弃了惰性构建，一次性把全部子项 build 完（正文 8.5 与第 6 章）——
// 短列表可用，长列表禁用，数据一大就又卡又吃内存