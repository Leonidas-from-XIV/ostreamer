open Batteries_uni

let _ =
    print_endline (Printf.sprintf "ost-launch %d" (Archive.version_number ()));
    let f_in = File.open_in "test.gz" in
    let content = IO.read_all f_in in
    let l = String.length content in
    let handle = Archive.read_new () in
        ignore (Archive.read_support_filter_all handle);
        ignore (Archive.read_support_format_all handle);
        ignore (Archive.read_open_memory handle content l);
        Archive.read_free handle;
    print_endline (Archive.version_string ())
