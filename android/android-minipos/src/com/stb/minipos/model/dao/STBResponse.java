package com.stb.minipos.model.dao;

import android.text.TextUtils;

import com.google.gson.Gson;
import com.stb.minipos.utils.Utils;

public class STBResponse {
	public String Data;
	public String MerchantID;
	public String FunctionName;
	public String RefNumber;
	public String RespCode;
	public String Signature;

	public boolean isSuccess() {
		return TextUtils.equals("00", RespCode);
	}

	public STBResponseProfiles getDataAsProfile() {
		String data = Utils.decodeBase64ToString(Data);
		return new Gson().fromJson(data, STBResponseProfiles.class);
	}

	public STBResponseBill getDataAsBill() {
		String data = Utils.decodeBase64ToString(Data);
		return new Gson().fromJson(data, STBResponseBill.class);
	}

	public STBResponseVersion getDataAsVersion() {
		String data = Utils.decodeBase64ToString(Data);
		return new Gson().fromJson(data, STBResponseVersion.class);
	}

}
