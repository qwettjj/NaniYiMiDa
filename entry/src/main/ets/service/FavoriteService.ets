/**
 * 收藏服务类
 * 对应后端 FavoriteController: /api/favorites
 */
import { HttpUtil, ResultVO } from './HttpUtil';
import { FavoriteVO } from '../model/FavoriteModel';

/** API 基础路径 */
const BASE_PATH: string = '/api/favorites';

/**
 * 收藏服务
 * 封装所有收藏相关的 API 请求
 */
export class FavoriteService {

  /**
   * 添加收藏
   * POST /api/favorites/{recipeId}
   * @param recipeId 食谱 ID
   * @returns 收藏记录
   */
  static async addFavorite(recipeId: number): Promise<ResultVO<FavoriteVO>> {
    return await HttpUtil.post<FavoriteVO>(`${BASE_PATH}/${recipeId}`);
  }

  /**
   * 取消收藏
   * DELETE /api/favorites/{recipeId}
   * @param recipeId 食谱 ID
   * @returns 操作结果
   */
  static async removeFavorite(recipeId: number): Promise<ResultVO<void>> {
    return await HttpUtil.delete<void>(`${BASE_PATH}/${recipeId}`);
  }

  /**
   * 获取当前用户的收藏列表
   * GET /api/favorites/getCurrentUserFavourites
   * @returns 收藏列表
   */
  static async getCurrentUserFavorites(): Promise<ResultVO<FavoriteVO[]>> {
    return await HttpUtil.get<FavoriteVO[]>(`${BASE_PATH}/getCurrentUserFavourites`);
  }
}
