/**
 * 注册页面
 * 提供用户注册功能
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { UserService } from '../service/UserService';
import { HttpUtil, ResultVO } from '../service/HttpUtil';
import { UserVO } from '../model/UserModel';
import { AppColors } from '../common';

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

  // 新增状态用于Logo切换
  @State showPasswordLogo: boolean = false;
  @State isPasswordFocused: boolean = false;
  @State isConfirmPasswordFocused: boolean = false;
  @State showPassword: boolean = false;
  @State showConfirmPassword: boolean = false;
  @State lastActivePasswordField: number = 0; // 0=无, 1=密码, 2=确认密码

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

  private updateLogoState(): void {
    // 如果任意一个密码框有焦点或内容，显示密码Logo
    const hasPasswordFocus = this.isPasswordFocused || this.isConfirmPasswordFocused;
    const hasPasswordContent = this.password.length > 0 || this.confirmPassword.length > 0;

    this.showPasswordLogo = hasPasswordFocus || hasPasswordContent;
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
    Stack() {
      // 渐变背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundImage(
          `linear-gradient(180deg, ${AppColors.C10} 0%, ${AppColors.C20} 100%)`
        )

      Scroll() {
        Column() {
          // 顶部返回按钮
          Row() {
            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Text('←')
                .fontSize(18)
            }
            .width(36)
            .height(36)
            .backgroundColor('rgba(250, 246, 240, 0.85)')
            .border({
              width: 1,
              color: 'rgba(96, 47, 39, 0.10)'
            })
            .borderRadius(12)
            .onClick(() => {
              this.goToLogin();
            })

            Blank()
          }
          .width('100%')
          .padding({ top: 6, bottom: 8 })

          // 标题区域和Logo并排
          Row() {
            Column() {
              Text('创建账号')
                .fontSize(30)
                .fontWeight(FontWeight.Bold)
                .fontColor('rgba(96, 47, 39, 0.92)')
                .margin({ bottom: 8 })

              Text('加入 NaniYiMiDa 社区')
                .fontSize(13)
                .fontColor('rgba(96, 47, 39, 0.55)')
            }
            .layoutWeight(1)

            Image(this.showPasswordLogo ? $r('app.media.hide') : $r('app.media.register'))
              .width(108)
              .height(108)
              .objectFit(ImageFit.Contain)
              .margin({ right: 26 })
          }
          .width('100%')
          .padding({ bottom: 6 })

          // 表单区域
          Column() {
            // 用户名输入框
            Column() {
              Text('用户名')
                .fontSize(13)
                .fontColor('rgba(96, 47, 39, 0.70)')
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 8 })
                .width('100%')

              TextInput({ placeholder: '请输入用户名', text: this.userName })
                .type(InputType.Normal)
                .width('100%')
                .height(52)
                .fontSize(14)
                .placeholderColor('rgba(96, 47, 39, 0.32)')
                .backgroundColor('rgba(250, 246, 240, 0.92)')
                .borderRadius(16)
                .padding({ left: 14, right: 14 })
                .border({ width: 1, color: 'rgba(96, 47, 39, 0.12)' })
                .shadow({
                  radius: 10,
                  color: 'rgba(96, 47, 39, 0.06)',
                  offsetY: 10
                })
                .onChange((value: string) => {
                  this.userName = value;
                })
            }
            .width('100%')
            .margin({ bottom: 14 })

            // 手机号输入框
            Column() {
              Text('手机号')
                .fontSize(13)
                .fontColor('rgba(96, 47, 39, 0.70)')
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 8 })
                .width('100%')

              TextInput({ placeholder: '请输入手机号', text: this.phoneNumber })
                .type(InputType.PhoneNumber)
                .width('100%')
                .height(52)
                .fontSize(14)
                .placeholderColor('rgba(96, 47, 39, 0.32)')
                .backgroundColor('rgba(250, 246, 240, 0.92)')
                .borderRadius(16)
                .padding({ left: 14, right: 14 })
                .border({ width: 1, color: 'rgba(96, 47, 39, 0.12)' })
                .shadow({
                  radius: 10,
                  color: 'rgba(96, 47, 39, 0.06)',
                  offsetY: 10
                })
                .onChange((value: string) => {
                  this.phoneNumber = value;
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

              Stack() {
                TextInput({ placeholder: '请输入密码（6~20位）', text: this.password })
                  .type(this.showPassword ? InputType.Normal : InputType.Password)
                  .width('100%')
                  .height(52)
                  .fontSize(14)
                  .placeholderColor('rgba(96, 47, 39, 0.32)')
                  .backgroundColor('rgba(250, 246, 240, 0.92)')
                  .borderRadius(16)
                  .padding({ left: 14, right: 56 })
                  .border({ width: 1, color: 'rgba(96, 47, 39, 0.12)' })
                  .shadow({
                    radius: 10,
                    color: 'rgba(96, 47, 39, 0.06)',
                    offsetY: 10
                  })
                  .onChange((value: string) => {
                    this.password = value;
                    this.updateLogoState();
                  })
                  .onEditChange((isEditing: boolean) => {
                    this.isPasswordFocused = isEditing;
                    if (isEditing) {
                      this.lastActivePasswordField = 1;
                    }
                    this.updateLogoState();

                    if (!isEditing) {
                      setTimeout(() => {
                        this.updateLogoState();
                      }, 100);
                    }
                  })

                // 正确位置的眼睛图标
                Column() {
                  Button({ type: ButtonType.Normal, stateEffect: false }) {
                    Text(this.showPassword ? '🙈' : '👁️')
                      .fontSize(14)
                  }
                  .width(34)
                  .height(34)
                  .backgroundColor('rgba(242, 229, 211, 0.55)')
                  .border({
                    width: 1,
                    color: 'rgba(96, 47, 39, 0.10)'
                  })
                  .borderRadius(10)
                  .onClick(() => {
                    this.showPassword = !this.showPassword;
                    this.lastActivePasswordField = 1;
                    this.updateLogoState();
                  })
                }
                .width(34)
                .height(34)
                .position({ x: '100%', y: '50%' })
                .translate({ x: -44, y: -17 })
              }
              .width('100%')
              .height(52)
            }
            .width('100%')
            .margin({ bottom: 14 })

            // 确认密码输入框
            Column() {
              Text('确认密码')
                .fontSize(13)
                .fontColor('rgba(96, 47, 39, 0.70)')
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 8 })
                .width('100%')

              Stack() {
                TextInput({ placeholder: '请再次输入密码', text: this.confirmPassword })
                  .type(this.showConfirmPassword ? InputType.Normal : InputType.Password)
                  .width('100%')
                  .height(52)
                  .fontSize(14)
                  .placeholderColor('rgba(96, 47, 39, 0.32)')
                  .backgroundColor('rgba(250, 246, 240, 0.92)')
                  .borderRadius(16)
                  .padding({ left: 14, right: 56 })
                  .border({ width: 1, color: 'rgba(96, 47, 39, 0.12)' })
                  .shadow({
                    radius: 10,
                    color: 'rgba(96, 47, 39, 0.06)',
                    offsetY: 10
                  })
                  .onChange((value: string) => {
                    this.confirmPassword = value;
                    this.updateLogoState();
                  })
                  .onEditChange((isEditing: boolean) => {
                    this.isConfirmPasswordFocused = isEditing;
                    if (isEditing) {
                      this.lastActivePasswordField = 2;
                    }
                    this.updateLogoState();

                    if (!isEditing) {
                      setTimeout(() => {
                        this.updateLogoState();
                      }, 100);
                    }
                  })

                // 正确位置的眼睛图标
                Column() {
                  Button({ type: ButtonType.Normal, stateEffect: false }) {
                    Text(this.showConfirmPassword ? '🙈' : '👁️')
                      .fontSize(14)
                  }
                  .width(34)
                  .height(34)
                  .backgroundColor('rgba(242, 229, 211, 0.55)')
                  .border({
                    width: 1,
                    color: 'rgba(96, 47, 39, 0.10)'
                  })
                  .borderRadius(10)
                  .onClick(() => {
                    this.showConfirmPassword = !this.showConfirmPassword;
                    this.lastActivePasswordField = 2;
                    this.updateLogoState();
                  })
                }
                .width(34)
                .height(34)
                .position({ x: '100%', y: '50%' })
                .translate({ x: -44, y: -17 })
              }
              .width('100%')
              .height(52)
            }
            .width('100%')
            .margin({ bottom: 14 })

            // 注册按钮
            Button(this.isLoading ? '注册中...' : '注册')
              .width('100%')
              .height(54)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .backgroundColor(this.isLoading ? 'rgba(203, 142, 84, 0.5)' : '#CB8E54')
              .backgroundImage(this.isLoading ? undefined :
                `linear-gradient(180deg, ${AppColors.C50} 0%, ${AppColors.C70} 100%)`)
              .borderRadius(22)
              .shadow({
                radius: 18,
                color: 'rgba(168, 88, 53, 0.28)',
                offsetY: 18
              })
              .enabled(!this.isLoading)
              .onClick(() => {
                this.handleRegister();
              })
              .margin({ top: 10 })

            // 已有账号链接
            Row() {
              Text('已有账号？')
                .fontSize(13)
                .fontColor('rgba(96, 47, 39, 0.55)')

              Text('去登录')
                .fontSize(13)
                .fontColor('rgba(168, 88, 53, 0.95)')
                .fontWeight(FontWeight.Bold)
                .margin({ left: 6 })
                .onClick(() => {
                  this.goToLogin();
                })
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .margin({ top: 10 })

            // 协议文本
            Row() {
              Text('注册即表示同意')
                .fontSize(11)
                .fontColor('rgba(96, 47, 39, 0.40)')

              Text('《用户协议》')
                .fontSize(11)
                .fontColor('rgba(168, 88, 53, 0.90)')
                .fontWeight(FontWeight.Bold)
                .onClick(() => {
                  // 打开用户协议
                })

              Text('和')
                .fontSize(11)
                .fontColor('rgba(96, 47, 39, 0.40)')

              Text('《隐私政策》')
                .fontSize(11)
                .fontColor('rgba(168, 88, 53, 0.90)')
                .fontWeight(FontWeight.Bold)
                .onClick(() => {
                  // 打开隐私政策
                })
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .margin({ top: 24 })
            .padding({ left: 10, right: 10 })
          }
          .width('100%')
          .padding({ left: 22, right: 22 })
        }
        .width('100%')
        .padding({ top: 14, bottom: 22 })
      }
      .scrollBar(BarState.Off)
      .onClick(() => {
        // 点击页面其他地方时检查
        this.updateLogoState();
      })
    }
    .width('100%')
    .height('100%')
    .onClick(() => {
      // 点击页面其他地方时检查
      this.updateLogoState();
    })
  }
}
