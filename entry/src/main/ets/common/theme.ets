/**
 * 应用主题配置
 * 定义全局颜色、字体、间距等样式规范
 */

/**
 * 主题色
 */
export class AppColors {
  // 主色调 - 美食橙
  static readonly PRIMARY = '#FF6B35';
  static readonly PRIMARY_LIGHT = '#FF8C5A';
  static readonly PRIMARY_DARK = '#E54D1F';
  
  // 辅助色 - 绿色（健康）
  static readonly ACCENT = '#4ECDC4';
  static readonly ACCENT_LIGHT = '#6FE0D7';
  static readonly ACCENT_DARK = '#3CB8AF';
  
  // 背景色
  static readonly BG_PRIMARY = '#FFFFFF';
  static readonly BG_SECONDARY = '#F8F9FA';
  static readonly BG_TERTIARY = '#F5F5F5';
  
  // 文字颜色
  static readonly TEXT_PRIMARY = '#212529';
  static readonly TEXT_SECONDARY = '#6C757D';
  static readonly TEXT_TERTIARY = '#ADB5BD';
  static readonly TEXT_INVERSE = '#FFFFFF';
  
  // 边框颜色
  static readonly BORDER_LIGHT = '#E9ECEF';
  static readonly BORDER_MEDIUM = '#DEE2E6';
  static readonly BORDER_DARK = '#CED4DA';
  
  // 状态颜色
  static readonly SUCCESS = '#28A745';
  static readonly WARNING = '#FFC107';
  static readonly ERROR = '#DC3545';
  static readonly INFO = '#17A2B8';
  
  // 阴影颜色
  static readonly SHADOW_LIGHT = 'rgba(0, 0, 0, 0.05)';
  static readonly SHADOW_MEDIUM = 'rgba(0, 0, 0, 0.1)';
  static readonly SHADOW_DARK = 'rgba(0, 0, 0, 0.15)';
}

/**
 * 字体规范
 */
export class AppFonts {
  // 字号
  static readonly HEADING_1 = 28;
  static readonly HEADING_2 = 24;
  static readonly HEADING_3 = 20;
  static readonly HEADING_4 = 18;
  static readonly BODY_LARGE = 16;
  static readonly BODY = 14;
  static readonly BODY_SMALL = 12;
  static readonly CAPTION = 10;
  
  // 字重
  static readonly WEIGHT_BOLD = FontWeight.Bold;
  static readonly WEIGHT_MEDIUM = FontWeight.Medium;
  static readonly WEIGHT_REGULAR = FontWeight.Normal;
}

/**
 * 间距规范
 */
export class AppSpacing {
  static readonly XS = 4;
  static readonly SM = 8;
  static readonly MD = 12;
  static readonly LG = 16;
  static readonly XL = 20;
  static readonly XXL = 24;
  static readonly XXXL = 32;
}

/**
 * 圆角规范
 */
export class AppRadius {
  static readonly SM = 4;
  static readonly MD = 8;
  static readonly LG = 12;
  static readonly XL = 16;
  static readonly XXL = 20;
  static readonly ROUND = 999;
}

/**
 * 动画时长
 */
export class AppDurations {
  static readonly FAST = 150;
  static readonly NORMAL = 300;
  static readonly SLOW = 500;
}
