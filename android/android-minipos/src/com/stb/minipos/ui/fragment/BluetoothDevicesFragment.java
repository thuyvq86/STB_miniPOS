package com.stb.minipos.ui.fragment;

import java.util.Observable;
import java.util.Observer;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.bluetooth.BluetoothDevice;
import android.content.DialogInterface;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.TextView;

import com.stb.minipos.POSApplication;
import com.stb.minipos.R;
import com.stb.minipos.model.POSManager;
import com.stb.minipos.model.STBProfile;
import com.stb.minipos.ui.DrawerMenuItem;
import com.stb.minipos.ui.ReceiveMessageActivity;
import com.stb.minipos.ui.helper.BluetoothDevicesAdapter;
import com.stb.minipos.utils.UIUtils;
import com.stb.minipos.utils.Utils;

public class BluetoothDevicesFragment extends BaseDialogFragment implements
		Observer {
	private ListView _listView;
	private View _vgNoResult;
	private View _btnPairDevice;

	private BluetoothDevicesAdapter _adapter;

	@Override
	public int getContentResource() {
		return R.layout.fragment_bluetooth_devices;
	}

	@Override
	public void onResume() {
		super.onResume();
		setTitle(R.string.app_name);
		POSApplication
				.setDrawerMenuActiveItem(DrawerMenuItem.BLUETOOTH_DEVICES);
		POSManager.instance().addObserver(this);
		POSManager.instance().updatePairedDevices();
	}

	@Override
	public void onPause() {
		super.onPause();
		POSManager.instance().deleteObserver(this);
	}

	@Override
	public void initComponent(View root) {
		_listView = (ListView) root.findViewById(R.id.listview);
		_vgNoResult = root.findViewById(R.id.vgNoResult);
		_btnPairDevice = root.findViewById(R.id.btnPairDevice);

		_adapter = new BluetoothDevicesAdapter(getActivity());
		_listView.setAdapter(_adapter);
		_listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				BluetoothDevice object = (BluetoothDevice) parent
						.getItemAtPosition(position);
				onDevicesSelected(object);
			}
		});
		// _listView
		// .setOnItemLongClickListener(new AdapterView.OnItemLongClickListener()
		// {
		//
		// @Override
		// public boolean onItemLongClick(AdapterView<?> parent,
		// View view, int position, long id) {
		// if (getActivity() instanceof MiniPosActivity) {
		// BluetoothDevice object = (BluetoothDevice) parent
		// .getItemAtPosition(position);
		// ((MiniPosActivity) getActivity())
		// .startActionMode(object);
		// return true;
		// }
		// return false;
		// }
		// });

		_btnPairDevice.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				Utils.openBluetoothSettings(getActivity());
			}
		});
	}

	@Override
	public void update() {
		if (_adapter != null) {
			_adapter.notifyDataSetChanged();
		}
		if (POSManager.instance().getPairDevicesCount() > 0) {
			_vgNoResult.setVisibility(View.GONE);
			_listView.setVisibility(View.VISIBLE);
		} else {
			_vgNoResult.setVisibility(View.VISIBLE);
			_listView.setVisibility(View.GONE);
		}
	}

	@Override
	public void update(Observable observable, Object data) {
		update();
	}

	@SuppressLint("InflateParams")
	private void onDevicesSelected(final BluetoothDevice device) {
		final STBProfile object = POSManager.instance().getProfile(device);
		AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
		builder.setTitle(object.title);
		View view = LayoutInflater.from(getActivity()).inflate(
				R.layout.item_dialog_profile, null);
		{
			TextView txtTitle = (TextView) view.findViewById(R.id.txtTitle);
			TextView txtAddress = (TextView) view.findViewById(R.id.txtAddress);
			txtTitle.setText(object.getName());
			txtAddress.setText(object.getDesc());
		}
		builder.setView(view);
		builder.setPositiveButton(R.string.button_active,
				new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						startMiniPOS(device);
					}
				});
		builder.create().show();
	}

	private void startMiniPOS(BluetoothDevice object) {
		if (POSManager.instance().activeBluetoothDevice(object)) {
			Intent intent = new Intent(getActivity(),
					ReceiveMessageActivity.class);
			getActivity().startActivity(intent);
		} else {
			UIUtils.showErrorMessage(getActivity(), R.string.active_devices_error);
		}
	}

}
