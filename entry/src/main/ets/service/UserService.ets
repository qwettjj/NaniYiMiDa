/**
 * 用户服务类
 * 对应后端 UserController: /api/users
 */
import { HttpUtil, ResultVO } from './HttpUtil';
import { UserVO } from '../model/UserModel';

/** API 基础路径 */
const BASE_PATH: string = '/api/users';

/**
 * 用户服务
 * 封装所有用户相关的 API 请求
 */
export class UserService {

  /**
   * 用户登录
   * POST /api/users/login?phone=xxx&password=xxx
   * @param phone 手机号
   * @param password 密码
   * @returns Token 字符串
   */
  static async login(phone: string, password: string): Promise<ResultVO<string>> {
    const url = `${BASE_PATH}/login?phone=${encodeURIComponent(phone)}&password=${encodeURIComponent(password)}`;
    console.info(`UserService: 正在登录 ${phone}...`);
    const result = await HttpUtil.post<string>(url);
    console.info(`UserService: 登录接口返回 code=${result.code}`);

    // 登录成功后保存 Token
    if (result.code === 0 && result.data) {
      await HttpUtil.saveToken(result.data);
      console.info('UserService: 登录成功，Token 已保存');
    } else {
      console.warn(`UserService: 登录未成功, code=${result.code}, message=${result.message}`);
    }

    return result;
  }

  /**
   * 用户注册
   * POST /api/users/register
   * @param userVO 用户注册信息（需包含 phoneNumber, password, userName）
   * @returns 注册是否成功
   */
  static async register(userVO: UserVO): Promise<ResultVO<boolean>> {
    return await HttpUtil.post<boolean>(`${BASE_PATH}/register`, userVO);
  }
  /**

   * 获取当前登录用户信息
   * GET /api/users/me
   * @returns 当前用户信息
   */
  static async getCurrentUser(): Promise<ResultVO<UserVO>> {
    return await HttpUtil.get<UserVO>(`${BASE_PATH}/me`);
  }

  /**
   * 更新当前用户信息
   * PUT /api/users/me
   * @param userVO 要更新的用户信息
   * @returns 更新是否成功
   */
  static async updateCurrentUser(userVO: UserVO): Promise<ResultVO<boolean>> {
    return await HttpUtil.put<boolean>(`${BASE_PATH}/me`, userVO);
  }

  /**
   * 关注用户
   * POST /api/users/{userId}/followings
   * @param userId 要关注的用户 ID
   * @returns 操作结果
   */
  static async followUser(userId: number): Promise<ResultVO<void>> {
    return await HttpUtil.post<void>(`${BASE_PATH}/${userId}/followings`);
  }

  /**
   * 取消关注用户
   * DELETE /api/users/{userId}/followings
   * @param userId 要取消关注的用户 ID
   * @returns 操作结果
   */
  static async unfollowUser(userId: number): Promise<ResultVO<void>> {
    return await HttpUtil.delete<void>(`${BASE_PATH}/${userId}/followings`);
  }

  /**
   * 获取我的关注列表
   * GET /api/users/me/followings
   * @returns 关注的用户列表
   */
  static async getMyFollowings(): Promise<ResultVO<UserVO[]>> {
    return await HttpUtil.get<UserVO[]>(`${BASE_PATH}/me/followings`);
  }

  /**
   * 根据用户名搜索用户
   * GET /api/users/search?username=xxx
   * @param userName 用户名
   * @returns 匹配的用户信息
   */
  static async findByUserName(userName: string): Promise<ResultVO<UserVO>> {
    const url = `${BASE_PATH}/search?username=${encodeURIComponent(userName)}`;
    return await HttpUtil.get<UserVO>(url);
  }

  /**
   * 退出登录
   * 清除本地存储的 Token
   */
  static async logout(): Promise<void> {
    await HttpUtil.clearToken();
    console.info('UserService: 已退出登录');
  }

  /**
   * 检查是否已登录
   * @returns 是否已登录
   */
  static async isLoggedIn(): Promise<boolean> {
    const token = await HttpUtil.getToken();
    return token !== '';
  }
}
