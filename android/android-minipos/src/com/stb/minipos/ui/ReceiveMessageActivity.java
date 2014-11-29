package com.stb.minipos.ui;

import java.util.Arrays;
import java.util.Observable;
import java.util.Observer;
import java.util.Timer;
import java.util.TimerTask;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.stb.minipos.R;
import com.stb.minipos.model.POSManager;
import com.stb.minipos.model.POSManager.DataChanged;
import com.stb.minipos.model.POSTransaction;
import com.stb.minipos.model.dao.PosMessageObject;
import com.stb.minipos.utils.UIUtils;

public class ReceiveMessageActivity extends BasePOSActivity implements
		Observer, View.OnClickListener {
	private static final int REQUEST_SIGN_CODE = 1010;

	private View txtRequestTransaction;
	private TextView txtTransactionType;
	private TextView txtTime;
	private TextView txtReceiptMid;
	private TextView txtReceiptTid;
	private TextView txtReceiptNo;
	private TextView txtMessage;
	private TextView txtCardType;
	private TextView txtCardNumber;
	private TextView txtCardName;

	private TextView txtExpiredDate;

	private TextView txtTotal;
	private View vgReprint;
	private View vgSignature;
	private ImageView imgSign;
	private TextView txtSignatureName;
	private TextView txtAppCode;
	private ProgressDialog dialog;
	private long dialogShowingTime;

	private boolean isProgressDialogShowing() {
		return dialog != null && dialog.isShowing();
	}

	public void showProgressDialog() {
		dialog = ProgressDialog.show(this, "",
				getString(R.string.hud_connect_bluetooth));
		dialogShowingTime = System.currentTimeMillis();
		dialog.setCancelable(true);
		dialog.setOnCancelListener(new DialogInterface.OnCancelListener() {
			@Override
			public void onCancel(DialogInterface dialog) {
				finish();
			}
		});
		dialog.setOnDismissListener(new DialogInterface.OnDismissListener() {
			@Override
			public void onDismiss(DialogInterface dialog) {
				updateLayout(POSManager.instance().popTransaction());
			}
		});
		dialog.setCanceledOnTouchOutside(false);
	}

	private void checkConnectTimeout() {
		if (System.currentTimeMillis() - dialogShowingTime > POS_CONNECT_TIMEOUT) {
			cancelTimer();
			dismissProgressDialog();
			AlertDialog.Builder builder = new AlertDialog.Builder(this);
			builder.setTitle(R.string.pos_connect_timeout_title);
			builder.setMessage(R.string.pos_connect_timeout_message);
			builder.setPositiveButton(R.string.button_ok,
					new DialogInterface.OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog, int which) {
							finish();
						}
					});
			builder.setOnCancelListener(new DialogInterface.OnCancelListener() {
				@Override
				public void onCancel(DialogInterface dialog) {
					finish();
				}
			});
			builder.create().show();
		}

	}

	public void dismissProgressDialog() {
		try {
			if (dialog != null)
				dialog.dismiss();
			dialogShowingTime = 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		dialog = null;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_receive_message);
		getSupportActionBar().setDisplayHomeAsUpEnabled(true);
		getSupportActionBar().setHomeButtonEnabled(true);

		txtRequestTransaction = findViewById(R.id.txtRequestTransaction);

		txtTransactionType = (TextView) findViewById(R.id.txtTransactionType);
		txtTime = (TextView) findViewById(R.id.txtTime);
		txtReceiptMid = (TextView) findViewById(R.id.txtReceiptMid);
		txtReceiptTid = (TextView) findViewById(R.id.txtReceiptTid);
		txtReceiptNo = (TextView) findViewById(R.id.txtReceiptNo);
		txtAppCode = (TextView) findViewById(R.id.txtAppCode);
		txtMessage = (TextView) findViewById(R.id.txtMessage);
		vgReprint = findViewById(R.id.vgReprint);
		txtCardName = (TextView) findViewById(R.id.txtCardName);
		txtCardType = (TextView) findViewById(R.id.txtCardType);
		txtCardNumber = (TextView) findViewById(R.id.txtCardNumber);

		txtExpiredDate = (TextView) findViewById(R.id.txtExpiredDate);

		vgSignature = findViewById(R.id.vgSignature);
		txtTotal = (TextView) findViewById(R.id.txtTotal);
		imgSign = (ImageView) findViewById(R.id.imgSign);
		txtSignatureName = (TextView) findViewById(R.id.txtSignatureName);

		imgSign.setOnClickListener(this);
		findViewById(R.id.btnDone).setOnClickListener(this);
		updateLayout(POSManager.instance().getCurrentTransaction());
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode == REQUEST_SIGN_CODE) {
			if (resultCode == RESULT_OK) {
				imgSign.setImageBitmap(POSManager.instance()
						.getCurrentTransaction().signature);
			}
		}
	}

	private Timer timer;

	@Override
	void onPclServiceConnected() {
		cancelTimer();
		timer = new Timer();
		timer.schedule(new TimerTask() {
			@Override
			public void run() {
				runOnUiThread(new Runnable() {
					@Override
					public void run() {
						if (checkNetworkSettings() && isCompanionConnected()) {
							runReceiveMessage();
						}
						if (isCompanionConnected() && isProgressDialogShowing()) {
							dismissProgressDialog();
						} else if (!isCompanionConnected()
								&& !isProgressDialogShowing()) {
							showProgressDialog();
						} else if (isProgressDialogShowing()) {
							checkConnectTimeout();
						}
					}
				});

			}
		}, 0, 1000);
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		cancelTimer();
	}

	private void cancelTimer() {
		if (timer != null) {
			timer.cancel();
			timer = null;
		}
	}

	protected void runReceiveMessage() {
		try {
			byte[] msg = new byte[1024];
			int[] byteReceived = new int[1];
			if (recvMsg(msg, byteReceived) && byteReceived[0] > 0) {
				byte[] data = Arrays.copyOf(msg, byteReceived[0]);
				PosMessageObject object = new PosMessageObject(new String(data));
				POSManager.instance().addTransactionToQueue(object);
			}
			if (SN <= 0)
				getTermInfo();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private void testTransaction() {
		String message = "F1^2|F2^4364450099631797|F4^000000001001|F12^20141008235225|F14^1804|F37^428116455333|F38^798910|F39^00|F41^60012086|F42^000000060108354|F49^704|F60^1|F62^7|F65^VISA|F66^ALL FOR YOU               |F67^M|F72^20138884|F79^SALE";
		POSManager.instance().addTransactionToQueue(
				new PosMessageObject(message));
	}

	@Override
	protected void onResume() {
		super.onResume();
		setTitle(POSManager.instance().getActivedDevice().title);
		POSManager.instance().addObserver(this);
		if (getIntent() != null
				&& getIntent().getAction() == Intent.ACTION_MAIN) {
			findViewById(R.id.txtRequestTransaction).setOnClickListener(
					new View.OnClickListener() {
						@Override
						public void onClick(View v) {
							testTransaction();
						}
					});
		}
	}

	@Override
	protected void onPause() {
		super.onPause();
		POSManager.instance().deleteObserver(this);
	}

	private boolean isFree() {
		POSTransaction transaction = POSManager.instance()
				.getCurrentTransaction();
		return transaction == null || transaction.isCommitted();
	}

	@Override
	public void update(Observable observable, Object data) {
		if (observable == POSManager.instance()
				&& data == DataChanged.TRANSACTION_ADD && isFree()) {
			POSTransaction trans = POSManager.instance().popTransaction();
			if (trans != null) {
				updateLayout(trans);
			}
		} else if (observable == POSManager.instance().getCurrentTransaction()) {
			POSTransaction transaction = POSManager.instance()
					.getCurrentTransaction();
			transaction.deleteObserver(this);
			if (_committingDialog != null && _committingDialog.isShowing()) {
				_committingDialog.dismiss();
			}
			if (transaction.isCommitted()) {
				UIUtils.showSuccessMessage(this, R.string.transaction_success);
				if (isFree()) {
					POSTransaction trans = POSManager.instance()
							.popTransaction();
					updateLayout(trans);
				}
			} else {
				UIUtils.showErrorMessage(this,
						"ERROR: " + transaction.getResponse().RespCode);
			}
		}
	}

	private void updateLayout(POSTransaction object) {
		if (!isCompanionConnected()) {
			vgReprint.setVisibility(View.GONE);
			txtMessage.setVisibility(View.GONE);
			txtRequestTransaction.setVisibility(View.GONE);
			return;
		}
		if (object == null || object.message == null
				|| !object.message.isSuccess()) {
			vgReprint.setVisibility(View.GONE);
			txtMessage.setVisibility(View.GONE);
			txtRequestTransaction.setVisibility(View.VISIBLE);
			return;
		}
		PosMessageObject message = object.message;

		txtMessage.setText(message.getMessage());

		vgReprint.setVisibility(View.VISIBLE);
		txtRequestTransaction.setVisibility(View.GONE);
		txtMessage.setVisibility(View.VISIBLE);

		txtTransactionType.setText(message.getTransactionType());
		txtTime.setText(message.getFormattedTime());
		txtReceiptNo.setText(message.getReceiptNo());
		txtReceiptMid.setText(message.getReceiptMid());
		txtReceiptTid.setText(message.getReceiptTid());

		txtAppCode.setText(message.getAppCode());
		txtCardType.setText(message.getCardType());
		txtCardName.setText(message.getCardName());
		txtCardNumber.setText(message.getCardNumber());

		txtExpiredDate.setText(message.getExpiredDate());
		txtTotal.setText(String.valueOf(message.getTotal()));

		if (message.needSignature()) {
			vgSignature.setVisibility(View.VISIBLE);
			txtSignatureName.setText(message.getCardName());
		} else {
			vgSignature.setVisibility(View.GONE);
		}
	}

	private ProgressDialog _committingDialog;

	private void commitTransaction() {
		POSTransaction transaction = POSManager.instance()
				.getCurrentTransaction();
		if (transaction.signature == null) {
			UIUtils.showErrorMessage(this,
					R.string.transaction_signature_empty_message);
			return;
		}
		if (!transaction.isCommitted()) {
			if (PN > 0 || getTermInfo()) {
				transaction.addObserver(this);
				transaction.commit();
				_committingDialog = ProgressDialog.show(this, null,
						getString(R.string.save));
			} else {
				UIUtils.showErrorMessage(this,
						R.string.pos_connect_timeout_message);
			}
		}

	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.btnDone:
			commitTransaction();
			break;
		case R.id.imgSign:
			Intent intent = new Intent(ReceiveMessageActivity.this,
					CaptureSignatureActivity.class);
			startActivityForResult(intent, REQUEST_SIGN_CODE);
			break;

		}
	}

}
