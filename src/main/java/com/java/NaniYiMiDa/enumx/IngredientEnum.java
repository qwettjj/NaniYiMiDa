package com.java.NaniYiMiDa.enumx;

import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import lombok.Getter; // 依然可以使用lombok来生成getDisplayName()，或者手动编写

/**
 * 常见食材枚举，包含尽可能多的基础食材信息，方便后续扩展使用。
 */
public enum IngredientEnum {
	// 谷物/主食
	RICE("大米", "米饭", "白米"), // 添加中文别名
	NOODLE("面条", "面"),
	WHEAT_FLOUR("小麦粉", "面粉", "高筋粉", "低筋粉"),
	CORN("玉米", "玉蜀黍"),
	OAT("燕麦", "麦片"),
	MILLET("小米"),

	// 肉类/海鲜
	PORK("猪肉", "猪"),
	BEEF("牛肉", "牛"),
	LAMB("羊肉", "羊"),
	CHICKEN("鸡肉", "鸡", "鸡腿", "鸡翅"), // 添加常见鸡肉部位
	DUCK("鸭肉", "鸭"),
	FISH("鱼肉", "鱼"),
	SHRIMP("虾", "鲜虾"),
	CRAB("蟹", "螃蟹"),
	CLAM("蛤蜊", "花甲"),
	SCALLOP("扇贝"),
	PRAWN("大虾", "明虾"),

	// 豆制品/坚果/蛋类
	EGG("鸡蛋", "蛋", "鸭蛋", "鹅蛋"), // 添加其他常见蛋类
	TOFU("豆腐", "豆干"),
	SOYBEAN("黄豆", "大豆"),
	EDAMAME("毛豆"),
	PEANUT("花生", "落花生"),
	WALNUT("核桃"),
	ALMOND("杏仁"),
	SESAME("芝麻"),

	// 蔬菜
	CABBAGE("卷心菜", "包菜", "圆白菜"),
	LETTUCE("生菜"),
	SPINACH("菠菜"),
	KALE("羽衣甘蓝"),
	BROCCOLI("西兰花"),
	CAULIFLOWER("菜花", "花菜"),
	CARROT("胡萝卜"),
	POTATO("土豆", "马铃薯", "洋芋", "POTATOES"), // 添加中文同义词和英文复数
	SWEET_POTATO("红薯", "地瓜", "番薯"),
	PUMPKIN("南瓜"),
	EGGPLANT("茄子"),
	CUCUMBER("黄瓜"),
	BELL_PEPPER("彩椒", "甜椒", "柿子椒"),
	CHILI_PEPPER("辣椒", "海椒", "红椒", "青椒"), // 添加常见辣椒类型
	TOMATO("西红柿", "番茄", "TOMATOES"), // 添加中文同义词和英文复数
	ONION("洋葱", "葱头"),
	GARLIC("大蒜", "蒜"),
	GINGER("生姜", "姜"),
	SPRING_ONION("葱", "小葱", "香葱"),
	CORIANDER("香菜", "芫荽"),
	MUSHROOM("蘑菇", "菌菇"),
	SHIITAKE("香菇"),
	ENOKI("金针菇"),

	// 水果
	APPLE("苹果"),
	BANANA("香蕉"),
	ORANGE("橙子", "橘子"), // 添加中文同义词
	GRAPE("葡萄"),
	STRAWBERRY("草莓"),
	BLUEBERRY("蓝莓"),
	MANGO("芒果"),
	PINEAPPLE("菠萝", "凤梨"), // 添加中文同义词
	WATERMELON("西瓜"),
	MELON("哈密瓜", "甜瓜"),
	PEACH("桃子"),
	PEAR("梨"),
	PLUM("李子"),
	KIWI("奇异果", "猕猴桃"), // 添加中文同义词

	// 奶制品
	MILK("牛奶", "乳"),
	CHEESE("奶酪", "芝士"),
	YOGURT("酸奶"),
	BUTTER("黄油"),

	// 调味品
	SUGAR("白糖", "糖"),
	SALT("食盐", "盐"),
	SOY_SAUCE("生抽", "酱油"),
	VINEGAR("食醋", "醋"),
	COOKING_WINE("料酒"),
	BLACK_PEPPER("黑胡椒", "胡椒粉"),
	WHITE_PEPPER("白胡椒"),
	CURRY_POWDER("咖喱粉", "咖喱"),
	CUMIN("孜然", "小茴香"),
	FIVE_SPICE("五香粉"),
	BASIL("罗勒"),
	ROSEMARY("迷迭香"),
	THYME("百里香"),
	OTHER("其他", "Other");

	@Getter
	private final String displayName;
	private final Set<String> matchableStrings;

	IngredientEnum(String displayName, String... aliases) {
		this.displayName = displayName;
		this.matchableStrings = new HashSet<>();

		this.matchableStrings.add(displayName.toUpperCase());

		this.matchableStrings.add(this.name().toUpperCase());
		this.matchableStrings.add(this.name().replace('_', ' ').toUpperCase()); // 例如 CHICKEN_BREAST -> CHICKEN BREAST
		this.matchableStrings.add(this.name().replace('_', ' ').toUpperCase()); // 例如 CHICKEN_BREAST -> CHICKENBREAST

		for (String alias : aliases) {
			this.matchableStrings.add(alias.toUpperCase());
		}
	}

	public Set<String> getMatchableStrings() {
		return Collections.unmodifiableSet(matchableStrings);
	}
}
