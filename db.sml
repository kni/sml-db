structure Db :
sig
  datatype DBTYPE =
      DB_BTREE
    | DB_HASH
    | DB_BTREE_INFO of { cachesize : word, duplicate : bool }
    | DB_HASH_INFO  of { cachesize : word }

  structure O :
  sig
    type flags

    val flags : flags list -> flags

    val creat    : flags
    val excl     : flags
    val exlock   : flags
    val nofollow : flags
    val nonblock : flags
    val rdonly   : flags
    val rdwr     : flags
    val shlock   : flags
    val sync     : flags
    val trunc    : flags
  end

  structure R :
  sig
    type flags

    val flags : flags list -> flags

    val cursor      : flags
    val first       : flags
    val last        : flags
    val next        : flags
    val nooverwrite : flags
    val prev        : flags
  end

  type db

  val dbopen : string * O.flags * Posix.FileSys.S.flags * DBTYPE -> db
  val close : db -> unit
end
=
struct
  open Db

  datatype DBTYPE =
      DB_BTREE
    | DB_HASH
    | DB_BTREE_INFO of { cachesize : word, duplicate : bool }
    | DB_HASH_INFO  of { cachesize : word }


  structure O =
  struct
    type flags = word

    val flags = foldl Word.orb 0w0

    val creat    = 0w512
    val excl     = 0w2048
    val exlock   = 0w32
    val nofollow = 0w256
    val nonblock = 0w4
    val rdonly   = 0w0
    val rdwr     = 0w2
    val shlock   = 0w16
    val sync     = 0w128
    val trunc    = 0w1024
  end


  (* Routine flags. *)
  structure R =
  struct
    type flags = word

    val flags = foldl Word.orb 0w0

    val cursor      = 0w1 (* del, put, seq *)
    val first       = 0w3 (* seq *)
    val last        = 0w6 (* seq (BTREE) *)
    val next        = 0w7 (* seq *)
    val nooverwrite = 0w8 (* put *)
    val prev        = 0w9 (* seq (BTREE) *)
  end



  fun dbopen (file:string, flags:O.flags, mode:Posix.FileSys.S.flags, dbtype:DBTYPE) =
    let
      val (dbtype, cachesize, duplicate) = case dbtype of
          DB_BTREE  => (0w0, 0w0, 0w0)
        | DB_HASH   => (0w1, 0w0, 0w0)
        | DB_BTREE_INFO { cachesize = cachesize, duplicate = duplicate } => (0w0, cachesize, if duplicate then 0w1 else 0w0)
        | DB_HASH_INFO  { cachesize = cachesize }                        => (0w1, cachesize, 0w0)

    in
      dbopen_ffi(file, Word.toInt flags, SysWord.toInt (Posix.FileSys.S.toWord mode), dbtype, cachesize, duplicate)
    end



  fun sync () = ()
  fun put () = ()
  fun get () = ()
  fun del () = ()
  fun seq () = ()

end
