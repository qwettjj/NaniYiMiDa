package com.java.NaniYiMiDa.tool;

import com.google.zxing.*;
import com.google.zxing.client.j2se.BufferedImageLuminanceSource;
import com.google.zxing.common.HybridBinarizer;
import com.java.NaniYiMiDa.enumx.ErrorCode;
import com.java.NaniYiMiDa.exception.BusinessException;

import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.util.Base64;

public class QrUtil {
    public static String decode(MultipartFile file) throws Exception {
        BufferedImage img = ImageIO.read(file.getInputStream());
        return decodeBufferedImage(img);
    }

    public static String decodeBase64(String base64) throws Exception {
        byte[] bytes = Base64.getDecoder().decode(base64.replaceAll("^data:image/[^;]+;base64,", ""));
        BufferedImage img = ImageIO.read(new ByteArrayInputStream(bytes));
        return decodeBufferedImage(img);
    }

    private static String decodeBufferedImage(BufferedImage img) throws NotFoundException {
        if (img == null)
            throw new BusinessException(ErrorCode.BAD_REQUEST,"未识别到图片");
        LuminanceSource source = new BufferedImageLuminanceSource(img);
        BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));
        Reader reader = new MultiFormatReader();
        try {
            Result result = reader.decode(bitmap);
            return result.getText();
        } catch (ChecksumException | FormatException e) {
            // 转换为 NotFound 或自定义异常，便于上层统一处理
            throw NotFoundException.getNotFoundInstance();
        }
    }
}