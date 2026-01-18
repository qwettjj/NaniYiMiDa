/**
 * 食谱相关模型
 * 对应后端 Recipe.java, RecipeVO.java, RecipeStep.java, RecipeStepVO.java
 */

/**
 * 食谱状态枚举
 * 对应后端 RecipeStatus
 */
export enum RecipeStatus {
  /** 草稿 */
  DRAFT = 'DRAFT',
  /** 已发布 */
  PUBLISHED = 'PUBLISHED',
  /** 已隐藏 */
  HIDDEN = 'HIDDEN'
}

/**
 * 食材枚举
 * 对应后端 IngredientEnum (完整同步)
 * 最后同步时间：2026-01-18
 */
export enum IngredientEnum {
  // 谷物/主食
  RICE = 'RICE',
  NOODLE = 'NOODLE',
  WHEAT_FLOUR = 'WHEAT_FLOUR',
  CORN = 'CORN',
  OAT = 'OAT',
  MILLET = 'MILLET',

  // 肉类/海鲜
  PORK = 'PORK',
  BEEF = 'BEEF',
  LAMB = 'LAMB',
  CHICKEN = 'CHICKEN',
  DUCK = 'DUCK',
  FISH = 'FISH',
  SHRIMP = 'SHRIMP',
  CRAB = 'CRAB',
  CLAM = 'CLAM',              // 新增
  SCALLOP = 'SCALLOP',        // 新增
  PRAWN = 'PRAWN',            // 新增

  // 豆制品/坚果/蛋类
  EGG = 'EGG',
  TOFU = 'TOFU',
  SOYBEAN = 'SOYBEAN',
  EDAMAME = 'EDAMAME',        // 新增
  PEANUT = 'PEANUT',
  WALNUT = 'WALNUT',          // 新增
  ALMOND = 'ALMOND',          // 新增
  SESAME = 'SESAME',          // 新增

  // 蔬菜
  CABBAGE = 'CABBAGE',
  LETTUCE = 'LETTUCE',
  SPINACH = 'SPINACH',
  KALE = 'KALE',              // 新增
  BROCCOLI = 'BROCCOLI',
  CAULIFLOWER = 'CAULIFLOWER', // 新增
  CARROT = 'CARROT',
  POTATO = 'POTATO',
  SWEET_POTATO = 'SWEET_POTATO',
  PUMPKIN = 'PUMPKIN',
  EGGPLANT = 'EGGPLANT',
  CUCUMBER = 'CUCUMBER',
  BELL_PEPPER = 'BELL_PEPPER', // 新增
  CHILI_PEPPER = 'CHILI_PEPPER', // 新增
  TOMATO = 'TOMATO',
  ONION = 'ONION',
  GARLIC = 'GARLIC',
  GINGER = 'GINGER',
  SPRING_ONION = 'SPRING_ONION', // 新增
  CORIANDER = 'CORIANDER',    // 新增
  MUSHROOM = 'MUSHROOM',
  SHIITAKE = 'SHIITAKE',      // 新增
  ENOKI = 'ENOKI',            // 新增

  // 水果
  APPLE = 'APPLE',
  BANANA = 'BANANA',
  ORANGE = 'ORANGE',
  GRAPE = 'GRAPE',
  STRAWBERRY = 'STRAWBERRY',
  BLUEBERRY = 'BLUEBERRY',    // 新增
  MANGO = 'MANGO',
  PINEAPPLE = 'PINEAPPLE',    // 新增
  WATERMELON = 'WATERMELON',
  MELON = 'MELON',            // 新增
  PEACH = 'PEACH',            // 新增
  PEAR = 'PEAR',              // 新增
  PLUM = 'PLUM',              // 新增
  KIWI = 'KIWI',              // 新增

  // 奶制品
  MILK = 'MILK',
  CHEESE = 'CHEESE',
  YOGURT = 'YOGURT',
  BUTTER = 'BUTTER',

  // 调味品
  SUGAR = 'SUGAR',
  SALT = 'SALT',
  SOY_SAUCE = 'SOY_SAUCE',
  VINEGAR = 'VINEGAR',
  COOKING_WINE = 'COOKING_WINE',
  BLACK_PEPPER = 'BLACK_PEPPER', // 新增
  WHITE_PEPPER = 'WHITE_PEPPER', // 新增
  CURRY_POWDER = 'CURRY_POWDER', // 新增
  CUMIN = 'CUMIN',            // 新增
  FIVE_SPICE = 'FIVE_SPICE',  // 新增
  BASIL = 'BASIL',            // 新增
  ROSEMARY = 'ROSEMARY',      // 新增
  THYME = 'THYME',            // 新增
  
