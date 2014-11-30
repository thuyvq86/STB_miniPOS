package com.stb.minipos.ui.helper;

import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.stb.minipos.R;
import com.stb.minipos.model.POSManager;
import com.stb.minipos.model.STBProfile;

public class BluetoothDevicesAdapter extends BaseAdapter {
	private final Context context;
	private final LayoutInflater inflater;

	public BluetoothDevicesAdapter(Context context) {
		this.context = context;
		this.inflater = LayoutInflater.from(this.context);
	}

	@Override
	public int getCount() {
		return POSManager.instance().getPairDevicesCount();
	}

	@Override
	public BluetoothDevice getItem(int position) {
		return POSManager.instance().getPairedDeviceAtPosition(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		final ViewHolder holder;
		if (convertView == null) {
			holder = new ViewHolder();
			convertView = inflater.inflate(R.layout.item_device, parent, false);
			holder.txtTitle = (TextView) convertView
					.findViewById(R.id.txtTitle);
			holder.txtAddress = (TextView) convertView
					.findViewById(R.id.txtAddress);
			convertView.setTag(holder);
		} else {
			holder = (ViewHolder) convertView.getTag();
		}

		// update layout
		final STBProfile item = POSManager.instance().getProfile(
				getItem(position));
		{
			holder.txtTitle.setText(item.getName());
			if (TextUtils.isEmpty(item.getDesc())) {
				holder.txtAddress.setVisibility(View.GONE);
			} else {
				holder.txtAddress.setVisibility(View.VISIBLE);
				holder.txtAddress.setText(item.getDesc());
			}

		}

		return convertView;
	}

	private static class ViewHolder {
		TextView txtTitle;
		TextView txtAddress;
	}

}
