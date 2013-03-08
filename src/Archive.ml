type archive
type entry
type write_buffer_ptr
type written_ptr
type entry_metadata =
    {
        pathname: string;
        filetype: Unix.file_kind;
        atime: float option;
        birthtime: float option;
        ctime: float option;
        mtime: float option;
        gid: int;
        gname: string option;
        size: int option;
        uid: int;
        uname: string option;
    }

type ost_entry = File of string * entry_metadata | Directory of entry_metadata

type status =
    | Ok
    | Eof
    | Retry
    | Warn
    | Failed
    | Fatal

external version_number: unit -> int = "ost_version_number"
external version_string: unit -> string = "ost_version_string"

external errno: archive -> int = "ost_errno"
external error_string: archive -> string = "ost_error_string"

external read_new: unit -> archive = "ost_read_new"
external read_support_filter_all: archive -> int = "ost_read_support_filter_all"
external read_support_format_all: archive -> int = "ost_read_support_format_all"
external read_support_format_raw: archive -> int = "ost_read_support_format_raw"
external read_open_memory: archive -> string -> int -> int = "ost_read_open_memory"
external read_next_header: archive -> entry -> status = "ost_read_next_header"
external read_data: archive -> string ref -> int -> int = "ost_read_data"
external read_data_block: archive -> string ref -> int ref -> int ref -> int = "ost_read_data_block"

external entry_new: unit -> entry = "ost_entry_new"
external entry_set_filetype: entry -> Unix.file_kind -> unit = "ost_entry_set_filetype"
external entry_pathname: entry -> string = "ost_entry_pathname"
external entry_size: entry -> int option = "ost_entry_size"
external entry_mtime: entry -> float option = "ost_entry_mtime"
external entry_atime: entry -> float option = "ost_entry_atime"
external entry_ctime: entry -> float option = "ost_entry_ctime"
external entry_birthtime: entry -> float option = "ost_entry_birthtime"
external entry_uid: entry -> int = "ost_entry_uid"
external entry_gid: entry -> int = "ost_entry_gid"
external entry_uname: entry -> string option = "ost_entry_uname"
external entry_gname: entry -> string option = "ost_entry_gname"
external entry_filetype: entry -> Unix.file_kind = "ost_entry_filetype"

external write_new: unit -> archive = "ost_write_new"
external write_open_memory: archive -> write_buffer_ptr -> written_ptr -> int = "ost_write_open_memory"
external write_header: archive -> entry -> int ="ost_write_header"
external write_set_format_raw: archive -> int = "ost_write_set_format_raw"
external write_add_filter_gzip: archive -> int = "ost_write_add_filter_gzip"
external write_data: archive -> string -> int -> int = "ost_write_data"
external write_close: archive -> int = "ost_write_close"

external print_pointer: entry -> unit = "ost_print_pointer"

external written_ptr_new: unit -> written_ptr = "ost_written_ptr_new"
external written_ptr_free: written_ptr -> unit = "ost_written_ptr_free"
external written_ptr_read: written_ptr -> int = "ost_written_ptr_read"

external write_buffer_new: unit -> write_buffer_ptr = "ost_write_buffer_new"
external write_buffer_read: write_buffer_ptr -> written_ptr -> string = "ost_write_buffer_read"
external write_buffer_free: write_buffer_ptr -> unit = "ost_write_buffer_free"


let read_entire_data archive =
        let c_buffer_size = 1024 in
        let c_buffer = ref (String.create c_buffer_size) in
        let buffer = Buffer.create 16 in
        let read = ref (read_data archive c_buffer c_buffer_size) in
        while !read = c_buffer_size do
                Buffer.add_string buffer !c_buffer;
                read := read_data archive c_buffer c_buffer_size
        done;
        (* Only add as many bytes to the buffer as were read *)
        Buffer.add_string buffer (String.sub !c_buffer 0 !read);
        Buffer.contents buffer

let read_meta_data entry =
        {
            pathname = entry_pathname entry;
            filetype = entry_filetype entry;
            size = entry_size entry;
            mtime = entry_mtime entry;
            atime = entry_atime entry;
            ctime = entry_ctime entry;
            birthtime = entry_birthtime entry;
            uid = entry_uid entry;
            gid = entry_gid entry;
            gname = entry_gname entry;
            uname = entry_uname entry;
        }


let extract_all archive =
    let entry = entry_new () in
    (*
     * go through the whole archive until you reach Eof and convert raw data
     * into structured OCaml types
     *)
    let rec read_all () =
        let err = read_next_header archive entry in
        match err with
            | Ok -> let metadata = read_meta_data entry in
                    (match metadata.filetype with
                            | Unix.S_REG -> let content = read_entire_data archive in
                                    (File (content, metadata))::(read_all ())
                            | Unix.S_DIR -> (Directory metadata)::(read_all ())
                            | _ -> (read_all ()))
            | Eof -> []
            | _ -> [] in
    read_all ()

(* internal *)
(*
let rec chunks str size = match String.length str with
        | n when n <= size -> [str]
        | n -> (String.sub str 0 size)::(chunks (String.sub str size (n-size)) size)
*)

let write_entire_data archive content =
    let length = String.length content in
    write_data archive content length
