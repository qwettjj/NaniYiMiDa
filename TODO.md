# NaniYiMiDa 项目开发任务清单

> **生成时间**: 2026-01-18  
> **项目类型**: HarmonyOS (Stage 模型) + Spring Boot 全栈应用  
> **技术规范**: 严格遵循 ArkTS 类型安全、状态管理、并发处理规范

---

## 📊 项目审计概览

### 后端接口覆盖情况
- ✅ **UserController** (`/api/users`): 8 个接口（注册、登录、用户信息、关注管理、用户搜索）
- ✅ **RecipeController** (`/api/recipes`): 14 个接口（食谱 CRUD、步骤管理、食材标签、搜索、分页查询）
- ✅ **FavoriteController** (`/api/favorites`): 3 个接口（收藏增删查）
- ✅ **HistoryController** (`/api/histories`): 3 个接口（浏览历史增删查）
- ✅ **ToolsController** (`/api`): 2 个接口（图片上传、二维码解析）
- ✅ **ProductController** (`/api/products`): 1 个接口（商品信息查询）

### 前端页面实现状态

| 页面名称              | 对应后端接口                                                                                             | 实现状态               | 说明                                                                                    |
| --------------------- | -------------------------------------------------------------------------------------------------------- | ---------------------- | --------------------------------------------------------------------------------------- |
| **LoginPage**         | `POST /api/users/login`                                                                                  | ✅ **已完成**           | 已完成登录逻辑，使用 `UserService.login()`，包含输入校验、Token 保存                    |
| **RegisterPage**      | `POST /api/users/register`                                                                               | ✅ **已完成**           | 已完成注册逻辑，使用 `UserService.register()`，包含完整输入校验                         |
| **HomePage**          | `GET /api/recipes/getRecentRecipe`                                                                       | ✅ **已完成**           | 已完成首页食谱列表加载，使用 `RecipeService.getRecentRecipes()`，支持分页和下拉刷新     |
| **ProfilePage**       | `GET /api/users/me`                                                                                      | ✅ **已完成**           | 已完成当前用户信息展示，使用 `UserService.getCurrentUser()`                             |
| **ProfileEditPage**   | `PUT /api/users/me`                                                                                      | ✅ **已完成**           | 编辑昵称、签名、生日、过敏原，修改密码功能完整                                          |
| **FollowingPage**     | `GET /api/users/me/followings`                                                                           | ✅ **已完成**           | 已完成关注列表展示，使用 `UserService.getMyFollowings()`                                |
| **UserDetailPage**    | `GET /api/recipes/recipe/{userId}`, 缺少 `GET /api/users/{userId}`                                       | ⚠️ **UI已完成数据未通** | 后端缺少根据 ID 获取用户信息的接口                                                      |
| **FavoritesPage**     | `GET /api/favorites/getCurrentUserFavourites`                                                            | ✅ **已完成**           | 已完成收藏列表展示，使用 `FavoriteService.getCurrentUserFavorites()` 并并行获取食谱详情 |
| **RecipeDetailPage**  | `GET /api/recipes/{recipeId}`, `POST /api/histories/{recipeId}`, `POST/DELETE /api/favorites/{recipeId}` | ✅ **已完成**           | 已完成食谱详情展示、收藏操作、浏览历史自动记录                                          |
| **SearchPage**        | `GET /api/recipes/search`                                                                                | ✅ **已完成**           | 关键词搜索、防抖处理、分页加载                                                          |
| **RecipePublishPage** | `POST /api/recipes/create`<br>`PUT /description`<br>`POST /steps`<br>`POST /publish`                     | ✅ **已完成**           | 已完成草稿创建、步骤添加、发布流程，包含错误处理                                        |
| **DraftPage**         | `GET /api/recipes/getCurrentUserDraft`, `DELETE /{recipeId}`                                             | ⚠️ **UI已完成数据未通** | 草稿列表展示正常，但编辑功能待实现（需创建 RecipeEditPage）                             |
| **HistoryPage**       | `GET /api/histories/getCurrentUserHistory`, `DELETE /{historyId}`                                        | ✅ **已完成**           | 分页加载历史、删除历史、跳转详情                                                        |
| **ScanPage**          | `POST /api/qr/decode`                                                                                    | ⚠️ **UI已完成数据未通** | Scan Kit 集成正常，但后端接口参数格式不匹配                                             |
| **Index** (主框架)    | -                                                                                                        | ✅ **已完成**           | 已完成 Tab 导航框架，集成首页、扫描入口、个人中心                                       |

### Service 层接口覆盖情况

| Service 文件        | 后端 Controller    | 接口覆盖率       | 缺失接口                                 |
| ------------------- | ------------------ | ---------------- | ---------------------------------------- |
| UserService.ets     | UserController     | **87.5%** (7/8)  | ❌ `getUserById(userId)` - 通过ID获取用户 |
| RecipeService.ets   | RecipeController   | **100%** (14/14) | ✅ 全部覆盖                               |
| FavoriteService.ets | FavoriteController | **100%** (3/3)   | ✅ 全部覆盖                               |
| HistoryService.ets  | HistoryController  | **100%** (3/3)   | ✅ 全部覆盖                               |
| ToolsService.ets    | ToolsController    | **50%** (1/2)    | ❌ 接口参数格式需调整                     |
| ImageService.ets    | ToolsController    | **待验证**       | 需检查上传逻辑实现                       |

---

## 🚨 缺失功能清单（按优先级排序）

### **P0 - 核心功能缺失（影响主流程）**

#### 1. 后端缺少根据用户 ID 获取用户信息接口 ❌ **后端缺失**
**影响**: UserDetailPage 无法获取其他用户的详细信息

