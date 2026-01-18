package com.java.NaniYiMiDa.controller;

import com.java.NaniYiMiDa.enumx.ErrorCode;
import com.java.NaniYiMiDa.service.ImageService;
import com.java.NaniYiMiDa.tool.QrUtil;
import com.java.NaniYiMiDa.vo.ResultVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import jakarta.servlet.http.HttpServletResponse;

@RestController
@RequestMapping("/api")
public class ToolsController {
    @Autowired
    ImageService imageService;

    @PostMapping("/images")
    public ResultVO<String> upload(@RequestParam MultipartFile file, HttpServletResponse response) {
        String imageUrl = imageService.upload(file);
        // 在响应头中添加图片 URL，方便 HarmonyOS 客户端通过 headerReceive 事件获取
        response.setHeader("X-Image-Url", imageUrl);
        response.setHeader("Access-Control-Expose-Headers", "X-Image-Url");
        return ResultVO.buildSuccess(imageUrl);
    }

    @PostMapping("qr/decode")
    public ResultVO<String> decodeQr(@RequestParam(required = false) MultipartFile file,
            @RequestParam(required = false) String base64) {
        try {
            if ((file == null || file.isEmpty()) && (base64 == null || base64.isBlank())) {
                return ResultVO.buildFailure(ErrorCode.BAD_REQUEST, "请上传图片或提供 base64");
            }
            String text;
            if (file != null && !file.isEmpty()) {
                text = QrUtil.decode(file);
            } else {
                text = QrUtil.decodeBase64(base64);
            }
            return ResultVO.buildSuccess(text);
        } catch (com.google.zxing.NotFoundException e) {
            return ResultVO.buildFailure(ErrorCode.BAD_REQUEST, "未识别到二维码");
        } catch (Exception e) {
            return ResultVO.buildFailure(ErrorCode.SERVER_ERROR, e.getMessage());
        }
    }
}