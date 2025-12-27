/**
 * 食谱服务类
 * 对应后端 RecipeController: /api/recipes
 */
import { HttpUtil, ResultVO } from './HttpUtil';
import { RecipeVO, RecipeStepVO, IngredientEnum } from '../model/RecipeModel';

/** API 基础路径 */
const BASE_PATH: string = '/api/recipes';

/**
 * 分页响应结构
 * 对应后端 Spring Data Page<T>
 */
export interface PageResponse<T> {
  /** 数据内容 */
  content: T[];
  /** 总元素数 */
  totalElements: number;
  /** 总页数 */
  totalPages: number;
  /** 每页大小 */
  size: number;
  /** 当前页码（从0开始） */
  number: number;
  /** 是否为第一页 */
  first: boolean;
  /** 是否为最后一页 */
  last: boolean;
  /** 是否为空 */
  empty: boolean;
}

/**
 * 食材配料 VO
 */
export interface RecipeIngredientVO {
  /** 配料 ID */
  ingredientId: number | null;
  /** 食材枚举 */
  ingredient: string | null;
  /** 配料描述 */
  description: string | null;
}

/**
 * 分页参数
 */
export interface PageParams {
  /** 页码（从0开始） */
  page?: number;
  /** 每页大小 */
  size?: number;
  /** 排序字段 */
  sort?: string;
}

/**
 * 食谱搜索参数
 */
export interface RecipeSearchParams extends PageParams {
  /** 关键词 */
  keyword?: string;
  /** 开始日期（格式: yyyy-MM-dd HH:mm:ss） */
  startDate?: string;
  /** 食材标签 */
  tag?: IngredientEnum;
}

/**
 * 食谱服务
 * 封装所有食谱相关的 API 请求
 */
export class RecipeService {

  /**
   * 获取最近食谱列表（首页数据）
   * GET /api/recipes/getRecentRecipe
   * @param startDate 开始日期（可选，格式: yyyy-MM-dd HH:mm:ss）
   * @param page 页码（从0开始，默认0）
   * @param size 每页大小（默认10）
   * @returns 分页食谱列表
   */
  static async getRecentRecipes(
    startDate?: string,
    page: number = 0,
    size: number = 10
  ): Promise<ResultVO<PageResponse<RecipeVO>>> {
    let url = `${BASE_PATH}/getRecentRecipe?page=${page}&size=${size}`;
    if (startDate) {
      url += `&startDate=${encodeURIComponent(startDate)}`;
    }
    return await HttpUtil.get<PageResponse<RecipeVO>>(url);
  }

  /**
   * 搜索食谱
   * GET /api/recipes/search
   * @param searchParams 搜索参数
   * @returns 分页食谱列表
   */
  static async searchRecipes(searchParams: RecipeSearchParams): Promise<ResultVO<PageResponse<RecipeVO>>> {
    const pageVal: number = searchParams.page ?? 0;
    const sizeVal: number = searchParams.size ?? 10;
    let url = `${BASE_PATH}/search?page=${pageVal}&size=${sizeVal}`;
    if (searchParams.keyword) {
      url += `&keyword=${encodeURIComponent(searchParams.keyword)}`;
    }
    if (searchParams.startDate) {
      url += `&startDate=${encodeURIComponent(searchParams.startDate)}`;
    }
    if (searchParams.tag) {
      url += `&tag=${searchParams.tag}`;
    }
    return await HttpUtil.get<PageResponse<RecipeVO>>(url);
  }

  /**
   * 获取用户的食谱列表
   * GET /api/recipes/recipe/{userId}
   * @param userId 用户 ID
   * @param startDate 开始日期（可选）
   * @param page 页码
   * @param size 每页大小
   * @returns 分页食谱列表
   */
  static async getUserRecipes(
    userId: number,
    startDate?: string,
    page: number = 0,
    size: number = 10
  ): Promise<ResultVO<PageResponse<RecipeVO>>> {
    let url = `${BASE_PATH}/recipe/${userId}?page=${page}&size=${size}`;
    if (startDate) {
      url += `&startDate=${encodeURIComponent(startDate)}`;
    }
    return await HttpUtil.get<PageResponse<RecipeVO>>(url);
  }

  /**
   * 获取当前用户的草稿食谱
   * GET /api/recipes/getCurrentUserDraft
   * @returns 草稿食谱列表
   */
  static async getCurrentUserDrafts(): Promise<ResultVO<RecipeVO[]>> {
    return await HttpUtil.get<RecipeVO[]>(`${BASE_PATH}/getCurrentUserDraft`);
  }

  /**
   * 创建食谱草稿
   * POST /api/recipes/create?title=xxx
   * @param title 食谱标题
   * @returns 创建的食谱 ID
   */
  static async createRecipeDraft(title: string): Promise<ResultVO<number>> {
    const url = `${BASE_PATH}/create?title=${encodeURIComponent(title)}`;
    return await HttpUtil.post<number>(url);
  }

  /**
   * 修改食谱标题
   * PUT /api/recipes/{recipeId}/title?title=xxx
   * @param recipeId 食谱 ID
   * @param title 新标题
   * @returns 操作结果
   */
  static async modifyRecipeTitle(recipeId: number, title: string): Promise<ResultVO<void>> {
    return await HttpUtil.put<void>(`${BASE_PATH}/${recipeId}/title?title=${encodeURIComponent(title)}`);
  }

