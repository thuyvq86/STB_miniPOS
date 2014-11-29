package com.stb.minipos.ui.fragment;

import java.util.Observable;
import java.util.Observer;

import com.stb.minipos.POSApplication;
import com.stb.minipos.ui.DrawerMenuItem;
import com.stb.minipos.R;

import android.view.View;

public class FeedbackFragment extends BaseDialogFragment implements Observer {

	@Override
	public int getContentResource() {
		return R.layout.fragment_feedback;
	}

	@Override
	public void onResume() {
		super.onResume();
		POSApplication.setDrawerMenuActiveItem(DrawerMenuItem.FEEDBACK);
	}

	@Override
	public void initComponent(View root) {
	}

	@Override
	public void update() {

	}

	@Override
	public void update(Observable observable, Object data) {

	}
}