  // 其他
  OTHER = 'OTHER'
}

/**
 * 食谱步骤接口
 * 对应后端 RecipeStepVO
 */
export interface RecipeStepVO {
  /** 步骤ID */
  stepId: number | null;
  /** 步骤序号 */
  stepNumber: number | null;
  /** 步骤描述 */
  description: string | null;
  /** 步骤图片URL列表 */
  imageUrls: string[];
}

/**
 * 食谱接口
 * 对应后端 RecipeVO
 */
export interface RecipeVO {
  /** 食谱ID */
  recipeId: number | null;

  creatorUserId: number | null;
  /** 食谱标题 */
  title: string | null;
  /** 食谱描述 */
  description: string | null;
  /** 步骤数量 */
  stepCount: number | null;
  /** 创建时间 (时间戳或ISO字符串) */
  createTime: string | null;
  /** 收藏数 */
  favouriteNumber: number | null;
  /** 食谱状态 */
  status: RecipeStatus | null;
  /** 食谱图片URL列表 */
  imageUrls: string[];
  /** 食谱步骤列表 */
  steps: RecipeStepVO[];
  /** 食材列表 */
  ingredients: IngredientEnum[];
}

/**
 * 创建食谱请求 (草稿)
 */
export interface CreateRecipeRequest {
  /** 食谱标题 */
  title: string;
  /** 食谱描述 */
  description?: string;
  /** 食谱图片URL列表 */
  imageUrls?: string[];
  /** 食谱步骤列表 */
  steps?: CreateRecipeStepRequest[];
  /** 食材列表 */
  ingredients?: IngredientEnum[];
}

/**
 * 创建食谱步骤请求
 */
export interface CreateRecipeStepRequest {
  /** 步骤序号 */
  stepNumber: number;
  /** 步骤描述 */
  description: string;
  /** 步骤图片URL列表 */
  imageUrls?: string[];
}

/**
 * 更新食谱请求
 */
export interface UpdateRecipeRequest {
  /** 食谱ID */
  recipeId: number;
  /** 食谱标题 */
  title?: string;
  /** 食谱描述 */
  description?: string;
  /** 食谱图片URL列表 */
  imageUrls?: string[];
  /** 食谱步骤列表 */
  steps?: RecipeStepVO[];
  /** 食材列表 */
  ingredients?: IngredientEnum[];
}

/**
 * 食谱搜索请求
 */
export interface RecipeSearchRequest {
  /** 关键词 */
  keyword?: string;
  /** 食材筛选 */
  ingredients?: IngredientEnum[];
  /** 状态筛选 */
  status?: RecipeStatus;
  /** 页码 */
  page?: number;
  /** 每页数量 */
  size?: number;
}

/**
 * 创建空的 RecipeVO 对象
 */
export function createEmptyRecipeVO(): RecipeVO {
  return {
    recipeId: null,
    creatorUserId: null,
    title: null,
    description: null,
    stepCount: null,
    createTime: null,
    favouriteNumber: null,
    status: null,
    imageUrls: [],
    steps: [],
    ingredients: []
  };
}

/**
 * 创建空的 RecipeStepVO 对象
 */
export function createEmptyRecipeStepVO(): RecipeStepVO {
  return {
    stepId: null,
    stepNumber: null,
    description: null,
    imageUrls: []
  };
}

/**
 * 获取食材的中文名称
 */
