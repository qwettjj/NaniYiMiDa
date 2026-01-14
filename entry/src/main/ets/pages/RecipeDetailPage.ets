import { router, promptAction } from '@kit.ArkUI';
import { RecipeService } from '../service/RecipeService';
import { RecipeVO, RecipeStepVO, IngredientEnum } from '../model/RecipeModel';
import { HttpUtil } from '../service/HttpUtil';
import { HistoryService } from '../service/HistoryService';
import { FavoriteService } from '../service/FavoriteService';
import { FavoriteVO } from '../model/FavoriteModel';

@Entry
@Component
struct RecipeDetailPage {
  @State recipeId: number = 0;
  @State recipe: RecipeVO | null = null;
  @State isLoading: boolean = true;
  @State isFavorited: boolean = false;

  async aboutToAppear(): Promise<void> {
    HttpUtil.init(getContext(this));
    const params = router.getParams() as Record<string, Object>;
    if (params && params['id']) {
      this.recipeId = params['id'] as number;
      await this.loadRecipeDetail();
      // 添加浏览历史记录
      await this.addHistory();
    } else {
      promptAction.showToast({ message: '参数错误' });
      setTimeout(() => {
        router.back();
      }, 1000);
    }
  }

  async addHistory(): Promise<void> {
    try {
      await HistoryService.addHistory(this.recipeId);
      console.info('RecipeDetail: 浏览历史记录成功');
    } catch (e) {
      console.warn('RecipeDetail: 记录浏览历史失败', e instanceof Error ? e.message : JSON.stringify(e));
      // 不影响主流程，仅记录日志
    }
  }

  async loadRecipeDetail(): Promise<void> {
    this.isLoading = true;
    try {
      const result = await RecipeService.getRecipeById(this.recipeId);
      if (result.code === 0 && result.data) {
        this.recipe = result.data;
        // 检查是否已收藏
        await this.checkFavoriteStatus();
      } else {
        promptAction.showToast({ message: result.message || '获取详情失败' });
      }
    } catch (e) {
      console.error('RecipeDetail: 加载失败', e instanceof Error ? e.message : JSON.stringify(e));
      promptAction.showToast({ message: '网络异常' });
    } finally {
      this.isLoading = false;
    }
  }

  async checkFavoriteStatus(): Promise<void> {
    try {
      const result = await FavoriteService.getCurrentUserFavorites();
      if (result.code === 0 && result.data) {
        // 检查当前食谱是否在收藏列表中
        this.isFavorited = result.data.some((favorite: FavoriteVO) => favorite.recipeId === this.recipeId);
      }
    } catch (e) {
      console.warn('RecipeDetail: 检查收藏状态失败', e instanceof Error ? e.message : JSON.stringify(e));
    }
  }

