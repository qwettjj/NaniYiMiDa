import { router, promptAction } from '@kit.ArkUI';
import { UserService } from '../service/UserService';
import { UserVO } from '../model/UserModel';
import { HttpUtil } from '../service/HttpUtil';

@CustomDialog
struct PasswordDialog {
  controller?: CustomDialogController
  @State oldPass: string = '';
  @State newPass: string = '';
  confirm: (old: string, newP: string) => void = (o: string, n: string): void => {};

  build() {
    Column() {
      Text('修改密码').fontSize(18).fontWeight(FontWeight.Bold).margin({bottom: 20})
      TextInput({ placeholder: '旧密码' })
        .type(InputType.Password)
        .onChange((val: string) => { this.oldPass = val })
        .margin({bottom: 10})
        .width('100%')
        .height(40)
      TextInput({ placeholder: '新密码' })
        .type(InputType.Password)
        .onChange((val: string) => { this.newPass = val })
        .margin({bottom: 20})
        .width('100%')
        .height(40)
      Row() {
        Button('取消')
          .onClick(() => {
            if (this.controller) {
              this.controller.close()
            }
          })
          .backgroundColor('#F5F5F5')
          .fontColor('#666666')
          .width('40%')
          .margin({right: 10})
        Button('确认')
          .onClick(() => {
            if (this.newPass.length < 6) {
               promptAction.showToast({ message: '密码长度不能少于6位' })
               return
            }
            this.confirm(this.oldPass, this.newPass)
            if (this.controller) {
              this.controller.close()
            }
          })
          .backgroundColor('#1698CE')
          .width('40%')
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .width('80%')
  }
}

@Entry
@Component
struct ProfileEditPage {
  @State currentUser: UserVO | null = null;
  @State nickName: string = '';
  @State signature: string = '';
  @State birthday: string = '';
  @State allergens: string = '';
  @State isLoading: boolean = false;

  dialogController: CustomDialogController = new CustomDialogController({
    builder: PasswordDialog({
      confirm: (oldPass: string, newPass: string): void => {
        this.handlePasswordChange(oldPass, newPass)
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  async aboutToAppear(): Promise<void> {
    HttpUtil.init(getContext(this));
    await this.loadUserData();
  }

  async loadUserData(): Promise<void> {
    this.isLoading = true;
    try {
      const result = await UserService.getCurrentUser();
      if (result.code === 0 && result.data) {
        this.currentUser = result.data;
        this.nickName = result.data.nickName || result.data.userName || '';
        this.signature = result.data.signature || '';
        this.birthday = result.data.birthday || '';
        this.allergens = result.data.allergens || '';
      } else {
        this.getUIContext().getPromptAction().showToast({ message: '获取用户信息失败' });
      }
    } catch (e) {
      console.error('ProfileEditPage: 加载失败', e instanceof Error ? e.message : JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  async handlePasswordChange(oldPass: string, newPass: string): Promise<void> {
    if (!this.currentUser) return;
    
    this.isLoading = true;
    const updateData: UserVO = {
      userId: this.currentUser.userId,
      userName: this.currentUser.userName,
      phoneNumber: this.currentUser.phoneNumber,
      password: newPass,
      createTime: this.currentUser.createTime,
      followerCount: this.currentUser.followerCount,
      followingCount: this.currentUser.followingCount,
      favouriteCount: this.currentUser.favouriteCount,
      imageUrl: this.currentUser.imageUrl,
      role: this.currentUser.role,
      nickName: this.nickName,
      signature: this.signature,
      birthday: this.birthday,
      allergens: this.allergens
    };

    try {
      const result = await UserService.updateCurrentUser(updateData);
      if (result.code === 0) {
        promptAction.showToast({ message: '密码修改成功' });
      } else {
        promptAction.showToast({ message: result.message || '修改失败' });
      }
    } catch (e) {
      promptAction.showToast({ message: '网络异常' });
    } finally {
      this.isLoading = false;
    }
  }

  async handleSave(): Promise<void> {
    if (!this.currentUser) return;

    const uiContext = this.getUIContext();
    this.isLoading = true;
    const updateData: UserVO = {
      userId: this.currentUser.userId,
      userName: this.currentUser.userName,
      phoneNumber: this.currentUser.phoneNumber,
      password: this.currentUser.password,
      createTime: this.currentUser.createTime,
      followerCount: this.currentUser.followerCount,
      followingCount: this.currentUser.followingCount,
      favouriteCount: this.currentUser.favouriteCount,
      imageUrl: this.currentUser.imageUrl,
      role: this.currentUser.role,
      nickName: this.nickName,
      signature: this.signature,
      birthday: this.birthday,
      allergens: this.allergens
    };

    try {
      const result = await UserService.updateCurrentUser(updateData);
      if (result.code === 0) {
        try {
          uiContext.getPromptAction().showToast({ message: '保存成功' });
        } catch (toastError) {
          console.warn('ProfileEditPage: Toast 显示失败', JSON.stringify(toastError));
        }
        setTimeout(() => {
          uiContext.runScopedTask(() => {
            router.back();
          });
        }, 1000);
      } else {
        try {
          uiContext.getPromptAction().showToast({ message: result.message || '保存失败' });
        } catch (toastError) {
          console.warn('ProfileEditPage: Toast 显示失败', JSON.stringify(toastError));
        }
      }
    } catch (e) {
      try {
        uiContext.getPromptAction().showToast({ message: '网络异常' });
      } catch (toastError) {
        console.warn('ProfileEditPage: Toast 显示失败', JSON.stringify(toastError));
      }
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // Header
      Row() {
        Row() {
          Image($r('app.media.startIcon'))
            .width(20)
            .height(20)
            .margin({ right: 5 })
          Text('返回')
            .fontSize(16)
            .fontColor('#333333')
        }
        .onClick(() => {
          router.back();
        })

        Text('个人信息管理')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 40 }) // 平衡左侧宽度
        
        Text('保存')
          .fontSize(16)
          .fontColor('#1698CE')
          .onClick(() => this.handleSave())
      }
      .width('100%')
      .height(50)
      .padding({ left: 15, right: 15 })
      .backgroundColor(Color.White)
      .alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        LoadingProgress().width(50).height(50).margin({ top: 100 })
      } else {
        List() {
          ListItem() {
            this.EditItem('昵称', this.nickName, (val: string): void => { this.nickName = val })
          }
          ListItem() {
            this.EditItem('签名', this.signature, (val: string): void => { this.signature = val })
          }
          ListItem() {
            this.EditItem('生日', this.birthday, (val: string): void => { this.birthday = val }, 'YYYY-MM-DD')
          }
          ListItem() {
            this.EditItem('过敏原', this.allergens, (val: string): void => { this.allergens = val })
          }
          ListItem() {
             Row() {
              Text('密码')
                .width(80)
                .fontSize(16)
              Text('修改密码')
                .layoutWeight(1)
                .fontColor('#1698CE')
                .textAlign(TextAlign.End)
                .onClick(() => this.dialogController.open())
            }
            .width('100%')
            .padding({ left: 15, right: 15, top: 15, bottom: 15 })
            .border({ width: { bottom: 1 }, color: '#F0F0F0' })
            .backgroundColor(Color.White)
          }
        }
        .width('100%')
        .margin({ top: 10 })
        .backgroundColor(Color.White)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  EditItem(label: string, value: string, onChange: (val: string) => void, placeholder: string = '请输入') {
    Row() {
      Text(label)
        .width(80)
        .fontSize(16)
      TextInput({ text: value, placeholder: placeholder })
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .onChange(onChange)
    }
    .width('100%')
    .padding({ left: 15, right: 15, top: 5, bottom: 5 })
    .border({ width: { bottom: 1 }, color: '#F0F0F0' })
  }
}
