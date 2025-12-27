/**
 * 用户相关模型
 * 对应后端 User.java 和 UserVO.java
 */

/**
 * 用户角色枚举
 * 对应后端 Role
 */
export enum Role {
  USER = 'USER',
  ADMIN = 'ADMIN'
}

/**
 * 用户信息接口
 * 对应后端 UserVO
 */
export interface UserVO {
  /** 用户ID */
  userId: number | null;
  /** 用户名 */
  userName: string | null;
  /** 密码 (登录/注册时使用) */
  password: string | null;
  /** 手机号 */
  phoneNumber: string | null;
  /** 创建时间 (时间戳或ISO字符串) */
  createTime: string | null;
  /** 粉丝数 */
  followerCount: number | null;
  /** 关注数 */
  followingCount: number | null;
  /** 收藏数 */
  favouriteCount: number | null;
  /** 头像URL */
  imageUrl: string | null;
  /** 用户角色 */
  role: Role | null;
  /** 昵称 */
  nickName?: string | null;
  /** 生日 */
  birthday?: string | null;
  /** 个人签名 */
  signature?: string | null;
  /** 过敏原 */
  allergens?: string | null;
}

/**
 * 用户登录请求参数
 */
export interface LoginRequest {
  /** 手机号 */
  phone: string;
  /** 密码 */
  password: string;
}

/**
 * 用户注册请求参数
 */
export interface RegisterRequest {
  /** 用户名 */
  userName: string;
  /** 手机号 */
  phoneNumber: string;
  /** 密码 */
  password: string;
}

/**
 * 用户信息更新请求
 */
export interface UserUpdateRequest {
  /** 用户名 */
  userName?: string;
  /** 头像URL */
  imageUrl?: string;
  /** 密码 */
  password?: string;
}

/**
 * 登录响应 (token在header中返回)
 */
export interface LoginResponse {
  /** token (从response header获取) */
  token: string;
  /** 用户信息 */
  user: UserVO | null;
}

/**
 * 创建空的 UserVO 对象
 */
export function createEmptyUserVO(): UserVO {
  return {
    userId: null,
    userName: null,
    password: null,
    phoneNumber: null,
    createTime: null,
    followerCount: null,
    followingCount: null,
    favouriteCount: null,
    imageUrl: null,
    role: null
  };
}
