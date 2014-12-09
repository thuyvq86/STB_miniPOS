package com.stb.minipos.ui;

import java.util.Observable;
import java.util.Observer;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.ListView;

import com.stb.minipos.Config;
import com.stb.minipos.Constant;
import com.stb.minipos.POSApplication;
import com.stb.minipos.R;
import com.stb.minipos.model.SettingManager;
import com.stb.minipos.ui.base.UIDialogFragment;
import com.stb.minipos.ui.base.UIDrawerActivity;
import com.stb.minipos.ui.fragment.WirelessAndBluetoothCheckingDialog;
import com.stb.minipos.utils.UIUtils;
import com.stb.minipos.utils.Utils;

public abstract class BaseActivity extends UIDrawerActivity implements
		Constant, Observer, Config {

	private boolean isActivityInForeground = false;

	public boolean isActivityInForeground() {
		return isActivityInForeground;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		// getSupportActionBar().setDisplayShowHomeEnabled(false);
		getSupportActionBar().setBackgroundDrawable(
				getResources().getDrawable(R.drawable.ic_ab_background));
	}

	private ListView _lvDrawerMenus;

	@Override
	public void onDrawerMenuViewCreated(View drawerMenuView) {
		super.onDrawerMenuViewCreated(drawerMenuView);
		_lvDrawerMenus = (ListView) drawerMenuView
				.findViewById(R.id.lvDrawerMenus);
		if (isDrawerMenuEnable() && _lvDrawerMenus != null) {
			_lvDrawerMenus.setAdapter(new DrawerMenuAdapter(
					getApplicationContext()));
			_lvDrawerMenus
					.setOnItemClickListener(new AdapterView.OnItemClickListener() {

						@Override
						public void onItemClick(AdapterView<?> parent,
								View view, int position, long id) {
							ondrawerMenuSelected((DrawerMenuItem) parent
									.getItemAtPosition(position));

						}
					});
		}
	}

	public void ondrawerMenuSelected(DrawerMenuItem item) {
		closeDrawer();
		switch (item) {
		default:
			if (getCurrentFragment() == null
					|| getCurrentFragment().getClass() != item
							.getClassInstance()) {
				UIDialogFragment fragment = item.newInstance();
				if (fragment != null) {
					POSApplication.setDrawerMenuActiveItem(item);
					if (_lvDrawerMenus != null
							&& _lvDrawerMenus.getAdapter() != null) {
						((BaseAdapter) _lvDrawerMenus.getAdapter())
								.notifyDataSetChanged();
					}
					switchState(fragment, FLAG_ADD_TO_BACK_STACK);
				}
			}

			break;
		}
	}

	@Override
	public void onDrawerVisible() {
		super.onDrawerVisible();
		if (_lvDrawerMenus != null && _lvDrawerMenus.getAdapter() != null) {
			((BaseAdapter) _lvDrawerMenus.getAdapter()).notifyDataSetChanged();
		}
	}

	private boolean isRootedDialogShown = false;

	private void checkForRootedDevice() {
		if (!isRootedDialogShown
				&& !SettingManager.instance().isAcceptRootedDevice()
				&& Utils.isRootedDevice()) {
			AlertDialog.Builder builder = new AlertDialog.Builder(this);
			builder.setTitle(R.string.rooted_dialog_title);
			builder.setMessage(R.string.rooted_dialog_message);
			builder.setPositiveButton(R.string.button_exit,
					new DialogInterface.OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog, int which) {
							Utils.exitApplication();
						}
					});
			Dialog dialog = builder.create();
			dialog.setCancelable(false);
			dialog.setCanceledOnTouchOutside(false);
			dialog.show();
			isRootedDialogShown = true;
		}
	}

	private WirelessAndBluetoothCheckingDialog _dialog = null;

	public boolean checkNetworkSettings() {
		// checking if wireless and bluetooth available
		if (!Utils.isWirelessAndBluetoothEnable(this)) {
			if (_dialog == null && isActivityInForeground()) {
				_dialog = new WirelessAndBluetoothCheckingDialog();
				showDialog(_dialog);
			}
			return false;
		} else if (_dialog != null) {
			UIUtils.safetyDismissDialog(_dialog);
			_dialog = null;
		}
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case R.id.mnuAbout:
			openAbout();
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}

	public void openAbout() {
		Intent intent = new Intent(this, AboutActivity.class);
		startActivity(intent);
	}

	@Override
	protected void onResume() {
		super.onResume();
		isActivityInForeground = true;
		SettingManager.instance().addObserver(this);
		checkNetworkSettings();
		checkForRootedDevice();

	}

	@Override
	protected void onPause() {
		super.onPause();
		isActivityInForeground = false;
		SettingManager.instance().deleteObserver(this);
	}

	@Override
	public void update(Observable observable, Object data) {
		if (observable instanceof SettingManager)
			checkForRootedDevice();
	}
}
