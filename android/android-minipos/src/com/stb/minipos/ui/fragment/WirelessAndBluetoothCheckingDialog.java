package com.stb.minipos.ui.fragment;

import java.util.Timer;
import java.util.TimerTask;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

import com.stb.minipos.R;
import com.stb.minipos.utils.Utils;

public class WirelessAndBluetoothCheckingDialog extends BaseDialogFragment {
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		return null;
	}

	@Override
	public Dialog onCreateDialog(Bundle savedInstanceState) {
		AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
		builder.setTitle(R.string.app_name);
		builder.setMessage(R.string.request_wireless_and_bluetooth);
		builder.setNegativeButton(R.string.button_exit,
				new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						exit();
					}
				});
		builder.setPositiveButton(R.string.button_opensettings, null);
		AlertDialog dialog = builder.create();
		dialog.setCancelable(false);
		dialog.setCanceledOnTouchOutside(false);
		overridePositiveButtonClick(dialog);
		update();
		return dialog;
	}

	@Override
	public void onResume() {
		super.onResume();
		AlertDialog dialog = (AlertDialog) getDialog();
		if (dialog != null) {
			overridePositiveButtonClick(dialog);
		}

	}

	private Timer _timer;
	private static final long TIME_PERIOD_FOR_CHECKING = 2000;

	@Override
	public void update() {
		_timer = new Timer();
		_timer.schedule(new TimerTask() {
			@Override
			public void run() {
				getActivity().runOnUiThread(new Runnable() {
					@Override
					public void run() {
						try {
							checkNetworkSettings();
						} catch (Exception e) {
							dismiss();
							e.printStackTrace();
						}
					}
				});
			}
		}, TIME_PERIOD_FOR_CHECKING, TIME_PERIOD_FOR_CHECKING);
	}

	private void overridePositiveButtonClick(AlertDialog dialog) {
		Button positiveButton = dialog.getButton(Dialog.BUTTON_POSITIVE);
		if (positiveButton != null)
			positiveButton.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					openSettings(getActivity());
				}
			});
	}

	@Override
	public void onDismiss(DialogInterface dialog) {
		super.onDismiss(dialog);
		if (_timer != null) {
			_timer.cancel();
			_timer = null;
		}
	}

	private void openSettings(Context context) {
		if (!Utils.isBluetoothEnable(context)
				&& !Utils.isNetworkEnable(context)) {
			Utils.openSettings(context);
		} else if (!Utils.isBluetoothEnable(context)) {
			Utils.openBluetoothSettings(context);
		} else {
			Utils.openNetworkSettings(context);
		}
	}

	@Override
	public int getContentResource() {
		return 0;
	}

	@Override
	public void initComponent(View root) {

	}

}
