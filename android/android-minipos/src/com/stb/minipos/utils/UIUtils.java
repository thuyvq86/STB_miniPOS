package com.stb.minipos.utils;

import com.stb.minipos.ui.base.UIDialogFragment;

import android.app.Dialog;
import android.content.Context;
import android.widget.Toast;

public class UIUtils {
	private UIUtils() {
	}

	public static void showErrorMessage(Context context, int messageId) {
		showErrorMessage(context, messageId, Toast.LENGTH_SHORT);
	}

	public static void showErrorMessage(Context context, String message) {
		showErrorMessage(context, message, Toast.LENGTH_SHORT);
	}

	public static void showErrorMessage(Context context, int messageId,
			int length) {
		Toast.makeText(context, messageId, length).show();
	}

	public static void showSuccessMessage(Context context, int messageId) {
		showSuccessMessage(context, messageId, Toast.LENGTH_SHORT);
	}

	public static void showSuccessMessage(Context context, int messageId,
			int length) {
		Toast.makeText(context, messageId, length).show();
	}

	public static void showErrorMessage(Context context, String message,
			int length) {
		Toast.makeText(context, message, length).show();
	}

	public static void safetyDismissDialog(Dialog dialog) {
		try {
			if (dialog != null) {
				dialog.dismiss();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public static void safetyDismissDialog(UIDialogFragment dialog) {
		try {
			if (dialog != null) {
				dialog.dismiss();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
