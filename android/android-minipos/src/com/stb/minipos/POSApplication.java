package com.stb.minipos;

import android.app.Application;

import com.stb.minipos.model.DatabaseManager;
import com.stb.minipos.model.POSManager;
import com.stb.minipos.model.STBApiManager;
import com.stb.minipos.model.SettingManager;
import com.stb.minipos.ui.DrawerMenuItem;

public class POSApplication extends Application implements Constant {
	@Override
	public void onCreate() {
		super.onCreate();
		// initialize database
		DatabaseManager.initialize(getApplicationContext());
		
		// initialize POS manager
		POSManager.initialize(getApplicationContext());
		
		STBApiManager.init(getApplicationContext());
		
		// initialize Setting manager
		SettingManager.initialize(getApplicationContext());
		
		_drawerActiveItem = null;
	}

	private static DrawerMenuItem _drawerActiveItem;

	public synchronized static void setDrawerMenuActiveItem(DrawerMenuItem item) {
		_drawerActiveItem = item;
	}

	public synchronized static DrawerMenuItem getDrawerMenuActiveItem() {
		return _drawerActiveItem;
	}
}
