open Db

fun openDb (clean, file, dbtype) =
  let
    val file = "/tmp/foo.db"
    val _ = if clean andalso Posix.FileSys.access (file, []) then Posix.FileSys.unlink file else ()

    val flags = let open Db.O in flags [creat, rdwr] end

    val mode = let open Posix.FileSys.S in flags [irusr, iwusr] end
  in
     dbopen (file, flags, mode, dbtype)
  end


fun test (dbtype, clean) =
  let
    val db = openDb (clean, "/tmp/foo.db", dbtype);

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




local
  val >>   = Word.>>    infix 9 >>
  val <<   = Word.<<    infix 9 <<
  val xorb = Word.xorb  infix 8 xorb
  val wordToChar = Byte.byteToChar o Word8.fromInt o Word.toInt
  val charToword = Word.fromInt o Word8.toInt o Byte.charToByte
in

fun pack (w:word) : string = String.implode (map wordToChar [w >> 0w24, w >> 0w16, w >> 0w8, w])

fun unpack (s:string) : word =
  case map charToword (String.explode s) of
      [w4, w3, w2, w1] => w4 << 0w24 xorb w3 << 0w16 xorb w2 << 0w8 xorb w1
    | _ => raise Overflow
end



fun recnoOverBTree clean =
  let
    val db = openDb (clean, "/tmp/foo.db", DB_BTREE);

    val key = ref (case seq (db, R.flags [R.last]) of NONE => 0w0 | SOME (k, v) => 0w1 + unpack k)


    fun add v =
      let
        val k = !key
      in
        put (db, pack k, v, R.flags []);
        key := k + 0w1
      end

    val _ = add "zero"
    val _ = add "one"
    val _ = add "two"
    val _ = add "tree"

    val _ = add "four"
    val _ = add "five"
    val _ = add "six"
    val _ = add "seven"

    fun do_seq () = case seq (db, R.flags [R.next]) of NONE => () | SOME (k, v) => ( print (Int.toString (Word.toInt (unpack k)) ^ ": " ^ v ^ "\n") ; do_seq () )
    val _ = do_seq ()
  in
    sync db;
    close db
  end



fun main () = (
    test (DB_HASH, true);
    print "---\n";
    test (DB_BTREE, true);
    print "---\n";
    recnoOverBTree true;
    print "...\n";
    recnoOverBTree false;
    print "...\n";
    print "The End.\n"
  ) handle exc => print ("function main raised an exception: " ^ exnMessage exc ^ "\n")
