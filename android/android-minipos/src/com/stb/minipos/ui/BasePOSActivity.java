package com.stb.minipos.ui;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;

import com.ingenico.pclservice.PclService;
import com.ingenico.pclservice.PclService.LocalBinder;
import com.ingenico.pclservice.TransactionIn;
import com.ingenico.pclservice.TransactionOut;

public abstract class BasePOSActivity extends BaseActivity {
	public static final String TAG = "PCLTESTAPP";
	protected PclService mPclService = null;
	private static Boolean m_BarCodeActivated = false;
	private static Boolean m_PrinterActivated = false;
	private BarCodeReceiver m_BarCodeReceiver = null;
	private StateReceiver m_StateReceiver = null;
	private PclServiceConnection mServiceConnection;
	private int mReleaseService;
	boolean mBound = false;

	private static boolean mStopService;
	private static boolean mServiceStarted = false;

	static class PclObject {
		PclServiceConnection serviceConnection;
		PclService service;
	}

	class PclServiceConnection implements ServiceConnection {
		public void onServiceConnected(ComponentName className,
				IBinder boundService) {
			// mPclService =
			// IPclService.Stub.asInterface((IBinder)boundService);
			// We've bound to LocalService, cast the IBinder and get
			// LocalService instance
			LocalBinder binder = (LocalBinder) boundService;
			mPclService = (PclService) binder.getService();
			mBound = true;
			onPclServiceConnected();
		}

		public void onServiceDisconnected(ComponentName className) {
			mBound = false;
			mPclService = null;
			Log.d(TAG, "onServiceDisconnected");
		}
	};

	int SN = 0, PN = 0;

	public class _SYSTEMTIME {
		// WORD = UInt16
		public short wYear;
		public short wMonth;
		public short wDayOfWeek;
		public short wDay;
		public short wHour;
		public short wMinute;
		public short wSecond;
		public short wMilliseconds;
	}

	protected _SYSTEMTIME sysTime;

	public BasePOSActivity() {

	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		{
			mStopService = true;
			startPclService();
		}
		{
			mReleaseService = 1;
			final PclObject data = (PclObject) getLastCustomNonConfigurationInstance();
			if (data == null || data.service == null
					|| data.serviceConnection == null) {
				Log.d(TAG, "onCreate: Init service");
				initService();
			} else {
				Log.d(TAG, "onCreate: Service already initialized");
				mServiceConnection = data.serviceConnection;
				mPclService = data.service;
			}
		}
	}

	@Override
	protected void onDestroy() {
		Log.d(TAG, "onDestroy");
		super.onDestroy();
		if (mReleaseService == 1)
			releaseService();

		if (mStopService)
			stopPclService();
	}

	@Override
	protected void onStart() {
		super.onStart();
		// initService();
	}

	@Override
	protected void onStop() {
		super.onStop();
		// releaseBarCodeReceiver();
	}

	@Override
	protected void onResume() {
		Log.d(TAG, "onResume");
		super.onResume();
		// openBarCode();
		initBarCodeReceiver();
		initStateReceiver();
	}

	@Override
	protected void onPause() {
		Log.d(TAG, "onPause");
		super.onPause();
		releaseBarCodeReceiver();
		releaseStateReceiver();
		// closeBarCode();
	}

	@Override
	public Object onRetainCustomNonConfigurationInstance() {
		mStopService = false;

		mReleaseService = 0;
		PclObject obj = new PclObject();
		obj.service = mPclService;
		obj.serviceConnection = mServiceConnection;
		return obj;
	}

	abstract void onPclServiceConnected();

	private void startPclService() {
		if (!mServiceStarted) {
			Intent intent = new Intent(this, PclService.class);
			intent.putExtra("PACKAGE_NAME", getPackageName());
			intent.putExtra("FILE_NAME", "pairing_addr.txt");

			if (getApplicationContext().startService(intent) != null)
				mServiceStarted = true;
		}
	}

	private void stopPclService() {
		if (mServiceStarted) {
			Intent i = new Intent(this, PclService.class);
			if (getApplicationContext().stopService(i))
				mServiceStarted = false;
		}
	}

	private void initService() {
		Log.d(TAG, "initService");
		mServiceConnection = new PclServiceConnection();
		Intent intent = new Intent(this, PclService.class);
		bindService(intent, mServiceConnection, Context.BIND_AUTO_CREATE);
	}

	private void releaseService() {
		Log.d(TAG, "releaseService");

		if (mBound) {
			unbindService(mServiceConnection);
			mBound = false;
		}

		Intent i = new Intent(this, PclService.class);
		getApplicationContext().stopService(i);
	}

