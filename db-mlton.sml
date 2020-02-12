structure Db =
struct

local
  open MLton.Pointer

  val db_open_ffi = _import "db_open": string * int * int * word * word * word -> t;

  val db_close_ffi = _import "db_close": t -> int;

  val db_put_ffi = _import "db_put": t * string * C_Size.word * string * C_Size.word * word-> int;

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


  fun close db = if db_close_ffi db < 0 then fail "Cannot close database" else ()


  fun put (db, key, data, flags) =
    let
      val r = db_put_ffi (db, key, C_Size.fromInt (String.size key), data, C_Size.fromInt (String.size data), flags)
    in
      if r = 0 then true else if r = 1 then false else fail "Cannot put to database"
    end
end

end
