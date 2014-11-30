package com.stb.minipos.model.dao;

import com.stb.minipos.utils.Utils;

import android.graphics.Bitmap;

public class STBRequestBill {
	public String MerchantID;
	public String TerminalID;
	public String SerialID;
	public String CustomerEmail;
	public String CustomerSignature;
	public String TransactionData;

	public void setCustomerSignature(Bitmap data) {
		if (data == null)
			CustomerSignature = "";
		else
			CustomerSignature = Utils.encodeTobase64(data);
	}
}
