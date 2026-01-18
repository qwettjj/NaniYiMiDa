/**
 * 登录页面
 * 提供用户登录功能
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { UserService } from '../service/UserService';
import { HttpUtil, ResultVO } from '../service/HttpUtil';
import { AppColors } from '../common';

@Entry
@Component
struct LoginPage {
  /** 手机号 */
  @State phone: string = '';
  /** 密码 */
  @State password: string = '';
  /** 是否正在登录 */
  @State isLoading: boolean = false;
  /** 是否显示密码相关的Logo */
  @State showPasswordLogo: boolean = false;
  /** 是否密码框获得焦点 */
  @State isPasswordFocused: boolean = false;

  aboutToAppear() {
    // 确保 HttpUtil 已初始化
    HttpUtil.init(getContext(this));
  }

  /**
   * 设置Logo状态
   */
  private setLogoState(isEditing: boolean): void {
    this.showPasswordLogo = isEditing;
  }

  /**
   * 重置Logo显示状态
   */
  private resetLogo(): void {
    this.showPasswordLogo = false;
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
    Stack() {
      // 背景渐变
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#FAF6F0')

      Scroll() {
        Column() {
          // 顶部返回栏
          Row() {
            // 返回按钮
            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Text('←')
                .fontSize(20)
                .fontColor('rgba(96, 47, 39, 0.7)')
            }
            .width(36)
            .height(36)
            .backgroundColor('rgba(250, 246, 240, 0.85)')
            .border({
              width: 1,
              color: 'rgba(96, 47, 39, 0.12)'
            })
            .borderRadius(12)
            .onClick(() => {
              // 跳转到用户详情页
              router.pushUrl({
                url: 'pages/Index'
              });
            })

            Blank()

            // 如果需要，可以在这里添加其他顶部元素，比如页面标题
            // Text('登录')
            //   .fontSize(16)
            //   .fontWeight(FontWeight.Bold)
            //   .fontColor('rgba(96, 47, 39, 0.88)')
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)

          // Logo 区域
          Image(this.showPasswordLogo ? $r('app.media.hide') : $r('app.media.login'))
            .width(108)
            .height(108)
            .objectFit(ImageFit.Contain)
            .margin({ top: 20, bottom: 24 }) // 调整上边距

          // 标题
          Column() {
            Text('欢迎回来~!')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('rgba(96, 47, 39, 0.88)')
              .margin({ bottom: 8 })

            Row() {
              Text('登录 ')
                .fontSize(13)
                .fontColor('rgba(96, 47, 39, 0.55)')
              Text('NaniYiMiDa')
                .fontSize(13)
                .fontColor('rgba(96, 47, 39, 0.72)')
                .fontWeight(FontWeight.Bold)
              Text(' , 马上开启美食之旅')
                .fontSize(13)
                .fontColor('rgba(96, 47, 39, 0.55)')
            }
            .margin({ bottom: 48 })
            .justifyContent(FlexAlign.Center)
            .width('100%')
          }
          .alignItems(HorizontalAlign.Center)
          .width('100%')

          // 表单区域
          Column() {
            // 手机号输入框
            Column() {
              Text('手机号')
                .fontSize(13)
                .fontColor('rgba(96, 47, 39, 0.70)')
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 8 })
                .width('100%')
                .textAlign(TextAlign.Start)

              TextInput({ placeholder: '请输入手机号', text: this.phone })
                .type(InputType.PhoneNumber)
                .width('100%')
                .height(52)
                .fontSize(14)
                .placeholderColor('rgba(96, 47, 39, 0.35)')
                .backgroundColor('rgba(250, 246, 240, 0.92)')
                .borderRadius(16)
                .padding({ left: 14, right: 14 })
                .border({ width: 1, color: 'rgba(96, 47, 39, 0.12)' })
                .onChange((value: string) => {
                  this.phone = value;
                })
                .onEditChange((isEditing: boolean) => {
                  if (isEditing) {
                    this.resetLogo();
                  }
                })
            }
            .width('100%')
            .margin({ bottom: 14 })

            // 密码输入框
            Column() {
              Text('密码')
                .fontSize(13)
                .fontColor('rgba(96, 47, 39, 0.70)')
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 8 })
                .width('100%')
                .textAlign(TextAlign.Start)

              TextInput({ placeholder: '请输入密码', text: this.password })
                .type(InputType.Password)
                .width('100%')
                .height(52)
                .fontSize(14)
                .placeholderColor('rgba(96, 47, 39, 0.35)')
                .backgroundColor('rgba(250, 246, 240, 0.92)')
                .borderRadius(16)
                .padding({ left: 14, right: 14 })
                .border({ width: 1, color: 'rgba(96, 47, 39, 0.12)' })
                .onChange((value: string) => {
                  this.password = value;
                })
                .onEditChange((isEditing: boolean) => {
                  this.isPasswordFocused = isEditing;
                  if (isEditing) {
                    this.setLogoState(true);
                  } else {
                    setTimeout(() => {
                      if (!this.isPasswordFocused && this.password.length === 0) {
                        this.setLogoState(false);
                      }
                    }, 50);
                  }
                })
            }
            .width('100%')
            .margin({ bottom: 14 })

            // 登录按钮
            Button(this.isLoading ? '登录中...' : '立即登录')
              .width('100%')
              .height(54)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .backgroundColor(this.isLoading ? AppColors.C30 : '#CB8E54')
              .borderRadius(22)
              .shadow({
                radius: 18,
                color: 'rgba(168, 88, 53, 0.28)',
                offsetY: 18
              })
              .enabled(!this.isLoading)
              .onClick(() => {
                this.handleLogin();
              })
              .margin({ bottom: 32 })

            // 注册提示
            Row() {
              Text('还没有账号？')
                .fontSize(13)
                .fontColor('rgba(96, 47, 39, 0.55)')

              Text('立即注册')
                .fontSize(13)
                .fontColor('rgba(168, 88, 53, 0.95)')
                .fontWeight(FontWeight.Bold)
                .margin({ left: 6 })
                .onClick(() => {
                  this.goToRegister();
                })
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .margin({ bottom: 32 })
          }
          .width('100%')
          .padding({ left: 24, right: 24 })

          // 底部协议（固定在底部）
          Column() {
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
            .justifyContent(FlexAlign.Center)
            .width('100%')
          }
          .width('100%')
          .margin({ top: 'auto', bottom: 32 }) // 自动上边距推到最下面
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start) // 改为从顶部开始排列
      }
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}