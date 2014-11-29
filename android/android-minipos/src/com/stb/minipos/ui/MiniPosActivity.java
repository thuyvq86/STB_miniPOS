package com.stb.minipos.ui;

import java.util.Observable;
import java.util.Observer;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.support.v7.view.ActionMode;
import android.view.Menu;
import android.view.MenuItem;

import com.stb.minipos.R;
import com.stb.minipos.model.POSManager;
import com.stb.minipos.model.dao.ProfileDao;
import com.stb.minipos.ui.fragment.BluetoothDevicesFragment;
import com.stb.minipos.utils.Utils;

public class MiniPosActivity extends BaseActivity implements Observer {

	@Override
	protected void onResume() {
		super.onResume();
		if (getCurrentFragment() == null) {
			switchState(new BluetoothDevicesFragment());
		}
	}

	public void startActionMode(final ProfileDao profile) {
		startSupportActionMode(new ActionMode.Callback() {

			@Override
			public boolean onPrepareActionMode(ActionMode mode, Menu menu) {
				return true;
			}

			@Override
			public void onDestroyActionMode(ActionMode mode) {
				supportInvalidateOptionsMenu();
			}

			@Override
			public boolean onCreateActionMode(ActionMode mode, Menu menu) {
				mode.setTitle(profile.title);
				mode.getMenuInflater().inflate(R.menu.edit_profile_activity,
						menu);
				return true;
			}

			@Override
			public boolean onActionItemClicked(ActionMode mode, MenuItem item) {
				switch (item.getItemId()) {
				case R.id.mnuReset:
					POSManager.instance().unPairDevice(profile);
					mode.finish();
					updateHud();
					return true;
				default:
					return false;
				}
			}
		});
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.select_device_activity, menu);
		return super.onCreateOptionsMenu(menu);
	}

	public void resetProfile() {
		if (POSManager.instance().getPairDevicesCount() <= 0) {
			return;
		}
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setTitle(R.string.pos_reset_title);
		builder.setMessage(R.string.pos_reset_message);
		builder.setNegativeButton(R.string.btn_cancel, null);
		builder.setPositiveButton(R.string.button_ok,
				new DialogInterface.OnClickListener() {

					@Override
					public void onClick(DialogInterface dialog, int which) {
						POSManager.instance().resetProfile();
						updateHud();
					}
				});
		builder.create().show();
	}

	private ProgressDialog _progressDialog;

	public void updateHud() {
		if (POSManager.instance().isResetingProfiles()) {
			if (_progressDialog == null || !_progressDialog.isShowing()) {
				_progressDialog = ProgressDialog.show(this, "",
						getString(R.string.hud_status_reset));
			}
		} else if (_progressDialog != null && _progressDialog.isShowing()) {
			_progressDialog.dismiss();
			_progressDialog = null;
		}
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case R.id.mnuReset:
			resetProfile();
			return true;
		case R.id.mnuOpenSettings:
			Utils.openBluetoothSettings(this);
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
	}

	@Override
	public void update(Observable observable, Object data) {
		if (observable instanceof POSManager)
			updateHud();
		else
			super.update(observable, data);
	}

}
