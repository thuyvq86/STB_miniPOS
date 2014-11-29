package com.stb.minipos.ui;

import com.stb.minipos.R;
import com.stb.minipos.ui.base.UIDialogFragment;
import com.stb.minipos.ui.fragment.AboutFragment;
import com.stb.minipos.ui.fragment.FeedbackFragment;
import com.stb.minipos.ui.fragment.BluetoothDevicesFragment;

public enum DrawerMenuItem {
	BLUETOOTH_DEVICES(0x1), //
	FEEDBACK(0x40), //
	ABOUT_US(0x80), //
	;
	private DrawerMenuItem(int id) {
		this.id = id;
	}

	public final int id;

	public Class<?> getClassInstance() {
		switch (this) {
		case BLUETOOTH_DEVICES:
			return BluetoothDevicesFragment.class;
		case FEEDBACK:
			return FeedbackFragment.class;
		case ABOUT_US:
			return AboutFragment.class;
		default:
			return null;
		}
	}

	public UIDialogFragment newInstance() {
		Class<?> clazz = getClassInstance();
		try {
			if (clazz != null) {
				return (UIDialogFragment) clazz.newInstance();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		return null;
	}

	public int getTextResourceId() {
		switch (this) {
		case BLUETOOTH_DEVICES:
			return R.string.slide_menu_bluetooth_devices;
		case FEEDBACK:
			return R.string.slide_menu_feedback;
		case ABOUT_US:
			return R.string.slide_menu_about;
		default:
			return 0;
		}
	}

}