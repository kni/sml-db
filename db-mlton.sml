structure Db =
struct

local
  open MLton.Pointer

  fun readMem (ptr:t, len:int) : string = Byte.bytesToString (Word8Array.vector (Word8Array.tabulate(len, (fn(i) => getWord8(ptr, i)))))

  val db_open_ffi = _import "db_open": string * int * int * word * word * word -> t;

  val db_sync_ffi = _import "db_sync": t -> int;

  val db_close_ffi = _import "db_close": t -> int;

  val db_put_ffi = _import "db_put": t * string * C_Size.word * string * C_Size.word * word-> int;

  val db_get_ffi = _import "db_get": t * string * C_Size.word * t ref * C_Size.word ref * word-> int;

  fun fail text = raise Fail (text ^ " (" ^ Int.toString (PrimitiveFFI.Posix.Error.getErrno ()) ^ ")." )
in
  type db = t


  fun dbopen_ffi (file, flags, mode, dbtype, cachesize, duplicate) =
    let
      val db = db_open_ffi (file, flags, mode, dbtype, cachesize, duplicate)
    in
      if db = null
      then fail "Cannot open database"
      else db
    end


  fun sync db = if db_sync_ffi db < 0 then fail "Cannot sync database" else ()

  fun close db = if db_close_ffi db < 0 then fail "Cannot close database" else ()


  fun put (db, key, data, flags) =
    let
      val r = db_put_ffi (db, key, C_Size.fromInt (String.size key), data, C_Size.fromInt (String.size data), flags)
    in
      if r = 0 then true else if r = 1 then false else fail "Cannot put to database"
    end


  fun get (db, key, flags) =
    let
      val data_r = ref null
      val data_len_r = ref 0w0
      val r  = db_get_ffi (db, key, C_Size.fromInt (String.size key), data_r, data_len_r, flags)
    in
      if r = 0
      then SOME (readMem (!data_r, C_Size.toInt (!data_len_r)))
      else if r = 1 then NONE else fail "Cannot get from database"
    end
end

end
