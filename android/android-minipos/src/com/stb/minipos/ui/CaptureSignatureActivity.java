package com.stb.minipos.ui;

import java.util.Timer;
import java.util.TimerTask;

import android.content.Intent;
import android.os.Bundle;
import android.os.SystemClock;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.github.gcacace.signaturepad.views.SignaturePad;
import com.stb.minipos.R;
import com.stb.minipos.model.POSManager;
import com.stb.minipos.model.STBProfile;
import com.stb.minipos.ui.view.SignatureView;
import com.stb.minipos.utils.UIUtils;
import com.stb.minipos.utils.Utils;

public class CaptureSignatureActivity extends BaseActivity {
	private static final String TAG = "PCLSIGNCAP";
	private static final int SIGN_CAPTURE_OK = RESULT_OK;
	private static final int SIGN_CAPTURE_KO = RESULT_CANCELED;
	private static final int SIGN_CAPTURE_TIMEOUT = RESULT_FIRST_USER;
	SignatureView mSignature;
	Button mClear, mGetSign, mCancel;
	private TextView txtMerchant;
	private EditText _edtEmail;

	private long mStartTime;
	private long mTimeout;
	private Timer timeoutCheck;
	private int mResult = SIGN_CAPTURE_KO;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.signature);

		mTimeout = (int) 1000000;
		mStartTime = SystemClock.uptimeMillis();
		timeoutCheck = new Timer();
		timeoutCheck.schedule(new TimerTask() {
			@Override
			public void run() {
				runOnUiThread(new Runnable() {
					public void run() {
						checkTimeout();
					}
				});
			}
		}, 1000, 1000); // updates each second

		_edtEmail = (EditText) findViewById(R.id.edtEmail);
		mSignature = (SignatureView) findViewById(R.id.vSignature);
		mClear = (Button) findViewById(R.id.clear);
		mGetSign = (Button) findViewById(R.id.getsign);
		mGetSign.setEnabled(false);
		mCancel = (Button) findViewById(R.id.cancel);
		txtMerchant = (TextView) findViewById(R.id.txtMerchant);
		STBProfile profile = POSManager.instance().getActivedProfile();
		txtMerchant.setText(profile.MerchantName);

		mSignature.setOnSignedListener(new SignaturePad.OnSignedListener() {

			@Override
			public void onSigned() {
				mGetSign.setEnabled(true);
			}

			@Override
			public void onClear() {
				mGetSign.setEnabled(false);
			}
		});

		if (!TextUtils
				.isEmpty(POSManager.instance().getCurrentTransaction().email))
			_edtEmail
					.append(POSManager.instance().getCurrentTransaction().email);

		mClear.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				Log.v(TAG, "Panel Cleared");
				mSignature.clear();
			}
		});

		mGetSign.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				saveSignature();
			}
		});

		mCancel.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				Log.v(TAG, "Panel Canceled");
				mResult = SIGN_CAPTURE_KO;
				setResult(mResult);
				finish();

			}
		});

	}

	private void saveSignature() {
		String email = _edtEmail.getText().toString();
		if (!TextUtils.isEmpty(email) && !Utils.isValidEmail(email)) {
			UIUtils.showErrorMessage(this, R.string.email_isnt_valid);
			return;
		}
		POSManager.instance().getCurrentTransaction().signature = mSignature
				.getTransparentSignatureBitmap();
		POSManager.instance().getCurrentTransaction().email = email;
		Intent i = getIntent();
		mResult = SIGN_CAPTURE_OK;
		setResult(mResult, i);
		CaptureSignatureActivity.this.finish();
	}

	protected void onDestroy() {
		Log.w(TAG, "onDestroy");
		super.onDestroy();
		timeoutCheck.cancel();
	}

	void checkTimeout() {
		if (SystemClock.uptimeMillis() - mStartTime > mTimeout) {
			Log.d(TAG, "Timeout expired!");
			timeoutCheck.cancel();
			mResult = SIGN_CAPTURE_TIMEOUT;
			setResult(mResult);
			finish();
		}
	}
}
