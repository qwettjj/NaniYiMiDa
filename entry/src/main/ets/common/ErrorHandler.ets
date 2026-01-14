/**
 * 全局错误处理器
 * 统一处理各类错误，提供一致的用户反馈
 */
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 错误类型枚举
 */
export enum ErrorType {
  /** 网络错误 */
  NETWORK = 'NETWORK',
  /** 业务逻辑错误 */
  BUSINESS = 'BUSINESS',
  /** 权限错误 */
  PERMISSION = 'PERMISSION',
  /** 未知错误 */
  UNKNOWN = 'UNKNOWN'
}

/**
 * 错误处理器类
 */
export class ErrorHandler {
  
  /**
   * 处理错误并显示 Toast 提示
   * @param error 错误对象
   * @param customMessage 自定义错误消息（可选）
   */
  static handleError(error: BusinessError | Error | unknown, customMessage?: string): void {
    let message: string;
    let errorType: ErrorType = ErrorType.UNKNOWN;

    if (error instanceof Error) {
      // 标准 Error 对象
      message = error.message;
      
      // 根据错误消息判断类型
      if (message.includes('network') || message.includes('connect') || message.includes('timeout')) {
        errorType = ErrorType.NETWORK;
        message = customMessage || '网络连接异常，请检查网络设置';
      } else if (message.includes('permission') || message.includes('授权')) {
        errorType = ErrorType.PERMISSION;
        message = customMessage || '权限不足，请检查应用权限';
      } else {
        message = customMessage || message || '操作失败，请重试';
      }
    } else if (typeof error === 'object' && error !== null) {
      // BusinessError 或其他对象
      const businessError = error as BusinessError;
      if (businessError.code !== undefined) {
        errorType = ErrorType.BUSINESS;
        message = customMessage || businessError.message || `错误代码: ${businessError.code}`;
      } else {
        message = customMessage || JSON.stringify(error);
      }
    } else {
      message = customMessage || '未知错误';
    }

    console.error(`[ErrorHandler] Type: ${errorType}, Message: ${message}`);

    // 显示 Toast
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }

  /**
   * 处理网络错误
   * @param error 错误对象
   */
  static handleNetworkError(error: unknown): void {
    this.handleError(error, '网络请求失败，请检查网络连接');
  }

  /**
   * 处理业务错误
   * @param code 错误代码
   * @param message 错误消息
   */
  static handleBusinessError(code: number, message: string | null): void {
    const errorMessage = message || `业务错误 (${code})`;
    
    // 根据常见错误码提供友好提示
    let friendlyMessage: string;
    switch (code) {
      case 401:
        friendlyMessage = '未登录或登录已过期，请重新登录';
        break;
      case 403:
        friendlyMessage = '没有权限执行此操作';
        break;
      case 404:
        friendlyMessage = '请求的资源不存在';
        break;
      case 409:
        friendlyMessage = '操作冲突，请刷新后重试';
        break;
      case 500:
        friendlyMessage = '服务器内部错误';
        break;
      default:
        friendlyMessage = errorMessage;
    }

    console.warn(`[ErrorHandler] Business Error: ${code} - ${friendlyMessage}`);
    
    promptAction.showToast({
      message: friendlyMessage,
      duration: 2000
    });
  }

  /**
   * 处理权限错误
   * @param permissionName 权限名称
   */
  static handlePermissionError(permissionName?: string): void {
    const message = permissionName 
      ? `需要 ${permissionName} 权限，请在设置中开启`
      : '权限不足，请检查应用权限设置';
    
    this.handleError(new Error('Permission denied'), message);
  }
}
