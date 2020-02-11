structure Db =
struct

local
  open Foreign
  val lib = loadLibrary "db.so"

  val db_open_ffi = buildCall6 ((getSymbol lib "db_open"), (cString, cInt, cInt, cUint, cUint, cUint), cPointer)

  val db_close_ffi = buildCall1 ((getSymbol lib "db_close"), cPointer, cInt)

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


  fun close db = if db_close_ffi db < 0 then fail "Cannot close database" else ()

end

end
