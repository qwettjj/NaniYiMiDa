# 前后端一致性检查报告

> 生成日期：2026-01-18  
> 检查范围：HarmonyOS 前端 (ArkTS) ↔ Spring Boot 后端 (Java)

---

## 🔴 [P0 - 阻断级/崩溃风险]

### 1. 类型不匹配：Date vs String

**问题描述**:  
- **后端**: `UserVO.createTime` 和 `RecipeVO.createTime` 类型为 `java.util.Date`
- **前端**: `UserModel.createTime` 和 `RecipeModel.createTime` 声明为 `string | null`

**原因分析**:  
在 HarmonyOS 的 HTTP 请求中，后端返回的 `Date` 对象会被 JSON 序列化为 ISO 8601 字符串（如 `"2025-01-18T12:30:00.000+08:00"`）。前端需要正确解析这个字符串才能进行时间运算和格式化显示。如果前端没有统一处理，可能导致：
1. 时间显示错乱（直接展示 ISO 字符串）
2. 时间比较逻辑失效（字符串比较与数值比较不同）
3. 涉及时区转换时出现 8 小时偏差

**建议修复**:  
在 `HttpUtil` 或各个 Service 层增加时间解析拦截器，将字符串统一转换为 `Date` 对象或时间戳。

**影响文件**:
- `entry/src/main/ets/model/UserModel.ets`
- `entry/src/main/ets/model/RecipeModel.ets`
- `entry/src/main/ets/service/HttpUtil.ets`

---

### 2. 类型不匹配：Long vs number

**问题描述**:  
- **后端**: `UserVO.followerCount`、`followingCount`、`favouriteCount` 类型为 `Long`
- **前端**: 对应字段声明为 `number | null`，但 JavaScript 的 `number` 类型最大安全整数为 `2^53 - 1`

**原因分析**:  
虽然当前业务场景下粉丝数不太可能超过 JavaScript 的安全整数范围，但 Java 的 `Long` (64位) 在传输到前端时，如果后端未做特殊处理，可能导致精度丢失。例如 `9007199254740993` 会被 JSON 解析为 `9007199254740992`。

**建议修复**:  
后端在序列化时将 `Long` 类型字段统一转为字符串（使用 `@JsonSerialize` 注解），前端接收后再按需转换。

**影响文件**:
- `Nani_Backend/src/main/java/com/java/NaniYiMiDa/vo/UserVO.java`
- `entry/src/main/ets/model/UserModel.ets`

---

### 3. 缺少网络异常生命周期处理

**问题描述**:  
`HomePage.loadRecipes()` 中有 `try-catch`，但当应用进入后台或网络切换时，正在执行的 HTTP 请求可能导致内存泄漏或状态不一致。

**原因分析**:  
HarmonyOS 应用在后台时，未取消的网络请求依然会回调 `@State` 变量，导致：
1. 已销毁组件的状态被意外修改
2. 无效的 Toast 提示弹出
3. 内存引用无法释放

**建议修复**:  
在 `aboutToDisappear()` 中取消所有正在进行的请求（`HttpUtil` 需要维护请求队列）。

**影响文件**:
- `entry/src/main/ets/pages/HomePage.ets`
- `entry/src/main/ets/service/HttpUtil.ets`

---

## 🟡 [P1 - 业务逻辑错误]

### 4. 时间格式不匹配：后端要求 `yyyy-MM-dd HH:mm:ss`

**问题描述**:  
后端 `RecipeController.searchRecipes()` 使用 `@DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")` 注解，要求前端传递精确的格式，但前端 `RecipeService.getRecentRecipes()` 直接使用 `startDate` 参数，未进行格式验证。

**原因分析**:  
如果前端传递的时间格式不符（如 `2025-01-18` 或时间戳），后端会抛出 `400 Bad Request`，导致首页无法加载。

**建议修复**:  
在 `RecipeService` 中增加时间格式化工具函数，确保所有日期参数都符合后端规范：
```typescript
function formatDateTime(date: Date): string {
  // 返回 "yyyy-MM-dd HH:mm:ss" 格式
}
```

**影响文件**:
- `entry/src/main/ets/service/RecipeService.ets`
- `Nani_Backend/src/main/java/com/java/NaniYiMiDa/controller/RecipeController.java`

---

### 5. 列表渲染缺少唯一 key

**问题描述**:  
`HomePage.ets` 中的 `ForEach` 渲染食谱列表时，未显式提供 `keyGenerator`：
```arkts
ForEach(this.recipes, (recipe: RecipeVO) => {
  // ...
})
```

**原因分析**:  
ArkUI 会使用数组索引作为默认 key，当数据刷新/删除时，可能导致：
1. 组件状态错乱（如点赞状态绑定到错误的食谱）
2. 不必要的组件重建，影响性能

**建议修复**:  
```arkts
ForEach(this.recipes, 
  (recipe: RecipeVO) => { /* ... */ },
  (recipe: RecipeVO) => recipe.recipeId?.toString() || ''
)
```

**影响文件**:
- `entry/src/main/ets/pages/HomePage.ets`
- 其他包含 `ForEach` 的页面组件

---

### 6. 枚举不完整：IngredientEnum 前端缺失大量后端定义

**问题描述**:  
后端 `IngredientEnum.java` 定义了 100+ 种食材，但前端 `RecipeModel.ets` 仅定义了约 20 种。

**原因分析**:  
当后端返回未定义的枚举值时，前端会显示 `undefined` 或空白，影响用户体验。

**建议修复**:  
1. 同步后端枚举定义到前端
2. 或在前端增加兜底处理（显示 `OTHER` 或原始字符串）

**影响文件**:
- `entry/src/main/ets/model/RecipeModel.ets`
- `Nani_Backend/src/main/java/com/java/NaniYiMiDa/enumx/IngredientEnum.java`

