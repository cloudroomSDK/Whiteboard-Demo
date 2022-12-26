package com.examples.tool;

import android.app.ActivityManager;
import android.content.Context;
import android.content.pm.ConfigurationInfo;

public class Tools {

	public static String getTimeStr(int sec) {
		int s = sec % 60;
		int m = sec / 60;
		int h = m / 60;
		StringBuffer time = new StringBuffer();
		if (h > 0) {
			time.append(h).append("小时");
		}
		if (m > 0) {
			time.append(m).append("分");
		}
		time.append(s).append("秒");
		return time.toString();
	}

	public static boolean detectOpenGLES20(Context context) {
		ActivityManager am = (ActivityManager) context
				.getSystemService(Context.ACTIVITY_SERVICE);
		ConfigurationInfo info = am.getDeviceConfigurationInfo();
		return (info.reqGlEsVersion >= 0x20000);
	}

	/**
	 * sp转换成px
	 */
	public static int sp2px(Context context, float spValue) {
		float fontScale = context.getResources().getDisplayMetrics().scaledDensity;
		return (int) (spValue * fontScale + 0.5f);
	}

	public static int dp2px(Context context, int dpValue) {
		float scale = context.getResources().getDisplayMetrics().density;
		return (int) (dpValue * scale + 0.5f);
	}

	// public static void YUV420P2RGB565(int[] rgb, byte[] yuv420sp, int width,
	// int height) {
	//
	// final int frameSize = width * height;
	// for (int j = 0, yp = 0; j < height; j++) {
	// int vp = frameSize * 5 / 4 + (j >> 2) * width;
	// int up = frameSize + (j >> 2) * width, u = 0, v = 0;
	// for (int i = 0; i < width; i++, yp++) {
	// int y = (0xff & ((int) yuv420sp[yp])) - 16;
	// if (y < 0)
	// y = 0;
	// v = (0xff & yuv420sp[vp + (i >> 1)]) - 128;
	// u = (0xff & yuv420sp[up + (i >> 1)]) - 128;
	//
	// int y1192 = 1192 * y;
	// int r = (y1192 + 1634 * v);
	// int g = (y1192 - 833 * v - 400 * u);
	// int b = (y1192 + 2066 * u);
	//
	// if (r < 0)
	// r = 0;
	// else if (r > 262143)
	// r = 262143;
	// if (g < 0)
	// g = 0;
	// else if (g > 262143)
	// g = 262143;
	// if (b < 0)
	// b = 0;
	// else if (b > 262143)
	// b = 262143;
	//
	// rgb[yp] = 0xff000000 | ((r << 6) & 0xff0000)
	// | ((g >> 2) & 0xff00) | ((b >> 10) & 0xff);
	// }
	// }
	// }
}
