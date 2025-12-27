import { router, promptAction } from '@kit.ArkUI';
import { UserService } from '../service/UserService';
import { UserVO } from '../model/UserModel';
import { HttpUtil } from '../service/HttpUtil';

@Entry
@Component
struct FollowingPage {
  @State followings: UserVO[] = [];
  @State isLoading: boolean = false;

  async aboutToAppear() {
    HttpUtil.init(getContext(this));
    await this.loadFollowings();
  }

  async loadFollowings() {
    this.isLoading = true;
    try {
      const result = await UserService.getMyFollowings();
      if (result.code === 0 && result.data) {
        this.followings = result.data;
      } else {
        this.getUIContext().getPromptAction().showToast({ message: result.message || '获取关注列表失败' });
      }
    } catch (e) {
      console.error('FollowingPage: 加载失败', JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // Header
      Row() {
        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })
        Text('我的关注')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 10 })
      }
      .width('100%')
      .padding(15)
      .backgroundColor(Color.White)

      if (this.isLoading) {
        LoadingProgress().width(50).height(50).margin({ top: 100 })
      } else if (this.followings.length === 0) {
        this.EmptyState()
      } else {
        List() {
          ForEach(this.followings, (user: UserVO) => {
            ListItem() {
              this.UserItem(user)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  UserItem(user: UserVO) {
    Row() {
      Image(user.imageUrl || $r('app.media.startIcon'))
        .width(50)
        .height(50)
        .borderRadius(25)
      
      Column() {
        Text(user.nickName || user.userName || '用户')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
        Text(user.signature || '暂无签名')
          .fontSize(12)
          .fontColor(Color.Gray)
          .margin({ top: 4 })
      }
      .margin({ left: 15 })
      .alignItems(HorizontalAlign.Start)
      
      Blank()
      
      Button('已关注')
        .fontSize(12)
        .height(30)
        .backgroundColor('#E0E0E0')
        .fontColor(Color.Gray)
        .onClick(async () => {
          if (user.userId) {
            const res = await UserService.unfollowUser(user.userId);
            if (res.code === 0) {
              this.loadFollowings();
            }
          }
        })
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .border({ width: { bottom: 1 }, color: '#F0F0F0' })
  }

  @Builder
  EmptyState() {
    Column() {
      Text('暂无关注')
        .fontSize(18)
        .fontColor(Color.Gray)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
