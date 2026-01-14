/**
 * 工具服务类
 * 对应后端 ToolsController: /api/qr
 */
import { HttpUtil, ResultVO } from './HttpUtil';

/** API 基础路径 */
const BASE_PATH: string = '/api/qr';

/**
 * 二维码解码请求参数
 */
interface DecodeQrRequest {
  /** 二维码内容 */
  qrCode: string;
}

/**
 * 二维码生成请求参数
 */
interface GenerateQrRequest {
  /** 要编码的内容 */
  content: string;
}

/**
 * 工具服务
 * 封装二维码解析等工具功能
 */
export class ToolsService {

  /**
   * 解码二维码
   * POST /api/qr/decode
   * @param qrCode 二维码内容
   * @returns 解析后的产品 ID 或其他数据
   */
  static async decodeQr(qrCode: string): Promise<ResultVO<string>> {
    const requestBody: DecodeQrRequest = { qrCode };
    return await HttpUtil.post<string>(`${BASE_PATH}/decode`, requestBody);
  }

  /**
   * 生成二维码
   * POST /api/qr/generate
   * @param content 要编码的内容
   * @returns 二维码图片 URL
   */
  static async generateQr(content: string): Promise<ResultVO<string>> {
    const requestBody: GenerateQrRequest = { content };
    return await HttpUtil.post<string>(`${BASE_PATH}/generate`, requestBody);
  }
}
