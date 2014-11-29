package com.stb.minipos.ui;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;

import com.stb.minipos.R;
import com.stb.minipos.utils.UIUtils;
import com.stb.minipos.utils.Utils;

public class ReceiptQueryActivity extends BaseActivity implements
		View.OnClickListener {
	private EditText edtEmail;
	private EditText edtTransactionReceipt;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_receipt_query);

		findViewById(R.id.btnSubmit).setOnClickListener(this);
		findViewById(R.id.btnClear).setOnClickListener(this);

		edtEmail = (EditText) findViewById(R.id.edtEmail);
		edtTransactionReceipt = (EditText) findViewById(R.id.edtTransactionReceipt);

	}

	private void clear() {
		edtEmail.setText("");
		edtTransactionReceipt.setText("");
		edtTransactionReceipt.requestFocus();
	}

	public void submit() {
		String email = edtEmail.getText().toString();
		String transactionReceipt = edtTransactionReceipt.getText().toString();

		if (TextUtils.isEmpty(email) || TextUtils.isEmpty(transactionReceipt)) {
			UIUtils.showErrorMessage(this, R.string.transaction_receipt_form_isnt_fill);
			return;
		}

		if (!Utils.isValidEmail(email)) {
			UIUtils.showErrorMessage(this, R.string.email_isnt_valid);
			return;
		}

	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.btnClear:
			clear();
			break;
		case R.id.btnSubmit:
			submit();
			break;
		default:
			break;
		}

	}

}
