package com.stb.minipos;

public interface Constant {

	public enum STBServer {
		PRIMARY("https://113.164.14.65:9444/api"), //
		SECONDARY("https://113.164.14.65:9444/api");
		private STBServer(String value) {
			this.value = value;
		}

		// value
		public final String value;

	}

	public enum STBRequest {
		PROFILE("ICMPProfileGetter"), //
		BILL("ICMPBillReceiver"), //
		VERSION("ICMPVersionGetter"), //
		;
		STBRequest(String name) {
			this.functionName = name;
		}

		public final String functionName;
	}
}
