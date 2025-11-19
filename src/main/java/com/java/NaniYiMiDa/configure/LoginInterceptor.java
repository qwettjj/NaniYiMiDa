package com.java.NaniYiMiDa.configure;

import com.java.NaniYiMiDa.enumx.ErrorCode;
import com.java.NaniYiMiDa.exception.BusinessException;
import com.java.NaniYiMiDa.tool.TokenUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class LoginInterceptor implements HandlerInterceptor {

    @Autowired
    TokenUtil tokenUtil;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        String token = extractToken(request);
        if (token != null && tokenUtil.verifyToken(token)) {
            request.getSession().setAttribute("currentUser", tokenUtil.getUser(token));
            return true;
        } else {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "未登录");
        }
    }

    private String extractToken(HttpServletRequest request) {
        // 优先从 Authorization: Bearer 头读取（标准方式）
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }
        // 兼容旧的 token 头方式
        return request.getHeader("token");
    }

}
