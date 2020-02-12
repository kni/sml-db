fun test () =
  let
    open Db

    val file = "/tmp/foo.db"
    val _ = if Posix.FileSys.access (file, []) then Posix.FileSys.unlink file else ()

    val flags = let open Db.O in flags [creat, rdwr] end

    val mode = let open Posix.FileSys.S in flags [irusr, iwusr] end

    val db = dbopen (file, flags, mode, DB_BTREE)


    fun put' (k, v) = put (db, k, v, R.flags [])

    val _ = put' ("one", "orange")
    val _ = put' ("two", "red")
    val _ = put' ("tree", "yellow")

    val _ = case get (db, "tree", R.flags []) of SOME v => () | NONE => ()
    val _ = del (db, "tree", R.flags [])
    val _ = put' ("tree", "yellow")

    fun do_seq () = case seq (db, R.flags [R.next]) of NONE => () | SOME (k, v) => ( print (k ^ ": " ^ v ^ "\n") ; do_seq () )
    val _ = do_seq ()

  in
    sync db;
    close db
  end



fun main () = (
    test ();
    print "The End.\n"
  ) handle exc => print ("function main raised an exception: " ^ exnMessage exc ^ "\n")
