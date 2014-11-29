package com.stb.minipos.model.dao;

import java.io.Serializable;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.text.TextUtils;

public class PosMessageObject implements Serializable {
	enum ValueType {
		TRANSACTION_TYPE(79), // sell, void
		CARD_NUMBER(2), // card number
		CARD_NAME(66), // card name
		CARD_TYPE(65), // card type
		TOTAL(4), // card number
		TERMINAL_ID(41), // card number
		APPROVE_CODE(38), // approve code
		RECEIPT_UNIT(49), // unit
		RECEIPT_NO(62), // card number
		RECEIPT_REF_NO(37), // reference number
		RECEIPT_BATCH_NO(60), // batch number
		TIME(12), // card number
		EXPIRED_DATE(14), // expired date
		;
		private ValueType(int id) {
			this.id = id;
		}

		public final int id;
	};

	private static final long serialVersionUID = 1L;

	public PosMessageObject(String message) {
		this.message = message;
	}

	public void checkCorrect() {

	}

	private final String message;

	public String getMessage() {
		return message;
	}

	public String getValue(int field) {
		try {
			String re = "(\\|)?F" + field + "\\^([a-z0-9A-Z ]+)";
			Pattern pattern = Pattern.compile(re);
			Matcher matcher = pattern.matcher(message);
			if (matcher.find())
				return matcher.group(2);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	private String getValue(ValueType field) {
		return getValue(field.id);
	}

	public boolean isSuccess() {
		return TextUtils.equals(getValue(39), "00");
	}

	public boolean needSignature() {
		return TextUtils.equals(getValue(1), "1");
	}

	public String getCardType() {
		return getValue(ValueType.CARD_TYPE);
	}

	public String getCardName() {
		return getValue(ValueType.CARD_NAME);
	}

	public String getCardNumber() {
		String number = getValue(ValueType.CARD_NUMBER);
		return String.format("%s %sXX XXXX %s", number.substring(0, 4),
				number.substring(4, 6), number.substring(number.length() - 4));
	}

	public int getTotal() {
		return Integer.parseInt(getValue(ValueType.TOTAL));
	}

	public Date getTime() {
		String timeformat = "yyyyMMddHHmmss";
		SimpleDateFormat formater = new SimpleDateFormat(timeformat,
				Locale.getDefault());
		try {
			return formater.parse(getValue(ValueType.TIME));
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return null;
	}

	public String getFormattedTime() {
		SimpleDateFormat formatter = new SimpleDateFormat("dd/MM/yy HH:mm",
				Locale.getDefault());
		return formatter.format(getTime());
	}

	public String getTransactionType() {
		return getValue(ValueType.TRANSACTION_TYPE);
	}

	public String getReceiptNo() {
		return getValue(ValueType.RECEIPT_NO);
	}

	public String getReceiptRefNo() {
		return getValue(ValueType.RECEIPT_REF_NO);
	}

	public String getReceiptBatchNo() {
		return getValue(ValueType.RECEIPT_BATCH_NO);
	}

	public String getExpiredDate() {
		String expireDay = getValue(ValueType.EXPIRED_DATE);
		return expireDay.substring(2) + "/" + expireDay.substring(0, 2);
	}

	public String getAppCode() {
		return getValue(ValueType.APPROVE_CODE);
	}
	
	public String getUnit() {
		return getValue(ValueType.RECEIPT_UNIT);
	}

}
