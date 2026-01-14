/**
 * 用户详情页
 * 显示其他用户的个人信息、食谱和关注状态
 */
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

  async aboutToAppear(): Promise<void> {
    HttpUtil.init(getContext(this));
    const params = router.getParams() as Record<string, Object>;
    if (params && params['userId']) {
      this.userId = params['userId'] as number;
      await this.loadUserInfo();
      await this.loadUserRecipes();
    } else {
      promptAction.showToast({ message: '参数错误' });
      setTimeout(() => {
        router.back();
      }, 1000);
    }
  }

  /**
   * 加载用户信息
   */
  async loadUserInfo(): Promise<void> {
    this.isLoading = true;
    try {
      const result = await UserService.getUserById(this.userId);
      if (result.code === 0 && result.data) {
        this.user = result.data;
        // 检查是否已关注
        await this.checkFollowStatus();
      } else {
        promptAction.showToast({ message: result.message || '获取用户信息失败' });
      }
    } catch (e) {
      console.error('UserDetailPage: 加载用户信息失败', e instanceof Error ? e.message : JSON.stringify(e));
      promptAction.showToast({ message: '网络异常' });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 检查是否已关注该用户
   */
  async checkFollowStatus(): Promise<void> {
    try {
      const result = await UserService.getMyFollowings();
      if (result.code === 0 && result.data) {
        this.isFollowing = result.data.some((user: UserVO) => user.userId === this.userId);
      }
    } catch (e) {
      console.warn('UserDetailPage: 检查关注状态失败', e instanceof Error ? e.message : JSON.stringify(e));
    }
  }

  /**
   * 加载用户的食谱列表
   */
  async loadUserRecipes(isRefresh: boolean = true): Promise<void> {
    if (isRefresh) {
      this.currentPage = 0;
    }

    try {
      const result = await RecipeService.getUserRecipes(
        this.userId,
        undefined,
        this.currentPage,
        this.pageSize
      );

      if (result.code === 0 && result.data) {
        const pageData = result.data;

        if (isRefresh) {
          this.recipes = pageData.content;
        } else {
          this.recipes = [...this.recipes, ...pageData.content];
        }

        this.hasMore = !pageData.last;
        this.currentPage = pageData.number;
      } else {
        console.warn('UserDetailPage: 加载食谱失败', result.message);
      }
    } catch (e) {
      console.error('UserDetailPage: 加载食谱异常', e instanceof Error ? e.message : JSON.stringify(e));
    }
  }

  /**
   * 切换关注状态
   */
  async toggleFollow(): Promise<void> {
    try {
      if (this.isFollowing) {
        const result = await UserService.unfollowUser(this.userId);
        if (result.code === 0) {
          this.isFollowing = false;
          promptAction.showToast({ message: '已取消关注' });
          console.info('UserDetailPage: 取消关注成功');
        } else {
          promptAction.showToast({ message: result.message || '取消关注失败' });
        }
      } else {
        const result = await UserService.followUser(this.userId);
        if (result.code === 0) {
          this.isFollowing = true;
          promptAction.showToast({ message: '关注成功' });
          console.info('UserDetailPage: 关注成功');
        } else {
          promptAction.showToast({ message: result.message || '关注失败' });
        }
      }
    } catch (e) {
      console.error('UserDetailPage: 切换关注失败', e instanceof Error ? e.message : JSON.stringify(e));
      promptAction.showToast({ message: '操作失败' });
    }
  }

  /**
   * 跳转到食谱详情页
   */
  goToRecipeDetail(recipeId: number | null): void {
    if (recipeId === null) {
      return;
    }
    router.pushUrl({
      url: 'pages/RecipeDetailPage',
      params: { id: recipeId }
    }).catch((error: Error) => {
      console.error('UserDetailPage: 跳转失败 -', error.message);
    });
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.startIcon')) // TODO: Replace with back icon
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })
        Text('用户主页')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 10 })
      }
      .width('100%')
      .height(50)
      .padding({ left: 15, right: 15 })
      .backgroundColor(Color.White)
      .alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(50).height(50)
          Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 10 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.user) {
        Scroll() {
          Column() {
            // 用户信息卡片
            Column() {
              // 头像
              Image(this.user.imageUrl || $r('app.media.startIcon'))
                .width(80)
                .height(80)
                .borderRadius(40)
                .margin({ top: 20 })

              // 昵称
              Text(this.user.nickName || this.user.userName || '用户')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .margin({ top: 15 })

              // 签名
              Text(this.user.signature || '这个人很懒，什么都没写')
                .fontSize(14)
                .fontColor('#666')
                .margin({ top: 5 })

              // 关注按钮
              Button(this.isFollowing ? '已关注' : '关注')
                .fontSize(14)
                .height(36)
                .backgroundColor(this.isFollowing ? '#E0E0E0' : '#1698CE')
                .fontColor(this.isFollowing ? '#666' : Color.White)
                .borderRadius(18)
                .padding({ left: 30, right: 30 })
                .margin({ top: 20, bottom: 20 })
                .onClick(() => {
                  this.toggleFollow();
                })
            }
            .width('100%')
            .backgroundColor(Color.White)
            .alignItems(HorizontalAlign.Center)

            Divider().color('#F0F0F0').strokeWidth(8)

            // 用户食谱列表
            Column() {
              Text('TA的食谱')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .margin({ top: 15, bottom: 15, left: 15 })
                .width('100%')

              if (this.recipes.length > 0) {
                List() {
                  ForEach(this.recipes, (recipe: RecipeVO) => {
                    ListItem() {
                      Row() {
                        // 食谱封面
                        if (recipe.imageUrls && recipe.imageUrls.length > 0) {
                          Image(recipe.imageUrls[0])
                            .width(100)
                            .height(100)
                            .objectFit(ImageFit.Cover)
                            .borderRadius(8)
                        } else {
                          Column()
                            .width(100)
                            .height(100)
                            .backgroundColor('#F0F0F0')
                            .borderRadius(8)
                        }

                        // 食谱信息
                        Column() {
                          Text(recipe.title || '未命名食谱')
                            .fontSize(16)
                            .fontWeight(FontWeight.Bold)
                            .maxLines(2)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .width('100%')

                          Text(recipe.description || '暂无描述')
                            .fontSize(14)
                            .fontColor('#666')
                            .maxLines(2)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .margin({ top: 5 })
                            .width('100%')

                          Row() {
                            Text(`${recipe.favouriteNumber || 0} 收藏`)
                              .fontSize(12)
                              .fontColor('#999')
                          }
                          .margin({ top: 8 })
                        }
                        .layoutWeight(1)
                        .margin({ left: 12 })
                        .alignItems(HorizontalAlign.Start)
                        .justifyContent(FlexAlign.SpaceBetween)
                      }
                      .width('100%')
                      .padding(15)
                      .backgroundColor(Color.White)
                      .onClick(() => {
                        this.goToRecipeDetail(recipe.recipeId);
                      })
                    }
                  }, (recipe: RecipeVO, index: number) => `${recipe.recipeId}_${index}`)
                }
                .width('100%')
                .divider({ strokeWidth: 1, color: '#F0F0F0' })
              } else {
                Column() {
                  Text('暂无食谱')
                    .fontSize(14)
                    .fontColor('#999')
                    .margin({ top: 40, bottom: 40 })
                }
                .width('100%')
                .alignItems(HorizontalAlign.Center)
                .backgroundColor(Color.White)
              }
            }
            .width('100%')
            .backgroundColor(Color.White)
          }
        }
        .layoutWeight(1)
        .backgroundColor('#F5F5F5')
      } else {
        // 错误状态
        Column() {
          Text('未找到用户信息').fontSize(16).fontColor('#999')
          Button('返回')
            .margin({ top: 20 })
            .onClick(() => router.back())
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
