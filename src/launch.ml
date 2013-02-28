open Batteries_uni

let _ =
    print_endline (Printf.sprintf "ost-launch %d" (Archive.version_number ()));
    print_endline (Archive.version_string ());
    let f_in = File.open_in "test.gz" in
    let content = IO.read_all f_in in
    let l = String.length content in
    let readhandle = Archive.read_new () in
    let readentry = Archive.entry_new () in
    let writehandle = Archive.write_new () in
    let compsize = 100 in
    let compressed = ref (String.create compsize) in
    let outused = Archive.out_used_new () in
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
        let uncompressed = Archive.read_entire_data readhandle in
        let read = String.length uncompressed in
        Printf.printf "read %d, uncompressed %s" read uncompressed;
        (* write stuff *)
        ignore (Archive.write_set_format_raw writehandle);
        ignore (Archive.write_add_filter_gzip writehandle);
        Printf.printf "outused %d\n" (Archive.out_used_read outused);
        ignore (Archive.write_open_memory writehandle compressed compsize outused);
        Archive.print_pointer writeentry;
        Archive.entry_set_filetype writeentry Unix.S_DIR;
        ignore (Archive.write_header writehandle writeentry);
        Archive.print_pointer writeentry;
        ignore (Archive.write_data writehandle uncompressed read);
        Printf.printf "outused %d\n" (Archive.out_used_read outused);
        ignore (Archive.write_close writehandle);
        Printf.printf "outused %d\n" (Archive.out_used_read outused);
        Printf.printf "compressed:\n";
        Printf.eprintf "%s" (String.sub !compressed 0 (Archive.out_used_read outused))
