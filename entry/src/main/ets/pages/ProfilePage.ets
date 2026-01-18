import { UserService } from '../service/UserService';
import { RecipeService } from '../service/RecipeService';
import { UserVO } from '../model/UserModel';
import { RecipeVO } from '../model/RecipeModel';
import router from '@ohos.router';
import { HttpUtil } from '../service/HttpUtil';
import { promptAction } from '@kit.ArkUI';

interface MyColors {
  BG: string;
  TEXT: string;
  MUTED: string;
  LINE: string;
  CARD_BG: string;
  PRIMARY: string;
  SECONDARY: string;
}

@Component
export struct ProfilePage {
  @State currentUser: UserVO | null = null;
  @State isLogin: boolean = false;
  @State drafts: RecipeVO[] = []; // 存储草稿列表
  @State isLoadingDrafts: boolean = false;

  readonly C: MyColors = {
    BG: '#FAF6F0',
    CARD_BG: '#F2E5D3',
    TEXT: '#602F27',
    MUTED: 'rgba(96,47,39,0.55)',
    LINE: 'rgba(96,47,39,0.10)',
    PRIMARY: '#CB8E54',
    SECONDARY: '#8E422F'
  };

  async aboutToAppear() {
    await this.checkLoginStatus();
    if (this.isLogin) {
      this.loadDrafts(); // 登录后自动加载草稿
    }
  }

  async checkLoginStatus() {
    const token = await HttpUtil.getToken();
    if (token) {
      const result = await UserService.getCurrentUser();
      if (result.code === 0 && result.data) {
        this.currentUser = result.data;
        this.isLogin = true;
      }
    }
  }

  /**
   * 获取草稿数据
   */
  async loadDrafts() {
    this.isLoadingDrafts = true;
    try {
      const result = await RecipeService.getCurrentUserDrafts();
      if (result.code === 0 && result.data) {
        this.drafts = result.data;
      }
    } catch (e) {
      console.error('加载草稿失败', e);
    } finally {
      this.isLoadingDrafts = false;
    }
  }