---

### 7. ScanPage 使用 Mock 数据，未与后端对齐

**问题描述**:  
`ScanPage.ets` 引入了 `MOCK_PRODUCTS` 和 `ProductModel`，但后端尚未提供 `/api/products/info` 接口。

**原因分析**:  
当前是预留状态，但代码中已经调用 `ToolsService` 相关方法，如果后端未及时实现，会导致扫码后报错。

**建议修复**:  
1. 在 `ScanPage` 中增加注释说明这是临时 Mock 逻辑
2. 在后端接口就绪时及时切换到真实 API
3. 或在前端增加开关控制 Mock 模式

**影响文件**:
- `entry/src/main/ets/pages/ScanPage.ets`
- `entry/src/main/ets/model/ProductModel.ets`
- `entry/src/main/ets/service/ToolsService.ets`
- `Nani_Backend/src/main/java/com/java/NaniYiMiDa/controller/ToolsController.java` (待实现)

---

## 🟢 [P2 - 体验与规范]

### 8. 缺少 Loading 空状态优化

**问题描述**:  
`HomePage.ets` 中 `isLoading` 仅用于禁止重复请求，但未在 UI 层展示骨架屏或 Loading 动画。

**原因分析**:  
首次进入首页时，列表为空且无提示，用户可能误以为应用崩溃。

**建议修复**:  
在 `List` 组件上方增加条件渲染：
```arkts
if (this.isLoading && this.recipes.length === 0) {
  LoadingComponent()
} else if (!this.isLoading && this.recipes.length === 0) {
  EmptyComponent()
}
```

**影响文件**:
- `entry/src/main/ets/pages/HomePage.ets`
- 创建 `entry/src/main/ets/common/LoadingManager.ets` (已存在但未使用)

---

### 9. 网络超时未配置

**问题描述**:  
`HttpUtil.request()` 方法中 `connectTimeout` 和 `readTimeout` 使用默认值（60秒），未根据业务场景调整。

**原因分析**:  
在弱网环境下，用户需要等待 60 秒才能看到"网络异常"提示，体验极差。

**建议修复**:  
将超时时间调整为 10 秒（`connectTimeout`）和 20 秒（`readTimeout`）：
```arkts
const config: RequestConfig = {
  connectTimeout: 10000,  // 10秒
  readTimeout: 20000,     // 20秒
  // ...
}
```

**影响文件**:
- `entry/src/main/ets/service/HttpUtil.ets`

---

### 10. Token 过期未处理

**问题描述**:  
后端使用 JWT Token，但前端 `HttpUtil` 在收到 `401 Unauthorized` 响应时，未自动跳转到登录页。

**原因分析**:  
Token 过期后，用户会在各个页面看到"请求失败"的 Toast，需手动返回登录页，体验不连贯。

**建议修复**:  
在 `HttpUtil.request()` 的响应拦截中，检测 HTTP 状态码 401，自动清除 Token 并跳转：
```arkts
if (response.responseCode === 401) {
  await HttpUtil.clearToken();
  router.replaceUrl({ url: 'pages/LoginPage' });
}
```

**影响文件**:
- `entry/src/main/ets/service/HttpUtil.ets`

---

### 11. ScanPage 权限引导不完善

**问题描述**:  
`ScanPage` 在用户拒绝相机权限后，仅显示"需要相机权限"文字，未提供跳转到系统设置的引导。

**原因分析**:  
用户一旦拒绝权限，只能手动进入"设置 > 应用管理"开启，流程繁琐。

**建议修复**:  
增加"去设置"按钮，调用系统 API 跳转到应用权限页面：
```arkts
Button('前往设置')
  .onClick(() => {
    // 跳转到系统设置
    bundleManager.getBundleInfoForSelf()
      .then(info => common.openSettings())
  })
```

**影响文件**:
- `entry/src/main/ets/pages/ScanPage.ets`

---

### 12. ArkTS 语法不规范：可选链滥用

**问题描述**:  
代码中大量使用 `recipe.recipeId?.toString()` 等可选链操作符，但部分场景下 `recipeId` 理论上不可能为 `null`（如已发布的食谱）。

**原因分析**:  
过度使用可选链会掩盖真实的数据异常（如后端返回了空 ID），增加调试难度。

**建议修复**:  
在明确非空的场景使用断言 `recipe.recipeId!`，并在必要时增加运行时检查：
```arkts
if (!recipe.recipeId) {
  console.error('Invalid recipe: missing ID');
  return;
}
const id = recipe.recipeId.toString();
```

**影响文件**:
- 所有使用可选链的 `.ets` 文件

---

## 优先级总结

| 优先级 | 问题数量 | 修复建议时间 |
| ------ | -------- | ------------ |
| 🔴 P0   | 3        | 立即修复     |
| 🟡 P1   | 4        | 1-2 天内修复 |
| 🟢 P2   | 5        | 迭代优化     |

**总计**: 12 个问题

---

## 修复检查清单

### Phase 1: P0 级问题（阻断修复）
- [ ] 统一时间类型处理（Date/String）
- [ ] 处理 Long 类型精度问题
- [ ] 实现网络请求生命周期管理

### Phase 2: P1 级问题（业务正确性）
- [ ] 规范时间格式传递
- [ ] 为所有 ForEach 添加 keyGenerator
- [ ] 同步 IngredientEnum 枚举
- [ ] 标注 ScanPage Mock 状态

### Phase 3: P2 级问题（体验优化）
- [ ] 实现 Loading/Empty 状态
- [ ] 调整网络超时配置
- [ ] 实现 Token 过期自动跳转
- [ ] 优化 ScanPage 权限引导
- [ ] 规范可选链使用
