#include <stdlib.h>
#include <sys/types.h>
#include <db.h>
#include <fcntl.h>
#include <limits.h>


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


int db_close(DB *db) {
	return db->close(db);
}
