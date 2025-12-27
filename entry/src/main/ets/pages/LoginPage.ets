/**
 * 登录页面
 * 提供用户登录功能
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { UserService } from '../service/UserService';
import { HttpUtil, ResultVO } from '../service/HttpUtil';

@Entry
@Component
struct LoginPage {
  /** 手机号 */
  @State phone: string = '';
  /** 密码 */
  @State password: string = '';
  /** 是否正在登录 */
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
    // 校验手机号非空
    if (!this.phone || this.phone.trim().length === 0) {
      promptAction.showToast({
        message: '请输入手机号',
        duration: 2000
      });
      return false;
    }

    // 校验手机号格式（简单校验11位数字）
    const phoneRegex = /^1[3-9]\d{9}$/;
    if (!phoneRegex.test(this.phone.trim())) {
      promptAction.showToast({
        message: '请输入正确的手机号',
        duration: 2000
      });
      return false;
    }

    // 校验密码非空
    if (!this.password || this.password.trim().length === 0) {
      promptAction.showToast({
        message: '请输入密码',
        duration: 2000
      });
      return false;
    }

    // 校验密码长度
    if (this.password.length < 6) {
      promptAction.showToast({
        message: '密码长度不能少于6位',
        duration: 2000
      });
      return false;
    }

    return true;
  }

  /**
   * 执行登录
   */
  private async handleLogin(): Promise<void> {
    // 确保在请求前初始化 Context
    const uiContext = this.getUIContext();
    HttpUtil.init(getContext(this));

    // 输入校验
    if (!this.validateInput()) {
      return;
    }

    this.isLoading = true;

    try {
      console.info('LoginPage: 开始登录请求...');
      const result: ResultVO<string> = await UserService.login(
        this.phone.trim(),
        this.password
      );
      console.info('LoginPage: 登录请求完成, 结果 -', JSON.stringify(result));

      if (result.code === 0 && result.data) {
        // 登录成功 (Token 已在 UserService 中保存)
        console.info('LoginPage: 登录成功，准备显示提示并跳转');

        try {
          uiContext.getPromptAction().showToast({
            message: '登录成功',
            duration: 1500
          });
        } catch (toastError) {
          console.warn('LoginPage: Toast 显示失败 (非致命) -', JSON.stringify(toastError));
        }

        // 跳转到主页
        setTimeout(() => {
          console.info('LoginPage: 执行页面跳转');
          uiContext.runScopedTask(() => {
            router.replaceUrl({
              url: 'pages/Index'
            });
          });
        }, 500);
      } else {
        // 登录失败
        console.warn('LoginPage: 登录失败业务错误 -', result.message);
        try {
          uiContext.getPromptAction().showToast({
            message: result.message || '登录失败，请重试',
            duration: 2000
          });
        } catch (toastError) {
          console.warn('LoginPage: Toast 显示失败 (非致命) -', JSON.stringify(toastError));
        }
      }
    } catch (error) {
      console.error('LoginPage: 登录过程捕获到异常 -', JSON.stringify(error));
      const err = error as Error;
      try {
        uiContext.getPromptAction().showToast({
          message: `登录失败: ${err.message || '网络异常'}`,
          duration: 2000
        });
      } catch (toastError) {
        console.warn('LoginPage: Toast 显示失败 (非致命) -', JSON.stringify(toastError));
      }
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 跳转到注册页
   */
  private goToRegister(): void {
    router.pushUrl({
      url: 'pages/RegisterPage'
    });
  }

  build() {
    Column() {
      // Logo 区域
      // 原本地图片（保留备用）
      // Image($r('app.media.startIcon'))
      //   .width(100)
      //   .height(100)
      //   .margin({ bottom: 20 })

      // 网络图片 Logo
      Image('https://lh3.googleusercontent.com/gg/AIJ2gl-VdXhHaNDZRnFJJr5QbmvIKzNZG9eq0IPfxrbhnfG0QGOlzBZMemg63exo8sh4jmYk3s8Nybvg0u6W6HzbkfJM0rht9jPbM-h7WI_Q6ieUSbtoK11ZejDUdQQXiV4_x0RFA4bBS9SRM0tTzqFWYTQVn5xKDyWUx6Y-3oXcErB0G4Kb8dn9=s1024-rj')
        .width(100)
        .height(100)
        .margin({ bottom: 20 })
        .objectFit(ImageFit.Contain)

      // 标题
      Text('欢迎登录')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 8 })

      Text('NaniYiMiDa 株式会社')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 40 })

      // 手机号输入框
      TextInput({ placeholder: '请输入手机号', text: this.phone })
        .type(InputType.PhoneNumber)
        .width('85%')
        .height(50)
        .fontSize(16)
        .placeholderColor('#CCCCCC')
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 16 })
        .onChange((value: string) => {
          this.phone = value;
        })

      // 密码输入框
      TextInput({ placeholder: '请输入密码', text: this.password })
        .type(InputType.Password)
        .width('85%')
        .height(50)
        .fontSize(16)
        .placeholderColor('#CCCCCC')
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 32 })
        .onChange((value: string) => {
          this.password = value;
        })

      // 登录按钮
      Button(this.isLoading ? '登录中...' : '登录')
        .width('85%')
        .height(50)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.isLoading ? '#CCCCCC' : '#FF6B35')
        .borderRadius(25)
        .enabled(!this.isLoading)
        .onClick(() => {
          this.handleLogin();
        })

      // 注册提示
      Row() {
        Text('还没有账号？')
          .fontSize(14)
          .fontColor('#999999')

        Text('立即注册')
          .fontSize(14)
          .fontColor('#FF6B35')
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.goToRegister();
          })
      }
      .margin({ top: 24 })

      // 底部协议
      Row() {
        Text('登录即表示同意')
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
      .margin({ top: 60 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
  }
}
