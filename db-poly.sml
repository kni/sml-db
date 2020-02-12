structure Db =
struct

local
  open Foreign
  val lib = loadLibrary "db.so"

  fun readMem (mem:Memory.voidStar, len:int) : string = CharVector.tabulate (len, fn i => Byte.byteToChar (Memory.get8 (mem, Word.fromInt i)))

  val db_open_ffi = buildCall6 ((getSymbol lib "db_open"), (cString, cInt, cInt, cUint, cUint, cUint), cPointer)

  val db_sync_ffi = buildCall1 ((getSymbol lib "db_sync"), cPointer, cInt)

  val db_close_ffi = buildCall1 ((getSymbol lib "db_close"), cPointer, cInt)

  val db_put_ffi = buildCall6 ((getSymbol lib "db_put"), (cPointer, cString, cUlong, cString, cUlong, cUint), cInt)

  val db_get_ffi = buildCall6 ((getSymbol lib "db_get"), (cPointer, cString, cUlong, cStar cPointer, cStar cUlong, cUint), cInt)

  fun fail text = raise Fail (text ^ " (" ^ Int.toString (SysWord.toInt (Foreign.Error.getLastError ())) ^ ")." )
in
  type db = Memory.voidStar


  fun dbopen_ffi (file, flags, mode, dbtype:word, cachesize:word, duplicate:word) =
    let
      val db = db_open_ffi (file, flags, mode, Word.toInt dbtype, Word.toInt cachesize, Word.toInt duplicate)
    in
      if db = Memory.null
      then fail "Cannot open database"
      else db
    end


  fun sync db = if db_sync_ffi db < 0 then fail "Cannot sync database" else ()

  fun close db = if db_close_ffi db < 0 then fail "Cannot close database" else ()


  fun put (db, key, data, flags) =
    let
      val r = db_put_ffi (db, key, String.size key, data, String.size data, Word.toInt flags)
    in
      if r = 0 then true else if r = 1 then false else fail "Cannot put to database"
    end


  fun get (db, key, flags) =
    let
      val data_r = ref Memory.null
      val data_len_r = ref 0
      val r  = db_get_ffi (db, key, String.size key, data_r, data_len_r, Word.toInt flags)
    in
      if r = 0
      then SOME (readMem (!data_r, !data_len_r))
      else if r =1 then NONE else fail "Cannot get from database"
    end
end

end
