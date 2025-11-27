<template>
  <div class="login-container">
    <el-row>
      <el-col :span="10" :xs="0"></el-col>
      <el-col :span="14" :xs="24">
        <el-form
          :model="form"
          label-width="80px"
          class="loginForm"
          :rules="rules"
          ref="loginform"
        >
          <h1>番茄管理系统</h1>
          <el-form-item label="登录账号" class="loginInput" prop="username">
            <el-input
              type="text"
              v-model="form.username"
              :prefix-icon="User"
              placeholder="请输入账号"
            />
          </el-form-item>
          <el-form-item label="登录密码" class="loginInput" prop="password">
            <el-input
              type="password"
              v-model="form.password"
              :prefix-icon="Lock"
              show-password
              placeholder="请输入密码"
            />
          </el-form-item>
          <el-form-item>
            <el-button
              :loading="loading"
              type="primary"
              class="loginButton"
              @click="login"
              >立即登录</el-button
            >
          </el-form-item>
        </el-form>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts" name="Login">
  import { User, Lock } from "@element-plus/icons-vue";
  import { reactive, ref } from "vue";
  import { useUserStore } from "../../store/modules/user";
  import { useRouter } from "vue-router";
  import { ElNotification } from "element-plus";
let useStore = useUserStore();
const router = useRouter();
  let form = reactive({ username: "", password: "" });
 
  let loading = ref(false);
  let loginform = ref();
const validatorPassword = (_:any, value: string, callback: any) => {
    //rule：即为校验规则对象
    //value：即为表单元素文本内容
    //函数：如果符合条件cal1Back放行
    //如果不符合条件cal1Back方法，注入错误提示信息
    if (value.length<=15&&value.length>0) {
      callback()
    }
    else if(value.length===0)
    {
      callback(new Error('密码长度不能为空'))
    }else 
    {
      callback(new Error('密码长度不能大于15'))
    }
};
  const validatorUsername = (_:any, value: string, callback: any) => {
    //rule：即为校验规则对象
    //value：即为表单元素文本内容
    //函数：如果符合条件cal1Back放行
    //如果不符合条件cal1Back方法，注入错误提示信息
    if (value.length<=15&&value.length>0) {
      callback()
    }
    else if(value.length===0)
    {
      callback(new Error('用户名长度不能为空'))
    }else 
    {
      callback(new Error('用户名长度不能大于15'))
    }
  };
  const rules = {
    username: [
      {
        trigger: "blur",
        validator: validatorUsername,
      },
    ],
    password: [
      {
        trigger: "change",
        validator: validatorPassword,
      },
    ],
  };

 
  const login = async () => {
    await loginform.value.validate();
    try {
      loading.value = true;
      await useStore.login(form).then(() => {
        ElNotification({
          type: "success",
          message: "欢迎回来",
          title: "Hi," + greet,
        });
        setTimeout(() => {
          router.push("/");
        }, 1000);
      });
    } catch (error) {
      setTimeout(() => {
        loading.value = false;
      }, 500);
      ElNotification({
        type: "error",
        message: (error as Error).message,
      });
    }
  };
  function getTimeGreet() {
    let hours = new Date().getHours();
    let message = "";
    if (hours > 0 && hours < 5) message = "凌晨了，早点休息";
    else if (hours < 10) message = "早上好";
    else if (hours < 16) message = "下午好";
    else message = "晚上好";
    return message;
  }
  let greet = getTimeGreet();
</script>

<style scoped lang="scss">
  .login-container {
    width: 100%;
    height: 100vh;
    background: url("@/assets/image/loginbackground.jpg") no-repeat;
    background-size: cover;
  }
  .loginForm {
    position: relative;
    top: 30px;
    width: 60%;
    margin: 100px;
    padding: 50px;
    background-color: skyblue;
    border-radius: 3%;
    opacity: 0.9;
    loginInput {
      position: relative;
      width: 60%;
    }
    h1 {
      color: white;
      font-size: 40px;
      padding: 0 0 30px 0;
    }
    .loginButton {
      width: 100%;
      margin: 0 auto;
    }
  }
</style>
