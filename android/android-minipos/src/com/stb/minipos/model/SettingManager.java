package com.stb.minipos.model;

import java.util.Observable;

import android.content.Context;

public class SettingManager extends Observable {

	/**
	 * private constructors
	 * 
	 * @param context
	 *            the application context
	 */
	private SettingManager(Context context) {
	}

	/**
	 * check if the application is accept rooted devices
	 * 
	 * @return true if the application is accept, otherwise return false
	 */
	public boolean isAcceptRootedDevice() {
		return false;
	}

	/**
	 * single instance
	 */
	private static SettingManager _instance;

	public static void initialize(Context context) {
		_instance = new SettingManager(context);
	}

	public static SettingManager instance() {
		if (_instance == null) {
			throw new RuntimeException(SettingManager.class.getName()
					+ " hasn't been initialzed!!!");
		}
		return _instance;
	}
}