  /**
   * 删除草稿逻辑
   */
  async deleteDraft(recipeId: number): Promise<void> {
    try {
      // 1. 调用删除接口
      const result = await RecipeService.deleteRecipe(recipeId);

      if (result.code === 0) {
        await this.loadDrafts();
        promptAction.showToast({ message: '草稿已删除' });


        // 方案 B：如果不想重新请求网络，也可以手动从本地数组中滤除（性能更高）
        // this.drafts = this.drafts.filter(item => item.recipeId !== recipeId);
      } else {
        promptAction.showToast({ message: result.message || '删除失败' });
      }
    } catch (e) {
      const errorMsg = e instanceof Error ? e.message : '删除失败';
      promptAction.showToast({ message: errorMsg });
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
    .backgroundColor(this.C.BG)
  }

  @Builder
  LoginView() {
    Scroll() {
      Column() {
        // --- 头部信息 ---
        Row() {
          Column() {
            Text(this.currentUser?.nickName || this.currentUser?.userName || '未知用户')
              .fontSize(32).fontWeight(900).fontColor(this.C.TEXT)
            Text(`生日：${this.currentUser?.birthday || '未设置'}`)
              .fontSize(14).fontColor(this.C.MUTED).margin({ top: 8 })
          }
          .alignItems(HorizontalAlign.Start).layoutWeight(1)

          Image(this.currentUser?.imageUrl || $r('app.media.startIcon'))
            .width(76).height(76).borderRadius(22)
            .border({ width: 1, color: this.C.LINE })
        }
        .width('100%').padding({ top: 40, bottom: 20 })

        // --- 会员卡片 ---
        Row() {
          Text('开通何异味会员').fontWeight(900).fontColor(this.C.TEXT)
          Text('最低 0.3元/天').fontSize(13).fontWeight(800).fontColor(this.C.SECONDARY)
            .backgroundColor('rgba(255,255,255,0.6)').padding({ left: 12, right: 12, top: 8, bottom: 8 }).borderRadius(999)
        }
        .width('100%').padding(16).backgroundColor(this.C.CARD_BG).borderRadius(22).margin({ bottom: 25 })

        // --- 统计项（点击关注跳转） ---
        Row() {
          this.StatItem('关注', this.currentUser?.followingCount?.toString() || '0', () => {
            router.pushUrl({ url: 'pages/FollowingPage' });
          })
          this.StatItem('粉丝', this.currentUser?.followerCount?.toString() || '0', () => {})
          this.StatItem('收藏', this.currentUser?.favouriteCount?.toString() || '0', () => {
            router.pushUrl({ url: 'pages/FavoritesPage' });
          })
        }
        .width('100%').margin({ bottom: 30 })

        // --- 我的草稿区域 ---
        Column() {
          Row() {
            Text('我的草稿')
              .fontSize(18).fontWeight(900).fontColor(this.C.TEXT)
            Blank()
            if (this.isLoadingDrafts) {
              LoadingProgress().width(20).height(20).color(this.C.PRIMARY)
            }
          }.width('100%').margin({ bottom: 15 })

          if (this.drafts.length > 0) {
            // 草稿列表展示
            List({ space: 12 }) {
              ForEach(this.drafts, (item: RecipeVO) => {
                ListItem() {
                  Row() {
                    Image(item.imageUrls?.[0] || $r('app.media.startIcon'))
                      .width(80).height(80).borderRadius(16).objectFit(ImageFit.Cover)

                    Column() {
                      Text(item.title || '未命名草稿')
                        .fontSize(16).fontWeight(900).fontColor(this.C.TEXT).maxLines(1)
                      Text(item.description || '暂无描述')
                        .fontSize(13).fontColor(this.C.MUTED).margin({ top: 4 }).maxLines(1)

                      Row({ space: 10 }) {
                        Text('编辑').fontSize(12).fontColor(this.C.PRIMARY).fontWeight(700)
                          .onClick(() => {
                            // 跳转编辑页逻辑
                            promptAction.showToast({ message: '编辑功能待对接' });
                          })
                        Text('删除').fontSize(12).fontColor(this.C.SECONDARY).fontWeight(700)
                          .onClick(() => this.deleteDraft(item.recipeId!))
                      }.margin({ top: 8 })
                    }
                    .layoutWeight(1).margin({ left: 12 }).alignItems(HorizontalAlign.Start)
                  }
                  .padding(12).backgroundColor(this.C.CARD_BG).borderRadius(20).width('100%')
                }
              })
            }.width('100%')
          } else {
            // 空状态
            Column() {
              Text('暂无草稿食谱').fontSize(16).fontWeight(900).fontColor(this.C.TEXT)
              Text('去发布页面创作你的第一道菜吧').fontSize(14).fontColor(this.C.MUTED).margin({ top: 8 })
            }.width('100%').margin({ top: 40 })
          }
        }

        // 退出登录
        Text('退出登录')
          .fontSize(14).fontColor(this.C.MUTED).margin({ top: 60, bottom: 40 })
          .onClick(async () => {
            await HttpUtil.clearToken();
            this.isLogin = false;
            router.replaceUrl({ url: 'pages/LoginPage' });
          })
      }
      .padding({ left: 20, right: 20 })
    }
    .scrollBar(BarState.Off)
  }

  @Builder
  StatItem(label: string, value: string, callback: () => void) {
    Column() {
      Text(value).fontSize(20).fontWeight(900).fontColor(this.C.TEXT)
      Text(label).fontSize(12).fontColor(this.C.MUTED).margin({ top: 4 })
    }
    .layoutWeight(1)
    .onClick(callback)
  }

  @Builder
  UnLoginView() {
    Column() {
      Image($r('app.media.unlog'))           // 使用和HTML相同的图片路径
        .width(155)                       // HTML中图片宽度185px
        .height(155)                      // 保持宽高一致
        .objectFit(ImageFit.Cover)        // 覆盖填充
        .borderRadius(16)                 // HTML中border-radius: 16px
        .opacity(0.95)
      Text('加入何异味厨房').fontSize(22).fontWeight(900).fontColor(this.C.TEXT)
      Button('立即登录 / 注册')
        .width('100%').height(54).margin({ top: 30 })
        .fontSize(16).fontWeight(900).fontColor('#FAF6F0')
        .backgroundColor(this.C.SECONDARY).borderRadius(18)
        .onClick(() => router.pushUrl({ url: 'pages/LoginPage' }))
    }
    .width('100%').height('100%').padding(40).justifyContent(FlexAlign.Center)
  }
}