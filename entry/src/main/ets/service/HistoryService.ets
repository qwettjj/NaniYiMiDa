/**
 * 浏览历史服务类
 * 对应后端 HistoryController: /api/histories
 */
import { HttpUtil, ResultVO } from './HttpUtil';
import { HistoryVO } from '../model/HistoryModel';
import { PageResponse } from './RecipeService';

/** API 基础路径 */
const BASE_PATH: string = '/api/histories';

/**
 * 浏览历史服务
 * 封装所有浏览历史相关的 API 请求
 */
export class HistoryService {

  /**
   * 添加浏览历史
   * POST /api/histories/{recipeId}
   * @param recipeId 食谱 ID
   * @returns 操作结果
   */
  static async addHistory(recipeId: number): Promise<ResultVO<void>> {
    return await HttpUtil.post<void>(`${BASE_PATH}/${recipeId}`);
  }

  /**
   * 删除浏览历史
   * DELETE /api/histories/{historyId}
   * @param historyId 浏览历史 ID
   * @returns 操作结果
   */
  static async deleteHistory(historyId: number): Promise<ResultVO<void>> {
    return await HttpUtil.delete<void>(`${BASE_PATH}/${historyId}`);
  }

  /**
   * 获取当前用户浏览历史（分页）
   * GET /api/histories/getCurrentUserHistory
   * @param startTime 开始时间（可选，格式: yyyy-MM-dd HH:mm:ss）
   * @param page 页码（从0开始，默认0）
   * @param size 每页大小（默认10）
   * @returns 分页浏览历史列表
   */
  static async getCurrentUserHistory(
    startTime?: string,
    page: number = 0,
    size: number = 10
  ): Promise<ResultVO<PageResponse<HistoryVO>>> {
    let url = `${BASE_PATH}/getCurrentUserHistory?page=${page}&size=${size}`;
    if (startTime) {
      url += `&startTime=${encodeURIComponent(startTime)}`;
    }
    return await HttpUtil.get<PageResponse<HistoryVO>>(url);
  }
}