export function getIngredientDisplayName(ingredient: IngredientEnum): string {
  const displayNames: Record<IngredientEnum, string> = {
    [IngredientEnum.RICE]: '大米',
    [IngredientEnum.NOODLE]: '面条',
    [IngredientEnum.WHEAT_FLOUR]: '面粉',
    [IngredientEnum.CORN]: '玉米',
    [IngredientEnum.OAT]: '燕麦',
    [IngredientEnum.MILLET]: '小米',
    [IngredientEnum.PORK]: '猪肉',
    [IngredientEnum.BEEF]: '牛肉',
    [IngredientEnum.LAMB]: '羊肉',
    [IngredientEnum.CHICKEN]: '鸡肉',
    [IngredientEnum.DUCK]: '鸭肉',
    [IngredientEnum.FISH]: '鱼肉',
    [IngredientEnum.SHRIMP]: '虾',
    [IngredientEnum.CRAB]: '蟹',
    [IngredientEnum.CLAM]: '蛤蜊',
    [IngredientEnum.SCALLOP]: '扇贝',
    [IngredientEnum.PRAWN]: '大虾',
    [IngredientEnum.EGG]: '鸡蛋',
    [IngredientEnum.TOFU]: '豆腐',
    [IngredientEnum.SOYBEAN]: '黄豆',
    [IngredientEnum.EDAMAME]: '毛豆',
    [IngredientEnum.PEANUT]: '花生',
    [IngredientEnum.WALNUT]: '核桃',
    [IngredientEnum.ALMOND]: '杏仁',
    [IngredientEnum.SESAME]: '芝麻',
    [IngredientEnum.CABBAGE]: '卷心菜',
    [IngredientEnum.LETTUCE]: '生菜',
    [IngredientEnum.SPINACH]: '菠菜',
    [IngredientEnum.KALE]: '羽衣甘蓝',
    [IngredientEnum.BROCCOLI]: '西兰花',
    [IngredientEnum.CAULIFLOWER]: '花菜',
    [IngredientEnum.CARROT]: '胡萝卜',
    [IngredientEnum.POTATO]: '土豆',
    [IngredientEnum.SWEET_POTATO]: '红薯',
    [IngredientEnum.PUMPKIN]: '南瓜',
    [IngredientEnum.EGGPLANT]: '茄子',
    [IngredientEnum.CUCUMBER]: '黄瓜',
    [IngredientEnum.BELL_PEPPER]: '甜椒',
    [IngredientEnum.CHILI_PEPPER]: '辣椒',
    [IngredientEnum.TOMATO]: '番茄',
    [IngredientEnum.ONION]: '洋葱',
    [IngredientEnum.GARLIC]: '大蒜',
    [IngredientEnum.GINGER]: '生姜',
    [IngredientEnum.SPRING_ONION]: '小葱',
    [IngredientEnum.CORIANDER]: '香菜',
    [IngredientEnum.MUSHROOM]: '蘑菇',
    [IngredientEnum.SHIITAKE]: '香菇',
    [IngredientEnum.ENOKI]: '金针菇',
    [IngredientEnum.APPLE]: '苹果',
    [IngredientEnum.BANANA]: '香蕉',
    [IngredientEnum.ORANGE]: '橙子',
    [IngredientEnum.GRAPE]: '葡萄',
    [IngredientEnum.STRAWBERRY]: '草莓',
    [IngredientEnum.BLUEBERRY]: '蓝莓',
    [IngredientEnum.MANGO]: '芒果',
    [IngredientEnum.PINEAPPLE]: '菠萝',
    [IngredientEnum.WATERMELON]: '西瓜',
    [IngredientEnum.MELON]: '甜瓜',
    [IngredientEnum.PEACH]: '桃子',
    [IngredientEnum.PEAR]: '梨',
    [IngredientEnum.PLUM]: '李子',
    [IngredientEnum.KIWI]: '猕猴桃',
    [IngredientEnum.MILK]: '牛奶',
    [IngredientEnum.CHEESE]: '奶酪',
    [IngredientEnum.YOGURT]: '酸奶',
    [IngredientEnum.BUTTER]: '黄油',
    [IngredientEnum.SUGAR]: '白糖',
    [IngredientEnum.SALT]: '食盐',
    [IngredientEnum.SOY_SAUCE]: '酱油',
    [IngredientEnum.VINEGAR]: '醋',
    [IngredientEnum.COOKING_WINE]: '料酒',
    [IngredientEnum.BLACK_PEPPER]: '黑胡椒',
    [IngredientEnum.WHITE_PEPPER]: '白胡椒',
    [IngredientEnum.CURRY_POWDER]: '咖喱粉',
    [IngredientEnum.CUMIN]: '孜然',
    [IngredientEnum.FIVE_SPICE]: '五香粉',
    [IngredientEnum.BASIL]: '罗勒',
    [IngredientEnum.ROSEMARY]: '迷迭香',
    [IngredientEnum.THYME]: '百里香',
    [IngredientEnum.OTHER]: '其他'
  };
  return displayNames[ingredient] || ingredient;
}

/**
 * 获取食谱状态的中文名称
 */
export function getRecipeStatusDisplayName(status: RecipeStatus): string {
  const displayNames: Record<RecipeStatus, string> = {
    [RecipeStatus.DRAFT]: '草稿',
    [RecipeStatus.PUBLISHED]: '已发布',
    [RecipeStatus.HIDDEN]: '已隐藏'
  };
  return displayNames[status] || status;
}
