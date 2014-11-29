package com.stb.minipos.ui;

import android.os.Bundle;
import android.widget.TextView;

import com.stb.minipos.R;
import com.stb.minipos.utils.AndroidUtils;

public class AboutActivity extends BaseActivity {
	private TextView txtAboutVersion;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		// requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_about);

		getSupportActionBar().setDisplayHomeAsUpEnabled(true);
		getSupportActionBar().setHomeButtonEnabled(true);

		txtAboutVersion = (TextView) findViewById(R.id.txtAboutVersion);

		String version = getString(R.string.about_version);
		version = String.format(version, AndroidUtils.getVersionName(this));
		txtAboutVersion.setText(version);

		setTitle(R.string.menu_about);
	}

}
