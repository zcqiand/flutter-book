// contract/main.tsp
// 教学切片：登录与受保护文章列表两个接口的契约定义。
// 家族实物原型：案例仓 shared 仓（TypeSpec 独立契约仓）；
// 编译器与发射配置以案例仓冻结版为准。
import "@typespec/http";

using TypeSpec.Http;

@service(#{title: "dio_lab contract"})

namespace Contract;

// 登录请求：两个字段的形状在这里定死，契约、生成物、后端实现三处同源
model LoginRequest {
  username: string;
  password: string;
}

// 登录响应：token 字段名是契约的一部分，改名走契约改动三步走（清单 22-3）
model LoginResponse {
  token: string;
}

// 受保护数据：字段名与第 14 章的翻车场景刻意呼应（title 的教训）
model Article {
  id: int32;
  title: string;
  authorName: string;
}

@route("auth")
interface Auth {
  @post
  @route("login")
  login(@body body: LoginRequest): LoginResponse;
}

@route("articles")
interface Articles {
  // 受保护接口：凭证由拦截器链统一挂头，契约只描述形状
  @get
  list(): Article[];
}
