let _ =
    print_endline (Printf.sprintf "ost-launch %d" (Archive.version_number ()));
    let handle = Archive.read_new () in
        ignore (Archive.read_support_filter_all handle);
        ignore (Archive.read_support_format_all handle);
        ignore (Archive.read_open_memory handle "abc" 3);
        Archive.read_free handle;
    print_endline (Archive.version_string ())
