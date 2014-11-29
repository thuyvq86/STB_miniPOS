package com.stb.minipos.model;

import org.apache.http.Header;

import com.loopj.android.http.TextHttpResponseHandler;

public abstract class STBHttpResponseHandler extends TextHttpResponseHandler {

	public abstract void onSuccess(int statusCode, Header[] arg1,
			STBResponse data);
	
	@Override
	public void onFailure(int arg0, Header[] arg1, String arg2, Throwable arg3) {
		System.out.println(arg0 + ": " + arg2);
		
	}
	
	@Override
	public void onSuccess(int arg0, Header[] arg1, String arg2) {
		
	}


}
