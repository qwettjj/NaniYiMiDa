package com.java.NaniYiMiDa.enumx;

public enum NutritionEnum {
    ENERGY("能量"),
    PROTEIN("蛋白质"),
    CARBOHYDRATES("碳水化合物"),
    FAT("脂肪"),
    SATURATED_FAT("饱和脂肪"),
    UNSATURATED_FAT("不饱和脂肪"),
    TRANS_FAT("反式脂肪"),
    CHOLESTEROL("胆固醇"),
    FIBER("纤维"),
    SUGARS("糖"),
    VITAMIN_A("维生素A"),
    VITAMIN_B1("维生素B1"),
    VITAMIN_B2("维生素B2"),
    VITAMIN_B3("维生素B3"),
    VITAMIN_B6("维生素B6"),
    VITAMIN_B12("维生素B12"),
    VITAMIN_C("维生素C"),
    VITAMIN_D("维生素D"),
    VITAMIN_E("维生素E"),
    VITAMIN_K("维生素K"),
    FOLIC_ACID("叶酸"),
    PANTOTHENIC_ACID("泛酸"),
    BIOTIN("生物素"),
    CALCIUM("钙"),
    IRON("铁"),
    MAGNESIUM("镁"),
    PHOSPHORUS("磷"),
    POTASSIUM("钾"),
    SODIUM("钠"),
    ZINC("锌"),
    COPPER("铜"),
    MANGANESE("锰"),
    SELENIUM("硒"),
    CHROMIUM("铬"),
    MOLYBDENUM("钼"),
    IODINE("碘"),
    WATER("水");

    private final String description;

    NutritionEnum(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
