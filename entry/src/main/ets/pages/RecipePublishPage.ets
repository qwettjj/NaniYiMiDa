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
  // 图片上传相关
  @State uploadedImageUrl: string = '';
  @State isUploading: boolean = false;

  async aboutToAppear() {
    HttpUtil.init(getContext(this));
  }

  // 图片上传功能
  async uploadImage() {
    try {
      this.isUploading = true;
      console.info('RecipePublish: 开始选择图片...');

      // 配置图片选择器
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;

      // 打开图片选择器
      const photoPicker = new picker.PhotoViewPicker();
      const result = await photoPicker.select(photoSelectOptions);

      if (result.photoUris && result.photoUris.length > 0) {
        const uri = result.photoUris[0];
        console.info('RecipePublish: 已选择图片 -', uri);

        // 构造文件信息
        const fileInfo: ImageFileInfo = {
          filename: `recipe_${Date.now()}.jpg`,
          uri: uri,
          type: 'image/jpeg'
        };

        // 调用上传服务
        console.info('RecipePublish: 开始上传...');
        const uploadResult = await ImageService.uploadImage(fileInfo);

        if (uploadResult.code === 0 && uploadResult.data) {
          this.uploadedImageUrl = uploadResult.data;
          console.info('RecipePublish: 上传成功！URL -', uploadResult.data);
          promptAction.showToast({
            message: '上传成功！',
            duration: 2000
          });
        } else {
          console.error('RecipePublish: 上传失败 -', uploadResult.message);
          promptAction.showToast({
            message: uploadResult.message || '上传失败',
            duration: 3000
          });
        }
      } else {
        console.info('RecipePublish: 未选择图片');
        promptAction.showToast({ message: '未选择图片' });
      }
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : JSON.stringify(error);
      console.error('RecipePublish: 测试上传异常 -', errorMsg);
      promptAction.showToast({
        message: `上传异常: ${errorMsg}`,
        duration: 3000
      });
    } finally {
      this.isUploading = false;
    }
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

          // ===== 图片上传功能 =====
          Divider().strokeWidth(2).color('#E0E0E0').margin({ top: 10, bottom: 10 })

          Column({ space: 10 }) {
            Text('📸 上传封面图片')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)

            Button(this.isUploading ? '上传中...' : '选择图片')
              .width('100%')
              .height(40)
              .backgroundColor('#4CAF50')
              .enabled(!this.isUploading)
              .onClick(() => this.uploadImage())

            if (this.uploadedImageUrl) {
              Column({ space: 8 }) {
                Text('✅ 上传成功！')
                  .fontSize(14)
                  .fontColor(Color.Green)
                  .fontWeight(FontWeight.Bold)

                Text(`URL: ${this.uploadedImageUrl}`)
                  .fontSize(12)
                  .fontColor('#666')
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                  .padding(8)
                  .backgroundColor('#F0F0F0')
                  .borderRadius(4)

                Image(this.uploadedImageUrl)
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Contain)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
              }
              .width('100%')
              .padding(10)
              .backgroundColor('#E8F5E9')
              .borderRadius(8)
            }
          }
          .width('100%')
          .padding(10)
          .backgroundColor('#FFF9C4')
          .borderRadius(8)

          Divider().strokeWidth(2).color('#E0E0E0').margin({ top: 10, bottom: 10 })
          // ===== 图片上传结束 =====

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
