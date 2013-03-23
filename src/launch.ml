open Batteries
(* TODO: eliminate this prefix *)
open Archive

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

let filep = function
        | Archive.File (content, metadata) -> "file"
        | Archive.Directory metadata -> "directory"

let is_file = function
        | Archive.File (_, _) -> true
        | _ -> false

let print_metadata metadata =
        Printf.printf "File name: %s\n" metadata.Archive.pathname;
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
        print_newline ()

let _ =
    print_endline (Printf.sprintf "ost-launch %d" (Archive.version_number ()));
    print_endline (Archive.version_string ());
    let commands = parse_commandline Sys.argv in
    let input_file = List.nth (List.nth commands 0) 0 in
    let output_file = List.nth (List.nth commands 1) 0 in
    let f_in = File.open_in input_file in
    let content = IO.read_all f_in in
    let l = String.length content in
    let readhandle = Archive.read_new_configured
        [Archive.AllFormatReader; Archive.RawFormatReader]
        [Archive.AllFilterReader] in
    let writehandle = Archive.write_new_configured Archive.RawFormatWriter
        [Archive.GZipFilterWriter] in
    let compressed = Archive.write_buffer_new () in
    let written = Archive.written_ptr_new () in
        Printf.printf "l: %d bytes\n" l;
        Archive.feed_data readhandle content;
        let archive_contents = Archive.extract_all readhandle in
        List.print (fun out e -> IO.nwrite out (filep e)) stdout archive_contents;
        print_newline ();
        let files = List.filter is_file archive_contents in
        let regular = List.hd files in
        (* Printf.printf "errno %d\n" (Archive.errno handle); *)
        (* Printf.printf "error %s\n" (Archive.error_string handle); *)
        match regular with
                | Archive.File (uncompressed, metadata) -> (
                        print_metadata metadata;
                        Printf.printf "uncompressed %s" uncompressed;
                        (* write stuff *)
                        Printf.printf "outused %d\n" (Archive.written_ptr_read written);
                        ignore (Archive.write_open_memory writehandle compressed written);
                        Archive.write_file writehandle (Archive.File (uncompressed, metadata));
                        Printf.printf "outused %d\n" (Archive.written_ptr_read written);
                        ignore (Archive.write_close writehandle);
                        Printf.printf "outused %d\n" (Archive.written_ptr_read written);
                        File.with_file_out output_file (fun f_out ->
                            IO.nwrite f_out (Archive.write_buffer_read compressed written)))
                | Archive.Directory metadata -> ()
