package com.java.NaniYiMiDa.controller;


import com.java.NaniYiMiDa.service.UserService;
import com.java.NaniYiMiDa.vo.ResultVO;
import com.java.NaniYiMiDa.vo.UserVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {
    @Autowired
    UserService userService;

    @PostMapping
    public ResultVO<Boolean> register(@RequestBody UserVO userVO){
        return ResultVO.buildSuccess(userService.userRegister(userVO));
    }

    @PostMapping("/login")
    public ResultVO<String> login(@RequestParam("phone") String phone, @RequestParam("password") String password){
        return ResultVO.buildSuccess(userService.userLogin(phone, password));
    }

    @GetMapping("/me")
    public ResultVO<UserVO> getInformation(){
        return ResultVO.buildSuccess(userService.getCurrentUserInformation());
    }

    @PutMapping("/me")
    public ResultVO<Boolean> updateInformation(@RequestBody UserVO userVO){
        return ResultVO.buildSuccess(userService.updateUserInformation(userVO));
    }

	@PostMapping("/{userId}/followings")
	public ResultVO<Void> follow(@PathVariable Long userId) {
		return ResultVO.buildSuccess(userService.followUser(userId));
	}

	@DeleteMapping("/{userId}/followings")
	public ResultVO<Void> unfollow(@PathVariable Long userId) {
		return ResultVO.buildSuccess(userService.unfollowUser(userId));
	}

	@GetMapping("/me/followings")
	public ResultVO<java.util.List<UserVO>> myFollowings() {
		return ResultVO.buildSuccess(userService.listMyFollowings());
	}

	@GetMapping("/search")
	public ResultVO<UserVO> findByUserName(@RequestParam("username") String userName) {
		return ResultVO.buildSuccess(userService.findByUserName(userName));
	}
}
