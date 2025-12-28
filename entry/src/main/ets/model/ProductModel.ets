export interface Product {
  id: string;
  name: string;
  imageUrl: ResourceStr;
  ingredients: string[];
  allergens: string[]; // 过敏源
}

export const MOCK_PRODUCTS: Record<string, Product> = {
  'NANI_001': {
    id: 'NANI_001',
    name: 'Nani 秘制酱油',
    imageUrl: $r('app.media.startIcon'),
    ingredients: ['水', '非转基因黄豆', '小麦粉', '食用盐', '谷氨酸钠', '白砂糖', '酵母提取物'],
    allergens: ['黄豆', '小麦']
  },
  'NANI_002': {
    id: 'NANI_002',
    name: '香浓花生酱',
    imageUrl: $r('app.media.startIcon'),
    ingredients: ['花生仁', '白砂糖', '植物油', '食用盐', '氢化植物油'],
    allergens: ['花生']
  },
  'NANI_003': {
    id: 'NANI_003',
    name: '全麦面包',
    imageUrl: $r('app.media.startIcon'),
    ingredients: ['全麦粉', '水', '酵母', '食用盐', '黄油', '鸡蛋'],
    allergens: ['小麦', '牛奶', '鸡蛋']
  },
  'NANI_004': {
    id: 'NANI_004',
    name: '纯牛奶',
    imageUrl: $r('app.media.startIcon'),
    ingredients: ['生牛乳'],
    allergens: ['牛奶']
  }
};
