package com.cloudroom.whiteboardkt;

import android.content.res.Configuration;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.examples.common.PermissionManager;

public class BaseActivity extends AppCompatActivity {

    private static boolean mHasRequested = false;

    protected Handler mainhandler = new Handler();

	@Override
	protected void onCreate(Bundle savedInstanceState) {
        refreshStatusBarStyle(getResources().getConfiguration());
		super.onCreate(savedInstanceState);
        if (!PermissionManager.getInstance().checkPermission(PermissionManager.STORATION_PERMISSION)) {
            PermissionManager.getInstance().applySDKPermissions(this);
        } else {
            mainhandler.post(new Runnable() {
                @Override
                public void run() {
                    onRequestPermissionsFinished();
                }
            });
        }
		DemoApp.getInstance().onActivityCreate(this);
	}

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions,
                                           int[] grantResults) {
        mHasRequested = true;
        onRequestPermissionsFinished();
    }

    @Override
    public void onConfigurationChanged(@NonNull Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        refreshStatusBarStyle(newConfig);
    }

    private void refreshStatusBarStyle(@NonNull Configuration newConfig) {
        if (newConfig.orientation==Configuration.ORIENTATION_LANDSCAPE){
            getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_FULLSCREEN);
        }else {
            getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
        }
    }

    @Override
	protected void onDestroy() {

		super.onDestroy();
		DemoApp.getInstance().onActivityDestroy(this);
	}

    protected void onRequestPermissionsFinished() {
       DemoApp.getInstance().initCloudroomVideoSDK();
    }
}
