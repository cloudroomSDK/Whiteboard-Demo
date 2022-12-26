package com.examples.tool;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RoundRectShape;

public class DrawableUtils {

    /**
     * 获取圆角背景图
     *
     * @param bgColor 背景颜色
     * @param corner 圆角弧度
     */
    public static ShapeDrawable getShapeDrawable(int bgColor, int corner) {
        ShapeDrawable mDrawable = new ShapeDrawable(new RoundRectShape(new float[]{corner, corner, corner,
                corner, corner, corner, corner, corner}, null, null));
        mDrawable.getPaint().setColor(bgColor);
        return mDrawable;
    }

    /**
     * @param orientation 渐变方向，需要有渐变效果时，不能为null
     * @param colors      渐变色，只有一个值时没有渐变效果
     * @param strokeWidth 描边宽度
     * @param strokeColor 描边颜色
     * @return Drawable对象
     * <p>
     * 矩形渐变Drawable
     */
    public static Drawable getRectDrawable(GradientDrawable.Orientation orientation, int[] colors, int strokeWidth, int strokeColor) {
        return getRoundRectDrawable(orientation, new float[]{0}, colors, strokeWidth, strokeColor);
    }

    /**
     * @param orientation 渐变方向，需要有渐变效果时，不能为null
     * @param radii       圆角半径
     * @param colors      渐变色，只有一个值时没有渐变效果
     * @param strokeWidth 描边宽度
     * @param strokeColor 描边颜色
     * @return Drawable对象
     * <p>
     * 圆角矩形渐变Drawable
     */
    public static Drawable getRoundRectDrawable(GradientDrawable.Orientation orientation, float[] radii, int[] colors,
                                                int strokeWidth, int strokeColor) {
        if (colors != null && colors.length == 0) {
            throw new IllegalArgumentException("needs >= 1 number of colors when colors != null");
        }

        if (radii != null && radii.length != 1 && radii.length != 8) {
            throw new IllegalArgumentException("needs == 1 || == 8 number of radii when radii != null");
        }

        if (colors != null && colors.length > 1 && orientation == null) {
            throw new IllegalArgumentException("needs orientation != null when colors.length >= 1");
        }

        GradientDrawable drawable = new GradientDrawable(orientation, null);

        // 设置圆角效果
        if (radii != null) {
            if (radii.length > 1) {
                drawable.setCornerRadii(radii);
            } else {
                drawable.setCornerRadius(radii[0]);
            }
        }

        // 设置渐变效果
        if (colors != null) {
            if (colors.length > 1) {
                drawable.setColors(colors);
            } else {
                drawable.setColor(colors[0]);
            }
        }

        // 设置描边效果
        if (strokeWidth > 0) {
            drawable.setStroke(strokeWidth, strokeColor);
        }

        return drawable;
    }

    /**
     * @param context       context
     * @param contentColor  填充颜色
     * @param radius        圆角半径，最小值为1，否则无阴影效果
     * @param shadowSize    阴影大小
     * @param maxShadowSize 阴影扩展
     * @return Drawable对象
     * <p>
     * 带阴影效果Drawable
     */
    public static Drawable getShadowDrawable(Context context, int contentColor, int radius, int shadowSize, int maxShadowSize) {
//        radius = radius < 1 ? 0 : radius;
        return new ShadowDrawableWrapperOverlay(
                context,
                getRoundRectDrawable(
                        null,
                        new float[]{radius, radius, radius, radius, radius, radius, radius, radius},
                        new int[]{contentColor}, 0, 0),
                radius,
                shadowSize,
                maxShadowSize);
    }

    /**
     * @param context       context
     * @param drawable      填充drawable
     * @param radius        圆角半径
     * @param shadowSize    阴影大小
     * @param maxShadowSize 阴影扩展
     * @return Drawable对象
     * <p>
     * 带阴影效果Drawable
     */
    public static Drawable getShadowDrawable(Context context, Drawable drawable, int radius, int shadowSize, int maxShadowSize) {
        return new ShadowDrawableWrapperOverlay(context, drawable, radius, shadowSize, maxShadowSize);
    }
}