  async toggleFavorite(): Promise<void> {
    try {
      if (this.isFavorited) {
        const result = await FavoriteService.removeFavorite(this.recipeId);
        if (result.code === 0) {
          this.isFavorited = false;
          promptAction.showToast({ message: '取消收藏成功' });
          console.info('RecipeDetail: 取消收藏成功');
        } else {
          promptAction.showToast({ message: result.message || '取消收藏失败' });
        }
      } else {
        const result = await FavoriteService.addFavorite(this.recipeId);
        if (result.code === 0) {
          this.isFavorited = true;
          promptAction.showToast({ message: '收藏成功' });
          console.info('RecipeDetail: 收藏成功');
        } else {
          promptAction.showToast({ message: result.message || '收藏失败' });
        }
      }
    } catch (e) {
      console.error('RecipeDetail: 切换收藏失败', e instanceof Error ? e.message : JSON.stringify(e));
      promptAction.showToast({ message: '操作失败' });
    }
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
        Text('食谱详情')
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
      } else if (this.recipe) {
        Scroll() {
          Column() {
            // 封面图
            if (this.recipe.imageUrls && this.recipe.imageUrls.length > 0) {
              Image(this.recipe.imageUrls[0])
                .width('100%')
                .height(250)
                .objectFit(ImageFit.Cover)
            } else {
              Image($r('app.media.startIcon')) // Placeholder
                .width('100%')
                .height(250)
                .objectFit(ImageFit.Cover)
                .backgroundColor('#F0F0F0')
            }

            Column() {
              // 标题与描述
              Text(this.recipe.title || '未命名食谱')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .margin({ top: 15, bottom: 10 })
              
              Text(this.recipe.description || '暂无描述')
                .fontSize(16)
                .fontColor('#666')
                .lineHeight(24)
                .margin({ bottom: 20 })

              // 数据统计与收藏按钮
              Row() {
                Text(`${this.recipe.favouriteNumber || 0} 人收藏`)
                  .fontSize(14)
                  .fontColor('#999')
                Blank()
                // 收藏按钮
                Button(this.isFavorited ? '已收藏' : '收藏')
                  .fontSize(14)
                  .height(32)
                  .backgroundColor(this.isFavorited ? '#FF6B6B' : '#1698CE')
                  .fontColor(Color.White)
                  .borderRadius(16)
                  .padding({ left: 20, right: 20 })
                  .onClick(() => {
                    this.toggleFavorite();
                  })
              }
              .width('100%')
              .margin({ bottom: 20 })

              Divider().color('#F0F0F0').strokeWidth(1)

              // 食材列表
              Text('所需食材')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .margin({ top: 20, bottom: 10 })
                .width('100%')
              
              if (this.recipe.ingredients && this.recipe.ingredients.length > 0) {
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.recipe.ingredients, (item: string) => {
                    Text(item)
                      .fontSize(14)
                      .fontColor('#333')
                      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                      .backgroundColor('#F5F5F5')
                      .borderRadius(16)
                      .margin({ right: 10, bottom: 10 })
                  })
                }
              } else {
                Text('暂无食材信息').fontSize(14).fontColor('#999')
              }

              Divider().color('#F0F0F0').strokeWidth(1).margin({ top: 10 })

              // 烹饪步骤
              Text('烹饪步骤')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .margin({ top: 20, bottom: 10 })
                .width('100%')

              if (this.recipe.steps && this.recipe.steps.length > 0) {
                List() {
                  ForEach(this.recipe.steps, (step: RecipeStepVO, index: number) => {
                    ListItem() {
                      Column() {
                        Row() {
                          Text(`步骤 ${index + 1}`)
                            .fontSize(16)
                            .fontWeight(FontWeight.Bold)
                            .fontColor('#1698CE')
                        }
                        .width('100%')
                        .margin({ bottom: 5 })

                        Text(step.description || '')
                          .fontSize(15)
                          .fontColor('#333')
                          .lineHeight(22)
                          .width('100%')
                          .margin({ bottom: 10 })

                        if (step.imageUrls && step.imageUrls.length > 0) {
                          Image(step.imageUrls[0])
                            .width('100%')
                            .height(200)
                            .objectFit(ImageFit.Cover)
                            .borderRadius(8)
                            .margin({ bottom: 10 })
                        }
                      }
                      .alignItems(HorizontalAlign.Start)
                      .padding({ bottom: 20 })
                    }
                  })
                }
                .width('100%')
                .divider({ strokeWidth: 0 }) // List internal divider
              } else {
                Text('暂无步骤信息').fontSize(14).fontColor('#999')
              }
            }
            .padding(15)
            .backgroundColor(Color.White)
            .borderRadius({ topLeft: 20, topRight: 20 })
            .margin({ top: -20 }) // Overlap effect
          }
        }
        .layoutWeight(1)
        .backgroundColor('#F5F5F5')
      } else {
        // Error state
        Column() {
          Text('未找到食谱信息').fontSize(16).fontColor('#999')
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
