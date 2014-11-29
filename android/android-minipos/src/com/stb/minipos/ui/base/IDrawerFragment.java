package com.stb.minipos.ui.base;

import android.view.View;

public interface IDrawerFragment {
	public boolean onBackPress();

	public void onDrawerClosed(View drawerView);

	public void onDrawerOpened(View drawerView);

	public void onDrawerVisible();
}
