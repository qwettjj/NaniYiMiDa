/**
 * 图片上传服务类
 * 对应后端 ToolsController: /api/images
 */
import { HttpUtil, ResultVO, BASE_URL } from './HttpUtil';
import { request } from '@kit.BasicServicesKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';

/** API 基础路径 */
const BASE_PATH: string = '/api/images';

/**
 * 图片文件信息接口
 */
export interface ImageFileInfo {
  /** 文件名称 */
  filename: string;
  /** 文件路径（本地 URI） */
  uri: string;
  /** 文件类型（MIME Type） */
  type: string;
}

/**
 * 图片上传服务
 * 封装图片上传相关的 API 请求
 */
export class ImageService {

  /**
   * 上传图片到服务器 (方案C: 响应头传递 URL)
   * POST /api/images
   * 
   * 实现方案：
   * - 后端：在响应头中添加 X-Image-Url 字段返回 OSS URL
   * - 前端：监听 headerReceive 事件提取 URL，解决 TaskState 无 response 的问题
   * 
   * 优点：
   * - 使用官方 request.uploadFile() API
   * - 可获取真实的 OSS URL
   * - 保持代码简洁性
   * 
   * @param fileInfo 图片文件信息
   * @returns 包含 OSS URL 的 ResultVO
   */
  static async uploadImage(fileInfo: ImageFileInfo): Promise<ResultVO<string>> {
    try {
      const token = await HttpUtil.getToken();
      const uploadConfig: request.UploadConfig = {
        url: `${BASE_URL}${BASE_PATH}`,
        header: {
          'Authorization': token ? `Bearer ${token}` : ''
        },
        method: 'POST',
        files: [
          {
            filename: fileInfo.filename,
            name: 'file',
            uri: fileInfo.uri,
            type: fileInfo.type
          }
        ],
        data: []
      };

      console.info('ImageService: 开始上传图片 -', fileInfo.filename);

      // 使用 Promise 风格的 uploadFile
      const uploadTask = await request.uploadFile(getContext(), uploadConfig);

      return new Promise<ResultVO<string>>((resolve, reject) => {
        let imageUrl: string | null = null;

        // 监听响应头（获取后端返回的 URL）
        uploadTask.on('headerReceive', (header: object) => {
          console.info('ImageService: 收到响应头 -', JSON.stringify(header));
          // 从响应头中提取 X-Image-Url
          if (header && typeof header === 'object') {
            const headers = header as Record<string, string | string[]>;
            const urlHeader = headers['x-image-url'] || headers['X-Image-Url'];
            if (urlHeader) {
              imageUrl = Array.isArray(urlHeader) ? urlHeader[0] : urlHeader;
              console.info('ImageService: 从响应头获取到 URL -', imageUrl);
            }
          }
        });

        // 监听上传进度（可选）
        uploadTask.on('progress', (uploadedSize: number, totalSize: number) => {
          const progress = Math.floor((uploadedSize / totalSize) * 100);
          console.info(`ImageService: 上传进度 ${progress}% (${uploadedSize}/${totalSize})`);
        });

        // 监听上传完成
        uploadTask.on('complete', (taskStates: Array<request.TaskState>) => {
          console.info('ImageService: 上传完成事件触发');
          
          if (taskStates && taskStates.length > 0) {
            const state = taskStates[0];
            console.info(`ImageService: responseCode=${state.responseCode}, message=${state.message}`);
            
            // 检查 HTTP 响应码
            if (state.responseCode === 200) {
              // 通过 headerReceive 事件已获取到 URL
              if (imageUrl) {
                console.info('ImageService: 上传成功，URL -', imageUrl);
                resolve({
                  code: 0,
                  message: '上传成功',
                  data: imageUrl
                } as ResultVO<string>);
              } else {
                console.warn('ImageService: 上传成功但未从响应头获取到 URL');
                resolve({
                  code: 0,
                  message: '上传成功，但未获取到 URL',
                  data: `${BASE_URL}/uploaded/${fileInfo.filename}`
                } as ResultVO<string>);
              }
              return;
            } else {
              // 非 200 响应码
              console.error(`ImageService: 上传失败，HTTP ${state.responseCode}`);
              reject({
                code: state.responseCode,
                message: state.message || `上传失败 (HTTP ${state.responseCode})`,
                data: null
              } as ResultVO<string>);
              return;
            }
          }
          
          // taskStates 为空
          reject({
            code: -1,
            message: '上传完成但无状态信息',
            data: null
          } as ResultVO<string>);
        });

        // 监听上传失败
        uploadTask.on('fail', (taskStates: Array<request.TaskState>) => {
          console.error('ImageService: 上传失败事件触发');
          
          if (taskStates && taskStates.length > 0) {
            const state = taskStates[0];
            reject({
              code: state.responseCode || -1,
              message: state.message || '上传失败',
              data: null
            } as ResultVO<string>);
          } else {
            reject({
              code: -1,
              message: '上传失败',
              data: null
            } as ResultVO<string>);
          }
        });
      });

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : JSON.stringify(error);
      console.error('ImageService: 上传异常 -', errorMsg);
      return {
        code: -1,
        message: `上传异常: ${errorMsg}`,
        data: null
      };
    }
  }

  /**
   * 使用文件选择器选择图片
   * @returns 选中的图片文件信息，未选择则返回 null
   */
  static async selectImage(): Promise<ImageFileInfo | null> {
    try {
      // 注意：实际使用时需要导入 @ohos.file.picker
      // 这里提供接口定义，实际实现需要在页面中调用
      // 因为 picker 需要 UIContext，不能在 Service 层直接调用
      console.warn('ImageService.selectImage: 此方法需要在页面中使用 @ohos.file.picker 实现');
      return null;
    } catch (error) {
      console.error('ImageService: 选择图片失败 -', error instanceof Error ? error.message : JSON.stringify(error));
      return null;
    }
  }
}
