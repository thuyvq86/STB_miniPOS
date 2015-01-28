package com.stb.minipos.model.dao;

import android.text.TextUtils;

import com.google.gson.Gson;
import com.stb.minipos.Constant.STBRequest;
import com.stb.minipos.utils.Utils;

public class STBResponse {
	public String Data;
	public String MerchantID;
	public String FunctionName;
	public String RefNumber;
	public String RespCode;
	public String Signature;

	private STBResponseProfiles _profilesData;
	private STBResponseBill _billData;
	private STBResponseVersion _versionData;

	public boolean isSuccess() {
		return TextUtils.equals("00", RespCode);
	}

	public Object getData() {
		if (STBRequest.BILL.functionName.equalsIgnoreCase(FunctionName)) {
			if (_billData == null) {
				String data = Utils.decodeBase64ToString(Data);
				_billData = new Gson().fromJson(data, STBResponseBill.class);
			}
			return _billData;
		} else if (STBRequest.PROFILE.functionName
				.equalsIgnoreCase(FunctionName)) {
			if (_profilesData == null) {
				String data = Utils.decodeBase64ToString(Data);
				_profilesData = new Gson().fromJson(data,
						STBResponseProfiles.class);
			}
			return _profilesData;
		} else {
			if (_versionData == null) {
				String data = Utils.decodeBase64ToString(Data);
				System.out.println(data);
				_versionData = new Gson().fromJson(data,
						STBResponseVersion.class);
			}
			return _versionData;
		}
	}

}
