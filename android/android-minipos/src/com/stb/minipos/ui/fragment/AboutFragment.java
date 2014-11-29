package com.stb.minipos.ui.fragment;

import android.view.View;

import com.stb.minipos.POSApplication;
import com.stb.minipos.ui.DrawerMenuItem;
import com.stb.minipos.R;

public class AboutFragment extends BaseDialogFragment {

	@Override
	public int getContentResource() {
		return R.layout.fragment_about;
	}

	@Override
	public void onResume() {
		super.onResume();
		POSApplication.setDrawerMenuActiveItem(DrawerMenuItem.ABOUT_US);
	}

	@Override
	public void initComponent(View root) {
	}

	@Override
	public void update() {

	}

}
