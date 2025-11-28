/**
 * HTTP 工具类
 * 封装 @ohos.net.http 模块，提供统一的网络请求方法
 */
import http from '@ohos.net.http';
import { preferences } from '@kit.ArkData';

/** API 基础地址 */
const BASE_URL: string = 'http://10.0.2.2:8080';

/** Token 存储键名 */
const TOKEN_KEY: string = 'user_token';

/** Preferences 文件名 */
const PREFERENCES_NAME: string = 'user_prefs';

/**
 * 通用响应结构
 * 对应后端 ResultVO<T>
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
 * HTTP 请求配置
 */
interface RequestConfig {
  /** 请求方法 */
  method: http.RequestMethod;
  /** 请求头 */
  header?: Record<string, string>;
  /** 请求体 */
  extraData?: string;
  /** 连接超时时间 */
  connectTimeout?: number;
  /** 读取超时时间 */
  readTimeout?: number;
}

/**
 * HTTP 工具类
 * 提供 GET、POST、PUT、DELETE 请求方法
 */
export class HttpUtil {
  /** 应用上下文 */
  private static context: Context | null = null;

  /**
   * 初始化 HTTP 工具类
   * 需要在 EntryAbility 的 onCreate 中调用
   * @param context 应用上下文
   */
  static init(context: Context): void {
    HttpUtil.context = context;
  }

  /**
   * 获取存储的 Token
   * @returns Token 字符串，未登录时返回空字符串
   */
  static async getToken(): Promise<string> {
    if (!HttpUtil.context) {
      console.error('HttpUtil: Context 未初始化');
      return '';
    }
    try {
      const pref = await preferences.getPreferences(HttpUtil.context, PREFERENCES_NAME);
      const token = await pref.get(TOKEN_KEY, '') as string;
      return token;
    } catch (e) {
      console.error('HttpUtil: 获取Token失败 -', JSON.stringify(e));
      return '';
    }
  }

  /**
   * 保存 Token
   * @param token 要保存的 Token
   */
  static async saveToken(token: string): Promise<void> {
    if (!HttpUtil.context) {
      console.error('HttpUtil: Context 未初始化');
      return;
    }
    try {
      const pref = await preferences.getPreferences(HttpUtil.context, PREFERENCES_NAME);
      await pref.put(TOKEN_KEY, token);
      await pref.flush();
      console.info('HttpUtil: Token 保存成功');
    } catch (e) {
      console.error('HttpUtil: 保存Token失败 -', JSON.stringify(e));
    }
  }

  /**
   * 清除 Token（退出登录时调用）
   */
  static async clearToken(): Promise<void> {
    if (!HttpUtil.context) {
      console.error('HttpUtil: Context 未初始化');
      return;
    }
    try {
      const pref = await preferences.getPreferences(HttpUtil.context, PREFERENCES_NAME);
      await pref.delete(TOKEN_KEY);
      await pref.flush();
      console.info('HttpUtil: Token 已清除');
    } catch (e) {
      console.error('HttpUtil: 清除Token失败 -', JSON.stringify(e));
    }
  }