  /**
   * 修改食谱描述
   * PUT /api/recipes/{recipeId}/description?description=xxx
   * @param recipeId 食谱 ID
   * @param description 新描述
   * @returns 操作结果
   */
  static async modifyRecipeDescription(recipeId: number, description: string): Promise<ResultVO<void>> {
    return await HttpUtil.put<void>(`${BASE_PATH}/${recipeId}/description?description=${encodeURIComponent(description)}`);
  }

  /**
   * 发布食谱
   * POST /api/recipes/{recipeId}/publish
   * @param recipeId 食谱 ID
   * @returns 操作结果
   */
  static async publishRecipe(recipeId: number): Promise<ResultVO<void>> {
    return await HttpUtil.post<void>(`${BASE_PATH}/${recipeId}/publish`);
  }

  /**
   * 隐藏食谱
   * POST /api/recipes/{recipeId}/hide
   * @param recipeId 食谱 ID
   * @returns 操作结果
   */
  static async hideRecipe(recipeId: number): Promise<ResultVO<void>> {
    return await HttpUtil.post<void>(`${BASE_PATH}/${recipeId}/hide`);
  }

  /**
   * 删除食谱
   * DELETE /api/recipes/{recipeId}
   * @param recipeId 食谱 ID
   * @returns 操作结果
   */
  static async deleteRecipe(recipeId: number): Promise<ResultVO<void>> {
    return await HttpUtil.delete<void>(`${BASE_PATH}/${recipeId}`);
  }

  /**
   * 添加食谱步骤
   * POST /api/recipes/{recipeId}/steps
   * @param recipeId 食谱 ID
   * @param stepVO 步骤信息
   * @param index 插入位置（可选）
   * @returns 更新后的食谱
   */
  static async addRecipeStep(
    recipeId: number,
    stepVO: RecipeStepVO,
    index?: number
  ): Promise<ResultVO<RecipeVO>> {
    let url = `${BASE_PATH}/${recipeId}/steps`;
    if (index !== undefined) {
      url += `?index=${index}`;
    }
    return await HttpUtil.post<RecipeVO>(url, stepVO);
  }

  /**
   * 修改食谱步骤
   * PUT /api/recipes/{recipeId}/steps/{stepId}
   * @param recipeId 食谱 ID
   * @param stepId 步骤 ID
   * @param stepVO 步骤信息
   * @returns 更新后的食谱
   */
  static async modifyRecipeStep(
    recipeId: number,
    stepId: number,
    stepVO: RecipeStepVO
  ): Promise<ResultVO<RecipeVO>> {
    return await HttpUtil.put<RecipeVO>(
      `${BASE_PATH}/${recipeId}/steps/${stepId}`,
      stepVO
    );
  }

  /**
   * 删除食谱步骤
   * DELETE /api/recipes/{recipeId}/steps/{stepId}
   * @param recipeId 食谱 ID
   * @param stepId 步骤 ID
   * @returns 更新后的食谱
   */
  static async deleteRecipeStep(recipeId: number, stepId: number): Promise<ResultVO<RecipeVO>> {
    return await HttpUtil.delete<RecipeVO>(`${BASE_PATH}/${recipeId}/steps/${stepId}`);
  }

  /**
   * 交换食谱步骤顺序
   * POST /api/recipes/{recipeId}/steps/swap?firstIndex=x&secondIndex=y
   * @param recipeId 食谱 ID
   * @param firstIndex 第一个步骤索引
   * @param secondIndex 第二个步骤索引
   * @returns 更新后的食谱
   */
  static async swapRecipeSteps(
    recipeId: number,
    firstIndex: number,
    secondIndex: number
  ): Promise<ResultVO<RecipeVO>> {
    const url = `${BASE_PATH}/${recipeId}/steps/swap?firstIndex=${firstIndex}&secondIndex=${secondIndex}`;
    return await HttpUtil.post<RecipeVO>(url);
  }

  /**
   * 修改食谱配料描述
   * PUT /api/recipes/{recipeId}/ingredient/description
   * @param recipeId 食谱 ID
   * @param description 配料描述
   * @returns 更新后的配料信息
   */
  static async modifyRecipeIngredient(
    recipeId: number,
    description: string
  ): Promise<ResultVO<RecipeIngredientVO>> {
    // 后端 @RequestBody String 期望纯字符串，直接发送 JSON 字符串
    return await HttpUtil.putRaw<RecipeIngredientVO>(
      `${BASE_PATH}/${recipeId}/ingredient/description`,
      JSON.stringify(description)
    );
  }

  /**
   * 设置食谱食材标签
   * PUT /api/recipes/{recipeId}/ingredient/tag?ingredient=xxx
   * @param recipeId 食谱 ID
   * @param ingredient 食材枚举
   * @returns 更新后的配料信息
   */
  static async setRecipeIngredientTag(
    recipeId: number,
    ingredient: IngredientEnum
  ): Promise<ResultVO<RecipeIngredientVO>> {
    return await HttpUtil.put<RecipeIngredientVO>(
      `${BASE_PATH}/${recipeId}/ingredient/tag?ingredient=${ingredient}`
    );
  }

  /**
   * 根据 ID 获取食谱详情
   * GET /api/recipes/{recipeId}
   * @param recipeId 食谱 ID
   * @returns 食谱详情
   */
  static async getRecipeById(recipeId: number): Promise<ResultVO<RecipeVO>> {
    return await HttpUtil.get<RecipeVO>(`${BASE_PATH}/${recipeId}`);
  }
}
