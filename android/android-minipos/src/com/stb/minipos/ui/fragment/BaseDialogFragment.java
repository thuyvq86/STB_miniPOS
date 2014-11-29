package com.stb.minipos.ui.fragment;

import com.stb.minipos.ui.BaseActivity;
import com.stb.minipos.ui.base.UIDialogFragment;

public abstract class BaseDialogFragment extends UIDialogFragment {

	public void checkNetworkSettings() {
		if (getActivity() instanceof BaseActivity) {
			((BaseActivity) getActivity()).checkNetworkSettings();
		}
	}

	public void exit() {
		getActivity().finish();
	}

	@Override
	public void onResume() {
		super.onResume();
		checkNetworkSettings();
	}

}
