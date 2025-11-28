/**
 * 收藏相关模型
 * 对应后端 Favorite.java 和 FavoriteVO.java
 */

/**
 * 收藏接口
 * 对应后端 FavoriteVO
 */
export interface FavoriteVO {
  /** 收藏ID */
  favouriteId: number | null;
  /** 食谱ID */
  recipeId: number | null;
  /** 用户ID */
  userId: number | null;
}

/**
 * 带食谱详情的收藏记录 (用于列表展示)
 */
export interface FavoriteWithRecipeVO {
  /** 收藏ID */
  favouriteId: number | null;
  /** 食谱ID */
  recipeId: number | null;
  /** 用户ID */
  userId: number | null;
  /** 食谱标题 */
  recipeTitle: string | null;
  /** 食谱封面图 */
  recipeImageUrl: string | null;
  /** 食谱收藏数 */
  recipeFavouriteNumber: number | null;
}

/**
 * 添加收藏请求
 */
export interface AddFavoriteRequest {
  /** 食谱ID */
  recipeId: number;
}

/**
 * 收藏查询请求
 */
export interface FavoriteQueryRequest {
  /** 页码 */
  page?: number;
  /** 每页数量 */
  size?: number;
}

/**
 * 创建空的 FavoriteVO 对象
 */
export function createEmptyFavoriteVO(): FavoriteVO {
  return {
    favouriteId: null,
    recipeId: null,
    userId: null
  };
}
