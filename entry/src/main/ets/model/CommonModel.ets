/**
 * 通用响应模型
 * 对应后端 ResultVO<T>
 */

/**
 * API 统一响应结构
 */
export interface ResultVO<T> {
  /** 业务状态码 */
  code: number;
  /** 提示信息 */
  message: string | null;
  /** 响应数据 */
  data: T | null;
}

/**
 * 错误码枚举
 * 对应后端 ErrorCode
 */
export enum ErrorCode {
  SUCCESS = 0,
  BAD_REQUEST = 400,
  UNAUTHORIZED = 401,
  FORBIDDEN = 403,
  NOT_FOUND = 404,
  CONFLICT = 409,
  SERVER_ERROR = 500
}

/**
 * 分页请求参数
 */
export interface PageRequest {
  /** 页码，从0开始 */
  page: number;
  /** 每页数量 */
  size: number;
}

/**
 * 分页响应结构
 */
export interface PageResponse<T> {
  /** 数据列表 */
  content: T[];
  /** 总元素数 */
  totalElements: number;
  /** 总页数 */
  totalPages: number;
  /** 当前页码 */
  number: number;
  /** 每页大小 */
  size: number;
  /** 是否为第一页 */
  first: boolean;
  /** 是否为最后一页 */
  last: boolean;
}
