package com.stb.minipos.ui;

import java.util.Observable;
import java.util.Observer;
import java.util.Timer;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.Window;
import android.widget.TextView;

import com.crashlytics.android.Crashlytics;
import com.google.gson.Gson;
import com.stb.minipos.R;
import com.stb.minipos.model.STBApiManager;
import com.stb.minipos.model.STBApiManager.ApiResponseData;
import com.stb.minipos.model.dao.STBResponseVersion;
import com.stb.minipos.utils.Utils;

public class SplashActivity extends BaseActivity implements Observer {
	private Timer timer;
	private Handler handler;
	private boolean isCanceled = false;
	private TextView txtStatus;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_splash);
		STBApiManager.instance().addObserver(this);

		txtStatus = (TextView) findViewById(R.id.txtStatus);

		timer = new Timer();

		// timer.schedule(new TimerTask() {
		// @Override
		// public void run() {
		// timer = null;
		// if (!isCanceled) {
		// Intent intent = new Intent(SplashActivity.this,
		// MiniPosActivity.class);
		// startActivity(intent);
		// finish();
		// }
		// }
		// }, 2000);
		Crashlytics.start(SplashActivity.this);

		handler = new Handler();
		handler.postDelayed(new Runnable() {
			@Override
			public void run() {
				handler = null;
				if (SplashActivity.this != null
						&& !SplashActivity.this.isFinishing())

					if (checkNetworkSettings()) {
						checkVersion();
					}
			}
		}, 1000);
	}

	public void checkVersion() {
		txtStatus.setText("Checking application version...");
		STBApiManager.instance().getVersion();
	}

	public void handleCheckVersionResponse(ApiResponseData response) {
		if (response != null && response.isSuccess
				&& response.stbResponse.isSuccess()) {
			STBResponseVersion data = (STBResponseVersion) response.stbResponse
					.getData();
			if (!data.Version.equals("1.0")) {
				txtStatus.setText("Update application to continue");
				alertUserToUpdateApp(data.IsForcedUpdate);

			} else {
				Intent intent = new Intent(SplashActivity.this,
						MiniPosActivity.class);
				startActivity(intent);
				finish();
			}
		}
	}

	public void alertUserToUpdateApp(final boolean isForceUpdate) {
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setTitle("New update available");
		builder.setMessage("Please update the application to continue");
		builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				Utils.openGoolgePlayApps(SplashActivity.this,
						SplashActivity.this.getPackageName());
			}
		});
		builder.setNegativeButton("Cancel",
				new DialogInterface.OnClickListener() {

					@Override
					public void onClick(DialogInterface dialog, int which) {
						if (isForceUpdate) {
							finish();
						}
					}
				});
		builder.setCancelable(false);
		builder.create().show();

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
		STBApiManager.instance().deleteObserver(this);
	}

	@Override
	public void update(Observable observable, Object data) {
		super.update(observable, data);
		if (observable == STBApiManager.instance()) {
			handleCheckVersionResponse((ApiResponseData) data);
		}
	}

}
