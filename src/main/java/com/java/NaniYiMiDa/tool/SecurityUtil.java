package com.java.NaniYiMiDa.tool;

import com.java.NaniYiMiDa.po.User;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class SecurityUtil {

	@Autowired
	private HttpServletRequest httpServletRequest;

	public User getCurrentUser() {
		return (User) httpServletRequest.getSession().getAttribute("currentUser");
	}
}
