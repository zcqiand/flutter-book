<!DOCTYPE html>
<html>
<body>
  <span id="count">0</span>
  <button id="btn">点我加一</button>
  <script>
    let count = 0;
    // 命令式的核心负担：界面不会自己变，每次都必须先"找到"显示节点，
    // 再手动把新值写进去——状态和界面是两条线，靠开发者人肉保持同步。
    document.getElementById('btn').addEventListener('click', () => {
      count = count + 1;
      // 忘了这一行，数据变了但界面纹丝不动，这是命令式最典型的bug来源
      document.getElementById('count').textContent = String(count);
    });
  </script>
</body>
</html>