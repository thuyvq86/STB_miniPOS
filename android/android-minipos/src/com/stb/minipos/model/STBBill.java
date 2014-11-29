package com.stb.minipos.model;

import com.stb.minipos.utils.Utils;

import android.graphics.Bitmap;

public class STBBill {
	public String MerchantID;
	public String TerminalID;
	public String SerialID;
	public String CustomerEmail;
	public String CustomerSignature;
	public String TransactionData;

	public void setCustomerSignature(Bitmap data) {
		CustomerSignature = Utils.encodeTobase64(data);
	}
}
