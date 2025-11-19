package com.java.NaniYiMiDa.enumx;

public enum ErrorCode {
	SUCCESS("000", "success"),
	BAD_REQUEST("400", "bad request"),
	UNAUTHORIZED("401", "unauthorized"),
	FORBIDDEN("403", "forbidden"),
	NOT_FOUND("404", "not found"),
	CONFLICT("409", "conflict"),
	SERVER_ERROR("500", "internal server error");

	private final String code;
	private final String defaultMessage;

	ErrorCode(String code, String defaultMessage) {
		this.code = code;
		this.defaultMessage = defaultMessage;
	}

	public String getCode() {
		return code;
	}

	public String getDefaultMessage() {
		return defaultMessage;
	}
}


