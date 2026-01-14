import { UserService } from '../service/UserService';
import { UserVO } from '../model/UserModel';
import router from '@ohos.router';
import { HttpUtil } from '../service/HttpUtil';
import { AppColors, AppFonts, AppSpacing, AppRadius } from '../common/theme';

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
    .backgroundColor(AppColors.BG_SECONDARY)
  }

  @Builder
  LoginView() {
    Scroll() {
      Column({ space: AppSpacing.LG }) {
        // 顶部用户信息卡片（带渐变背景）
        Column() {
          // 头像和基本信息
          Column({ space: AppSpacing.MD }) {
            // 头像（带边框和阴影）
            Stack() {
              Image(this.currentUser?.imageUrl || $r('app.media.startIcon'))
                .width(100)
                .height(100)
                .borderRadius(AppRadius.ROUND)
                .objectFit(ImageFit.Cover)
              
              // 头像边框
              Circle()
                .width(100)
                .height(100)
                .fill('transparent')
                .stroke(AppColors.BG_PRIMARY)
                .strokeWidth(4)
            }
            .shadow({
              radius: 16,
              color: AppColors.SHADOW_DARK,
              offsetY: 4
            })

            // 昵称
            Text(this.currentUser?.nickName || this.currentUser?.userName || '用户')
              .fontSize(AppFonts.HEADING_2)
              .fontWeight(AppFonts.WEIGHT_BOLD)
              .fontColor(AppColors.TEXT_INVERSE)

            // 签名
            Text(this.currentUser?.signature || '这个人很懒，还没有签名~')
              .fontSize(AppFonts.BODY)
              .fontColor(`${AppColors.TEXT_INVERSE}CC`)
              .maxLines(2)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding({ top: AppSpacing.XXXL, bottom: AppSpacing.XXL })
        }
        .width('100%')
        .linearGradient({
          angle: 135,
          colors: [
            [AppColors.PRIMARY_LIGHT, 0.0],
            [AppColors.PRIMARY, 1.0]
          ]
        })
        .borderRadius({ bottomLeft: AppRadius.XXL, bottomRight: AppRadius.XXL })

        // 统计卡片
        Row({ space: AppSpacing.MD }) {
          Column({ space: AppSpacing.SM }) {
            Text('👥')
              .fontSize(AppFonts.HEADING_3)

            Text(this.currentUser?.followingCount?.toString() || '0')
              .fontSize(AppFonts.HEADING_3)
              .fontWeight(AppFonts.WEIGHT_BOLD)
              .fontColor(AppColors.TEXT_PRIMARY)

            Text('关注')
              .fontSize(AppFonts.BODY_SMALL)
              .fontColor(AppColors.TEXT_SECONDARY)
          }
          .width('100%')
          .layoutWeight(1)
          .padding(AppSpacing.LG)
          .backgroundColor(AppColors.BG_PRIMARY)
          .borderRadius(AppRadius.XL)
          .shadow({
            radius: 12,
            color: AppColors.SHADOW_MEDIUM,
            offsetY: 2
          })
          .onClick(() => {
            router.pushUrl({ url: 'pages/FollowingPage' });
          })

          Column({ space: AppSpacing.SM }) {
            Text('⭐')
              .fontSize(AppFonts.HEADING_3)

            Text(this.currentUser?.followerCount?.toString() || '0')
              .fontSize(AppFonts.HEADING_3)
              .fontWeight(AppFonts.WEIGHT_BOLD)
              .fontColor(AppColors.TEXT_PRIMARY)

            Text('粉丝')
              .fontSize(AppFonts.BODY_SMALL)
              .fontColor(AppColors.TEXT_SECONDARY)
          }
          .width('100%')
          .layoutWeight(1)
          .padding(AppSpacing.LG)
          .backgroundColor(AppColors.BG_PRIMARY)
          .borderRadius(AppRadius.XL)
          .shadow({
            radius: 12,
            color: AppColors.SHADOW_MEDIUM,
            offsetY: 2
          })
          .onClick(() => {
            console.info('粉丝列表功能待开发');
          })

          Column({ space: AppSpacing.SM }) {
            Text('❤️')
              .fontSize(AppFonts.HEADING_3)

            Text(this.currentUser?.favouriteCount?.toString() || '0')
              .fontSize(AppFonts.HEADING_3)
              .fontWeight(AppFonts.WEIGHT_BOLD)
              .fontColor(AppColors.TEXT_PRIMARY)

            Text('收藏')
              .fontSize(AppFonts.BODY_SMALL)
              .fontColor(AppColors.TEXT_SECONDARY)
          }
          .width('100%')
          .layoutWeight(1)
          .padding(AppSpacing.LG)
          .backgroundColor(AppColors.BG_PRIMARY)
          .borderRadius(AppRadius.XL)
          .shadow({
            radius: 12,
            color: AppColors.SHADOW_MEDIUM,
            offsetY: 2
          })
          .onClick(() => {
            router.pushUrl({ url: 'pages/FavoritesPage' });
          })
        }
        .width('100%')
        .padding({ left: AppSpacing.LG, right: AppSpacing.LG })
        .margin({ top: -AppSpacing.XXL })

        // 个人信息卡片
        Column({ space: 0 }) {
          this.InfoItem('🎂 生日', this.currentUser?.birthday || '未设置', true)
          this.InfoItem('🚫 过敏原', this.currentUser?.allergens || '无', false)
        }
        .width('100%')
        .backgroundColor(AppColors.BG_PRIMARY)
        .borderRadius(AppRadius.XL)
        .margin({ left: AppSpacing.LG, right: AppSpacing.LG })
        .shadow({
          radius: 12,
          color: AppColors.SHADOW_MEDIUM,
          offsetY: 2
        })

        // 功能按钮区
        Column({ space: AppSpacing.MD }) {
          // 编辑个人信息按钮
          Row({ space: AppSpacing.MD }) {
            Text('✏️ 编辑个人信息')
              .fontSize(AppFonts.BODY_LARGE)
              .fontColor(AppColors.TEXT_INVERSE)
              .fontWeight(AppFonts.WEIGHT_MEDIUM)
          }
          .width('100%')
          .height(52)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(AppColors.PRIMARY)
          .borderRadius(AppRadius.LG)
          .shadow({
            radius: 8,
            color: `${AppColors.PRIMARY}40`,
            offsetY: 2
          })
          .onClick(() => {
            router.pushUrl({ url: 'pages/ProfileEditPage' });
          })
          
          // 我的草稿按钮
          Row({ space: AppSpacing.MD }) {
            Text('📝 我的草稿')
              .fontSize(AppFonts.BODY_LARGE)
              .fontColor(AppColors.TEXT_INVERSE)
              .fontWeight(AppFonts.WEIGHT_MEDIUM)
          }
          .width('100%')
          .height(52)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(AppColors.ACCENT)
          .borderRadius(AppRadius.LG)
          .shadow({
            radius: 8,
            color: `${AppColors.ACCENT}40`,
            offsetY: 2
          })
          .onClick(() => {
            router.pushUrl({ url: 'pages/DraftPage' });
          })
          
          // 浏览历史按钮
          Row({ space: AppSpacing.MD }) {
            Text('🕐 浏览历史')
              .fontSize(AppFonts.BODY_LARGE)
              .fontColor(AppColors.TEXT_INVERSE)
              .fontWeight(AppFonts.WEIGHT_MEDIUM)
          }
          .width('100%')
          .height(52)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(AppColors.INFO)
          .borderRadius(AppRadius.LG)
          .shadow({
            radius: 8,
            color: `${AppColors.INFO}40`,
            offsetY: 2
          })
          .onClick(() => {
            router.pushUrl({ url: 'pages/HistoryPage' });
          })
          
          // 退出登录按钮
          Row({ space: AppSpacing.MD }) {
            Text('🚪 退出登录')
              .fontSize(AppFonts.BODY_LARGE)
              .fontColor(AppColors.TEXT_INVERSE)
              .fontWeight(AppFonts.WEIGHT_MEDIUM)
          }
          .width('100%')
          .height(52)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(AppColors.ERROR)
          .borderRadius(AppRadius.LG)
          .shadow({
            radius: 8,
            color: `${AppColors.ERROR}40`,
            offsetY: 2
          })
          .onClick(async () => {
            await HttpUtil.clearToken();
            this.isLogin = false;
            this.currentUser = null;
            router.replaceUrl({ url: 'pages/LoginPage' });
          })
        }
        .width('100%')
        .padding({ left: AppSpacing.LG, right: AppSpacing.LG, bottom: AppSpacing.XXL })
      }
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  UnLoginView() {
    Column({ space: AppSpacing.XXL }) {
      // 图标
      Text('👤')
        .fontSize(80)

      // 提示文字
      Column({ space: AppSpacing.SM }) {
        Text('您尚未登录')
          .fontSize(AppFonts.HEADING_2)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(AppFonts.WEIGHT_BOLD)

        Text('登录后可查看个人信息和收藏')
          .fontSize(AppFonts.BODY)
          .fontColor(AppColors.TEXT_SECONDARY)
      }

      // 登录按钮
      Button('立即登录')
        .width(200)
        .height(48)
        .fontSize(AppFonts.BODY_LARGE)
        .fontColor(AppColors.TEXT_INVERSE)
        .backgroundColor(AppColors.PRIMARY)
        .borderRadius(AppRadius.XXL)
        .shadow({
          radius: 8,
          color: `${AppColors.PRIMARY}50`,
          offsetY: 4
        })
        .onClick(() => {
          router.pushUrl({ url: 'pages/LoginPage' });
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 信息项组件
   */
  @Builder
  InfoItem(label: string, value: string, showDivider: boolean) {
    Row() {
      Text(label)
        .fontSize(AppFonts.BODY_LARGE)
        .fontColor(AppColors.TEXT_PRIMARY)

      Blank()

      Text(value)
        .fontSize(AppFonts.BODY)
        .fontColor(AppColors.TEXT_SECONDARY)
    }
    .width('100%')
    .height(56)
    .padding({ left: AppSpacing.LG, right: AppSpacing.LG })
    .border({
      width: { bottom: showDivider ? 1 : 0 },
      color: AppColors.BORDER_LIGHT
    })
  }
}
