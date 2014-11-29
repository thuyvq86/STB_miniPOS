package com.stb.minipos.model.dao;

import java.lang.reflect.Method;

import android.bluetooth.BluetoothDevice;

import com.ingenico.pclutilities.PclUtilities.BluetoothCompanion;
import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

@DatabaseTable(tableName = "Profiles")
public class ProfileDao {
	@DatabaseField(id = true)
	public String address;

	@DatabaseField
	public String title;

	public BluetoothCompanion btCompanion;

	public boolean isActivated() {
		if (btCompanion != null)
			return btCompanion.isActivated();
		return false;
	}

	public void unpairDevice() {
		try {
			BluetoothDevice device = btCompanion.getBluetoothDevice();
			Method m = device.getClass()
					.getMethod("removeBond", (Class[]) null);
			m.invoke(device, (Object[]) null);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
}
