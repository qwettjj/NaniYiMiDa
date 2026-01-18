import { router, promptAction } from '@kit.ArkUI';
import { FavoriteService } from '../service/FavoriteService';
import { FavoriteWithRecipeVO } from '../model/FavoriteModel';
import { HttpUtil } from '../service/HttpUtil';

interface ThemeColors {
  BG: string,
  CARD_BG: string,
  TEXT: string,
  MUTED: string,
  MUTED2: string,
  PRIMARY: string,
  LINE: string,
  GRADIENT_START: string
}

@Entry
@Component
export struct FavoritesPage {
  @State favoriteRecipes: FavoriteWithRecipeVO[] = [];
  @State isLoading: boolean = false;
  @State searchText: string = '';
  @State isRefreshing: boolean = false;


  // 十色配色方案 (对应 like.html)
  readonly C : ThemeColors= {
    BG: '#FAF6F0',
    CARD_BG: 'rgba(255,255,255,0.62)',
    TEXT: '#602F27',
    MUTED: 'rgba(96,47,39,0.55)',
    MUTED2: 'rgba(96,47,39,0.38)',
    PRIMARY: '#8E422F',
    LINE: 'rgba(96,47,39,0.10)',
    GRADIENT_START: '#F2E5D3'
  };

  async onPageShow(): Promise<void> {
    // 每次页面回到前台，都重新加载一次数据
    await this.loadFavorites();
  }

  async aboutToAppear(): Promise<void> {
    HttpUtil.init(getContext(this));
    await this.loadFavorites();
  }

