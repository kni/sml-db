structure Db =
struct

local
  open MLton.Pointer

  val db_open_ffi = _import "db_open": string * int * int * word * word * word -> t;

  val db_close_ffi = _import "db_close": t -> int;

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
end

end