	/** BarCode */
	private void initBarCodeReceiver() {
		if (m_BarCodeReceiver == null) {
			m_BarCodeReceiver = new BarCodeReceiver();
			IntentFilter intentfilter = new IntentFilter(
					"com.ingenico.pclservice.action.BARCODE_EVENT");
			registerReceiver(m_BarCodeReceiver, intentfilter);
		}
	}

	private void releaseBarCodeReceiver() {
		if (m_BarCodeReceiver != null) {
			unregisterReceiver(m_BarCodeReceiver);
			m_BarCodeReceiver = null;
		}
	}

	public Boolean openBarCode() {
		Log.d(TAG, "openBarCode");
		if ((mPclService != null) && !m_BarCodeActivated)
			m_BarCodeActivated = setBarCodeActivation(true);

		return m_BarCodeActivated;
	}

	public Boolean closeBarCode() {
		Log.d(TAG, "closeBarCode");
		if ((mPclService != null) && m_BarCodeActivated)
			m_BarCodeActivated = !setBarCodeActivation(false);

		return m_BarCodeActivated;
	}

	public Boolean reopenBarCode() {
		if (m_BarCodeActivated)
			closeBarCode();
		return openBarCode();
	}

	private Boolean setBarCodeActivation(boolean activateBarCode) {
		boolean result = false;
		byte array[] = null;

		if (mPclService != null) {
			array = new byte[1];
			{
				if (activateBarCode) {
					result = mPclService.openBarcode(array);
					if (result == true) {
						if (array[0] != 0)
							result = false;
					}
				} else {
					mPclService.closeBarcode(array);
					result = true;
				}
			}

		}

		return result;
	}

	public boolean openPrinter() {
		if ((mPclService != null) && !m_PrinterActivated)
			m_PrinterActivated = setPrinterActivation(true);

		return m_PrinterActivated;
	}

	public boolean closePrinter() {
		if (m_PrinterActivated)
			m_PrinterActivated = !setPrinterActivation(false);

		return m_PrinterActivated;
	}

	private boolean setPrinterActivation(boolean activatePrinter) {
		boolean result = false;
		byte array[] = null;

		if (mPclService != null) {
			array = new byte[1];
			{
				if (activatePrinter)
					result = mPclService.openPrinter(array);
				else
					result = mPclService.closePrinter(array);
			}
		}

		return result;
	}

	public boolean printText(String strText) {
		boolean Result = false;

		if (openPrinter()) {
			byte[] PrintResult = new byte[1];
			{
				Result = mPclService.printText(strText, PrintResult);
			}
			Log.d(TAG, String.format("TO PRINT : %s", strText));
			Log.d(TAG, String.format("printText result=%d", PrintResult[0]));

			closePrinter();
		}

		return Result;
	}

	public boolean printBitmap(byte[] bmpBuf, int bmpSize) {
		boolean result = false;

		if (bmpBuf != null) {
			if (openPrinter()) {
				byte[] printResult = new byte[1];
				{
					result = mPclService.printBitmap(bmpBuf, bmpSize,
							printResult);
				}
				Log.d(TAG,
						String.format("printBitMap result=%d", printResult[0]));

				closePrinter();
			}
		}

		return result;
	}

	boolean storeLogo(String name, int type, byte[] bmpBuf, int bmpSize,
			byte[] result) {
		boolean ret = false;
		if (mPclService != null) {
			{
				ret = mPclService
						.storeLogo(name, type, bmpBuf, bmpSize, result);
			}
		}
		return ret;
	}

	boolean printLogo(String name, byte[] result) {
		boolean ret = false;
		if (mPclService != null) {
			{
				ret = mPclService.printLogo(name, result);
			}
		}
		return ret;
	}

	boolean getPrinterStatus(byte[] result) {
		boolean ret = false;
		if (mPclService != null) {
			{
				ret = mPclService.getPrinterStatus(result);
			}
		}
		return ret;
	}

	boolean getTime() {
		boolean ret = false;
		byte[] time = new byte[16];
		if (mPclService != null) {
			{
				sysTime = new _SYSTEMTIME();
				ret = mPclService.getTerminalTime(time);
				ByteBuffer bbTime = ByteBuffer.wrap(time);
				bbTime.order(ByteOrder.LITTLE_ENDIAN);
				sysTime.wYear = bbTime.getShort();
				sysTime.wMonth = bbTime.getShort();
				sysTime.wDayOfWeek = bbTime.getShort();
				sysTime.wDay = bbTime.getShort();
				sysTime.wHour = bbTime.getShort();
				sysTime.wMinute = bbTime.getShort();
				sysTime.wSecond = bbTime.getShort();
				sysTime.wMilliseconds = bbTime.getShort();

			}
		}
		return ret;
	}

