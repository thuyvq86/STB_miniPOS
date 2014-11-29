package com.stb.minipos.ui.base;

import android.content.res.Configuration;
import android.os.Bundle;
import android.support.v4.app.ActionBarDrawerToggle;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarActivity;
import android.text.TextUtils;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import com.stb.minipos.R;

public abstract class UIDrawerActivity extends ActionBarActivity implements
		IDrawerActivity {
	// variable
	private DrawerLayout _drawerLayout;
	private ActionBarDrawerToggle _drawerToggle;
	private View _drawerMenuLayout;
	private boolean _isDrawerTaskActived = false;

	private boolean _isDrawerMenuEnable = false;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		_isDrawerMenuEnable = isDrawerMenuEnable();
		super.onCreate(savedInstanceState);
		if (_isDrawerMenuEnable) {
			setContentView(R.layout.activity_drawer_base);
			initDrawerMenu();
			onDrawerMenuViewCreated(_drawerMenuLayout);
		} else {
			setContentView(R.layout.activity_base);
		}
		if (savedInstanceState != null) {
			_fragment = (UIDialogFragment) getSupportFragmentManager()
					.findFragmentById(R.id.vgFragmentContent);

		}
		if (_fragment == null) {
			resetState();
		}
	}

	@Override
	protected void onPostCreate(Bundle savedInstanceState) {
		super.onPostCreate(savedInstanceState);
		// Sync the toggle state after onRestoreInstanceState has occurred.
		if (_isDrawerMenuEnable)
			_drawerToggle.syncState();
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		boolean result = super.onCreateOptionsMenu(menu);
		if (getCurrentFragment() != null) {
			getCurrentFragment().onCreateOptionsMenu(menu, getMenuInflater());
		}
		return result;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		if (_isDrawerMenuEnable && _drawerToggle.onOptionsItemSelected(item)) {
			return true;
		}
		if (getCurrentFragment() != null
				&& getCurrentFragment().onOptionsItemSelected(item))
			return true;

		switch (item.getItemId()) {
		case android.R.id.home:
			finish();
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
		if (_isDrawerMenuEnable)
			_drawerToggle.onConfigurationChanged(newConfig);
	}

	@Override
	public void setTitle(CharSequence title) {
		try {
			super.setTitle(title);
			if (getSupportActionBar() != null) {
				getSupportActionBar().setTitle(title);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public void setTitle(int titleId) {
		try {
			super.setTitle(titleId);
			getSupportActionBar().setTitle(titleId);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * This method will be called once when the activity create.
	 * 
	 * @return <b>true</b> if drawer menu is enable on this screen, otherwise
	 *         return <b>false</b>
	 */
	public boolean isDrawerMenuEnable() {
		return false;
	}

	/**
	 * Initial drawer menu. This method will be called in
	 * {@link #onCreate(Bundle)} when drawer menu enable (
	 * {@link #isDrawerMenuEnable()} equals <b>true</b>)
	 */
	private void initDrawerMenu() {
		_drawerLayout = (DrawerLayout) findViewById(R.id.drawerLayout);
		_drawerMenuLayout = findViewById(R.id.left_drawer);
		_drawerLayout.setDrawerShadow(R.drawable.drawer_shadow,
				GravityCompat.START);
		_drawerToggle = new ActionBarDrawerToggle(this, _drawerLayout,
				getDrawerImageRes(), getOpenDrawerContentDescRes(),
				getCloseDrawerContentDescRes()) {
			@Override
			public void onDrawerSlide(View drawerView, float slideOffset) {
				super.onDrawerSlide(drawerView, slideOffset);
				UIDrawerActivity.this.onDrawerSlide(drawerView, slideOffset);
			}

			@Override
			public void onDrawerStateChanged(int newState) {
				super.onDrawerStateChanged(newState);
				if (newState == DrawerLayout.STATE_IDLE) {
					_isDrawerTaskActived = false;
				} else if (!_isDrawerTaskActived) {
					_isDrawerTaskActived = true;
					if (!isDrawerOpen()) {
						onDrawerVisible();
						if (_fragment != null) {
							_fragment.onDrawerVisible();
						}
					}
				}
				UIDrawerActivity.this.onDrawerStateChanged(newState);
			}

			@Override
			public void onDrawerClosed(View drawerView) {
				super.onDrawerClosed(drawerView);
				UIDrawerActivity.this.onDrawerClosed(drawerView);
				if (_fragment != null) {
					_fragment.onDrawerClosed(drawerView);
				}
			}

			@Override
			public void onDrawerOpened(View drawerView) {
				super.onDrawerOpened(drawerView);
				UIDrawerActivity.this.onDrawerOpened(drawerView);
				if (_fragment != null) {
					_fragment.onDrawerOpened(drawerView);
				}
			}

		};

		_drawerLayout.setDrawerListener(_drawerToggle);

		getSupportActionBar().setDisplayHomeAsUpEnabled(true);
		getSupportActionBar().setHomeButtonEnabled(true);
	}

	public int getOpenDrawerContentDescRes() {
		return R.string.openDrawerContentDescRes;
	}

	public int getCloseDrawerContentDescRes() {
		return R.string.closeDrawerContentDescRes;
	}

	@Override
	public UIDialogFragment getCurrentFragment() {
		if (_fragment == null) {
			_fragment = (UIDialogFragment) getSupportFragmentManager()
					.findFragmentById(R.id.vgFragmentContent);
		}
		if (_fragment == null) {
			resetState();
		}

		return _fragment;
	}

	@Override
	public void onBackPressed() {
		if (_isDrawerMenuEnable && isDrawerOpen()) {
			closeDrawer();
			return;
		}
		int count = getSupportFragmentManager().getBackStackEntryCount();
		if (backState()) {
			return;
		}
		super.onBackPressed();
		if (getCurrentFragment() == null && count <= 1) {
			finish();
		}
	}

	@Override
	public int getDrawerImageRes() {
		return R.drawable.ic_drawer;
	}

	public void onDrawerMenuViewCreated(View drawerMenuView) {

	}

	public void onDrawerSlide(View drawerView, float slideOffset) {
	}

	public void onDrawerStateChanged(int newState) {
	}

	public void onDrawerClosed(View drawerView) {
	}

	public void onDrawerOpened(View drawerView) {
	}

	public void onDrawerVisible() {
	}

	public void openDrawer() {
		if (!isDrawerOpen()) {
			_drawerLayout.openDrawer(_drawerLayout);
		}
	}

	// state handle
	private UIDialogFragment _fragment;

	public void closeDrawer() {
		if (isDrawerOpen()) {
			_drawerLayout.closeDrawers();
		}
	}

	public boolean isDrawerOpen() {
		return _drawerLayout != null && _drawerMenuLayout != null
				&& _drawerLayout.isDrawerOpen(_drawerMenuLayout);
	}

	/**
	 * wrapper for showing a dialog
	 * 
	 * @param dialog
	 *            an instance of {@link UIDialogFragment}
	 */
	public void showDialog(UIDialogFragment dialog) {
		if (dialog != null)
			dialog.show(getSupportFragmentManager(), getTag(dialog));
	}

	/**
	 * 
	 * show the dialog fragment. This fragment will not be added to back stack
	 * and use default tag provided by {@link #getTag(UIDialogFragment)}
	 * 
	 * @param state
	 *            an instance of {@link UIDialogFragment}
	 */
	public void switchState(UIDialogFragment state) {
		switchToState(state, 0, null);
	}

	/**
	 * Show the dialog fragment. This fragment will use default tag provided by
	 * {@link #getTag(UIDialogFragment)}
	 * 
	 * @param state
	 *            an instance of {@link UIDialogFragment}
	 * 
	 * @param flags
	 *            options for showing fragment <br>
	 * 
	 *            <pre>
	 * Currently, below values are supported
	 * {@link IDrawerActivity#FLAG_ADD_TO_BACK_STACK}
	 * </pre>
	 */
	public void switchState(UIDialogFragment state, int flags) {
		switchToState(state, flags, null);
	}

	public void switchState(UIDialogFragment state, String tag) {
		switchToState(state, 0, null);
	}

	public void switchState(UIDialogFragment state, int flags, String tag) {
		switchToState(state, flags, tag);
	}

	/**
	 * Show the dialog fragment. This fragment will use default tag provided by
	 * {@link #getTag(UIDialogFragment)}
	 * 
	 * @param fragment
	 *            an instance of {@link UIDialogFragment}
	 * @param tag
	 *            the tag of {@link UIDialogFragment}
	 * @param flags
	 *            options for showing fragment
	 * 
	 *            <pre>
	 * Currently, below values are supported
	 * {@link IDrawerActivity#FLAG_ADD_TO_BACK_STACK}
	 * </pre>
	 */
	private void switchToState(UIDialogFragment fragment, int flags, String tag) {
		if (TextUtils.isEmpty(tag)) {
			// default tag will be generated
			tag = getTag(fragment);
		}

		_fragment = fragment;
		FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
		ft.replace(R.id.vgFragmentContent, fragment, tag);
		if ((flags & FLAG_ADD_TO_BACK_STACK) != 0) {
			ft.addToBackStack(tag);
		}
		ft.commit();
	}

	public boolean backState() {
		_fragment = null;
		int count = getSupportFragmentManager().getBackStackEntryCount();
		if (count > 1) {
			return getSupportFragmentManager().popBackStackImmediate();
		} else if (count > 0) {
			getSupportFragmentManager().popBackStack();
		}
		return false;
	}

	private void resetState() {
		_fragment = null;
		// remove all fragments
		FragmentManager fm = getSupportFragmentManager();
		if (fm != null) {
			for (int i = 0; i < fm.getBackStackEntryCount(); ++i) {
				fm.popBackStack();
			}
		}
	}

	/**
	 * 
	 * @param tag
	 *            the default tag of fragment
	 * @param fragment
	 *            Class instances representing {@link UIDialogFragment}
	 * @return true if default tag match with the fragment, otherwise return
	 *         false
	 */
	public boolean isInstance(String tag,
			Class<? extends UIDialogFragment> fragment) {
		if (fragment == null || TextUtils.isEmpty(tag))
			return false;
		return getTag(fragment).equals(tag);
	}

	/**
	 * get default tag of {@link UIDialogFragment}
	 * 
	 * @param fragment
	 *            an instance of {@link UIDialogFragment}
	 * 
	 * @return default tag of that instance
	 */
	private String getTag(UIDialogFragment fragment) {
		if (fragment == null) {
			return "";
		}
		return fragment.getClass().getName();
	}

	/**
	 * get default tag of {@link UIDialogFragment}
	 * 
	 * @param fragment
	 *            Class instances representing {@link UIDialogFragment}
	 * 
	 * @return default tag of that instance
	 */
	public String getTag(Class<? extends UIDialogFragment> fragment) {
		if (fragment == null) {
			return "";
		}
		return fragment.getName();
	}
}
