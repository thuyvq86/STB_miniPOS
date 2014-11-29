package com.stb.minipos.utils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

/**
 * Helper class to import an existing database into the app.
 * 
 * @author Toan Nguyen Canh
 * 
 */
public class JMDBUtils {
	private JMDBUtils() {
	};

	public static boolean importDataBaseIfNotExist(Context context,
			String dbName) {
		if (isDatabaseExists(context, dbName)) {
			return false;
		}
		return importDataBase(context, dbName);
	}

	/**
	 * Creates an empty database on the system and rewrites it with your own
	 * database.
	 * 
	 * @param context
	 *            The context.
	 * @param dbName
	 *            The name of the db.
	 * @return True if the db has been imported, otherwise false.
	 */
	public static boolean importDataBase(Context context, String dbName) {
		InputStream in = null;
		OutputStream out = null;
		try {
			// Open local db from assets as the input stream
			in = context.getAssets().open(dbName);

			// Open the empty db as the output stream
			File outDatabase = getDatabaseFile(context, dbName);
			if (outDatabase.exists()) {
				outDatabase.delete();
			}
			createEmptyDatabase(context, dbName);
			out = new FileOutputStream(getDatabaseFile(context, dbName));

			// transfer bytes from the inputfile to the outputfile
			byte[] buffer = new byte[1024];
			int length;
			while ((length = in.read(buffer)) > 0) {
				out.write(buffer, 0, length);
			}

			out.flush();
			return true;
		} catch (IOException e) {
			Log.e("DatabaseImportHelper", e.getMessage());
		} finally {
			if (in != null) {
				try {
					in.close();
				} catch (IOException e) {
				}
			}
			if (out != null) {
				try {
					out.close();
				} catch (IOException e) {
				}
			}
		}

		return false;
	}

	/**
	 * Check if the database already exists.
	 * 
	 * @param context
	 *            The context.
	 * @param dbName
	 *            The name of the db.
	 * @return True if it exists, false if it doesn't.
	 */
	public static boolean isDatabaseExists(Context context, String dbName) {
		return getDatabaseFile(context, dbName).exists();
	}

	/**
	 * Sets the version of the database (PRAGMA user version).
	 * 
	 * @param database
	 *            the database to set the version.
	 * @param version
	 *            the version number.
	 */
	public static void setDatabaseVersion(File database, int version) {
		SQLiteDatabase db = null;
		try {
			db = SQLiteDatabase.openDatabase(database.getAbsolutePath(), null,
					SQLiteDatabase.OPEN_READWRITE);
			db.execSQL("PRAGMA user_version = " + version);
		} catch (SQLiteException e) {
			Log.e("DatabaseImportHelper", e.getMessage());
		} finally {
			if (db != null && db.isOpen()) {
				db.close();
			}
		}
	}

	/**
	 * get the version of database
	 * 
	 * @param database
	 *            the database to get the version
	 * @return the version of database
	 */
	public static int getDatabaseVersion(File database) {
		SQLiteDatabase db = null;
		Cursor cursor = null;
		try {
			db = SQLiteDatabase.openDatabase(database.getAbsolutePath(), null,
					SQLiteDatabase.OPEN_READWRITE);
			cursor = db.rawQuery("PRAGMA user_version", null);
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				return cursor.getInt(0);
			}
		} catch (SQLiteException e) {
			Log.e("DatabaseImportHelper", e.getMessage());
		} finally {
			if (db != null && db.isOpen()) {
				db.close();
			}
			if (cursor != null && !cursor.isClosed()) {
				cursor.close();
			}
		}
		return -1;
	}

	/**
	 * Gets the database file.
	 * 
	 * @param context
	 *            the context.
	 * @param dbName
	 *            the name of the database.
	 */
	public static File getDatabaseFile(Context context, String dbName) {
		return context.getDatabasePath(dbName);
	}

	private static void createEmptyDatabase(Context context, String dbName) {
		// use anonymous helper to create empty database
		new SQLiteOpenHelper(context, dbName, null, 1) {

			// Methods are empty. We don`t need to override them
			@Override
			public void onUpgrade(SQLiteDatabase db, int oldVersion,
					int newVersion) {
			}

			@Override
			public void onCreate(SQLiteDatabase db) {
			}
		}.getReadableDatabase().close();
	}

	public static boolean deleteDatabase(Context context, String dbName) {
		try {
			File file = context.getDatabasePath(dbName);
			file.delete();
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
}