  // 显式声明返回类型，符合 ArkTS 规范
  async loadFavorites(): Promise<void> {
    this.isLoading = true;
    try {
      // 建议使用 FavoriteWithRecipeVO 接口，一次性获取详情
      const res = await FavoriteService.getCurrentUserFavorites();
      if (res.code === 0 && res.data) {
        this.favoriteRecipes = res.data as FavoriteWithRecipeVO[];
      } else {
        promptAction.showToast({ message: res.message || '获取收藏失败' });
      }
    } catch (e) {
      const msg = e instanceof Error ? e.message : '网络异常';
      promptAction.showToast({ message: msg });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 取消收藏逻辑
   */
  async handleUnfavorite(favId: number | null): Promise<void> {
    if (favId === null) return;
    try {
      const res = await FavoriteService.removeFavorite(favId);
      if (res.code === 0) {
        // 这一行代码利用了 ArkUI 的 @State 响应式机制
        // 过滤后的数组赋值给 favoriteRecipes，List 会自动重新渲染，删除该项
        this.favoriteRecipes = this.favoriteRecipes.filter(item => item.favouriteId !== favId);
        promptAction.showToast({ message: '已从收藏中移除' });
      }
    } catch (e) {
      // 修正 arkts-no-any-unknown
      const msg = e instanceof Error ? e.message : '网络异常';
      promptAction.showToast({ message: msg });
    }
  }

  // 搜索过滤逻辑
  getFilteredList(): FavoriteWithRecipeVO[] {
    if (!this.searchText.trim()) return this.favoriteRecipes;
    return this.favoriteRecipes.filter(item =>
    item.recipeTitle?.includes(this.searchText)
    );
  }

  build() {
    Column() {
      // 1. Header & Search Bar (对应 HTML .header)
      Column() {
        Row() {
          Text('🔎').fontSize(18).margin({ left: 14, right: 10 }).opacity(0.9)
          TextInput({ placeholder: '搜索我的收藏...', text: this.searchText })
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .placeholderColor(this.C.MUTED)
            .fontSize(14)
            .fontColor(this.C.TEXT)
            .onChange((val: string) => this.searchText = val)
        }
        .width('100%')
        .height(44)
        .backgroundColor('rgba(255,255,255,0.72)')
        .borderRadius(22)
        .border({ width: 1, color: this.C.LINE })
        .shadow({ radius: 22, color: 'rgba(96,47,39,0.06)', offsetY: 10 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 10 })
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [[this.C.GRADIENT_START, 0.0], [this.C.BG, 1.0]]
      })

      // 2. Content Area
      if (this.isLoading) {
        LoadingProgress().width(50).height(50).margin({ top: 100 }).color(this.C.PRIMARY)
      } else if (this.getFilteredList().length === 0) {
        this.EmptyState()
      } else {
        Refresh({ refreshing: $$this.isRefreshing }) {
          List({ space: 14 }) {
            ListItem() {
              Text('我的收藏')
                .fontSize(16)
                .fontWeight(900)
                .fontColor(this.C.TEXT)
                .margin({ top: 10, bottom: 4, left: 2 })
            }

            ForEach(this.getFilteredList(), (item: FavoriteWithRecipeVO) => {
              ListItem() {
                this.RecipeCard(item)
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 16, right: 16, bottom: 20 })
          .edgeEffect(EdgeEffect.Spring)
        }
        .onRefreshing(async () => {
          await this.loadFavorites();
          this.isRefreshing = false;
        })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.C.BG)
  }

  @Builder
  RecipeCard(item: FavoriteWithRecipeVO) {
    Row({ space: 12 }) {
      // 食谱封面 (对应 HTML .thumb)
      Image(item.recipeImageUrl || $r('app.media.startIcon'))
        .width(118)
        .height(88)
        .borderRadius(16)
        .objectFit(ImageFit.Cover)
        .backgroundColor(this.C.GRADIENT_START)

      // 信息区 (对应 HTML .info)
      Column() {
        Text(item.recipeTitle || '未知食谱')
          .fontSize(15)
          .fontWeight(900)
          .fontColor(this.C.TEXT)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 8 })

        Row() {
          // 作者头像占位 (对应 HTML .avatar)
          Circle({ width: 22, height: 22 })
            .fill(this.C.GRADIENT_START)
            .stroke(this.C.LINE)
            .margin({ right: 8 })

          Text(`收藏数: ${item.recipeFavouriteNumber || 0}`)
            .fontSize(13)
            .fontColor(this.C.MUTED)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 收藏图标 (对应 HTML .heart)
      Stack() {
        // 根据业务逻辑，这里默认显示实心星星
        // 如果想做切换效果，可以用 item.isFavorite ? '★' : '☆'
        Text('★')
          .fontSize(18)
          .fontColor(this.C.PRIMARY)
          .translate({ y: 1 })
      }
      .width(44) // 增加热区宽度
      .height(44)
      .borderRadius(12)
      .backgroundColor('rgba(242,229,211,0.7)')
      .border({ width: 1, color: this.C.LINE })
      // 关键点 1：将点击事件放在 Stack 容器上，而不是 Text 上
      .onClick((event: ClickEvent) => {
        // 关键点 2：在 handleUnfavorite 执行前，我们可以先手动从列表移除，达到“秒回馈”效果
        this.handleUnfavorite(item.favouriteId);
      })
      // 关键点 3：阻止点击事件冒泡到外层的 Row (详情跳转)
      .hitTestBehavior(HitTestMode.Block)
      .shadow({ radius: 20, color: 'rgba(96,47,39,0.08)', offsetY: 10 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.C.CARD_BG)
    .borderRadius(18)
    .border({ width: 1, color: this.C.LINE })
    .shadow({ radius: 26, color: 'rgba(96,47,39,0.10)', offsetY: 10 })
    .onClick(() => {
      if (item.recipeId) {
        router.pushUrl({
          url: 'pages/RecipeDetailPage',
          params: { id: item.recipeId }
        });
      }
    })
  }

  @Builder
  EmptyState() {
    Column({ space: 12 }) {
      Stack() {
        Text('⭐').fontSize(40)
      }
      .width(84)
      .height(84)
      .borderRadius(22)
      .backgroundColor('rgba(242,229,211,0.75)')
      .border({ width: 1, color: this.C.LINE })

      Text('还没有收藏')
        .fontSize(16)
        .fontWeight(900)
        .fontColor(this.C.TEXT)

      Text('去首页逛逛，把喜欢的食谱收藏起来～')
        .fontSize(14)
        .fontColor(this.C.MUTED2)
        .textAlign(TextAlign.Center)
        .width(260)
        .lineHeight(20)
    }
    .width('100%')
    .margin({ top: 100 })
  }
}