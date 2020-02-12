#include <stdlib.h>
#include <sys/types.h>
#include <db.h>
#include <fcntl.h>
#include <limits.h>
#include <string.h>


DB *db_open(const char *file, int flags, int mode, u_int db_type, u_int cachesize, u_int duplicate) {
	DBTYPE type = db_type == 1 ? DB_HASH : DB_BTREE;

	if (cachesize || duplicate) {
		if (type == DB_BTREE) {
			BTREEINFO info = {
				.flags = (duplicate ? R_DUP : 0),
				.cachesize = cachesize,
				.maxkeypage = 0,
				.minkeypage = 0,
				.psize = 0,
				.compare = NULL,
				.prefix = NULL,
				.lorder = 0,
			};
			return dbopen(file, flags, mode, type, &info);
		} else if (DB_HASH) {
			HASHINFO info = {
				.bsize = 0,
				.ffactor = 0,
				.nelem = 0,
				.cachesize = cachesize,
				.hash = NULL,
				.lorder = 0,
			};

			return dbopen(file, flags, mode, type, &info);
		}
	} else {
		return dbopen(file, flags, mode, type, NULL);
	}
}


int db_sync(DB *db) {
	return db->sync(db, 0);
}


int db_close(DB *db) {
	return db->close(db);
}


int db_put(const DB *db, void *key, size_t key_len, const void *data, const size_t data_len, u_int flags) {
	DBT dbt_key, dbt_data;

	memset(&dbt_key, 0, sizeof(dbt_key));
	dbt_key.data = key;
	dbt_key.size = key_len;

	memset(&dbt_data, 0, sizeof(dbt_data));
	dbt_data.data = (void *) data;
	dbt_data.size = data_len;

	return db->put(db, &dbt_key, &dbt_data, flags);
}


int db_get (const DB *db, const void *key, const size_t key_len, void **data, size_t *data_len, u_int flags) {
	DBT dbt_key, dbt_data;

	memset(&dbt_key, 0, sizeof(dbt_key));
	dbt_key.data = (void *) key;
	dbt_key.size = key_len;

	memset(&dbt_data, 0, sizeof(dbt_data));

	int ret = db->get(db, &dbt_key, &dbt_data, flags);

	if (ret == 0) {
		*data = dbt_data.data;
		*data_len = dbt_data.size;
	} else {
		*data = NULL;
		*data_len = 0;
	}
	return ret;
}


int db_del (const DB *db, const void *key, const size_t key_len, u_int flags) {
	DBT dbt_key;

	memset(&dbt_key, 0, sizeof(dbt_key));
	dbt_key.data = (void *) key;
	dbt_key.size = key_len;

	return db->del(db, &dbt_key, flags);
}
