/**
 * 注册页面
 * 提供用户注册功能
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { UserService } from '../service/UserService';
import { HttpUtil, ResultVO } from '../service/HttpUtil';
import { UserVO } from '../model/UserModel';

@Entry
@Component
struct RegisterPage {
  /** 用户名 */
  @State userName: string = '';
  /** 手机号 */
  @State phoneNumber: string = '';
  /** 密码 */
  @State password: string = '';
  /** 确认密码 */
  @State confirmPassword: string = '';
  /** 是否正在注册 */
  @State isLoading: boolean = false;

  aboutToAppear() {
    // 确保 HttpUtil 已初始化
    HttpUtil.init(getContext(this));
  }

  /**
   * 校验输入
   * @returns 是否通过校验
   */
  private validateInput(): boolean {
    // 校验用户名非空
    if (!this.userName || this.userName.trim().length === 0) {
      promptAction.showToast({
        message: '请输入用户名',
        duration: 2000
      });
      return false;
    }

    // 校验用户名长度
    if (this.userName.trim().length < 2 || this.userName.trim().length > 20) {
      promptAction.showToast({
        message: '用户名长度需在2-20个字符之间',
        duration: 2000
      });
      return false;
    }

    // 校验手机号非空
    if (!this.phoneNumber || this.phoneNumber.trim().length === 0) {
      promptAction.showToast({
        message: '请输入手机号',
        duration: 2000
      });
      return false;
    }

    // 校验手机号格式（11位数字，以1开头）
    const phoneRegex = /^1[3-9]\d{9}$/;
    if (!phoneRegex.test(this.phoneNumber.trim())) {
      promptAction.showToast({
        message: '请输入正确的手机号',
        duration: 2000
      });
      return false;
    }

    // 校验密码非空
    if (!this.password || this.password.length === 0) {
      promptAction.showToast({
        message: '请输入密码',
        duration: 2000
      });
      return false;
    }

    // 校验密码长度
    if (this.password.length < 6 || this.password.length > 20) {
      promptAction.showToast({
        message: '密码长度需在6-20个字符之间',
        duration: 2000
      });
      return false;
    }

    // 校验确认密码
    if (!this.confirmPassword || this.confirmPassword.length === 0) {
      promptAction.showToast({
        message: '请确认密码',
        duration: 2000
      });
      return false;
    }

    // 校验两次密码是否一致
    if (this.password !== this.confirmPassword) {
      promptAction.showToast({
        message: '两次输入的密码不一致',
        duration: 2000
      });
      return false;
    }

    return true;
  }

  /**
   * 执行注册
   */
  private async handleRegister(): Promise<void> {
    // 确保在请求前初始化 Context
    const uiContext = this.getUIContext();
    HttpUtil.init(getContext(this));

    // 输入校验
    if (!this.validateInput()) {
      return;
    }

    this.isLoading = true;

    try {
      // 构建用户对象（按照 UserVO 结构）
      const userVO: UserVO = {
        userId: null,
        userName: this.userName.trim(),
        phoneNumber: this.phoneNumber.trim(),
        password: this.password,
        createTime: null,
        followerCount: null,
        followingCount: null,
        favouriteCount: null,
        imageUrl: null,
        role: null
      };

      const result: ResultVO<boolean> = await UserService.register(userVO);
      console.info('RegisterPage: 注册结果 -', JSON.stringify(result));

      if (result.code === 0 && result.data === true) {
        // 注册成功
        try {
          uiContext.getPromptAction().showToast({
            message: '注册成功，请登录',
            duration: 2000
          });
        } catch (e) {
          console.warn('RegisterPage: Toast 显示失败', e instanceof Error ? e.message : JSON.stringify(e));
        }

        // 延迟跳转到登录页
        setTimeout(() => {
          uiContext.runScopedTask(() => {
            router.back();
          });
        }, 1000);
      } else {
        // 注册失败（例如 409 手机号已存在）
        const errorMsg = result.message || '注册失败，请重试';
        console.warn('RegisterPage: 业务失败 -', errorMsg);
        try {
          uiContext.getPromptAction().showToast({
            message: errorMsg,
            duration: 2000
          });
        } catch (e) {
          console.warn('RegisterPage: Toast 显示失败', e instanceof Error ? e.message : JSON.stringify(e));
        }
      }
    } catch (error) {
      console.error('RegisterPage: 注册异常详情 -', JSON.stringify(error));
      let msg = '网络异常，请稍后重试';
      if (error && typeof error === 'object' && error['code'] === '100001') {
        msg = '系统弹窗异常，请重试';
      }
      try {
        uiContext.getPromptAction().showToast({
          message: msg,
          duration: 2000
        });
      } catch (e) {
        console.warn('RegisterPage: Toast 显示失败', e instanceof Error ? e.message : JSON.stringify(e));
      }
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 跳转到登录页
   */
  private goToLogin(): void {
    router.back();
  }

  build() {
    Column() {
      // 顶部返回按钮
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => {
            this.goToLogin();
          })

        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      // 标题区域
      Column() {
        Text('创建账号')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 8 })

        Text('加入 NaniYiMiDa 社区')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ bottom: 32 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 24, right: 24 })

      // 表单区域
      Column() {
        // 用户名输入框
        Column() {
          Text('用户名')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 })

          TextInput({ placeholder: '请输入用户名', text: this.userName })
            .type(InputType.Normal)
            .width('100%')
            .height(50)
            .fontSize(16)
            .placeholderColor('#CCCCCC')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.userName = value;
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 20 })

        // 手机号输入框
        Column() {
          Text('手机号')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 })

          TextInput({ placeholder: '请输入手机号', text: this.phoneNumber })
            .type(InputType.PhoneNumber)
            .width('100%')
            .height(50)
            .fontSize(16)
            .placeholderColor('#CCCCCC')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.phoneNumber = value;
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 20 })

        // 密码输入框
        Column() {
          Text('密码')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 })

          TextInput({ placeholder: '请输入密码（6-20位）', text: this.password })
            .type(InputType.Password)
            .width('100%')
            .height(50)
            .fontSize(16)
            .placeholderColor('#CCCCCC')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.password = value;
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 20 })

        // 确认密码输入框
        Column() {
          Text('确认密码')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 })

          TextInput({ placeholder: '请再次输入密码', text: this.confirmPassword })
            .type(InputType.Password)
            .width('100%')
            .height(50)
            .fontSize(16)
            .placeholderColor('#CCCCCC')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.confirmPassword = value;
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 32 })

        // 注册按钮
        Button(this.isLoading ? '注册中...' : '注册')
          .width('100%')
          .height(50)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.isLoading ? '#CCCCCC' : '#FF6B35')
          .borderRadius(25)
          .enabled(!this.isLoading)
          .onClick(() => {
            this.handleRegister();
          })
      }
      .width('100%')
      .padding({ left: 24, right: 24 })

      // 底部登录链接
      Row() {
        Text('已有账号？')
          .fontSize(14)
          .fontColor('#999999')

        Text('去登录')
          .fontSize(14)
          .fontColor('#FF6B35')
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.goToLogin();
          })
      }
      .margin({ top: 24 })

      // 占位，将内容往上推
      Blank()

      // 底部协议
      Row() {
        Text('注册即表示同意')
          .fontSize(12)
          .fontColor('#CCCCCC')

        Text('《用户协议》')
          .fontSize(12)
          .fontColor('#FF6B35')

        Text('和')
          .fontSize(12)
          .fontColor('#CCCCCC')

        Text('《隐私政策》')
          .fontSize(12)
          .fontColor('#FF6B35')
      }
      .margin({ bottom: 30 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
