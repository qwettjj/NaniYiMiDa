import { type MockMethod } from "vite-plugin-mock";

// 用户数据样例
const mockUsers = [
  {
    id: 1,
    username: "admin",
    password: "111111",
    role: "admin",
    name: "超级管理员",
    age: 30,
    avatar: "https://example.com/avatar-admin.jpg",
    token: "admin-token-123456",
  },
  {
    id: 2,
    username: "editor",
    password: "111111",
    role: "editor",
    name: "内容编辑",
    age: 25,
    avatar: "https://example.com/avatar-editor.jpg",
    token: "editor-token-789012",
  },
  {
    id: 3,
    username: "guest",
    password: "111111",
    role: "guest",
    name: "访客用户",
    age: 20,
    avatar: "https://example.com/avatar-guest.jpg",
    token: "guest-token-345678",
  },
];

// 登录接口
function createLoginApiMock(): MockMethod {
  return {
    url: "/api/user/login",
    method: "post",
    response: (request: {
      body: { username: string; password: string; };
    }) => {
      const { username, password} = request.body;
      // 查找匹配的用户
      const user = mockUsers.find(
        (u) =>
          u.username === username &&
          u.password === password
      );

      if (user) {
        // 登录成功，返回用户信息和token（实际项目中不要返回密码）
        return {
          code: 200,
          message: "登录成功",
          data: {
            id: user.id,
            username: user.username,
            role: user.role,
            name: user.name,
            avatar: user.avatar,
            token: user.token,
          },
        };
      } else {
        // 登录失败
        return {
          code: 401,
          message: "用户名或密码错误",
          data: null,
        };
      }
    },
  };
}

// 用户信息接口（示例）
function createUserInfoApiMock(): MockMethod {
  return {
    url: "/api/user/info",
    method: "get",
    response: (request: { headers: { token: string } }) => {
      const token = request.headers?.token;
      const user = mockUsers.find((u) => u.token === token);

      if (user) {
        return {
          code: 200,
          message: "获取用户信息成功",
          data: {
            id: user.id,
            username: user.username,
            role: user.role,
            name: user.name,
            avatar: user.avatar,
            age: user.age,
          },
        };
      } else {
        return {
          code: 401,
          message: "未授权，请先登录",
          data: null,
        };
      }
    },
  };
}

// 导出所有Mock接口
export default [createLoginApiMock(), createUserInfoApiMock()] as MockMethod[];
