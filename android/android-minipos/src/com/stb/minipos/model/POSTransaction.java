package com.stb.minipos.model;

import java.util.Observable;
import java.util.Observer;

import android.graphics.Bitmap;

import com.stb.minipos.model.dao.POSMessage;
import com.stb.minipos.model.dao.STBRequestBill;
import com.stb.minipos.model.dao.STBResponse;

public class POSTransaction extends Observable implements Observer {
	public POSTransaction(POSMessage object) {
		this.message = object;
	}

	private boolean isCommitting = false;
	private int requestId = 0;

	public void commit() {
		STBApiManager.instance().addObserver(this);
		STBProfile profile = POSManager.instance().getActivedProfile();
		isCommitting = true;
		STBRequestBill data = new STBRequestBill();
		data.setCustomerSignature(signature);
		data.CustomerEmail = email;
		data.SerialID = profile.SerialID;
		data.MerchantID = profile.MerchantID;
		data.TerminalID = profile.TerminalID;
		data.TransactionData = this.message.getMessage();
		requestId = STBApiManager.instance().saveBill(data);
	}

	public boolean isCommitted() {
		return response != null && response.isSuccess
				&& response.stbResponse.isSuccess();
	}

	public boolean isCommitting() {
		return isCommitting;
	}

	public STBResponse getResponse() {
		if (response == null)
			return null;
		return response.stbResponse;
	}

	public final POSMessage message;
	public Bitmap signature;
	public String email;
	private ApiResponseData response;

	@Override
	public void update(Observable observable, Object data) {
		if (observable instanceof STBApiManager) {
			if (((ApiResponseData) data).requestId == requestId) {
				STBApiManager.instance().deleteObserver(this);
				response = (ApiResponseData) data;
				isCommitting = false;
				setChanged();
				notifyObservers();
			}
		}

	}
}
