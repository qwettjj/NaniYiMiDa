/**
 * Service 层统一导出
 * 方便其他模块统一引入
 */

// HTTP 工具类
export { HttpUtil, ResultVO } from './HttpUtil';

// 用户服务
export { UserService } from './UserService';

// 食谱服务
export {
  RecipeService,
  PageResponse,
  RecipeIngredientVO,
  PageParams,
  RecipeSearchParams
} from './RecipeService';

// 收藏服务
export { FavoriteService } from './FavoriteService';

// 浏览历史服务
export { HistoryService } from './HistoryService';

// 图片上传服务
export { ImageService, ImageFileInfo } from './ImageService';

// 工具服务
export { ToolsService } from './ToolsService';
