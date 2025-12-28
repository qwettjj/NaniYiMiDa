/**
 * 主页
 * 展示最近的食谱列表
 */
import { promptAction, router } from '@kit.ArkUI';
import { RecipeService, PageResponse } from '../service/RecipeService';
import { ResultVO } from '../service/HttpUtil';
import { RecipeVO } from '../model/RecipeModel';

@Component
export struct HomePage {
  /** 食谱列表 */
  @State recipes: RecipeVO[] = [];
  /** 是否正在加载 */
  @State isLoading: boolean = false;
  /** 是否还有更多数据 */
  @State hasMore: boolean = true;
  /** 当前页码 */
  @State currentPage: number = 0;
  /** 每页大小 */
  private pageSize: number = 10;
  /** 是否正在加载更多 */
  @State isLoadingMore: boolean = false;

  /**
   * 页面即将显示时加载数据
   */
  aboutToAppear(): void {
    this.loadRecipes();
  }

  /**
   * 加载食谱列表
   * @param isRefresh 是否是刷新操作
   */
  private async loadRecipes(isRefresh: boolean = true): Promise<void> {
    if (isRefresh) {
      this.isLoading = true;
      this.currentPage = 0;
    } else {
      this.isLoadingMore = true;
    }

    try {
      const result: ResultVO<PageResponse<RecipeVO>> = await RecipeService.getRecentRecipes(
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
        promptAction.showToast({
          message: result.message || '加载失败',
          duration: 2000
        });
      }
    } catch (error) {
      console.error('HomePage: 加载食谱异常 -', JSON.stringify(error));
      promptAction.showToast({
        message: '网络异常，请稍后重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
      this.isLoadingMore = false;
    }
  }

  /**
   * 加载更多
   */
  private async loadMore(): Promise<void> {
    if (this.isLoadingMore || !this.hasMore) {
      return;
    }
    this.currentPage++;
    await this.loadRecipes(false);
  }

  /**
   * 查看食谱详情
   * @param recipeId 食谱 ID
   */
  private goToRecipeDetail(recipeId: number | null): void {
    if (recipeId === null) {
      return;
    }
    router.pushUrl({
      url: 'pages/RecipeDetailPage',
      params: {
        id: recipeId
      }
    });
  }

  /**
   * 获取封面图片
   * @param recipe 食谱对象
   * @returns 封面图片 URL 或默认图片
   */
  private getCoverImage(recipe: RecipeVO): string | Resource {
    if (recipe.imageUrls && recipe.imageUrls.length > 0) {
      return recipe.imageUrls[0];
    }
    return $r('app.media.startIcon');
  }

  /**
   * 构建食谱卡片
   */
  @Builder
  RecipeCard(recipe: RecipeVO) {
    Column() {
      // 食谱封面图
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(this.getCoverImage(recipe))
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 16, topRight: 16 })

        // 收藏按钮（视觉效果）
        Row() {
          Text('❤')
            .fontSize(14)
            .fontColor('#FFFFFF')
        }
        .padding(8)
        .backgroundColor('rgba(0,0,0,0.3)')
        .borderRadius(20)
        .margin({ top: 12, right: 12 })
      }

      // 食谱信息
      Column() {
        // 标题
        Text(recipe.title || '无标题')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        // 描述
        if (recipe.description) {
          Text(recipe.description)
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .margin({ top: 8 })
            .lineHeight(20)
        }

        // 底部统计信息
        Row() {
          // 作者头像和昵称（模拟）
          Row() {
            Image($r('app.media.startIcon'))
              .width(20)
              .height(20)
              .borderRadius(10)
              .margin({ right: 6 })
            Text('Nani Chef')
              .fontSize(12)
              .fontColor('#666666')
          }

          Blank()

          // 统计数据
          Row({ space: 12 }) {
            Row() {
              Text('🔥')
                .fontSize(12)
                .margin({ right: 4 })
              Text(`${recipe.favouriteNumber || 0}`)
                .fontSize(12)
                .fontColor('#999999')
            }
            
            Row() {
              Text('📝')
                .fontSize(12)
                .margin({ right: 4 })
              Text(`${recipe.stepCount || 0}`)
                .fontSize(12)
                .fontColor('#999999')
            }
          }
        }
        .width('100%')
        .margin({ top: 16 })
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({
      radius: 12,
      color: 'rgba(0, 0, 0, 0.05)',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      this.goToRecipeDetail(recipe.recipeId);
    })
  }

  /**
   * 构建空状态
   */
  @Builder
  EmptyState() {
    Column() {
      Text('🍳')
        .fontSize(60)
        .margin({ bottom: 16 })

      Text('暂无食谱')
        .fontSize(18)
        .fontColor('#999999')
        .margin({ bottom: 8 })

      Text('快来发布第一个食谱吧')
        .fontSize(14)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 构建加载状态
   */
  @Builder
  LoadingState() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color('#FF6B35')

      Text('加载中...')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 构建列表底部
   */
  @Builder
  ListFooter() {
    Row() {
      if (this.isLoadingMore) {
        LoadingProgress()
          .width(24)
          .height(24)
          .color('#FF6B35')
        Text('加载中...')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ left: 8 })
      } else if (!this.hasMore) {
        Text('— 没有更多了 —')
          .fontSize(14)
          .fontColor('#CCCCCC')
      }
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Column() {
          Text('早上好，')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ bottom: 4 })
          Text('今天想吃点什么？')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Text('📷')
            .fontSize(20)
            .fontColor('#FFFFFF')
        }
        .width(48)
        .height(48)
        .backgroundColor('#4CAF50')
        .margin({ right: 12 })
        .shadow({ radius: 10, color: 'rgba(76, 175, 80, 0.3)', offsetY: 4 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/ScanPage' });
        })

        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Text('+')
            .fontSize(24)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Lighter)
            .offset({ y: -2 })
        }
        .width(48)
        .height(48)
        .backgroundColor('#FF6B35')
        .shadow({ radius: 10, color: 'rgba(255, 107, 53, 0.3)', offsetY: 4 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/RecipePublishPage' });
        })
      }
      .width('100%')
      .height(88)
      .padding({ left: 24, right: 24 })
      .backgroundColor('#FFFFFF')
      .alignItems(VerticalAlign.Center)

      // 内容区域
      Refresh({ refreshing: $$this.isLoading, offset: 120, friction: 100 }) {
        List({ space: 20 }) {
          // 搜索框占位
          ListItem() {
            Row() {
              Text('🔍')
                .fontSize(16)
                .margin({ right: 8 })
              Text('搜索食谱、食材...')
                .fontSize(14)
                .fontColor('#999999')
            }
            .width('100%')
            .height(48)
            .backgroundColor('#F5F5F5')
            .borderRadius(24)
            .padding({ left: 16 })
            .margin({ bottom: 8 })
          }
          .padding({ left: 24, right: 24 })

          if (this.recipes.length === 0 && !this.isLoading) {
            ListItem() {
              this.EmptyState()
            }
          } else {
            ForEach(this.recipes, (recipe: RecipeVO) => {
              ListItem() {
                this.RecipeCard(recipe)
              }
              .padding({ left: 24, right: 24 })
            }, (recipe: RecipeVO) => {
              return recipe.recipeId !== null ? recipe.recipeId.toString() : Math.random().toString();
            })

            // 列表底部
            ListItem() {
              this.ListFooter()
            }
          }
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .onReachEnd(() => {
          this.loadMore();
        })
      }
      .onRefreshing(() => {
        this.loadRecipes(true);
      })
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