**后端需新增接口**:
```java
// UserController.java
@GetMapping("/{userId}")
public ResultVO<UserVO> getUserById(@PathVariable Long userId) {
    return ResultVO.buildSuccess(userService.getUserById(userId));
}
```

**前端需新增方法**:
**文件**: `entry/src/main/ets/service/UserService.ets`
```typescript
static async getUserById(userId: number): Promise<ResultVO<UserVO>> {
    return await HttpUtil.get<UserVO>(`${BASE_PATH}/${userId}`);
}
```

**涉及装饰器**: 无（Service 层）

---

### **P1 - 重要功能待完善**

#### 1. ToolsService 二维码解析参数格式不匹配
**影响**: ScanPage 无法正确调用后端二维码解析接口

**文件**: `entry/src/main/ets/service/ToolsService.ets`

**问题分析**: 
- 后端接口接收 `MultipartFile file` 或 `String base64`
- 前端当前发送 JSON body `{ qrCode: string }`

**核心逻辑修复**: 需使用 FormData 或 base64 参数格式

**涉及装饰器**: 无（Service 层）

---

#### 2. 草稿编辑页面 RecipeEditPage 未实现
**影响**: DraftPage 编辑按钮无法使用

**文件**: `entry/src/main/ets/pages/RecipeEditPage.ets` ❌ **待创建**

**核心逻辑**:
- 加载指定 recipeId 的草稿数据
- 编辑标题、描述、食材
- 管理步骤（增删改、排序）
- 保存修改 / 发布草稿

**涉及装饰器**: `@Entry`, `@Component`, `@State`, `@Builder`

---

#### 3. 图片上传功能未集成到发布/编辑流程
**影响**: 食谱封面、步骤图片无法上传

**相关文件**:
- `entry/src/main/ets/service/ImageService.ets` - 需验证上传逻辑
- `entry/src/main/ets/pages/RecipePublishPage.ets` - 需集成图片选择器

**核心逻辑**:
- 使用 `@ohos.file.picker` 选择图片
- 调用 `POST /api/images` 上传至 OSS
- 获取返回的 URL 绑定到食谱数据

**涉及装饰器**: `@State` (存储图片URL列表)

---

### **P2 - 体验优化项**

#### 1. 粉丝列表页面未实现
**影响**: ProfilePage 粉丝数点击无响应

**说明**: 后端当前无粉丝列表接口，需先评估需求优先级

---

#### 2. 食谱标签筛选功能未实现
**影响**: SearchPage 仅支持关键词搜索

**文件**: `entry/src/main/ets/pages/SearchPage.ets`

**核心逻辑**: 
- 添加 IngredientEnum 标签选择器
- 传递 `tag` 参数到 `RecipeService.searchRecipes()`

**涉及装饰器**: `@State` (选中的标签)

---

#### 3. 下拉刷新动画优化
**影响**: 各列表页刷新体验待提升

**相关文件**: HomePage, SearchPage, HistoryPage, FavoritesPage

**涉及组件**: `Refresh` 组件配合 `@State isRefreshing`

---

## 🔧 技术规范强制要点

### 1. 类型安全
- ❌ **禁止**: `let data: any = ...`
- ✅ **正确**: `let data: UserVO = ...` 或使用 `interface`/`class` 定义

### 2. 状态管理
- 所有需要触发 UI 更新的变量必须使用 `@State`
- 父子组件传递数据使用 `@Prop` (单向) 或 `@Link` (双向)
- 跨层级传递使用 `@Provide/@Consume`

### 3. 并发处理
- 网络请求必须使用 `async/await`
- 多个独立请求使用 `Promise.all` 并行
- 大数据处理使用 `taskpool` 或 `worker`

### 4. UI 范式
- 禁止直接操作 DOM（HarmonyOS 无 DOM）
- 优先使用内置组件：`Row`, `Column`, `List`, `Flex`, `Grid`
- 自定义组件必须使用 `@Builder` 或 `@Component`

---

## 📝 后续开发建议

1. **优先解决 P0 任务** - 后端需新增 `GET /api/users/{userId}` 接口
2. **修复 ToolsService** - 二维码解析参数格式需与后端对齐
3. **创建 RecipeEditPage** - 完善草稿编辑功能
4. **集成图片上传** - 在发布流程中添加图片选择和上传
5. **体验优化** - 标签筛选、粉丝列表、下拉刷新动画

---

**生成工具**: GitHub Copilot Workspace Audit Agent  
**审计范围**: 后端 6 个 Controller + 前端 15 个页面 + 6 个 Service  
**最后更新**: 2026-01-18

---

## ✅ 已完成功能 (归档)

### 核心功能已实现
- ✅ **用户认证**: 登录/注册完整流程
- ✅ **个人信息**: 查看/编辑用户资料、修改密码
- ✅ **食谱浏览**: 首页列表、详情页、分页加载
- ✅ **食谱创作**: 草稿创建、步骤管理、发布流程
- ✅ **收藏功能**: 添加/取消收藏、收藏列表
- ✅ **浏览历史**: 自动记录、历史列表、删除历史
- ✅ **搜索功能**: 关键词搜索、防抖处理
- ✅ **关注系统**: 关注/取关用户、关注列表
- ✅ **扫码功能**: Scan Kit 集成、商品识别（本地数据）

### Service 层接口覆盖
- ✅ UserService: 7/8 接口
- ✅ RecipeService: 14/14 接口
- ✅ FavoriteService: 3/3 接口
- ✅ HistoryService: 3/3 接口
- ⚠️ ToolsService: 1/2 接口（参数格式待修复）