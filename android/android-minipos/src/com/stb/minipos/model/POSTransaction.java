package com.stb.minipos.model;

import java.util.Observable;
import java.util.Observer;

import android.graphics.Bitmap;

import com.stb.minipos.model.STBApiManager.ApiResponseData;
import com.stb.minipos.model.dao.PosMessageObject;

public class POSTransaction extends Observable implements Observer {
	public POSTransaction(PosMessageObject object) {
		this.message = object;
	}

	private boolean isCommitting = false;
	private int requestId = 0;

	public void commit() {
		STBApiManager.instance().addObserver(this);
		isCommitting = true;
		STBBill data = new STBBill();
		data.setCustomerSignature(signature);
		data.CustomerEmail = email;
		data.SerialID = "01";
		data.MerchantID = "000000080100308";
		data.TerminalID = "60002647";
		data.TransactionData = this.message.getMessage();
		requestId = STBApiManager.instance().saveBill(data);
	}

	public boolean isCommitted() {
		return response != null && response.isSuccess
				&& "00".equalsIgnoreCase(response.stbResponse.RespCode);
	}

	public boolean isCommitting() {
		return isCommitting;
	}

	public STBResponse getResponse() {
		if (response == null)
			return null;
		return response.stbResponse;
	}

	public final PosMessageObject message;
	public Bitmap signature;
	public String email;
	private ApiResponseData response;
	private int terminalId;

	public void setTerminalId(int terminalId) {
		this.terminalId = terminalId;
	}

	@Override
	public void update(Observable observable, Object data) {
		if (observable instanceof STBApiManager) {
			if (((ApiResponseData) data).requestId == requestId) {
				System.out.println("successfull ");
				STBApiManager.instance().deleteObserver(this);
				response = (ApiResponseData) data;
				isCommitting = false;
				setChanged();
				notifyObservers();
			}
		}

	}
}
