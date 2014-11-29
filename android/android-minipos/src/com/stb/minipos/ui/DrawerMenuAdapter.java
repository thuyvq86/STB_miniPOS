package com.stb.minipos.ui;

import com.stb.minipos.POSApplication;
import com.stb.minipos.R;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

class DrawerMenuAdapter extends BaseAdapter {
	private final LayoutInflater _inflater;

	public DrawerMenuAdapter(Context context) {
		_inflater = LayoutInflater.from(context);
	}

	@Override
	public int getCount() {
		return DrawerMenuItem.values().length;
	}

	@Override
	public DrawerMenuItem getItem(int position) {
		return DrawerMenuItem.values()[position];
	}

	@Override
	public long getItemId(int position) {
		return getItem(position).id;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		final DrawerMenuViewHolder holder;
		if (convertView == null) {
			holder = new DrawerMenuViewHolder();
			convertView = _inflater.inflate(R.layout.drawer_menu_item, parent,
					false);
			holder.txtTitle = (TextView) convertView
					.findViewById(R.id.txtTitle);
			convertView.setTag(holder);
		} else {
			holder = (DrawerMenuViewHolder) convertView.getTag();
		}

		// updating
		{
			final DrawerMenuItem item = getItem(position);
			holder.txtTitle.setText(item.getTextResourceId());
			if (item == POSApplication.getDrawerMenuActiveItem()) {
				convertView.setBackgroundResource(R.color.color_active);
			} else {
				convertView.setBackgroundResource(R.color.color_null);
			}
		}

		return convertView;
	}
}
