package com.stb.minipos.ui;

import java.util.Timer;
import java.util.TimerTask;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.os.Bundle;
import android.os.SystemClock;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;

import com.stb.minipos.R;
import com.stb.minipos.model.POSManager;
import com.stb.minipos.utils.UIUtils;
import com.stb.minipos.utils.Utils;

public class CaptureSignatureActivity extends BaseActivity {
	private static final String TAG = "PCLSIGNCAP";
	private static final int SIGN_CAPTURE_OK = RESULT_OK;
	private static final int SIGN_CAPTURE_KO = RESULT_CANCELED;
	private static final int SIGN_CAPTURE_TIMEOUT = RESULT_FIRST_USER;
	LinearLayout mLinearLayout;
	SignatureView mSignature;
	Button mClear, mGetSign, mCancel;
	View mView;
	private EditText _edtEmail;

	private long mStartTime;
	private long mTimeout;
	private Timer timeoutCheck;
	private int mResult = SIGN_CAPTURE_KO;
	private Path mPath;
	private boolean mBtnSaveEnabled;

	static byte[] headbmp = { 0x42, 0x4D, (byte) 0x66, (byte) 0x24, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x3E, 0x00, 0x00, 0x00, 0x28, 0x00, 0x00,
			0x00, (byte) 0x90, 0x01, 0x00, 0x00, (byte) 0xB2, 0x00, 0x00, 0x00,
			0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, (byte) 0x28,
			(byte) 0x24, 0x00, 0x00, (byte) 0xC4, 0x0E, 0x00, 0x00,
			(byte) 0xC4, 0x0E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, (byte) 0xFF, (byte) 0xFF,
			(byte) 0xFF, (byte) 0X00 };

