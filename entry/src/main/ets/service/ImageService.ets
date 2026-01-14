/**
 * 图片上传服务类
 * 对应后端 ToolsController: /api/images
 */
import { HttpUtil, ResultVO } from './HttpUtil';
import { request } from '@kit.BasicServicesKit';
import { BusinessError } from '@kit.BasicServicesKit';

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
   * 上传图片到服务器
   * POST /api/images
   * @param fileInfo 图片文件信息
   * @returns 图片 URL
   */
  static async uploadImage(fileInfo: ImageFileInfo): Promise<ResultVO<string>> {
    try {
      const token = await HttpUtil.getToken();
      const uploadConfig: request.UploadConfig = {
        url: `http://localhost:8080${BASE_PATH}`,
        header: {
          'Authorization': token ? `Bearer ${token}` : '',
          'Content-Type': 'multipart/form-data'
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

      return new Promise<ResultVO<string>>((resolve, reject) => {
        request.uploadFile(getContext(), uploadConfig, (err: BusinessError, uploadTask: request.UploadTask) => {
          if (err) {
            console.error('ImageService: 上传失败 -', err.message);
            reject({
              code: -1,
              message: `上传失败: ${err.message}`,
              data: null
            } as ResultVO<string>);
            return;
          }

          uploadTask.on('complete', (taskStates: Array<request.TaskState>) => {
            console.info('ImageService: 上传完成');
            for (let taskState of taskStates) {
              if (taskState.response) {
                try {
                  const result = JSON.parse(taskState.response) as ResultVO<string>;
                  console.info('ImageService: 解析结果 -', JSON.stringify(result));
                  resolve(result);
                } catch (parseError) {
                  console.error('ImageService: 解析响应失败');
                  reject({
                    code: -1,
                    message: '解析服务器响应失败',
                    data: null
                  } as ResultVO<string>);
                }
                return;
              }
            }
            reject({
              code: -1,
              message: '服务器无响应',
              data: null
            } as ResultVO<string>);
          });

          uploadTask.on('fail', (taskStates: Array<request.TaskState>) => {
            console.error('ImageService: 上传失败事件触发');
            reject({
              code: -1,
              message: '上传失败',
              data: null
            } as ResultVO<string>);
          });
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
