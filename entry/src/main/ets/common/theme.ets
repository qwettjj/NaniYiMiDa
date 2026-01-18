/**
 * 应用主题配置
 * 定义全局颜色、字体、间距等样式规范
 */

/**
 * 主题色
 */
export class AppColors {
  // 主色调 - 美食橙
  static readonly PRIMARY_LIGHT = '#FF8C5A';
  static readonly PRIMARY_DARK = '#E54D1F';
  
  // 辅助色 - 绿色（健康）
  static readonly ACCENT = '#4ECDC4';
  static readonly ACCENT_LIGHT = '#6FE0D7';
  static readonly ACCENT_DARK = '#3CB8AF';

  // 背景色
  static readonly BG_TERTIARY = '#F5F5F5';

  // 文字颜色
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

  static readonly BG_PRIMARY = '#E3C7A4';        // 主背景色
  static readonly BG_SECONDARY = '#FAF6F0';     // 顶部栏和底部栏背景色（对应 .bottom-nav 的 background）
  static readonly TEXT_PRIMARY = '#602F27';     // 主要字体颜色
  static readonly TEXT_SECONDARY = '#8E8E93';   // 次要字体颜色
  static readonly PRIMARY_ACCENT = '#8E422F';   // 按钮橙色/主色调

  // 原有颜色（如果还有其他颜色）
  static readonly PRIMARY = '#8E422F';          // 与 PRIMARY_ACCENT 相同
  static readonly TEXT_TERTIARY = '#8E8E93';    // 与 TEXT_SECONDARY 相同
  static readonly WHITE = '#FFFFFF';
  static readonly BLACK = '#000000';
  static readonly C10 = '#FAF6F0';
  static readonly C20 = '#F2E5D3';
  static readonly C30 = '#E3C7A4';
  static readonly C40 = '#D5A874';
  static readonly C50 = '#CB8E54';
  static readonly C60 = '#C07240';
  static readonly C70 = '#A85835';
  static readonly C80 = '#8E422F';
  static readonly C90 = '#74362C';
  static readonly C100 = '#602F27';
  // 透明度辅助颜色
  static getPrimaryWithAlpha(alpha: number): string {
    // 将 HEX 颜色转换为 RGBA
    const hex = AppColors.PRIMARY_ACCENT; // 直接使用类名访问静态属性
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    return `rgba(${r}, ${g}, ${b}, ${alpha})`;
  }
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
