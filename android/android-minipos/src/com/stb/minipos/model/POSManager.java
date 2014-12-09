package com.stb.minipos.model;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Observable;
import java.util.Set;

import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.os.AsyncTask;
import android.text.TextUtils;

import com.ingenico.pclutilities.PclUtilities;
import com.ingenico.pclutilities.PclUtilities.BluetoothCompanion;
import com.stb.minipos.model.dao.POSMessage;

public class POSManager extends Observable {
	public enum DataChanged {
		TRANSACTION_ADD, //
		TRANSACTION_POP, //
	}

	public static final String TAG = POSManager.class.getSimpleName();

	private final Context context;
	private final PclUtilities mPclUtil;
	private final Map<String, STBProfile> _profiles = new HashMap<String, STBProfile>();
	private final List<BluetoothDevice> _bluetoothDevices = new ArrayList<BluetoothDevice>();

	private BluetoothDevice activedDevice = null;

	private POSManager(Context context) {
		this.context = context;
		mPclUtil = new PclUtilities(this.context,
				this.context.getPackageName(), "pairing_addr.txt");

		// load profiles
		_profiles.clear();
		List<STBProfile> profiles = DatabaseManager.instance().getProfiles();
		for (STBProfile profile : profiles) {
			_profiles.put(profile.address, profile);
		}
	}

	public boolean hasActiveProfiles() {
		return _profiles != null && !_profiles.isEmpty();
	}

	public void updatePairedDevices() {
		Set<BluetoothCompanion> btComps = mPclUtil.GetPairedCompanions();
		if (!_bluetoothDevices.isEmpty()) {
			_bluetoothDevices.clear();
			setChanged();
		}
		if (btComps != null) {
			for (BluetoothCompanion btComp : btComps) {
				if (!hasActiveProfiles()
						|| hasProfile(btComp.getBluetoothDevice())) {
					_bluetoothDevices.add(btComp.getBluetoothDevice());
					setChanged();
				}
			}
		}
		notifyObservers();
	}

	private boolean isReseting = false;

	public boolean isResetingProfiles() {
		return isReseting;
	}

	public void resetProfile() {
		DatabaseManager.instance().clearProfiles();
		_profiles.clear();
		updatePairedDevices();
	}

	public void unPairDevice(BluetoothDevice device) {
		if (isReseting)
			return;
		final int size = getPairDevicesCount();
		unpairDevice(device);
		updatePairedDevices();
		if (getPairDevicesCount() == size) {
			isReseting = true;
			new AsyncTask<Void, Integer, Boolean>() {

				@Override
				protected Boolean doInBackground(Void... params) {
					final long time = System.currentTimeMillis();
					try {
						Thread.sleep(200);
						while (System.currentTimeMillis() - time < 10 * 1000
								&& mPclUtil.GetPairedCompanions().size() == size) {
							Thread.sleep(200);
						}
						return mPclUtil.GetPairedCompanions().size() == size;
					} catch (Exception e) {
						e.printStackTrace();
					}
					isReseting = false;
					return false;
				}

				protected void onPostExecute(Boolean result) {
					isReseting = false;
					if (result) {
						updatePairedDevices();
					}
					setChanged();
					notifyObservers();
				};

				protected void onCancelled() {
					super.onCancelled();
					isReseting = false;
				};
			}.execute();
		} else {
			isReseting = false;
			setChanged();
			notifyObservers();
		}
	}

	public BluetoothDevice getActivedDevice() {
		return activedDevice;
	}

	public STBProfile getActivedProfile() {
		return getProfile(activedDevice);
	}

	public boolean hasProfile(BluetoothDevice device) {
		return _profiles.containsKey(device.getAddress());
	}

	public STBProfile getProfile(BluetoothDevice device) {
		STBProfile object = _profiles.get(device.getAddress());
		if (object == null) {
			object = new STBProfile(device);
			_profiles.put(device.getAddress(), object);
		}
		return object;
	}

	/**
	 * get paired device at specific location
	 * 
	 * @param position
	 * @return
	 */
	public BluetoothDevice getPairedDeviceAtPosition(int position) {
		return _bluetoothDevices.get(position);
	}

	/**
	 * get number of pair devices
	 * 
	 * @return the number of pair devices
	 */
	public int getPairDevicesCount() {
		return _bluetoothDevices.size();
	}

	/**
	 * add profile to database
	 */
	public void updateProfile(STBProfile profile) {
		_profiles.put(profile.address, profile);
		DatabaseManager.instance().createOrUpdate(profile);
	}

	public boolean activeBluetoothDevice(BluetoothDevice object) {
		if (object == null || TextUtils.isEmpty(object.getAddress())) {
			return false;
		}
		try {
			this.activedDevice = object;
			mPclUtil.ActivateCompanion(object.getAddress());
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	private static void unpairDevice(BluetoothDevice device) {
		try {
			Method m = device.getClass()
					.getMethod("removeBond", (Class[]) null);
			m.invoke(device, (Object[]) null);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	// ---------------------------------------------------------
	// TRANSACTION
	// ---------------------------------------------------------
	private ArrayList<POSTransaction> transactions = new ArrayList<POSTransaction>();
	private POSTransaction currentTransaction;

	public void addTransactionToQueue(POSMessage object) {
		POSTransaction trans = new POSTransaction(object);
		transactions.add(trans);
		setChanged();
		notifyObservers(DataChanged.TRANSACTION_ADD);
	}

	public POSTransaction popTransaction() {
		if (transactions.size() > 0) {
			currentTransaction = transactions.remove(0);
		} else {
			currentTransaction = null;
		}

		setChanged();
		notifyObservers(DataChanged.TRANSACTION_POP);
		return currentTransaction;
	}

	public POSTransaction getCurrentTransaction() {
		return currentTransaction;
	}

	/**
	 * singleton
	 */
	private static POSManager _instance;

	public static void initialize(Context context) {
		_instance = new POSManager(context);
	}

	public static POSManager instance() {
		if (_instance == null) {
			throw new RuntimeException(POSManager.class.getName()
					+ " hasn't been initialized!!!");
		}
		return _instance;
	}

}
