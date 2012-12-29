open Batteries_uni

let _ =
    print_endline (Printf.sprintf "ost-launch %d" (Archive.version_number ()));
    let f_in = File.open_in "test.gz" in
    let content = IO.read_all f_in in
    let l = String.length content in
    let decompressed = "           " in
    let ldec = String.length decompressed in
    let handle = Archive.read_new () in
    let entry = Archive.entry_new () in
        ignore (Archive.read_support_filter_all handle);
        ignore (Archive.read_support_format_all handle);
        Printf.printf "l: %d bytes\n" l;
        ignore (Archive.read_open_memory handle content l);
        ignore (Archive.read_next_header handle entry);
        (* print_endline (Archive.entry_pathname entry); *)
        ignore (Archive.read_data handle decompressed ldec);
        print_endline decompressed;
        Archive.read_free handle;
    print_endline (Archive.version_string ())
