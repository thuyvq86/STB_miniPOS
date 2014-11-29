package com.stb.minipos.model;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import android.app.Application;
import android.content.Context;

import com.j256.ormlite.dao.LruObjectCache;

public class DatabaseManager {
	private final LruObjectCache _cache;
	private final DBDataHelper _dataHelper;

	private DatabaseManager(Context context) {
		_cache = new LruObjectCache(1000);
		_dataHelper = new DBDataHelper(context, _cache);
	}

	public List<STBProfile> getProfiles() {
		try {
			return _dataHelper.getProfileDao().queryForAll();
		} catch (SQLException e) {
			e.printStackTrace();
			return new ArrayList<STBProfile>();
		}
	}

	public boolean createOrUpdate(STBProfile data) {
		try {
			_dataHelper.getProfileDao().createOrUpdate(data);
			return true;
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return false;
	}

	/**
	 * singleton
	 */
	private static DatabaseManager _instance;

	/**
	 * initialize an instance of {@link DatabaseManager}. This function should
	 * be called one on the {@link Application#onCreate()}
	 * 
	 * @param context
	 *            the application context
	 */
	public static void initialize(Context context) {
		_instance = new DatabaseManager(context);
	}

	/**
	 * get an instance of {@link DatabaseManager}
	 * 
	 * @return the instance of {@link DatabaseManager}
	 */
	protected static DatabaseManager instance() {
		if (_instance == null) {
			throw new RuntimeException(DatabaseManager.class.getName()
					+ " hasn't been initialized!!!");
		}
		return _instance;
	}

}
