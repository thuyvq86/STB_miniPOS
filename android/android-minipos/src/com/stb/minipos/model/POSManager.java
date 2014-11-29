package com.stb.minipos.model;

import java.util.ArrayList;
import java.util.List;
import java.util.Observable;
import java.util.Set;

import android.content.Context;
import android.os.AsyncTask;

import com.ingenico.pclutilities.PclUtilities;
import com.ingenico.pclutilities.PclUtilities.BluetoothCompanion;
import com.stb.minipos.model.dao.PosMessageObject;

public class POSManager extends Observable {
	public enum DataChanged {
		TRANSACTION_ADD, //
		TRANSACTION_POP, //
	}

	public static final String TAG = POSManager.class.getSimpleName();

	private final Context context;
	private final PclUtilities mPclUtil;
	private final List<STBProfile> _pairDevices = new ArrayList<STBProfile>();

	private STBProfile activedDevice = null;

	private POSManager(Context context) {
		this.context = context;
		mPclUtil = new PclUtilities(this.context,
				this.context.getPackageName(), "pairing_addr.txt");
	}

	public void updatePairedDevices() {
		Set<BluetoothCompanion> btComps = mPclUtil.GetPairedCompanions();
		if (!_pairDevices.isEmpty()) {
			_pairDevices.clear();
			setChanged();
		}
		if (btComps != null) {
			for (BluetoothCompanion btComp : btComps) {
				STBProfile profile = new STBProfile();
				profile.address = btComp.getBluetoothDevice().getAddress();
				profile.title = btComp.getBluetoothDevice().getName();
				profile.btCompanion = btComp;
				_pairDevices.add(profile);
				setChanged();
			}
		}
		notifyObservers(_pairDevices);
	}

	private boolean isReseting = false;

	public boolean isResetingProfiles() {
		return isReseting;
	}

	public void resetProfile() {
		if (isReseting)
			return;

		for (STBProfile device : _pairDevices) {
			device.unpairDevice();
		}
		updatePairedDevices();
		if (getPairDevicesCount() > 0) {
			isReseting = true;
			new AsyncTask<Void, Integer, Boolean>() {

				@Override
				protected Boolean doInBackground(Void... params) {
					final long time = System.currentTimeMillis();
					try {
						while (System.currentTimeMillis() - time < 10 * 1000
								&& mPclUtil.GetPairedCompanions().size() > 0) {
							Thread.sleep(200);
						}
						return mPclUtil.GetPairedCompanions().size() == 0;
					} catch (Exception e) {
						e.printStackTrace();
					}
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
		}
	}

	public void unPairDevice(STBProfile profile) {
		if (isReseting)
			return;
		final int size = getPairDevicesCount();

		for (STBProfile device : _pairDevices) {
			device.unpairDevice();
		}
		updatePairedDevices();
		if (getPairDevicesCount() == size) {
			isReseting = true;
			new AsyncTask<Void, Integer, Boolean>() {

				@Override
				protected Boolean doInBackground(Void... params) {
					final long time = System.currentTimeMillis();
					try {
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

	public void requestProfile() {

	}

	public STBProfile getActivedProfile() {
		return activedDevice;
	}

	/**
	 * get all pair devices
	 * 
	 * @return all pair devices
	 */
	public List<STBProfile> getPairedDevices() {
		return _pairDevices;
	}

	/**
	 * get paired device at specific location
	 * 
	 * @param position
	 * @return
	 */
	public STBProfile getPairedDeviceAtPosition(int position) {
		return _pairDevices.get(position);
	}

	/**
	 * get number of pair devices
	 * 
	 * @return the number of pair devices
	 */
	public int getPairDevicesCount() {
		return _pairDevices.size();
	}

	/**
	 * add profile to database
	 */
	public void addProfile(STBProfile profile) {

	}

	public void activeBluetoothDevice(STBProfile object) {
		this.activedDevice = object;
		mPclUtil.ActivateCompanion(this.activedDevice.btCompanion
				.getBluetoothDevice().getAddress());
	}

	// ---------------------------------------------------------
	// TRANSACTION
	// ---------------------------------------------------------
	private ArrayList<POSTransaction> transactions = new ArrayList<POSTransaction>();
	private POSTransaction currentTransaction;

	public void addTransactionToQueue(PosMessageObject object) {
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
