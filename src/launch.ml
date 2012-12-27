let _ =
    print_endline (Printf.sprintf "ost-launch %d" (Archive.version_number ()));
    let handle = Archive.read_new () in
        Archive.read_free handle;
    print_endline (Archive.version_string ())
