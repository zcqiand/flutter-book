// 小改一处：只动 Row 的第二枚盒子——包一层 Expanded，摘掉写死的 width。
// 正文 8.4 归因：布局意图是第一枚定宽 200、第二枚吃掉剩余的 40；
// Expanded 不再自报 200，而是把 Row 分到的剩余宽度接过来再转发给子盒，
// 子盒从「我要 200」改成「约束给多少收多少」，400 对 240 的账就此对平
Row(
  children: <Widget>[
    Container(width: 200, color: Colors.orangeAccent),
    Expanded(
      child: Container(color: Colors.deepOrange),
    ),
  ],
)

// 边界一句：这条修法只对「吃掉剩余空间」的意图成立；
// 若意图是内容多到看不完、想滚着看，正路是换成滚动视图（如 ListView），
// 不是硬塞 Expanded——那只是把「看不见」改成「压扁看」（正文 8.4）