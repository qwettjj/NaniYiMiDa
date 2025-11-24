package com.java.NaniYiMiDa.exception;

import com.java.NaniYiMiDa.enumx.ErrorCode;
import org.apache.tomcat.util.http.fileupload.FileUploadException;

public class BusinessException extends RuntimeException {
	private final ErrorCode errorCode;

	public BusinessException(ErrorCode errorCode, String message) {
		super(message);
		this.errorCode = errorCode;
	}

	public ErrorCode getErrorCode() {
		return errorCode;
	}
}


