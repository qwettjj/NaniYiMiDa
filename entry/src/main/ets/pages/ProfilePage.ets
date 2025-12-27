import { UserService } from '../service/UserService';
import { UserVO } from '../model/UserModel';
import router from '@ohos.router';
import { HttpUtil } from '../service/HttpUtil';

@Component
export struct ProfilePage {
  @State currentUser: UserVO | null = null;
  @State isLogin: boolean = false;

  async aboutToAppear() {
    await this.checkLoginStatus();
  }

  async checkLoginStatus() {
    const token = await HttpUtil.getToken();
    if (token) {
      const result = await UserService.getCurrentUser();
      if (result.code === 0 && result.data) {
        this.currentUser = result.data;
        this.isLogin = true;
      } else {
        this.isLogin = false;
        this.currentUser = null;
      }
    } else {
      this.isLogin = false;
      this.currentUser = null;
    }
  }

  build() {
    Column() {
      if (this.isLogin && this.currentUser) {
        this.LoginView()
      } else {
        this.UnLoginView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  LoginView() {
    Column() {
      // User Info Section
      Row() {
        Image(this.currentUser?.imageUrl || $r('app.media.startIcon'))
          .width(80)
          .height(80)
          .borderRadius(40)
          .margin({ right: 20 })
          .backgroundColor(Color.Gray) // Fallback if image fails
        
        Column() {
          Text(this.currentUser?.nickName || this.currentUser?.userName || '用户')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 5 })
          
          Text(this.currentUser?.signature || '暂无个性签名')
            .fontSize(14)
            .fontColor(Color.Gray)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Color.White)

      // Stats Section
      Row() {
        this.StatItem(this.currentUser?.followingCount?.toString() || '0', '关注', () => {
           router.pushUrl({ url: 'pages/FollowingPage' });
        })
        this.StatItem(this.currentUser?.followerCount?.toString() || '0', '粉丝', () => {
           // No action specified for fans
        })
        this.StatItem(this.currentUser?.favouriteCount?.toString() || '0', '收藏', () => {
           router.pushUrl({ url: 'pages/FavoritesPage' });
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .padding({ top: 15, bottom: 15 })
      .backgroundColor(Color.White)
      .margin({ top: 10 })

      // Info List
      Column() {
        this.InfoItem('生日', this.currentUser?.birthday || '未设置')
        this.InfoItem('过敏原', this.currentUser?.allergens || '无')
      }
      .width('100%')
      .backgroundColor(Color.White)
      .margin({ top: 10 })

      // Buttons
      Button('个人信息管理')
        .width('90%')
        .height(50)
        .margin({ top: 20 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/ProfileEditPage' });
        })

      Button('退出登录')
        .width('90%')
        .height(50)
        .margin({ top: 10 })
        .backgroundColor(Color.Red)
        .onClick(async () => {
           await HttpUtil.clearToken();
           this.isLogin = false;
           this.currentUser = null;
           router.replaceUrl({ url: 'pages/LoginPage' });
        })
    }
  }

  @Builder
  UnLoginView() {
    Column() {
      Text('您尚未登录')
        .fontSize(20)
        .margin({ bottom: 20 })
      
      Button('去登录')
        .width('50%')
        .onClick(() => {
          router.pushUrl({ url: 'pages/LoginPage' });
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  StatItem(count: string, label: string, onClick?: () => void) {
    Column() {
      Text(count)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
      Text(label)
        .fontSize(14)
        .fontColor(Color.Gray)
        .margin({ top: 5 })
    }
    .onClick(() => {
      if (onClick) {
        onClick();
      }
    })
  }

  @Builder
  InfoItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(16)
      Text(value)
        .fontSize(16)
        .fontColor(Color.Gray)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(15)
    .border({ width: { bottom: 1 }, color: '#F0F0F0' })
  }
}
