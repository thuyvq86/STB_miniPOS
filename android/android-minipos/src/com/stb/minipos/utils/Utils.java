package com.stb.minipos.utils;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.UnsupportedEncodingException;

import android.bluetooth.BluetoothAdapter;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.text.TextUtils;
import android.util.Base64;

/**
 * @author Toan Nguyen Canh
 * 
 */
public class Utils {
	/**
	 * private constructor
	 */
	private Utils() {
	}

	public static final boolean DEBUG_MODE = false;

	/**
	 * check if Wifi or 3G network available
	 * 
	 * @param context
	 *            the application context
	 * @return true if Wifi or 3G available, otherwise return false
	 */
	public static boolean isNetworkEnable(Context context) {
		try {
			ConnectivityManager cm = (ConnectivityManager) context
					.getSystemService(Context.CONNECTIVITY_SERVICE);
			NetworkInfo netInfo = cm.getActiveNetworkInfo();
			if (netInfo != null && netInfo.isConnectedOrConnecting()) {
				return true;
			}
		} catch (Exception e) {
			if (DEBUG_MODE)
				e.printStackTrace();
			return true;
		}
		return false;
	}

	/**
	 * check if the wireless and bluetooth is enable
	 * 
	 * @param context
	 *            the application context
	 * @return true if wireless and bluetooth is enable, otherwise return false
	 */
	public static boolean isWirelessAndBluetoothEnable(Context context) {
		return isBluetoothEnable(context) && isNetworkEnable(context);
	}

	/**
	 * check if bluetooth available
	 * 
	 * @param context
	 *            the application context
	 * @return true bluetooth available, otherwise return false
	 */
	public static boolean isBluetoothEnable(Context context) {
		BluetoothAdapter mBluetoothAdapter = BluetoothAdapter
				.getDefaultAdapter();
		if (mBluetoothAdapter != null) {
			return mBluetoothAdapter.isEnabled();
		}
		return false;
	}

	/**
	 * lead users to the bluetooth settings
	 * 
	 * @param context
	 *            the application context
	 */
	public static void openBluetoothSettings(Context context) {
		try {
			Intent settingsIntent = new Intent(
					android.provider.Settings.ACTION_BLUETOOTH_SETTINGS);
			context.startActivity(settingsIntent);
		} catch (Exception e) {
			UIUtils.showErrorMessage(context,
					"Couldnot found any activity to handle this action");
		}
	}

	/**
	 * lead users to the android settings
	 * 
	 * @param context
	 *            the application context
	 */
	public static void openNetworkSettings(Context context) {
		try {
			Intent settingsIntent = new Intent(
					android.provider.Settings.ACTION_NETWORK_OPERATOR_SETTINGS);
			context.startActivity(settingsIntent);
		} catch (Exception e) {
			UIUtils.showErrorMessage(context,
					"Couldnot found any activity to handle this action");
		}
	}

	/**
	 * lead users to the android settings
	 * 
	 * @param context
	 *            the application context
	 */
	public static void openSettings(Context context) {
		try {
			Intent settingsIntent = new Intent(
					android.provider.Settings.ACTION_SETTINGS);
			context.startActivity(settingsIntent);
		} catch (Exception e) {
			UIUtils.showErrorMessage(context,
					"Couldnot found any activity to handle this action");
		}
	}

	/**
	 * Check if device is rooted <br>
	 * Google Wallet used three methods to determine whether an Android device
	 * had root access configured. <br>
	 * 1) Check if the �su� command was successful <br>
	 * 2) Check if the file �/system/app/Superuser.apk� exists<br>
	 * 3) Check if the system OS was built with test-keys<br>
	 * 
	 * <a href=
	 * "http://www.joeyconway.com/blog/2014/03/29/android-detect-root-access-from-inside-an-app/"
	 * >Android - Detect Root Access from inside an app by Joey</a>
	 * 
	 * @return true if the device is rooted, otherwise return false
	 */
	public static boolean isRootedDevice() {
		return hasSuperuserApk() || isTestKeyBuild() || canExecuteSuCommand();

	}

	/**
	 * check if device has the super user APK
	 * 
	 * @return true if rooted device, otherwise return false
	 */
	private static boolean hasSuperuserApk() {
		return new File("/system/app/Superuser.apk").exists();
	}

	/**
	 * 
	 * @return true if rooted device, otherwise return false
	 */
	public static boolean isTestKeyBuild() {
		String buildTags = android.os.Build.TAGS;
		return buildTags != null && buildTags.contains("test-keys");
	}

	/**
	 * check if device can execute super user (su) command
	 * 
	 * @return true if rooted device, otherwise return false
	 */
	private static boolean canExecuteSuCommand() {
		try {
			Runtime.getRuntime().exec("su");
			return true;
		} catch (Exception e) {
			if (DEBUG_MODE)
				e.printStackTrace();
		}
		return false;
	}

	/**
	 * exit the application
	 * 
	 * @param context
	 *            the application context
	 */
	public static void exitApplication() {
		android.os.Process.killProcess(android.os.Process.myPid());
	}

	public final static boolean isValidEmail(CharSequence email) {
		if (TextUtils.isEmpty(email)) {
			return false;
		} else {
			return android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches();
		}
	}

	public static int getDeviceWidth(Context context) {
		return context.getResources().getDisplayMetrics().widthPixels;
	}

	public static String encodeTobase64(Bitmap image) {
		Bitmap immagex = Bitmap.createScaledBitmap(image, 250, 150, true);
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		immagex.compress(Bitmap.CompressFormat.PNG, 100, baos);
		byte[] b = baos.toByteArray();
		String imageEncoded = Base64.encodeToString(b, Base64.DEFAULT);
		return imageEncoded;
	}

	public static Bitmap decodeBase64ToBitmap(String input) {
		byte[] decodedByte = Base64.decode(input, 0);
		return BitmapFactory
				.decodeByteArray(decodedByte, 0, decodedByte.length);
	}

	public static String decodeBase64ToString(String base64) {
		byte[] data = Base64.decode(base64, Base64.DEFAULT);
		try {
			return new String(data, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		return new String(data);
	}

}