	boolean setTime(byte[] result) {
		boolean ret = false;

		if (mPclService != null) {
			{
				ret = mPclService.setTerminalTime(result);
			}
		}
		return ret;

	}

	boolean getTermInfo() {
		boolean ret = false;
		byte[] serialNbr = new byte[4];
		byte[] productNbr = new byte[4];
		if (mPclService != null) {
			{
				ret = mPclService.getTerminalInfo(serialNbr, productNbr);
				ByteBuffer bbSN = ByteBuffer.wrap(serialNbr);
				ByteBuffer bbPN = ByteBuffer.wrap(productNbr);
				bbSN.order(ByteOrder.LITTLE_ENDIAN);
				bbPN.order(ByteOrder.LITTLE_ENDIAN);
				SN = bbSN.getInt();
				PN = bbPN.getInt();
			}
		}
		return ret;

	}

	boolean getComponentsInfo() {
		boolean ret = false;

		if (mPclService != null) {
			{
				ret = mPclService.getTerminalComponents("Running.lst");
			}
		}
		return ret;

	}

	boolean doTransaction(TransactionIn transIn, TransactionOut transOut) {
		boolean ret = false;

		if (mPclService != null) {
			{
				ret = mPclService.doTransaction(transIn, transOut);
			}
		}
		return ret;

	}

	boolean doTransactionEx(TransactionIn transIn, TransactionOut transOut,
			int appNumber, byte[] inBuffer, int inBufferSize, byte[] outBuffer,
			long[] outBufferSize) {
		boolean ret = false;

		if (mPclService != null) {
			{
				ret = mPclService.doTransactionEx(transIn, transOut, appNumber,
						inBuffer, inBufferSize, outBuffer, outBufferSize);
			}
		}
		return ret;

	}

	boolean doUpdate(byte[] result) {
		boolean ret = false;
		if (mPclService != null) {
			{
				ret = mPclService.doUpdate(result);
			}
		}
		return ret;

	}

	boolean resetTerminal(int resetInfo) {
		boolean ret = false;
		if (mPclService != null) {
			{
				ret = mPclService.resetTerminal(resetInfo);
			}
		}
		return ret;

	}

	boolean sendMsg(byte[] msg, int[] byteSent) {
		boolean ret = false;
		if (mPclService != null) {
			{
				ret = mPclService.sendMessage(msg, byteSent);
			}
		}
		return ret;

	}

	boolean recvMsg(byte[] msg, int[] byteReceived) {
		boolean ret = false;
		if (mPclService != null) {
			ret = mPclService.receiveMessage(msg, byteReceived);
		}
		return ret;

	}

	boolean flushMsg() {
		boolean ret = false;
		if (mPclService != null) {
			{
				ret = mPclService.flushMessages();
			}
		}
		return ret;

	}

	boolean launchM2OSShortcut(byte[] shortcut) {
		boolean ret = false;
		if (mPclService != null) {
			{
				ret = mPclService.launchM2OSShortcut(shortcut);
			}
		}
		return ret;

	}

	public boolean isCompanionConnected() {
		boolean bRet = false;
		if (mPclService != null) {
			byte result[] = new byte[1];
			{
				if (mPclService.serverStatus(result) == true) {
					if (result[0] == 0x10)
						bRet = true;
				}
			}
		}
		return bRet;
	}

	private void initStateReceiver() {
		if (m_StateReceiver == null) {
			m_StateReceiver = new StateReceiver();
			IntentFilter intentfilter = new IntentFilter(
					"com.ingenico.pclservice.intent.action.STATE_CHANGED");
			registerReceiver(m_StateReceiver, intentfilter);
		}
	}

	private void releaseStateReceiver() {
		if (m_StateReceiver != null) {
			unregisterReceiver(m_StateReceiver);
			m_StateReceiver = null;
		}
	}

	private class BarCodeReceiver extends BroadcastReceiver {

		public void onReceive(Context context, Intent intent) {
			byte abyte0[] = intent.getByteArrayExtra("barcode");
			String BarCodeStr = new String(abyte0);
			Log.d(TAG, String.format("receiver: BarCode %s", BarCodeStr));
		}
	}

	private class StateReceiver extends BroadcastReceiver {

		public void onReceive(Context context, Intent intent) {
			String state = intent.getStringExtra("state");
			Log.d(TAG, String.format("receiver: State %s", state));
		}

	}

}
