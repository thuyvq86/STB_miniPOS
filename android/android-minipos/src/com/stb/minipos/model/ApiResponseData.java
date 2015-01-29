package com.stb.minipos.model;

import java.io.Serializable;

import com.stb.minipos.Constant.STBRequest;
import com.stb.minipos.Constant.STBServer;
import com.stb.minipos.model.dao.STBResponse;

public class ApiResponseData implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	public ApiResponseData(int id) {
		this.requestId = id;
	}

	public final int requestId;
	public STBServer stbServer;
	public STBRequest stbRequest;
	public STBResponse stbResponse;
	public boolean isSuccess;
}