package com.stb.minipos.model;

import java.io.UnsupportedEncodingException;
import java.security.KeyStore;
import java.util.Observable;

import org.apache.http.Header;
import org.apache.http.entity.StringEntity;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;

import com.google.gson.Gson;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.MySSLSocketFactory;
import com.loopj.android.http.TextHttpResponseHandler;
import com.stb.minipos.Config;
import com.stb.minipos.Constant.STBRequest;
import com.stb.minipos.Constant.STBServer;
import com.stb.minipos.model.dao.STBRequestBill;
import com.stb.minipos.model.dao.STBResponse;

public class STBApiManager extends Observable implements Config {
	private final Context context;

	private STBApiManager(Context context) {
		this.context = context;
	}

	private AsyncHttpClient _httpClient;

	public class ApiResponseData {
		public ApiResponseData(int id) {
			this.requestId = id;
		}

		public final int requestId;
		public STBServer stbServer;
		public STBRequest stbRequest;
		public STBResponse stbResponse;
		public boolean isSuccess;
	}

	public int getProfile(String serialID) {
		JSONObject jsonData = new JSONObject();
		try {
			jsonData.put("SerialID", serialID);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return executeRequest(_id++, STBServer.PRIMARY, STBRequest.PROFILE,
				jsonData.toString());
	}

	public int saveBill(STBRequestBill data) {
		return executeRequest(_id++, STBServer.PRIMARY, STBRequest.BILL,
				new Gson().toJson(data));
	}

	public int getVersion() {
		return executeRequest(_id++, STBServer.PRIMARY, STBRequest.VERSION, "");
	}

	private int _id = 0;

	private int executeRequest(final int requestId, final STBServer server,
			final STBRequest request, final String jsonData) {

		final ApiResponseData responseData = new ApiResponseData(requestId);
		responseData.stbServer = server;

		_httpClient = new AsyncHttpClient();
		_httpClient.setTimeout(API_REQUEST_TIMEOUT);
		if (SSL_TRUST_ALL_CERTIFICATE) {
			MySSLSocketFactory trustStore = getTrustSocket();
			if (trustStore != null) {
				_httpClient.setSSLSocketFactory(trustStore);
			}
		}
		_httpClient.addHeader("Content-Type", API_CONTENT_TYPE);

		// init parameters
		StringEntity httpEntity = null;
		try {

			JSONObject jsonObj = new JSONObject();
			jsonObj.put("Data", jsonData);
			jsonObj.put("MerchantID", "MiniPOS");
			jsonObj.put("FunctionName", request.functionName);
			jsonObj.put("RefNumber", "");
			jsonObj.put("Signature", "");
			jsonObj.put("Token", "");
			httpEntity = new StringEntity(jsonObj.toString(), "UTF-8");
			httpEntity.setContentEncoding("UTF-8");
			httpEntity.setContentType(API_CONTENT_TYPE);
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		} catch (JSONException e) {
			e.printStackTrace();
		}

		_httpClient.post(context, server.value, httpEntity, API_CONTENT_TYPE,
				new TextHttpResponseHandler("utf-8") {
					@Override
					public void onSuccess(int statusCode, Header[] headers,
							String response) {
						STBResponse object = new Gson().fromJson(response,
								STBResponse.class);
						responseData.isSuccess = true;
						responseData.stbResponse = object;
						setChanged();
						notifyObservers(responseData);
					}

					@Override
					public void onFailure(int arg0, Header[] arg1, String arg2,
							Throwable arg3) {
						if (server == STBServer.PRIMARY) {
							executeRequest(requestId, STBServer.SECONDARY,
									request, jsonData);
						} else {
							responseData.isSuccess = false;
							setChanged();
							notifyObservers(responseData);
						}
					}
				});

		return requestId;
	}

	private static MySSLSocketFactory getTrustSocket() {
		try {
			KeyStore trustStore = KeyStore.getInstance(KeyStore
					.getDefaultType());
			trustStore.load(null, null);
			// We initialize a new SSLSocketFacrory
			MySSLSocketFactory socketFactory = new MySSLSocketFactory(
					trustStore);
			// We set that all host names are allowed in the socket factory
			socketFactory
					.setHostnameVerifier(MySSLSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER);
			// We initialize the Async Client
			return socketFactory;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * single instance of {@link STBApiManager}
	 */
	private static STBApiManager _instance;

	/**
	 * create new single instance of {@link STBApiManager}
	 * 
	 * @param context
	 *            the application context
	 */
	public static void init(Context context) {
		_instance = new STBApiManager(context);
	}

	/**
	 * get an instance of {@link STBApiManager}
	 * 
	 * @return an instance of {@link STBApiManager}
	 *         <p/>
	 *         throw <br/>
	 *         {@link RuntimeException} if the instance hasn't been initialized
	 */
	public static STBApiManager instance() {
		if (_instance == null) {
			throw new RuntimeException(STBApiManager.class.getName()
					+ " hasn't been initialized!!!");
		}
		return _instance;
	}
}
