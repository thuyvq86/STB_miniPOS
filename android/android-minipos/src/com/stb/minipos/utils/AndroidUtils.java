/*
 * Copyright (C) 2012 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.stb.minipos.utils;

import java.io.File;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Build;
import android.os.Environment;
import android.provider.Settings.Secure;
import android.text.TextUtils;

/**
 * Class containing some static utility methods.
 */
public class AndroidUtils {
	private AndroidUtils() {
	};

	public static boolean hasFroyo() {
		// Can use static final constants like FROYO, declared in later versions
		// of the OS since they are inlined at compile time. This is guaranteed
		// behavior.
		return Build.VERSION.SDK_INT >= Build.VERSION_CODES.FROYO;
	}

	public static boolean hasGingerbread() {
		return Build.VERSION.SDK_INT >= Build.VERSION_CODES.GINGERBREAD;
	}

	public static boolean hasHoneycomb() {
		return Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB;
	}

	public static boolean hasHoneycombMR1() {
		return Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB_MR1;
	}

	public static boolean hasJellyBean() {
		return Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN;
	}

	public static String getVersionName(Context context) {
		PackageInfo pInfo;
		String version = null;
		try {
			pInfo = context.getPackageManager().getPackageInfo(
					context.getPackageName(), 0);
			version = pInfo.versionName;
		} catch (Exception e) {
			e.printStackTrace();
			version = null;
		}
		return version;
	}

	public static int getVersionCode(Context context) {
		PackageInfo pInfo;
		int version = -1;
		try {
			pInfo = context.getPackageManager().getPackageInfo(
					context.getPackageName(), 0);
			version = pInfo.versionCode;
		} catch (Exception e) {
			e.printStackTrace();
			version = -1;
		}
		return version;

	}

	public static boolean isAppInstalled(Context context, String appPackage) {
		PackageManager pm = context.getPackageManager();
		boolean isInstalled = false;
		try {
			pm.getPackageInfo(appPackage, PackageManager.GET_ACTIVITIES);
			isInstalled = true;
		} catch (PackageManager.NameNotFoundException e) {
			isInstalled = false;
		}
		return isInstalled;
	}

	/**
	 * Gets an usable cache directory (external if available, internal
	 * otherwise).
	 * 
	 * @param context
	 *            The context to use
	 * @param uniqueName
	 *            A unique directory name to append to the cache dir
	 * @return The cache dir
	 */
	public static File getDiskCacheDir(Context context, String uniqueName) {
		// Check if media is mounted or storage is built-in, if so, try and use
		// external cache dir
		// otherwise use internal cache dir

		boolean mounted = Environment.MEDIA_MOUNTED.equals(Environment
				.getExternalStorageState());
		boolean builtin = !isExternalStorageRemovable();
		File cacheDir = mounted || builtin ? getExternalCacheDir(context)
				: context.getCacheDir();
		if (TextUtils.isEmpty(uniqueName)) {
			return cacheDir;
		}
		return new File(cacheDir.getPath() + File.separator + uniqueName);
	}

	/**
	 * Checks if external storage is built-in or removable.
	 * 
	 * @return True if external storage is removable (like an SD card), false
	 *         otherwise.
	 */
	@TargetApi(9)
	public static boolean isExternalStorageRemovable() {
		if (hasGingerbread()) {
			return Environment.isExternalStorageRemovable();
		}
		return true;
	}

	/**
	 * Gets the external app cache directory.
	 * 
	 * @param context
	 *            The context to use
	 * @return The external cache dir
	 */
	@TargetApi(8)
	public static File getExternalCacheDir(Context context) {
		File cacheDir;
		if (hasFroyo()) {
			cacheDir = context.getExternalCacheDir();
		} else {

			// Before Froyo we need to construct the external cache dir
			// ourselves
			final String cachePath = "/Android/data/"
					+ context.getPackageName() + "/cache/";
			cacheDir = new File(Environment.getExternalStorageDirectory()
					.getPath() + cachePath);
		}

		// if external cache dir is null, use normal cache dir
		if (cacheDir == null)
			cacheDir = context.getCacheDir();

		return cacheDir;
	}

	/***
	 * Indicates if a connection to the Internet is available.
	 * 
	 * @param context
	 *            The context.
	 * @return True if a connection to the Internet is available, otherwise
	 *         false.
	 */
	public static boolean isInternetConnectionAvailable(Context context) {
		ConnectivityManager cm = (ConnectivityManager) context
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo ni = cm.getActiveNetworkInfo();
		if (ni != null && ni.isAvailable() && ni.isConnected()) {
			return true;
		} else {
			return false;
		}
	}

	/***
	 * Work around pre-Froyo bugs in HTTP connection reuse.
	 */
	public static void disableConnectionReuseIfNecessary() {
		// Work around pre-Froyo bugs in HTTP connection reuse.
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.FROYO) {
			System.setProperty("http.keepAlive", "false");
		}
	}

	/***
	 * Gets the date in GMT from a date string.
	 * 
	 * @param date
	 *            the date string.
	 * @return The date.
	 */
	public static Date getDateFromString(String date) {
		try {
			SimpleDateFormat sdf = new SimpleDateFormat(
					"EEE, dd MMM yyyy HH:mm:ss 'GMT'", Locale.US);
			sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
			return sdf.parse(date);
		} catch (ParseException e) {
			return null;
		}
	}

	/***
	 * Gets the date as "EEE, dd MMM yyyy HH:mm:ss GMT".
	 * 
	 * @return The date string.
	 */
	public static String getTimeGMTFromDate(Date date) {
		SimpleDateFormat sdf = new SimpleDateFormat(
				"EEE, dd MMM yyyy HH:mm:ss 'GMT'", Locale.US);
		sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
		return sdf.format(date);
	}

	public static String getUDID(Context context) {
		return Secure
				.getString(context.getContentResolver(), Secure.ANDROID_ID);
	}

	public static String getDefaultUserAgent(Context context) {
		if (context == null) {
			throw new RuntimeException("Context cannot be null");
		}
		// don't modify user-agent on alpha, beta and gold build
		String namespace = context.getPackageName();
		String version = AndroidUtils.getVersionName(context);
		String osVersion = android.os.Build.VERSION.RELEASE;
		String deviceName = android.os.Build.MODEL;
		String density = getDensityName(context);

		return String.format("%s/%s (Android %s, %s, %s)", namespace, version,
				osVersion, density, deviceName);
	}

	/**
	 * Gets the screen density like "XHDPI".
	 * 
	 * @param context
	 *            The context.
	 * @return The screen density string.
	 */
	public static String getDensityName(Context context) {
		float density = context.getResources().getDisplayMetrics().density;
		if (density >= 4.0) {
			return "XXXHDPI";
		}
		if (density >= 3.0) {
			return "XXHDPI";
		}
		if (density >= 2.0) {
			return "XHDPI";
		}
		if (density >= 1.5) {
			return "HDPI";
		}
		if (density >= 1.0) {
			return "MDPI";
		}
		return "LDPI";
	}

}
