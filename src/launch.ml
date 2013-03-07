open Batteries_uni

(* helper for reduce *)
let bang_fold acc = function
    | "!" -> []::acc
    | e -> (List.append (List.hd acc) [e])::(List.tl acc)

(* splits a list of [a b ! c] into [[a b] [c] *)
let bang_split pipe = List.rev (List.fold_left bang_fold [[]] pipe)

(* debugging only *)
let print_pipe pipe = List.print (fun out element -> IO.nwrite out element) stdout pipe

let parse_commandline argv =
    let largv = Array.to_list argv in
    let args = List.tl largv in
    bang_split args

let regfilep = function
        | Unix.S_REG -> "Regular file"
        | _ -> "Something nonregular"

let _ =
    print_endline (Printf.sprintf "ost-launch %d" (Archive.version_number ()));
    print_endline (Archive.version_string ());
    let commands = parse_commandline Sys.argv in
    let input_file = List.nth (List.nth commands 0) 0 in
    let output_file = List.nth (List.nth commands 1) 0 in
    let f_in = File.open_in input_file in
    let content = IO.read_all f_in in
    let l = String.length content in
    let readhandle = Archive.read_new () in
    let readentry = Archive.entry_new () in
    let writehandle = Archive.write_new () in
    let compressed = Archive.write_buffer_new () in
    let written = Archive.written_ptr_new () in
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
        let metadata = (Archive.read_meta_data readentry) in
        Printf.printf "File name: %s\n" metadata.Archive.filename;
        print_endline (regfilep metadata.Archive.filetype);
        Option.print (fun out e -> IO.nwrite out (string_of_int e)) stdout metadata.Archive.size;
        print_newline ();
        Option.print (fun out e -> IO.nwrite out (string_of_float e)) stdout metadata.Archive.mtime;
        print_newline ();
        Option.print (fun out e -> IO.nwrite out (string_of_float e)) stdout metadata.Archive.atime;
        print_newline ();
        Option.print (fun out e -> IO.nwrite out (string_of_float e)) stdout metadata.Archive.ctime;
        print_newline ();
        Option.print (fun out e -> IO.nwrite out (string_of_float e)) stdout metadata.Archive.birthtime;
        print_newline ();
        Printf.printf "File uid: %d\n" metadata.Archive.uid;
        Printf.printf "File gid: %d\n" metadata.Archive.gid;
        Option.print (fun out e -> IO.nwrite out e) stdout metadata.Archive.uname;
        print_newline ();
        Option.print (fun out e -> IO.nwrite out e) stdout metadata.Archive.gname;
        print_newline ();
        let uncompressed = Archive.read_entire_data readhandle in
        let read = String.length uncompressed in
        Printf.printf "read %d, uncompressed %s" read uncompressed;
        (* write stuff *)
        ignore (Archive.write_set_format_raw writehandle);
        ignore (Archive.write_add_filter_gzip writehandle);
        Printf.printf "outused %d\n" (Archive.written_ptr_read written);
        ignore (Archive.write_open_memory writehandle compressed written);
        Archive.print_pointer writeentry;
        Archive.entry_set_filetype writeentry Unix.S_DIR;
        ignore (Archive.write_header writehandle writeentry);
        Archive.print_pointer writeentry;
        ignore (Archive.write_data writehandle uncompressed read);
        Printf.printf "outused %d\n" (Archive.written_ptr_read written);
        ignore (Archive.write_close writehandle);
        Printf.printf "outused %d\n" (Archive.written_ptr_read written);
        File.with_file_out output_file (fun f_out ->
            IO.nwrite f_out (Archive.write_buffer_read compressed written))
