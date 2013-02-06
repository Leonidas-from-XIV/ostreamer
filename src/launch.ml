open Batteries_uni

let _ =
    print_endline (Printf.sprintf "ost-launch %d" (Archive.version_number ()));
    print_endline (Archive.version_string ());
    let f_in = File.open_in "test.gz" in
    let content = IO.read_all f_in in
    let l = String.length content in
    let handle = Archive.read_new () in
    let entry = Archive.entry_new () in
    let buff = ref "" in
    let size = ref 0 in
    let offset = ref 0 in
        Archive.print_pointer entry;
        ignore (Archive.read_support_filter_all handle);
        ignore (Archive.read_support_format_all handle);
        ignore (Archive.read_support_format_raw handle);
        Printf.printf "l: %d bytes\n" l;
        ignore (Archive.read_open_memory handle content l);
        (* Printf.printf "errno %d\n" (Archive.errno handle); *)
        (* Printf.printf "error %s\n" (Archive.error_string handle); *)
        ignore (Archive.read_next_header handle entry);
        Archive.print_pointer entry;
        print_endline (Archive.entry_pathname entry);
        ignore (Archive.read_data_block handle buff size offset);
        Printf.printf "size %d, offset %d, buff %s\n" !size !offset !buff;
        ignore (Archive.write_set_format_raw handle);
        ignore (Archive.write_add_filter_gzip handle)
