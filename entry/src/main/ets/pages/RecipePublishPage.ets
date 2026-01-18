import { router, promptAction } from '@kit.ArkUI';
import { RecipeService } from '../service/RecipeService';
import { RecipeVO, RecipeStepVO, IngredientEnum } from '../model/RecipeModel';
import { HttpUtil } from '../service/HttpUtil';
import { ImageService, ImageFileInfo } from '../service/ImageService';
import { picker } from '@kit.CoreFileKit';

@Entry
@Component
struct RecipePublishPage {
  @State title: string = '';
  @State description: string = '';
  @State ingredients: string = '';
  @State steps: RecipeStepVO[] = [];
  @State recipeId: number | null = null;
  @State isSubmitting: boolean = false;
  // 图片上传测试
  @State testImageUrl: string = '';
  @State isUploading: boolean = false;

  async aboutToAppear() {
    HttpUtil.init(getContext(this));
  }

  // 添加步骤
  addStep() {
    this.steps.push({
      stepId: null,
      stepNumber: this.steps.length + 1,
      description: '',
      imageUrls: []
    });
  }

  // 删除步骤
  deleteStep(index: number) {
    this.steps.splice(index, 1);
    // 重置步骤序号
    this.steps.forEach((step, idx) => {
      step.stepNumber = idx + 1;
    });
  }

  // 发布食谱
  async publishRecipe() {
    if (!this.title.trim()) {
      promptAction.showToast({ message: '请输入食谱标题' });
      return;
    }
    if (!this.description.trim()) {
      promptAction.showToast({ message: '请输入食谱描述' });
      return;
    }
    if (this.steps.length === 0) {
      promptAction.showToast({ message: '请至少添加一个步骤' });
      return;
    }

    this.isSubmitting = true;

    try {
      // 1. 创建草稿
      console.info('Publish: 1. Creating draft...');
      const createRes = await RecipeService.createRecipeDraft(this.title);
      console.info('Publish: Draft result:', JSON.stringify(createRes));
      if (createRes.code !== 0 || !createRes.data) {
        throw new Error(createRes.message || '创建草稿失败');
      }
      this.recipeId = createRes.data;

      // 2. 更新描述
      console.info('Publish: 2. Updating description...');
      const descRes = await RecipeService.modifyRecipeDescription(this.recipeId, this.description);
      if (descRes.code !== 0) throw new Error(descRes.message || '更新描述失败');

      // 3. 更新食材
      if (this.ingredients.trim()) {
        console.info('Publish: 3. Updating ingredients...');
        const ingRes = await RecipeService.modifyRecipeIngredient(this.recipeId, this.ingredients);
        if (ingRes.code !== 0) throw new Error(ingRes.message || '更新食材失败');
      }

      // 4. 添加步骤
      console.info('Publish: 4. Adding steps...');
      for (let i = 0; i < this.steps.length; i++) {
        const step = this.steps[i];
        const desc = step.description || '';
        if (desc.trim()) {
          const stepRes = await RecipeService.addRecipeStep(this.recipeId, {
            stepId: null,
            stepNumber: i + 1,
            description: desc,
            imageUrls: [] // 暂不支持图片上传
          });
          if (stepRes.code !== 0) throw new Error(stepRes.message || `添加步骤 ${i + 1} 失败`);
        }
      }

      // 5. 发布
      console.info('Publish: 5. Publishing...');
      const publishRes = await RecipeService.publishRecipe(this.recipeId);
      if (publishRes.code === 0) {
        try {
          promptAction.showToast({ message: '发布成功！' });
          // 使用 setTimeout 确保页面执行后再跳转
          setTimeout(() => {
            try {
              router.back();
            } catch (e) {
              console.error('router.back failed', e);
            }
          }, 300); // 延迟 300ms 返回，避免 UI 执行上下文丢失
        } catch (e) {
          console.error('Toast or router error:', e);
        }
      } else {
        throw new Error(publishRes.message || '发布失败');
      }

    } catch (e) {
      let message = '发布过程中出现错误';
      if (e instanceof Error) {
        console.error('Publish Error Message:', e.message);
        message = e.message;
      } else {
        console.error('Publish Error:', JSON.stringify(e));
      }
      promptAction.showToast({ message: message });
    } finally {
      this.isSubmitting = false;
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
        Text('发布食谱')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 10 })
      }
      .width('100%')
      .height(50)
      .padding({ left: 15, right: 15 })
      .backgroundColor(Color.White)
      .alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 15 }) {
          // 标题
          Text('标题').fontSize(16).fontWeight(FontWeight.Bold)
          TextInput({ placeholder: '给你的食谱起个名字吧', text: this.title })
            .onChange((value) => this.title = value)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)

          // 描述
          Text('描述').fontSize(16).fontWeight(FontWeight.Bold)
          TextArea({ placeholder: '简单介绍一下这道菜...', text: this.description })
            .onChange((value) => this.description = value)
            .height(100)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)

          // 食材
          Text('食材').fontSize(16).fontWeight(FontWeight.Bold)
          TextArea({ placeholder: '例如：五花肉 500g，葱姜蒜适量...', text: this.ingredients })
            .onChange((value) => this.ingredients = value)
            .height(80)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)

          // 步骤
          Row() {
            Text('步骤').fontSize(16).fontWeight(FontWeight.Bold)
            Blank()
            Button('添加步骤')
              .fontSize(12)
              .height(28)
              .onClick(() => this.addStep())
          }.width('100%')

          ForEach(this.steps, (step: RecipeStepVO, index: number) => {
            Column() {
              Row() {
                Text(`步骤 ${index + 1}`).fontSize(14).fontColor('#666')
                Blank()
                Text('删除')
                  .fontSize(14)
                  .fontColor(Color.Red)
                  .onClick(() => this.deleteStep(index))
              }.width('100%').margin({ bottom: 5 })

              TextArea({ placeholder: `步骤 ${index + 1} 详情...`, text: step.description || '' })
                .onChange((value) => {
                  this.steps[index].description = value;
                })
                .height(80)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
            }
            .padding(10)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .shadow({ radius: 2, color: '#E0E0E0', offsetY: 2 })
          })

          // 底部占位
          Blank().height(20)

          Button(this.isSubmitting ? '发布中...' : '发布食谱')
            .width('100%')
            .height(45)
            .enabled(!this.isSubmitting)
            .onClick(() => this.publishRecipe())
        }
        .padding(15)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
