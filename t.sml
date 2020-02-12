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


  in
    close db
  end



fun main () = (
    test ();
    print "The End.\n"
  ) handle exc => print ("function main raised an exception: " ^ exnMessage exc ^ "\n")
