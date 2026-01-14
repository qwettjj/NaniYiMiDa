/**
 * 搜索页面
 * 支持按关键词、日期、标签搜索食谱
 */
import { promptAction, router } from '@kit.ArkUI';
import { RecipeService, PageResponse, RecipeSearchParams } from '../service/RecipeService';
import { ResultVO, HttpUtil } from '../service/HttpUtil';
import { RecipeVO } from '../model/RecipeModel';

@Entry
@Component
struct SearchPage {
  /** 搜索关键词 */
  @State keyword: string = '';
  /** 搜索结果列表 */
  @State searchResults: RecipeVO[] = [];
  /** 是否正在搜索 */
  @State isSearching: boolean = false;
  /** 是否还有更多数据 */
  @State hasMore: boolean = true;
  /** 当前页码 */
  @State currentPage: number = 0;
  /** 每页大小 */
  private pageSize: number = 10;
  /** 是否显示搜索结果 */
  @State showResults: boolean = false;
  /** 防抖定时器 ID */
  private debounceTimer: number = -1;

  async aboutToAppear(): Promise<void> {
    HttpUtil.init(getContext(this));
  }

  /**
   * 执行搜索
   * @param isRefresh 是否是刷新操作
   */
  private async performSearch(isRefresh: boolean = true): Promise<void> {
    if (!this.keyword.trim()) {
      this.searchResults = [];
      this.showResults = false;
      return;
    }

    if (isRefresh) {
      this.isSearching = true;
      this.currentPage = 0;
    }

    try {
      const searchParams: RecipeSearchParams = {
        keyword: this.keyword.trim(),
        page: this.currentPage,
        size: this.pageSize
      };

      const result: ResultVO<PageResponse<RecipeVO>> = await RecipeService.searchRecipes(searchParams);

      if (result.code === 0 && result.data) {
        const pageData = result.data;

        if (isRefresh) {
          this.searchResults = pageData.content;
        } else {
          this.searchResults = [...this.searchResults, ...pageData.content];
        }

        this.hasMore = !pageData.last;
        this.currentPage = pageData.number;
        this.showResults = true;

        if (isRefresh && this.searchResults.length === 0) {
          promptAction.showToast({ message: '未找到相关食谱', duration: 2000 });
        }
      } else {
        promptAction.showToast({ message: result.message || '搜索失败', duration: 2000 });
      }
    } catch (error) {
      console.error('SearchPage: 搜索异常 -', JSON.stringify(error));
      promptAction.showToast({ message: '网络异常，请稍后重试', duration: 2000 });
    } finally {
      this.isSearching = false;
    }
  }

  /**
   * 加载更多搜索结果
   */
  private async loadMore(): Promise<void> {
    if (this.isSearching || !this.hasMore) {
      return;
    }
    this.currentPage++;
    await this.performSearch(false);
  }

  /**
   * 防抖搜索
   */
  private debounceSearch(): void {
    // 清除之前的定时器
    if (this.debounceTimer !== -1) {
      clearTimeout(this.debounceTimer);
    }

    // 设置新的定时器（500ms 后执行搜索）
    this.debounceTimer = setTimeout(() => {
      this.performSearch(true);
    }, 500);
  }

  /**
   * 跳转到食谱详情页
   */
  private goToRecipeDetail(recipeId: number | null): void {
    if (recipeId === null) {
      return;
    }
    router.pushUrl({
      url: 'pages/RecipeDetailPage',
      params: { id: recipeId }
    }).catch((error: Error) => {
      console.error('SearchPage: 跳转失败 -', error.message);
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
        Text('搜索食谱')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 10 })
      }
      .width('100%')
      .height(50)
      .padding({ left: 15, right: 15 })
      .backgroundColor(Color.White)
      .alignItems(VerticalAlign.Center)

      // 搜索框
      Row() {
        Search({ value: this.keyword, placeholder: '输入食谱名称或食材' })
          .width('100%')
          .height(40)
          .backgroundColor('#F5F5F5')
          .placeholderColor('#999')
          .textFont({ size: 14 })
          .onChange((value: string) => {
            this.keyword = value;
            // 触发防抖搜索
            this.debounceSearch();
          })
          .onSubmit((value: string) => {
            this.keyword = value;
            this.performSearch(true);
          })
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 10, bottom: 10 })
      .backgroundColor(Color.White)

      Divider().color('#F0F0F0').strokeWidth(1)

      // 搜索结果列表
      if (this.isSearching && this.currentPage === 0) {
        // 加载中状态
        Column() {
          LoadingProgress().width(50).height(50)
          Text('搜索中...').fontSize(14).fontColor('#999').margin({ top: 10 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else if (this.showResults) {
        // 显示搜索结果
        if (this.searchResults.length > 0) {
          List() {
            ForEach(this.searchResults, (recipe: RecipeVO) => {
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

            // 加载更多提示
            if (this.hasMore) {
              ListItem() {
                Row() {
                  if (this.isSearching) {
                    LoadingProgress().width(30).height(30)
                    Text('加载中...').fontSize(14).fontColor('#999').margin({ left: 8 })
                  } else {
                    Text('下拉加载更多').fontSize(14).fontColor('#999')
                  }
                }
                .width('100%')
                .height(50)
                .justifyContent(FlexAlign.Center)
              }
              .onClick(() => {
                this.loadMore();
              })
            } else {
              ListItem() {
                Text('没有更多了')
                  .fontSize(14)
                  .fontColor('#999')
                  .width('100%')
                  .height(50)
                  .textAlign(TextAlign.Center)
              }
            }
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor('#F5F5F5')
          .divider({ strokeWidth: 1, color: '#F0F0F0' })
        } else {
          // 空结果提示
          Column() {
            Text('未找到相关食谱')
              .fontSize(16)
              .fontColor('#999')
            Text('换个关键词试试吧')
              .fontSize(14)
              .fontColor('#CCC')
              .margin({ top: 10 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F5F5F5')
        }
      } else {
        // 初始状态提示
        Column() {
          Image($r('app.media.startIcon')) // TODO: Replace with search icon
            .width(80)
            .height(80)
            .opacity(0.3)
          Text('输入关键词搜索食谱')
            .fontSize(16)
            .fontColor('#999')
            .margin({ top: 20 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
