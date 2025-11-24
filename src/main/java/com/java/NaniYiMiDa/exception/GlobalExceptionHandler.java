package com.java.NaniYiMiDa.exception;

import com.java.NaniYiMiDa.enumx.ErrorCode;
import com.java.NaniYiMiDa.vo.ResultVO;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

	@ExceptionHandler(BusinessException.class)
	public ResponseEntity<ResultVO<Void>> handleBusiness(BusinessException e) {
		return ResponseEntity.status(HttpStatus.BAD_REQUEST)
			.body(ResultVO.buildFailure(e.getErrorCode(), e.getMessage()));
	}

	@ExceptionHandler(MethodArgumentNotValidException.class)
	public ResponseEntity<ResultVO<Void>> handleValidation(MethodArgumentNotValidException e) {
		String message = e.getBindingResult().getFieldErrors().stream().findFirst()
			.map(f -> f.getField() + " " + f.getDefaultMessage())
			.orElse("参数校验失败");
		return ResponseEntity.status(HttpStatus.BAD_REQUEST)
			.body(ResultVO.buildFailure(ErrorCode.BAD_REQUEST, message));
	}

	@ExceptionHandler(Exception.class)
	public ResponseEntity<ResultVO<Void>> handleOthers(Exception e) {
		return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
			.body(ResultVO.buildFailure(ErrorCode.SERVER_ERROR, e.getMessage()));
	}
}
