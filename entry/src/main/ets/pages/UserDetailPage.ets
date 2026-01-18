import { router, promptAction } from '@kit.ArkUI';
import { UserService } from '../service/UserService';
import { RecipeService, PageResponse } from '../service/RecipeService';
import { UserVO } from '../model/UserModel';
import { RecipeVO } from '../model/RecipeModel';
import { HttpUtil } from '../service/HttpUtil';

@Entry
@Component
struct UserDetailPage {
  @State userId: number = 0;
  @State user: UserVO | null = null;
  @State recipes: RecipeVO[] = [];
  @State isLoading: boolean = true;
  @State isFollowing: boolean = false;
  @State currentPage: number = 0;
  private pageSize: number = 10;
  @State hasMore: boolean = true;

  // 对应 profile.html 的八色体系配色方案
  // readonly COLORS: Record<string, string> = {
  //   // BG: '#FAF6F0',
  //   // CARD_BG: '#F2E5D3',
  //   // TEXT: '#602F27',
  //   // MUTED: 'rgba(96,47,39,0.55)',
  //   // MUTED2: 'rgba(96,47,39,0.38)',
  //   // LINE: 'rgba(96,47,39,0.10)',
  //   // PRIMARY: '#A85835',
  //   // SECONDARY: '#8E422F'
  // };

  async aboutToAppear(): Promise<void> {
    HttpUtil.init(getContext(this));
    const params = router.getParams() as Record<string, Object>;
    if (params && params['userId']) {
      this.userId = params['userId'] as number;
      await this.loadUserInfo();
      await this.loadUserRecipes();
    } else {
      promptAction.showToast({ message: '参数错误' });
      setTimeout(() => router.back(), 1000);
    }
  }

  // ... (逻辑部分：loadUserInfo, checkFollowStatus, loadUserRecipes, toggleFollow 保持原样) ...

  /**
   * 加载用户信息
   */
  async loadUserInfo(): Promise<void> {
    this.isLoading = true;
    try {
      const result = await UserService.getCurrentUser();
      if (result.code === 0 && result.data) {
        this.user = result.data;
        await this.checkFollowStatus();
      }else {
        promptAction.showToast({ message: result.message || '获取用户信息失败' });
      }
    } catch (e) {
      console.error('加载失败', e);
      promptAction.showToast({ message: '网络异常' });
    } finally {
      this.isLoading = false;
    }
  }

  async checkFollowStatus(): Promise<void> {
    try {
      const result = await UserService.getMyFollowings();
      if (result.code === 0 && result.data) {
        this.isFollowing = result.data.some((u: UserVO) => u.userId === this.userId);
      }
    } catch (e) {}
  }

  async loadUserRecipes(isRefresh: boolean = true): Promise<void> {
    if (isRefresh) this.currentPage = 0;
    try {
      const result = await RecipeService.getUserRecipes(this.userId, undefined, this.currentPage, this.pageSize);
      if (result.code === 0 && result.data) {
        const pageData = result.data;
        this.recipes = isRefresh ? pageData.content : [...this.recipes, ...pageData.content];
        this.hasMore = !pageData.last;
        this.currentPage = pageData.number;
      }
    } catch (e) {}
  }

  async toggleFollow(): Promise<void> {
    try {
      const res = this.isFollowing ? await UserService.unfollowUser(this.userId) : await UserService.followUser(this.userId);
      if (res.code === 0) {
        this.isFollowing = !this.isFollowing;
        promptAction.showToast({ message: this.isFollowing ? '关注成功' : '已取消关注' });
      }
    } catch (e) {
      promptAction.showToast({ message: '操作失败' });
    }
  }

  goToRecipeDetail(recipeId: number | null): void {
    if (recipeId) router.pushUrl({ url: 'pages/RecipeDetailPage', params: { id: recipeId } });
  }

