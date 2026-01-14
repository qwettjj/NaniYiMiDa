/**
 * 主页
 * 展示最近的食谱列表
 */
import { promptAction, router } from '@kit.ArkUI';
import { RecipeService, PageResponse } from '../service/RecipeService';
import { ResultVO } from '../service/HttpUtil';
import { RecipeVO } from '../model/RecipeModel';
import { AppColors, AppFonts, AppSpacing, AppRadius } from '../common/theme';

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
          .borderRadius({ topLeft: AppRadius.XL, topRight: AppRadius.XL })
          .alt($r('app.media.startIcon'))

        // 收藏按钮（视觉效果）
        Row() {
          Text('❤️')
            .fontSize(AppFonts.BODY)
        }
        .width(36)
        .height(36)
        .backgroundColor('rgba(255,255,255,0.9)')
        .borderRadius(AppRadius.ROUND)
        .justifyContent(FlexAlign.Center)
        .margin({ top: AppSpacing.MD, right: AppSpacing.MD })
        .shadow({
          radius: 8,
          color: AppColors.SHADOW_MEDIUM,
          offsetY: 2
        })
      }

      // 食谱信息
      Column({ space: AppSpacing.SM }) {
        // 标题
        Text(recipe.title || '无标题')
          .fontSize(AppFonts.HEADING_4)
          .fontWeight(AppFonts.WEIGHT_BOLD)
          .fontColor(AppColors.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        // 描述
        if (recipe.description) {
          Text(recipe.description)
            .fontSize(AppFonts.BODY_SMALL)
            .fontColor(AppColors.TEXT_SECONDARY)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .lineHeight(18)
        }

        // 底部统计信息
        Row() {
          // 作者信息
          Row({ space: 6 }) {
            Text('👨‍🍳')
              .fontSize(AppFonts.BODY_SMALL)
            Text('Nani Chef')
              .fontSize(AppFonts.BODY_SMALL)
              .fontColor(AppColors.TEXT_SECONDARY)
          }

          Blank()

          // 统计数据
          Row({ space: AppSpacing.MD }) {
            Row({ space: 4 }) {
              Text('❤️')
                .fontSize(AppFonts.BODY_SMALL)
              Text(`${recipe.favouriteNumber || 0}`)
                .fontSize(AppFonts.BODY_SMALL)
                .fontColor(AppColors.TEXT_TERTIARY)
            }
            
            Row({ space: 4 }) {
              Text('📋')
                .fontSize(AppFonts.BODY_SMALL)
              Text(`${recipe.stepCount || 0}步`)
                .fontSize(AppFonts.BODY_SMALL)
                .fontColor(AppColors.TEXT_TERTIARY)
            }
          }
        }
        .width('100%')
        .margin({ top: AppSpacing.SM })
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding(AppSpacing.LG)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(AppColors.BG_PRIMARY)
    .borderRadius(AppRadius.XL)
    .shadow({
      radius: 12,
      color: AppColors.SHADOW_MEDIUM,
      offsetX: 0,
      offsetY: 2
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
    Column({ space: AppSpacing.LG }) {
      Text('🍳')
        .fontSize(60)

      Text('暂无食谱')
        .fontSize(AppFonts.HEADING_3)
        .fontColor(AppColors.TEXT_SECONDARY)

      Text('快来发布第一个食谱吧')
        .fontSize(AppFonts.BODY)
        .fontColor(AppColors.TEXT_TERTIARY)
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
    Column({ space: AppSpacing.MD }) {
      LoadingProgress()
        .width(50)
        .height(50)
        .color(AppColors.PRIMARY)

      Text('加载中...')
        .fontSize(AppFonts.BODY)
        .fontColor(AppColors.TEXT_SECONDARY)
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
    Row({ space: AppSpacing.SM }) {
      if (this.isLoadingMore) {
        LoadingProgress()
          .width(24)
          .height(24)
          .color(AppColors.PRIMARY)
        Text('加载中...')
          .fontSize(AppFonts.BODY)
          .fontColor(AppColors.TEXT_SECONDARY)
      } else if (!this.hasMore) {
        Text('— 没有更多了 —')
          .fontSize(AppFonts.BODY)
          .fontColor(AppColors.TEXT_TERTIARY)
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
        Column({ space: 4 }) {
          Text('早上好，')
            .fontSize(AppFonts.BODY)
            .fontColor(AppColors.TEXT_SECONDARY)
          Text('今天想吃点什么？')
            .fontSize(AppFonts.HEADING_2)
            .fontWeight(AppFonts.WEIGHT_BOLD)
            .fontColor(AppColors.TEXT_PRIMARY)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Text('📷')
            .fontSize(20)
        }
        .width(48)
        .height(48)
        .backgroundColor(AppColors.ACCENT)
        .margin({ right: AppSpacing.MD })
        .shadow({ radius: 10, color: `${AppColors.ACCENT}50`, offsetY: 4 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/ScanPage' });
        })

        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Text('+')
            .fontSize(24)
            .fontColor(AppColors.TEXT_INVERSE)
            .fontWeight(FontWeight.Lighter)
            .offset({ y: -2 })
        }
        .width(48)
        .height(48)
        .backgroundColor(AppColors.PRIMARY)
        .shadow({ radius: 10, color: `${AppColors.PRIMARY}50`, offsetY: 4 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/RecipePublishPage' });
        })
      }
      .width('100%')
      .height(88)
      .padding({ left: AppSpacing.XXL, right: AppSpacing.XXL })
      .backgroundColor(AppColors.BG_PRIMARY)
      .alignItems(VerticalAlign.Center)

      // 内容区域
      Refresh({ refreshing: $$this.isLoading, offset: 120, friction: 100 }) {
        List({ space: 20 }) {
          // 搜索框占位
          ListItem() {
            Row({ space: AppSpacing.SM }) {
              Text('🔍')
                .fontSize(AppFonts.BODY_LARGE)
              Text('搜索食谱、食材...')
                .fontSize(AppFonts.BODY)
                .fontColor(AppColors.TEXT_TERTIARY)
            }
            .width('100%')
            .height(48)
            .backgroundColor(AppColors.BG_TERTIARY)
            .borderRadius(AppRadius.XXL)
            .padding({ left: AppSpacing.LG })
            .margin({ bottom: AppSpacing.SM })
            .onClick(() => {
              router.pushUrl({ url: 'pages/SearchPage' });
            })
          }
          .padding({ left: AppSpacing.XXL, right: AppSpacing.XXL })

          if (this.recipes.length === 0 && !this.isLoading) {
            ListItem() {
              this.EmptyState()
            }
          } else {
            ForEach(this.recipes, (recipe: RecipeVO) => {
              ListItem() {
                this.RecipeCard(recipe)
              }
              .padding({ left: AppSpacing.XXL, right: AppSpacing.XXL })
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
    .backgroundColor(AppColors.BG_SECONDARY)
  }
}
