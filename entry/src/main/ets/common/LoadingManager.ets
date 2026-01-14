/**
 * 全局 Loading 管理器
 * 统一管理页面加载状态
 */
import { promptAction } from '@kit.ArkUI';

/**
 * Loading 管理器类
 */
export class LoadingManager {
  private static loadingCount: number = 0;
  private static loadingToastId: number = -1;

  /**
   * 显示全局 Loading
   * @param message 加载提示消息（可选）
   */
  static showLoading(message: string = '加载中...'): void {
    this.loadingCount++;
    
    if (this.loadingCount === 1) {
      // 只在第一次显示 loading
      promptAction.showToast({
        message: message,
        duration: 0 // 持续显示，直到手动关闭
      });
      console.info('[LoadingManager] Loading started');
    }
  }

  /**
   * 隐藏全局 Loading
   */
  static hideLoading(): void {
    if (this.loadingCount > 0) {
      this.loadingCount--;
    }

    if (this.loadingCount === 0) {
      // 所有 loading 都结束时才关闭
      // 注意：HarmonyOS Toast 没有直接的关闭 API
      // 这里只是重置计数器
      console.info('[LoadingManager] Loading finished');
    }
  }

  /**
   * 重置 Loading 状态
   * 在页面销毁或导航时调用
   */
  static reset(): void {
    this.loadingCount = 0;
    console.info('[LoadingManager] Loading reset');
  }

  /**
   * 包装异步操作，自动管理 Loading 状态
   * @param asyncFn 异步函数
   * @param loadingMessage 加载提示消息
   * @returns Promise
   */
  static async withLoading<T>(
    asyncFn: () => Promise<T>,
    loadingMessage?: string
  ): Promise<T> {
    this.showLoading(loadingMessage);
    try {
      const result = await asyncFn();
      return result;
    } finally {
      this.hideLoading();
    }
  }

  /**
   * 显示成功提示
   * @param message 提示消息
   */
  static showSuccess(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }

  /**
   * 显示警告提示
   * @param message 提示消息
   */
  static showWarning(message: string): void {
    promptAction.showToast({
      message: '⚠️ ' + message,
      duration: 2500
    });
  }

  /**
   * 显示信息提示
   * @param message 提示消息
   */
  static showInfo(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }
}