  build() {
    Column() {
      // 1. 顶部导航 (匹配 profile.html 极简风格)
      Row() {
        Text('⬅')
          .fontSize(20)
          .fontColor('#602F27')
          .onClick(() => router.back())
        Blank()
      }
      .width('100%')
      .height(44)
      .padding({ left: 18, right: 18 })

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(50).height(50).color('#A85835')
        }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.user) {
        Scroll() {
          Column() {
            // 2. 个人信息头部 (匹配 .profile-head)
            Row() {
              Column() {
                Text(this.user.nickName || this.user.userName || '未知用户')
                  .fontSize(34)
                  .fontWeight(900)
                  .fontColor('#602F27')

                Text(`生日：${this.user.birthday || '未填'}`)
                  .fontSize(14)
                  .fontColor('rgba(96,47,39,0.55)')
                  .margin({ top: 6 })

                Text('过敏原信息：无')
                  .fontSize(14)
                  .fontColor('rgba(96,47,39,0.55)')
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Column() {
                Image(this.user.imageUrl || $r('app.media.startIcon'))
                  .width(76)
                  .height(76)
                  .borderRadius(22)
                  .border({ width: 1, color: 'rgba(96,47,39,0.10)' })

                Button(this.isFollowing ? '已关注' : '关注')
                  .fontSize(12)
                  .fontWeight(700)
                  .height(28)
                  .fontColor(this.isFollowing ? 'rgba(96,47,39,0.55)' : '#8E422F')
                  .backgroundColor('rgba(250,246,240,0.8)')
                  .border({ width: 1, color: 'rgba(96,47,39,0.10)' })
                  .borderRadius(999)
                  .margin({ top: 10 })
                  .onClick(() => this.toggleFollow())
              }
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .padding({ top: 10 })

            // 3. 会员卡片 (匹配 .member-card)
            Row() {
              Text('开通何异味会员')
                .fontWeight(900)
                .fontColor('#602F27')
              Text('最低 0.3元/天')
                .fontSize(13)
                .fontWeight(800)
                .fontColor('#8E422F')
                .backgroundColor('rgba(250,246,240,0.8)')
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .borderRadius(999)
            }
            .width('100%')
            .margin({ top: 18 })
            .padding(14)
            .backgroundColor('#F2E5D3')
            .borderRadius(22)
            .border({ width: 1, color: 'rgba(96,47,39,0.10)' })
            .justifyContent(FlexAlign.SpaceBetween)

            // 4. Tab 栏
            Column() {
              Text(`我的发布 ${this.recipes.length}`)
                .fontSize(16)
                .fontWeight(900)
                .fontColor('#602F27')
              Divider()
                .width(20)
                .strokeWidth(3)
                .color('#602F27')
                .margin({ top: 6 })
            }
            .margin({ top: 25, bottom: 15 })

            // 5. 列表内容
            if (this.recipes.length > 0) {
              List({ space: 12 }) {
                ForEach(this.recipes, (recipe: RecipeVO) => {
                  ListItem() {
                    Row() {
                      Image(recipe.imageUrls?.[0] || $r('app.media.startIcon'))
                        .width(80)
                        .height(80)
                        .borderRadius(16)
                        .objectFit(ImageFit.Cover)

                      Column() {
                        Text(recipe.title || '未命名食谱')
                          .fontSize(16)
                          .fontWeight(900)
                          .fontColor('#602F27')
                        Text(recipe.description || '这个厨师很懒，没写描述')
                          .fontSize(13)
                          .fontColor('rgba(96,47,39,0.55)')
                          .margin({ top: 4 })
                          .maxLines(2)
                      }
                      .layoutWeight(1)
                      .margin({ left: 12 })
                      .alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                    .padding(12)
                    .backgroundColor('#F2E5D3')
                    .borderRadius(20)
                    .onClick(() => this.goToRecipeDetail(recipe.recipeId))
                  }
                })
              }
              .width('100%')
            } else {
              // 空状态 (匹配 .empty)
              Column() {
                Text('创建菜谱的人是厨房里的天使')
                  .fontSize(18)
                  .fontWeight(900)
                  .fontColor('#602F27')
                Text('开始创建第一道菜谱')
                  .fontSize(18)
                  .fontWeight(900)
                  .fontColor('#A85835')
                  .margin({ top: 18 })
              }
              .width('100%')
              .margin({ top: 64 })
            }
          }
          .padding({ left: 18, right: 18, bottom: 40 })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAF6F0')
  }
}