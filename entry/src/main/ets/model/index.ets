/**
 * Model 层统一导出
 * 方便其他模块统一引入
 */

// 通用模型
export { ResultVO, ErrorCode, PageRequest, PageResponse } from './CommonModel';

// 用户模型
export { UserVO, Role, LoginRequest, RegisterRequest, UserUpdateRequest, LoginResponse, createEmptyUserVO } from './UserModel';

// 食谱模型
export {
  RecipeVO,
  RecipeStepVO,
  RecipeStatus,
  IngredientEnum,
  CreateRecipeRequest,
  CreateRecipeStepRequest,
  UpdateRecipeRequest,
  RecipeSearchRequest,
  createEmptyRecipeVO,
  createEmptyRecipeStepVO,
  getIngredientDisplayName,
  getRecipeStatusDisplayName
} from './RecipeModel';

// 历史记录模型
export {
  HistoryVO,
  HistoryWithRecipeVO,
  CreateHistoryRequest,
  HistoryQueryRequest,
  createEmptyHistoryVO
} from './HistoryModel';

// 收藏模型
export {
  FavoriteVO,
  FavoriteWithRecipeVO,
  AddFavoriteRequest,
  FavoriteQueryRequest,
  createEmptyFavoriteVO
} from './FavoriteModel';
