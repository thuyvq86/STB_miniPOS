package com.stb.minipos.ui;

import java.util.Timer;
import java.util.TimerTask;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.Window;

import com.crashlytics.android.Crashlytics;
import com.stb.minipos.R;

public class SplashActivity extends Activity {
	private Timer timer;
	private Handler handler;
	private boolean isCanceled = false;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_splash);

		timer = new Timer();

		timer.schedule(new TimerTask() {
			@Override
			public void run() {
				timer = null;
				if (!isCanceled) {
					Intent intent = new Intent(SplashActivity.this,
							MiniPosActivity.class);
					startActivity(intent);
					finish();
				}
			}
		}, 2000);

		handler = new Handler();
		handler.postDelayed(new Runnable() {
			@Override
			public void run() {
				handler = null;
				if (SplashActivity.this != null
						&& !SplashActivity.this.isFinishing())
					Crashlytics.start(SplashActivity.this);
			}
		}, 100);
	}
	private void cancelTask() {
		if (timer != null) {
			try {
				timer.cancel();
				isCanceled = true;
			} catch (Exception e) {
				e.printStackTrace();
			}
			timer = null;
		}
	}
	@Override
	public void finish() {
		super.finish();
		cancelTask();
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		cancelTask();
	}

}
