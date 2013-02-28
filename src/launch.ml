open Batteries_uni

let _ =
    print_endline (Printf.sprintf "ost-launch %d" (Archive.version_number ()));
    print_endline (Archive.version_string ());
    let f_in = File.open_in "test.gz" in
    let content = IO.read_all f_in in
    let l = String.length content in
    let readhandle = Archive.read_new () in
    let readentry = Archive.entry_new () in
    let uncompsize = 100 in
    let buff = ref (String.create uncompsize) in
    let writehandle = Archive.write_new () in
    let compsize = 100 in
    let compressed = ref (String.create compsize) in
    let outused = ref 23 in
    let writeentry = Archive.entry_new () in
        Archive.print_pointer readentry;
        ignore (Archive.read_support_filter_all readhandle);
        ignore (Archive.read_support_format_all readhandle);
        ignore (Archive.read_support_format_raw readhandle);
        Printf.printf "l: %d bytes\n" l;
        ignore (Archive.read_open_memory readhandle content l);
        (* Printf.printf "errno %d\n" (Archive.errno handle); *)
        (* Printf.printf "error %s\n" (Archive.error_string handle); *)
        ignore (Archive.read_next_header readhandle readentry);
        Archive.print_pointer readentry;
        print_endline (Archive.entry_pathname readentry);
        (* let read = Archive.read_data readhandle buff uncompsize in *)
        let uncompressed = Archive.read_whole_data readhandle in
        let read = String.length uncompressed in
        Printf.printf "read %d, uncompressed %s" read uncompressed;
        buff := uncompressed;
        (* Printf.printf "read %d, buff %s\n" read !buff; *)
        (* write stuff *)
        ignore (Archive.write_set_format_raw writehandle);
        ignore (Archive.write_add_filter_gzip writehandle);
        ignore (Archive.write_open_memory writehandle compressed compsize outused);
        Printf.printf "outused %d\n" !outused;
        Archive.print_pointer writeentry;
        Archive.entry_set_filetype writeentry Unix.S_DIR;
        ignore (Archive.write_header writehandle writeentry);
        Archive.print_pointer writeentry;
        ignore (Archive.write_data writehandle !buff read);
        ignore (Archive.write_close writehandle);
        Printf.printf "compressed:\n";
        Printf.eprintf "%s" !compressed
