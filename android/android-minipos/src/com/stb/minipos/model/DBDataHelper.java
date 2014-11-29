package com.stb.minipos.model;

import java.sql.SQLException;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;

import com.j256.ormlite.android.apptools.OrmLiteSqliteOpenHelper;
import com.j256.ormlite.dao.Dao;
import com.j256.ormlite.dao.LruObjectCache;
import com.j256.ormlite.support.ConnectionSource;
import com.j256.ormlite.table.TableUtils;
import com.stb.minipos.model.dao.ProfileDao;
import com.stb.minipos.utils.JMDBUtils;

public class DBDataHelper extends OrmLiteSqliteOpenHelper {

	public static final String DATABASE_NAME = "data.sqlite";
	private static final int DATABASE_VERSION = 1;

	private final LruObjectCache _cache;
	@SuppressWarnings("unused")
	private final Context context;

	// dao
	private Dao<ProfileDao, String> _profileDao;

	public DBDataHelper(Context context, LruObjectCache cache) {
		super(context, DATABASE_NAME, null, DATABASE_VERSION);
		this.context = context;
		this._cache = cache;

		// import database
		// if (JMDBUtils.importDataBaseIfNotExist(context, DATABASE_NAME)) {
		// JMDBUtils.setDatabaseVersion(
		// JMDBUtils.getDatabaseFile(context, DATABASE_NAME),
		// DATABASE_VERSION);
		// }

		// check if the database upgrade is needed
		if (JMDBUtils.isDatabaseExists(context, DATABASE_NAME)) {
			int oldVersion = JMDBUtils.getDatabaseVersion(JMDBUtils
					.getDatabaseFile(context, DATABASE_NAME));
			if (DATABASE_VERSION > oldVersion) {
				doUpgrade(DATABASE_VERSION, oldVersion);
			}
		}
	}

	/**
	 * this method will be called when the database upgrade is needed
	 */
	public void doUpgrade(int newVersion, int oldVersion) {
		// if (JMDBUtils.importDataBase(context, DATABASE_NAME)) {
		// JMDBUtils.setDatabaseVersion(
		// JMDBUtils.getDatabaseFile(context, DATABASE_NAME),
		// DATABASE_VERSION);
		// }
	}

	@Override
	public void onCreate(SQLiteDatabase arg0, ConnectionSource arg1) {
		try {
			TableUtils.createTable(getConnectionSource(), ProfileDao.class);
		} catch (SQLException e) {
			e.printStackTrace();
		}

	}

	@Override
	public void onUpgrade(SQLiteDatabase arg0, ConnectionSource arg1, int arg2,
			int arg3) {

	}

	public Dao<ProfileDao, String> getProfileDao() {
		if (_profileDao == null) {
			try {
				_profileDao = getDao(ProfileDao.class);
				if (_cache != null)
					_profileDao.setObjectCache(_cache);
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return _profileDao;
	}

}
