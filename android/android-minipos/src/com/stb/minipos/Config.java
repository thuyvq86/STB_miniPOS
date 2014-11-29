package com.stb.minipos;

public interface Config {
	public static final boolean IS_RELEASE = false;
	public static final int POS_CONNECT_TIMEOUT = 15 * 1000; // connect timeout
	
	public static final boolean SSL_TRUST_ALL_CERTIFICATE = true;
	public static final int API_REQUEST_TIMEOUT = 20 * 1000;
	public static final String API_CONTENT_TYPE = "application/json; charset=utf-8";
}
