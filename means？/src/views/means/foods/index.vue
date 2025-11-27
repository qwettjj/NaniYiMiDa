<template>
  <div class="recipe-list-container">
    <h1 class="list-title">🍳 菜谱收录展示</h1>
    
    <div class="filter-options">
      <div class="filter-group">
        <label>难度:</label>
        <select v-model="filters.difficulty" class="filter-select">
          <option value="">全部</option>
          <option value="easy">简单</option>
          <option value="medium">中等</option>
          <option value="hard">困难</option>
        </select>
      </div>
      
      <div class="filter-group">
        <label>烹饪时间:</label>
        <select v-model="filters.cookTime" class="filter-select">
          <option value="">全部</option>
          <option value="short">30分钟以内</option>
          <option value="medium">30-60分钟</option>
          <option value="long">60分钟以上</option>
        </select>
      </div>
    </div>
    
    <div class="recipe-list">
      <div 
        v-for="recipe in filteredRecipes" 
        :key="recipe.id" 
        class="recipe-item"
      >
        <div class="recipe-image">
          <img 
            :src="recipe.imageUrl" 
            :alt="recipe.title"
            class="recipe-img"
            v-if="recipe.imageUrl"
          />
          <div class="image-placeholder" v-else>
            <span class="placeholder-icon">🍲</span>
          </div>
        </div>
        
        <div class="recipe-content">
          <h3 class="recipe-title">{{ recipe.title }}</h3>          <p class="recipe-description">{{ recipe.description }}</p>
          
          <div class="recipe-details">
            <div class="detail-section">
              <h4>📝 主要食材：</h4>
              <ul class="ingredients-list">
                <li v-for="(ingredient, index) in recipe.ingredients" :key="index">
                  {{ ingredient }}
                </li>
              </ul>
            </div>
            
            <div class="detail-section">
              <h4>🧂 调味料：</h4>
              <ul class="seasonings-list">
                <li v-for="(seasoning, index) in recipe.seasonings" :key="index">
                  {{ seasoning }}
                </li>
              </ul>
            </div>
          </div>
          
          <div class="recipe-meta">
            <span class="meta-item">
              <span class="icon">⭐</span>
              <span>{{ difficultyText(recipe.difficulty) }}</span>
            </span>
            <span class="meta-item">
              <span class="icon">⏱️</span>
              <span>{{ recipe.cookTime }}分钟</span>
            </span>
            <span class="meta-item">
              <span class="icon">👥</span>
              <span>{{ recipe.servings }}人份</span>
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'

// 定义菜谱类型
interface Recipe {
  id: number
  title: string
  description: string
  difficulty: 'easy' | 'medium' | 'hard'
  cookTime: number
  servings: number
  imageUrl?: string
  ingredients: string[]
  seasonings: string[]
}


const recipes: Recipe[] = [
  {
    id: 1,
    title: '番茄炒蛋',
    description: '经典家常菜，简单美味，营养丰富',
    difficulty: 'easy',
    cookTime: 15,
    servings: 2,
    imageUrl: 'https://ts1.tc.mm.bing.net/th/id/R-C.3245f20b6c034d9b4e3390bd58ddbc1e?rik=6cL0BlrlKSUsVw&riu=http%3a%2f%2fp11.qhimg.com%2ft0157253a40538d67a4.jpg&ehk=3xha4arGtTTepuLTr6JLUO9valkPmIGcwlz4FIlQChI%3d&risl=&pid=ImgRaw&r=0',
    ingredients: ['鸡蛋 3个', '番茄 2个', '葱 1根', '盐 适量', '糖 1小勺'],
    seasonings: ['食用油', '生抽', '白胡椒粉']
  },
  {
    id: 2,
    title: '红烧肉',
    description: '传统中式菜肴，肥而不腻，入口即化',
    difficulty: 'medium',
    cookTime: 60,
    servings: 4,
    imageUrl: 'https://materials.cdn.bcebos.com/images/69370566/2a0f0dcdc9cb9d9a74bc87e4d005a44b.jpeg',
    ingredients: ['五花肉 500g', '生姜 1块', '葱 2根', '冰糖 20g'],
    seasonings: ['生抽', '老抽', '料酒', '八角', '桂皮']
  },
  {
    id: 3,
    title: '清蒸鲈鱼',
    description: '营养丰富的海鲜菜品，保持原汁原味',
    difficulty: 'medium',
    cookTime: 30,
    servings: 3,
    imageUrl: 'https://ts1.tc.mm.bing.net/th/id/R-C.ebb6af4e5a7b157d5aa86d2947b6c6e5?rik=ZFHTmmj6kGzm0A&riu=http%3a%2f%2fcp1.douguo.net%2fupload%2fcaiku%2f2%2f4%2f2%2fyuan_246e4c537d5e9a6d08e1eba163f63ba2.jpg&ehk=0I6B2peQ5q%2fLlp8i16jgRvJeS9wbauHmff%2fTiui42dU%3d&risl=&pid=ImgRaw&r=0',
    ingredients: ['鲈鱼 1条约500g', '生姜 1块', '葱 2根', '红椒 半个'],
    seasonings: ['蒸鱼豉油', '料酒', '盐', '食用油']
  },
  {
    id: 4,
    title: '牛肉拉面',
    description: '西北特色面食，汤头浓郁，面条劲道',
    difficulty: 'hard',
    cookTime: 120,
    servings: 4,
    imageUrl: 'https://ts1.tc.mm.bing.net/th/id/R-C.596ad139ae04636d8a5c6f0d3f1a3e4f?rik=7pA8CVoXEAcQuA&riu=http%3a%2f%2fi2.chuimg.com%2ffebff45487e211e6b87c0242ac110003_700w_530h.jpg%3fimageView2%2f2%2fw%2f660%2finterlace%2f1%2fq%2f90&ehk=XzxxsNuLAfZogKpXlqLUBfofnyvnXaPcOBW1E%2fbv6%2fk%3d&risl=&pid=ImgRaw&r=0',
    ingredients: ['牛骨 1kg', '牛肉 300g', '拉面 400g', '白萝卜 1个', '香菜 适量'],
    seasonings: ['生姜', '葱', '八角', '草果', '花椒', '辣椒油']
  }
]

