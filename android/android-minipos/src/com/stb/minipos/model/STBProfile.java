package com.stb.minipos.model;

import java.lang.reflect.Method;
import java.util.Observable;
import java.util.Observer;

import android.bluetooth.BluetoothDevice;
import android.text.TextUtils;

import com.ingenico.pclutilities.PclUtilities.BluetoothCompanion;
import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;
import com.stb.minipos.model.STBApiManager.ApiResponseData;
import com.stb.minipos.model.dao.STBResponseProfiles;

@DatabaseTable(tableName = "Profiles")
public class STBProfile extends Observable implements Observer {
	@DatabaseField(id = true)
	public String address;
	@DatabaseField
	public String title;

	@DatabaseField
	public String MerchantID;
	@DatabaseField
	public String MerchantName;
	@DatabaseField
	public String TerminalID;
	@DatabaseField
	public String SerialID;
	@DatabaseField
	public String PhoneSerialID;

	public boolean isValid() {
		return !TextUtils.isEmpty(TerminalID) && !TextUtils.isEmpty(MerchantID)
				&& !TextUtils.isEmpty(SerialID);
	}

	public void setData(STBResponseProfiles data) {
		this.MerchantID = data.MerchantID;
		this.MerchantName = data.MerchantName;
		this.PhoneSerialID = data.PhoneSerialID;
		this.SerialID = data.SerialID;
		this.TerminalID = data.TerminalID;
	}

	private int requestId;
	private boolean isUpdating;

	public boolean isUpdating() {
		return isUpdating;
	}

	public int updateProfile() {
		STBApiManager.instance().addObserver(this);
		isUpdating = true;
		requestId = STBApiManager.instance().getProfile(SerialID);
		return requestId;
	}

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

	@Override
	public void update(Observable observable, Object data) {
		if (observable == STBApiManager.instance()) {
			ApiResponseData response = (ApiResponseData) data;
			if (requestId == response.requestId) {
				STBApiManager.instance().deleteObserver(this);
				if (response.isSuccess && response.stbResponse.isSuccess())
					setData((STBResponseProfiles) response.stbResponse
							.getData());
				setChanged();
				notifyObservers(data);
				isUpdating = false;
			}
		}
	}

}