  /**
   * 构建请求头
   * @param token 认证 Token
   * @returns 请求头对象
   */
  private static buildHeaders(token: string): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    };
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }
    return headers;
  }

  /**
   * 拼接 URL 查询参数
   * @param url 基础 URL
   * @param params 查询参数
   * @returns 完整 URL
   */
  private static buildUrlWithParams(url: string, params?: Record<string, string | number>): string {
    if (!params) {
      return url;
    }
    const queryString = Object.keys(params)
      .filter(key => params[key] !== undefined && params[key] !== null)
      .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(String(params[key]))}`)
      .join('&');

    if (!queryString) {
      return url;
    }
    return url + (url.includes('?') ? '&' : '?') + queryString;
  }

  /**
   * 发送 HTTP 请求
   * @param url 请求路径（不含 BASE_URL）
   * @param config 请求配置
   * @returns 响应结果
   */
  private static async request<T>(url: string, config: RequestConfig): Promise<ResultVO<T>> {
    const httpRequest = http.createHttp();
    const fullUrl = BASE_URL + url;

    try {
      const token = await HttpUtil.getToken();
      const response = await httpRequest.request(fullUrl, {
        method: config.method,
        header: config.header || HttpUtil.buildHeaders(token),
        extraData: config.extraData,
        connectTimeout: config.connectTimeout || 30000,
        readTimeout: config.readTimeout || 30000
      });

      console.info(`HttpUtil: ${config.method} ${url} -> ${response.responseCode}`);

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as ResultVO<T>;
        return result;
      } else {
        return {
          code: response.responseCode,
          message: `HTTP 错误: ${response.responseCode}`,
          data: null
        };
      }
    } catch (e) {
      console.error(`HttpUtil: 请求异常 ${url} -`, JSON.stringify(e));
      return {
        code: 500,
        message: '网络请求异常，请检查网络连接',
        data: null
      };
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * GET 请求
   * @param url 请求路径
   * @param params 查询参数
   * @returns 响应结果
   */
  static async get<T>(url: string, params?: Record<string, string | number>): Promise<ResultVO<T>> {
    const fullUrl = HttpUtil.buildUrlWithParams(url, params);
    const token = await HttpUtil.getToken();
    return HttpUtil.request<T>(fullUrl, {
      method: http.RequestMethod.GET,
      header: HttpUtil.buildHeaders(token)
    });
  }

  /**
   * POST 请求
   * @param url 请求路径
   * @param data 请求体数据
   * @returns 响应结果
   */
  static async post<T>(url: string, data?: object): Promise<ResultVO<T>> {
    const token = await HttpUtil.getToken();
    return HttpUtil.request<T>(url, {
      method: http.RequestMethod.POST,
      header: HttpUtil.buildHeaders(token),
      extraData: data ? JSON.stringify(data) : undefined
    });
  }

  /**
   * POST 请求（带查询参数，用于登录等场景）
   * @param url 请求路径
   * @param params 查询参数
   * @returns 响应结果
   */
  static async postWithParams<T>(url: string, params?: Record<string, string | number>): Promise<ResultVO<T>> {
    const fullUrl = HttpUtil.buildUrlWithParams(url, params);
    const token = await HttpUtil.getToken();
    return HttpUtil.request<T>(fullUrl, {
      method: http.RequestMethod.POST,
      header: HttpUtil.buildHeaders(token)
    });
  }

  /**
   * PUT 请求
   * @param url 请求路径
   * @param data 请求体数据
   * @returns 响应结果
   */
  static async put<T>(url: string, data?: object): Promise<ResultVO<T>> {
    const token = await HttpUtil.getToken();
    return HttpUtil.request<T>(url, {
      method: http.RequestMethod.PUT,
      header: HttpUtil.buildHeaders(token),
      extraData: data ? JSON.stringify(data) : undefined
    });
  }

  /**
   * PUT 请求（发送原始字符串）
   * 用于后端 @RequestBody String 的场景
   * @param url 请求路径
   * @param rawData 原始字符串数据
   * @returns 响应结果
   */
  static async putRaw<T>(url: string, rawData: string): Promise<ResultVO<T>> {
    const token = await HttpUtil.getToken();
    return HttpUtil.request<T>(url, {
      method: http.RequestMethod.PUT,
      header: HttpUtil.buildHeaders(token),
      extraData: rawData
    });
  }

  /**
   * DELETE 请求
   * @param url 请求路径
   * @returns 响应结果
   */
  static async delete<T>(url: string): Promise<ResultVO<T>> {
    const token = await HttpUtil.getToken();
    return HttpUtil.request<T>(url, {
      method: http.RequestMethod.DELETE,
      header: HttpUtil.buildHeaders(token)
    });
  }
}
