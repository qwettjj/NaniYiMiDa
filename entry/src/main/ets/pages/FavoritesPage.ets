import { router, promptAction } from '@kit.ArkUI';
import { FavoriteService } from '../service/FavoriteService';
import { RecipeService } from '../service/RecipeService';
import { RecipeVO } from '../model/RecipeModel';
import { HttpUtil } from '../service/HttpUtil';

@Entry
@Component
export struct FavoritesPage {
  @State favoriteRecipes: RecipeVO[] = [];
  @State isLoading: boolean = false;

  async aboutToAppear() {
    HttpUtil.init(getContext(this));
    await this.loadFavorites();
  }

  async loadFavorites() {
    this.isLoading = true;
    try {
      const favResult = await FavoriteService.getCurrentUserFavorites();
      if (favResult.code === 0 && favResult.data) {
        const favs = favResult.data;
        
        // 使用 Promise.all 并行请求食谱详情，提升性能
        const promises = favs
          .filter(fav => fav.recipeId !== null)
          .map(fav => RecipeService.getRecipeById(fav.recipeId!));
        
        const results = await Promise.all(promises);
        
        // 过滤成功的结果
        this.favoriteRecipes = results
          .filter(r => r.code === 0 && r.data !== null)
          .map(r => r.data!);
        
        console.info(`FavoritesPage: 成功加载 ${this.favoriteRecipes.length} 个收藏食谱`);
      } else {
        this.getUIContext().getPromptAction().showToast({ message: favResult.message || '获取收藏失败' });
      }
    } catch (e) {
      let msg = 'Unknown error';
      if (e instanceof Error) {
        msg = e.message;
      } else {
        msg = JSON.stringify(e);
      }
      console.error('FavoritesPage: 加载失败', msg);
      this.getUIContext().getPromptAction().showToast({ message: '加载失败，请重试' });
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
        Text('我的收藏')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 10 })
      }
      .width('100%')
      .padding(15)
      .backgroundColor(Color.White)

      if (this.isLoading) {
        LoadingProgress().width(50).height(50).margin({ top: 100 })
      } else if (this.favoriteRecipes.length === 0) {
        this.EmptyState()
      } else {
        List({ space: 10 }) {
          ForEach(this.favoriteRecipes, (recipe: RecipeVO) => {
            ListItem() {
              this.RecipeCard(recipe)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding(10)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  RecipeCard(recipe: RecipeVO) {
    Row() {
      Image((recipe.imageUrls && recipe.imageUrls.length > 0) ? recipe.imageUrls[0] : $r('app.media.startIcon'))
        .width(100)
        .height(100)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
      
      Column() {
        Text(recipe.title || '无标题')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Text(recipe.description || '暂无描述')
          .fontSize(14)
          .fontColor(Color.Gray)
          .margin({ top: 5 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Blank()
        
        Row() {
          Text('❤')
            .fontSize(12)
            .fontColor(Color.Red)
          Text(`${recipe.favouriteNumber || 0}`)
            .fontSize(12)
            .fontColor(Color.Gray)
            .margin({ left: 4 })
        }
      }
      .layoutWeight(1)
      .height(100)
      .margin({ left: 10 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(10)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .onClick(() => {
      if (recipe.recipeId) {
        router.pushUrl({
          url: 'pages/RecipeDetailPage',
          params: {
            id: recipe.recipeId
          }
        });
      }
    })
  }

  @Builder
  EmptyState() {
    Column() {
      Text('暂无收藏')
        .fontSize(18)
        .fontColor(Color.Gray)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
