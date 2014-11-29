package com.stb.minipos.model;

import java.util.Observable;
import java.util.Observer;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.TextView;

import com.google.gson.Gson;
import com.stb.minipos.R;

public class TestAPIActivity extends Activity implements OnClickListener,
		Observer {
	TextView txtResult;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_test_reponse);
		txtResult = (TextView) findViewById(R.id.txtResult);
		STBApiManager.instance().addObserver(this);
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.btnGetProfiles:
			STBApiManager.instance().getProfile("01");
			break;
		case R.id.btnSaveBill:
			STBBill data = new STBBill();
			data.MerchantID = "000000080100308";
			data.TerminalID = "60002647";
			data.SerialID = "01";
			data.CustomerEmail = "lochh12839@sacombank.com";
			data.CustomerSignature = "ABCDEF";
			data.TransactionData = "F1^1|F2^472074XXXXXX0130|F4^000000010100|F12^145459|F38^183256|F39^00";
			STBApiManager.instance().saveBill(data);
			break;

		default:
			break;
		}
	}

	@Override
	public void update(Observable observable, Object data) {
		if (observable == STBApiManager.instance()
				&& data instanceof STBApiManager.ApiResponseData) {
			STBResponse res = ((STBApiManager.ApiResponseData) data).stbResponse;
			res.getData();
			txtResult.setText(new Gson().toJson(res));
		}
	}
}
