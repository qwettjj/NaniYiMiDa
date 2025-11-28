/**
 * 浏览历史相关模型
 * 对应后端 History.java 和 HistoryVO.java
 */

/**
 * 浏览历史接口
 * 对应后端 HistoryVO
 */
export interface HistoryVO {
  /** 历史记录ID */
  historyId: number | null;
  /** 用户ID */
  userId: number | null;
  /** 食谱ID */
  recipeId: number | null;
  /** 浏览时间 (时间戳或ISO字符串) */
  createTime: string | null;
}

/**
 * 带食谱详情的历史记录 (用于列表展示)
 */
export interface HistoryWithRecipeVO {
  /** 历史记录ID */
  historyId: number | null;
  /** 用户ID */
  userId: number | null;
  /** 食谱ID */
  recipeId: number | null;
  /** 浏览时间 */
  createTime: string | null;
  /** 食谱标题 */
  recipeTitle: string | null;
  /** 食谱封面图 */
  recipeImageUrl: string | null;
}

/**
 * 创建历史记录请求
 */
export interface CreateHistoryRequest {
  /** 食谱ID */
  recipeId: number;
}

/**
 * 历史记录查询请求
 */
export interface HistoryQueryRequest {
  /** 开始时间 (格式: yyyy-MM-dd HH:mm:ss) */
  startTime?: string;
  /** 结束时间 (格式: yyyy-MM-dd HH:mm:ss) */
  endTime?: string;
  /** 页码 */
  page?: number;
  /** 每页数量 */
  size?: number;
}

/**
 * 创建空的 HistoryVO 对象
 */
export function createEmptyHistoryVO(): HistoryVO {
  return {
    historyId: null,
    userId: null,
    recipeId: null,
    createTime: null
  };
}