// 筛选条件
const filters = ref({
  difficulty: '',
  cookTime: ''
})

// 计算属性
const filteredRecipes = computed(() => {
  let result = [...recipes]
  
  if (filters.value.difficulty) {
    result = result.filter(recipe => recipe.difficulty === filters.value.difficulty)
  }
  
  if (filters.value.cookTime) {
    result = result.filter(recipe => {
      switch (filters.value.cookTime) {
        case 'short': return recipe.cookTime <= 30
        case 'medium': return recipe.cookTime > 30 && recipe.cookTime <= 60
        case 'long': return recipe.cookTime > 60
        default: return true
      }
    })
  }
  
  return result.slice(0, 4) // 固定展示4个食谱
})

// 方法
const router = useRouter()
const viewRecipe = (id: number) => {
  router.push(`/recipes/${id}`)
}

const difficultyText = (difficulty: string): string => {
  const map = {
    easy: '简单',
    medium: '中等',
    hard: '困难'
  }
  return map[difficulty as keyof typeof map] || difficulty
}
</script>

<style scoped>
.recipe-list-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 30px 20px;
  font-family: 'Arial', sans-serif;
}

.list-title {
  text-align: center;
  color: #333;
  margin-bottom: 30px;
  font-size: 2.5rem;
}

.filter-options {
  display: flex;
  justify-content: center;
  gap: 30px;
  margin-bottom: 40px;
  flex-wrap: wrap;
}

.filter-group {
  display: flex;
  align-items: center;
  gap: 10px;
}

.filter-select {
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 0.9rem;
}

.recipe-list {
  display: flex;
  flex-direction: column;
  gap: 30px;
}

.recipe-item {
  display: flex;
  background-color: white;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  cursor: pointer;
  transition: transform 0.3s, box-shadow 0.3s;
  height: 280px;
}

.recipe-item:hover {
  transform: translateY(-5px);
  box-shadow: 0 6px 15px rgba(0, 0, 0, 0.15);
}

.recipe-image {
  width: 35%;
  min-width: 35%;
}

.recipe-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-placeholder {
  width: 100%;
  height: 100%;
  background-color: #f8f9fa;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 4rem;
  color: #ff6b6b;
}

.recipe-content {
  padding: 25px;
  width: 65%;
  display: flex;
  flex-direction: column;
}

.recipe-title {
  margin: 0 0 15px 0;
  color: #333;
  font-size: 1.5rem;
}

.recipe-description {
  color: #666;
  font-size: 1rem;
  margin-bottom: 20px;
  line-height: 1.5;
}

.recipe-details {
  display: flex;
  flex-direction: column;
  gap: 15px;
  margin-bottom: 20px;
  flex-grow: 1;
}

.detail-section {
  margin-bottom: 10px;
}

.detail-section h4 {
  margin: 0 0 8px 0;
  color: #444;
  font-size: 0.95rem;
}

.ingredients-list,
.seasonings-list {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 8px;
  padding-left: 20px;
  margin: 0;
  font-size: 0.9rem;
  color: #555;
}

.ingredients-list li,
.seasonings-list li {
  list-style-type: disc;
}

.recipe-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  font-size: 0.85rem;
  color: #555;
  align-items: center;
  margin-top: auto;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 5px;
}

@media (max-width: 768px) {
  .recipe-item {
    flex-direction: column;
    height: auto;
  }
  
  .recipe-image,
  .recipe-content {
    width: 100%;
  }
  
  .recipe-image {
    height: 200px;
  }
  
  .ingredients-list,
  .seasonings-list {
    grid-template-columns: 1fr;
  }
}
</style>