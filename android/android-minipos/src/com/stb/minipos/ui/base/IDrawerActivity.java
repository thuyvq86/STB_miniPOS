package com.stb.minipos.ui.base;

import android.view.View;

public interface IDrawerActivity {
	public static final int FLAG_ADD_TO_BACK_STACK = 0x1;

	public static final int FLAG_RESTORE_INSTANCE = 0x2;

	// get the current fragment
	public IDrawerFragment getCurrentFragment();

	public int getDrawerImageRes();

	public void onDrawerSlide(View drawerView, float slideOffset);

	public void onDrawerStateChanged(int newState);

	public void onDrawerClosed(View drawerView);

	public void onDrawerOpened(View drawerView);

	public void onDrawerVisible();

	/**
	 * check if drawer menu is opening or not
	 * 
	 * @return <b>true</b> if drawer menu is opening, otherwise return
	 *         <b>false</b>
	 */
	public boolean isDrawerOpen();

	/**
	 * Close drawer menu
	 */
	public void closeDrawer();

	/**
	 * Open drawer menu
	 */
	public void openDrawer();

}