	@Override
	public void onCreate(Bundle savedInstanceState) {
		Log.d(TAG, "onCreate");
		super.onCreate(savedInstanceState);
		setContentView(R.layout.signature);

		Intent intent = getIntent();
		intent.getIntExtra("POS_X", (char) 0);
		intent.getIntExtra("POS_Y", (char) 0);
		int width = intent.getIntExtra("WIDTH", (char) -1);
		int height = intent.getIntExtra("HEIGHT", (char) 500);
		width = Utils.getDeviceWidth(this);
		height = width * 3 / 5;
		mTimeout = intent.getIntExtra("TIMEOUT", (int) 100000);
		mStartTime = SystemClock.uptimeMillis();
		mPath = new Path();
		mBtnSaveEnabled = false;
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

		mLinearLayout = (LinearLayout) findViewById(R.id.linearLayout);
		_edtEmail = (EditText) findViewById(R.id.edtEmail);
		mSignature = new SignatureView(this, null, mPath);
		mSignature.setBackgroundColor(0xcc31b4e3);
		mLinearLayout.addView(mSignature, width, height);
		mClear = (Button) findViewById(R.id.clear);
		mGetSign = (Button) findViewById(R.id.getsign);
		mGetSign.setEnabled(mBtnSaveEnabled);
		mCancel = (Button) findViewById(R.id.cancel);
		mView = mLinearLayout;

		if (!TextUtils
				.isEmpty(POSManager.instance().getCurrentTransaction().email))
			_edtEmail
					.append(POSManager.instance().getCurrentTransaction().email);

		mClear.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				Log.v(TAG, "Panel Cleared");
				mSignature.clear();
				mGetSign.setEnabled(false);
				mBtnSaveEnabled = false;
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
		if (TextUtils.isEmpty(email)) {
			UIUtils.showErrorMessage(this, R.string.email_isnt_valid);
			return;
		}
		if (!Utils.isValidEmail(email)) {
			UIUtils.showErrorMessage(this, R.string.email_isnt_valid);
			return;
		}
		Log.v(TAG, "Panel Saved");
		mView.setDrawingCacheEnabled(true);
		Bitmap bmp = mSignature.save(mView);
		POSManager.instance().getCurrentTransaction().signature = bmp;
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

	public class SignatureView extends View {
		private static final float STROKE_WIDTH = 5f;
		private static final float HALF_STROKE_WIDTH = STROKE_WIDTH / 2;
		private Paint mPaint = new Paint();
		private Path mPath;

		private float lastTouchX;
		private float lastTouchY;
		private final RectF dirtyRect = new RectF();

		public SignatureView(Context context, AttributeSet attrs) {
			super(context, attrs);
			mPaint.setAntiAlias(true);
			mPaint.setColor(Color.BLACK);
			mPaint.setStyle(Paint.Style.STROKE);
			mPaint.setStrokeJoin(Paint.Join.ROUND);
			mPaint.setStrokeWidth(STROKE_WIDTH);
			mPath = new Path();
		}

		public SignatureView(Context context, AttributeSet attrs, Path path) {
			super(context, attrs);
			mPaint.setAntiAlias(true);
			mPaint.setColor(Color.BLACK);
			mPaint.setStyle(Paint.Style.STROKE);
			mPaint.setStrokeJoin(Paint.Join.ROUND);
			mPaint.setStrokeWidth(STROKE_WIDTH);
			mPath = path;
		}

		public Bitmap save(View v) {
			Log.v(TAG, "Width: " + v.getWidth());
			Log.v(TAG, "Height: " + v.getHeight());
			Bitmap bmp = Bitmap.createBitmap(mLinearLayout.getWidth(),
					mLinearLayout.getHeight(), Bitmap.Config.RGB_565);

			Canvas canvas = new Canvas(bmp);
			v.draw(canvas);
			return bmp;

		}

		public void clear() {
			mPath.reset();
			invalidate();
		}

		@Override
		protected void onDraw(Canvas canvas) {
			canvas.drawPath(mPath, mPaint);
		}

		@SuppressLint("ClickableViewAccessibility")
		@Override
		public boolean onTouchEvent(MotionEvent event) {
			float eventX = event.getX();
			float eventY = event.getY();
			mGetSign.setEnabled(true);
			mBtnSaveEnabled = true;

			switch (event.getAction()) {
			case MotionEvent.ACTION_DOWN:
				mPath.moveTo(eventX, eventY);
				lastTouchX = eventX;
				lastTouchY = eventY;
				return true;

			case MotionEvent.ACTION_MOVE:

			case MotionEvent.ACTION_UP:

				resetDirtyRect(eventX, eventY);
				int historySize = event.getHistorySize();
				for (int i = 0; i < historySize; i++) {
					float historicalX = event.getHistoricalX(i);
					float historicalY = event.getHistoricalY(i);
					expandDirtyRect(historicalX, historicalY);
					mPath.lineTo(historicalX, historicalY);
				}
				mPath.lineTo(eventX, eventY);
				break;

			default:
				debug("Ignored touch event: " + event.toString());
				return false;
			}

			invalidate((int) (dirtyRect.left - HALF_STROKE_WIDTH),
					(int) (dirtyRect.top - HALF_STROKE_WIDTH),
					(int) (dirtyRect.right + HALF_STROKE_WIDTH),
					(int) (dirtyRect.bottom + HALF_STROKE_WIDTH));

			lastTouchX = eventX;
			lastTouchY = eventY;

			return true;
		}

		private void debug(String string) {
		}

		private void expandDirtyRect(float historicalX, float historicalY) {
			if (historicalX < dirtyRect.left) {
				dirtyRect.left = historicalX;
			} else if (historicalX > dirtyRect.right) {
				dirtyRect.right = historicalX;
			}

			if (historicalY < dirtyRect.top) {
				dirtyRect.top = historicalY;
			} else if (historicalY > dirtyRect.bottom) {
				dirtyRect.bottom = historicalY;
			}
		}

		private void resetDirtyRect(float eventX, float eventY) {
			dirtyRect.left = Math.min(lastTouchX, eventX);
			dirtyRect.right = Math.max(lastTouchX, eventX);
			dirtyRect.top = Math.min(lastTouchY, eventY);
			dirtyRect.bottom = Math.max(lastTouchY, eventY);
		}
	}
}
