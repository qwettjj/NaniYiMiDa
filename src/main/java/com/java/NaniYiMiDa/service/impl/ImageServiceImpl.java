package com.java.NaniYiMiDa.service.impl;

import com.java.NaniYiMiDa.enumx.ErrorCode;
import com.java.NaniYiMiDa.exception.BusinessException;
import com.java.NaniYiMiDa.service.ImageService;
import com.java.NaniYiMiDa.tool.OssUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class ImageServiceImpl implements ImageService {
    @Autowired
    OssUtil ossUtil;

    @Override
    public String upload(MultipartFile file){
        try {
            return ossUtil.upload(file.getOriginalFilename(),file.getInputStream());
        }catch (Exception e){
            e.printStackTrace();
            throw new BusinessException(ErrorCode.SERVER_ERROR,"图片上传失败");
        }
    }
}