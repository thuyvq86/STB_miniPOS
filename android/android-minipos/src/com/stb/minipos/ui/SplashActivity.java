package com.stb.minipos.ui;

import java.util.Observable;
import java.util.Observer;
import java.util.Timer;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.view.View;
import android.view.Window;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.crashlytics.android.Crashlytics;
import com.stb.minipos.R;
import com.stb.minipos.model.STBApiManager;
import com.stb.minipos.model.STBApiManager.ApiResponseData;
import com.stb.minipos.model.dao.STBResponseVersion;
import com.stb.minipos.ui.BasePOSActivity._SYSTEMTIME;
import com.stb.minipos.utils.Utils;

public class SplashActivity extends BaseActivity implements Observer {
	private Timer timer;
	private Handler handler;
	private TextView txtStatus;

	private ProgressBar loadingBar;

	private boolean needCheckVersion = false;
	private boolean isCheckingVersion = false;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_splash);
		STBApiManager.instance().addObserver(this);

		txtStatus = (TextView) findViewById(R.id.txtStatus);
		loadingBar = (ProgressBar) findViewById(R.id.loadingBar);

		timer = new Timer();
		Crashlytics.start(SplashActivity.this);

		handler = new Handler();
		handler.postDelayed(new Runnable() {
			@Override
			public void run() {
				handler = null;
				if (SplashActivity.this != null
						&& !SplashActivity.this.isFinishing()) {
					loadingBar.setVisibility(View.VISIBLE);
					txtStatus.setText("Loading...");
					if (checkNetworkSettings()) {
						checkVersion();
					} else { // setting not available, version will be checked
								// after the setting is available.
						needCheckVersion = true;
					}
				}
			}
		}, 1000);
	}

	public void checkVersion() {
		if (isCheckingVersion) {
			return;
		}
		isCheckingVersion = true;
		txtStatus.setText("Check for updates...");
		loadingBar.setVisibility(View.VISIBLE);
		STBApiManager.instance().getVersion();
	}

	public void handleCheckVersionResponse(ApiResponseData response) {
		txtStatus.setText("");
		loadingBar.setVisibility(View.INVISIBLE);
		if (response != null && response.isSuccess
				&& response.stbResponse.isSuccess()) {
			STBResponseVersion data = (STBResponseVersion) response.stbResponse
					.getData();
			if (!TextUtils.equals(data.Version, Utils.getVersionName(this))) {
				alertUserToUpdateApp(data.IsForcedUpdate);
			} else {
				Intent intent = new Intent(SplashActivity.this,
						MiniPosActivity.class);
				startActivity(intent);
				finish();
				needCheckVersion = false;
				isCheckingVersion = false;
			}
		} else {
			alertUserRequestFailure();
		}
	}

	@Override
	public void onNetworkAvailable() {
		super.onNetworkAvailable();
		if (needCheckVersion) {
			needCheckVersion = false;
			checkVersion();
		}
	}

	@Override
	protected void onResume() {
		super.onResume();
		if (needCheckVersion && checkNetworkSettings()) {
			checkVersion();
		}
	}

	public void alertUserRequestFailure() {
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setMessage("Cannot connect to server. Please check your internet connection and try again!");
		builder.setPositiveButton("Retry",
				new DialogInterface.OnClickListener() {

					@Override
					public void onClick(DialogInterface dialog, int which) {
						isCheckingVersion = false;
						checkVersion();
					}
				});
		builder.setNegativeButton("Cancel",
				new DialogInterface.OnClickListener() {

					@Override
					public void onClick(DialogInterface dialog, int which) {
						finish();
						isCheckingVersion = false;
					}
				});
		builder.setCancelable(false);
		builder.create().show();
	}

	public void alertUserToUpdateApp(final boolean isForceUpdate) {
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setTitle("New version is available");
		builder.setMessage("Please update the application to continue");
		builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				Utils.openGoolgePlayApps(SplashActivity.this,
						SplashActivity.this.getPackageName());
				isCheckingVersion = false;
				needCheckVersion = true;
			}
		});
		builder.setNegativeButton("Cancel",
				new DialogInterface.OnClickListener() {

					@Override
					public void onClick(DialogInterface dialog, int which) {
						if (isForceUpdate) {
							finish();
						}
						isCheckingVersion = false;
					}
				});
		builder.setCancelable(false);
		builder.create().show();
	}

	private void cancelTask() {
		if (timer != null) {
			try {
				timer.cancel();
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
