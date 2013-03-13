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

type read_filter = AllFilterReader
type read_format = AllFormatReader | RawFormatReader

type write_filter =
        | Base64FilterWriter
        | BZip2FilterWriter
        | CompressFilterWriter
        | GRZipFilterWriter
        | GZipFilterWriter
        | LRZipFilterWriter
        | LZipFilterWriter
        | LZMAFilterWriter
        | LZOPFilterWriter
        | NoneFilterWriter
        | UUEncodeFilterWriter
        | XZFilterWriter
type write_format =
        | SevenZipFormatWriter
        | ARBSDFormatWriter
        | ARSVR4FormatWriter
        | CPIOFormatWriter
        | CPIONEWCFormatWriter
        | GnuTARFormatWriter
        | ISO9660FormatWriter
        | MtreeFormatWriter
        | PAXFormatWriter
        | RawFormatWriter
        | SharFormatWriter
        | USTARFormatWriter
        | V7TARFormatWriter
        | XARFormatWriter
        | ZipFormatWriter

external version_number: unit -> int = "ost_version_number"
external version_string: unit -> string = "ost_version_string"

external errno: archive -> int = "ost_errno"
external error_string: archive -> string = "ost_error_string"

external read_new: unit -> archive = "ost_read_new"
external read_support_filter_all: archive -> status = "ost_read_support_filter_all"
external read_support_format_all: archive -> status = "ost_read_support_format_all"
external read_support_format_raw: archive -> status = "ost_read_support_format_raw"
external read_open_memory: archive -> string -> int -> status = "ost_read_open_memory"
external read_next_header: archive -> entry -> status = "ost_read_next_header"
external read_data: archive -> string ref -> int -> int = "ost_read_data"
external read_data_block: archive -> string ref -> int ref -> int ref -> int = "ost_read_data_block"

external entry_new: unit -> entry = "ost_entry_new"
external entry_set_filetype: entry -> Unix.file_kind -> unit = "ost_entry_set_filetype"
external entry_set_pathname: entry -> Unix.file_kind -> unit = "ost_entry_set_pathname"
external entry_set_size: entry -> int -> unit = "ost_entry_set_size"
external entry_set_mtime: entry -> float -> unit = "ost_entry_set_mtime"
external entry_set_atime: entry -> float -> unit = "ost_entry_set_atime"
external entry_set_ctime: entry -> float -> unit = "ost_entry_set_ctime"
external entry_set_birthtime: entry -> float -> unit = "ost_entry_set_birthtime"
external entry_set_uid: entry -> int = "ost_entry_set_uid"
external entry_set_gid: entry -> int = "ost_entry_set_gid"
external entry_set_uname: entry -> int = "ost_entry_set_uname"
external entry_set_gname: entry -> int = "ost_entry_set_gname"
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
external write_open_memory: archive -> write_buffer_ptr -> written_ptr -> status = "ost_write_open_memory"
external write_header: archive -> entry -> status = "ost_write_header"
external write_set_format_7zip: archive -> status = "ost_write_set_format_7zip"
external write_set_format_ar_bsd: archive -> status = "ost_write_set_format_ar_bsd"
external write_set_format_ar_svr4: archive -> status = "ost_write_set_format_ar_svr4"
external write_set_format_cpio: archive -> status = "ost_write_set_format_cpio"
external write_set_format_cpio_newc: archive -> status = "ost_write_set_format_cpio_newc"
external write_set_format_gnutar: archive -> status = "ost_write_set_format_gnutar"
external write_set_format_iso9660: archive -> status = "ost_write_set_format_iso9660"
external write_set_format_mtree: archive -> status = "ost_write_set_format_mtree"
external write_set_format_pax: archive -> status = "ost_write_set_format_pax"
external write_set_format_raw: archive -> status = "ost_write_set_format_raw"
external write_set_format_shar: archive -> status = "ost_write_set_format_shar"
external write_set_format_ustar: archive -> status = "ost_write_set_format_ustar"
external write_set_format_v7tar: archive -> status = "ost_write_set_format_v7tar"
external write_set_format_xar: archive -> status = "ost_write_set_format_xar"
external write_set_format_zip: archive -> status = "ost_write_set_format_zip"
external write_add_filter_b64encode: archive -> status = "ost_write_add_filter_b64encode"
external write_add_filter_bzip2: archive -> status = "ost_write_add_filter_bzip2"
external write_add_filter_compress: archive -> status = "ost_write_add_filter_compress"
external write_add_filter_grzip: archive -> status = "ost_write_add_filter_grzip"
external write_add_filter_gzip: archive -> status = "ost_write_add_filter_gzip"
external write_add_filter_lrzip: archive -> status = "ost_write_add_filter_lrzip"
external write_add_filter_lzip: archive -> status = "ost_write_add_filter_lzip"
external write_add_filter_lzma: archive -> status = "ost_write_add_filter_lzma"
external write_add_filter_lzop: archive -> status = "ost_write_add_filter_lzop"
external write_add_filter_none: archive -> status = "ost_write_add_filter_none"
external write_add_filter_uuencode: archive -> status = "ost_write_add_filter_uuencode"
external write_add_filter_xz: archive -> status = "ost_write_add_filter_xz"
external write_data: archive -> string -> int -> int = "ost_write_data"
external write_close: archive -> status = "ost_write_close"

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
    ignore (write_data archive content length)

let set_metadata entry meta =
    (* entry_set_pathname meta.pathname; *)
    entry_set_filetype entry meta.filetype

let write_file archive file =
    let entry = entry_new () in
    match file with
        | File (content, metadata) ->
                set_metadata entry metadata;
                ignore (write_header archive entry);
                write_entire_data archive content
        | Directory metadata -> ()

let apply_read_filter archive = function
        | AllFilterReader -> read_support_filter_all archive

let apply_read_format archive = function
        | AllFormatReader -> read_support_format_all archive
        | RawFormatReader -> read_support_format_raw archive

let apply_write_filter archive = function
        | Base64FilterWriter -> write_add_filter_b64encode archive
        | BZip2FilterWriter -> write_add_filter_bzip2 archive
        | CompressFilterWriter -> write_add_filter_compress archive
        | GRZipFilterWriter -> write_add_filter_grzip archive
        | GZipFilterWriter -> write_add_filter_gzip archive
        | LRZipFilterWriter -> write_add_filter_lrzip archive
        | LZipFilterWriter -> write_add_filter_lzip archive
        | LZMAFilterWriter -> write_add_filter_lzma archive
        | LZOPFilterWriter -> write_add_filter_lzop archive
        | NoneFilterWriter -> write_add_filter_none archive
        | UUEncodeFilterWriter -> write_add_filter_uuencode archive
        | XZFilterWriter -> write_add_filter_xz archive

let apply_write_format archive = function
        | SevenZipFormatWriter -> write_set_format_7zip archive
        | ARBSDFormatWriter -> write_set_format_ar_bsd archive
        | ARSVR4FormatWriter -> write_set_format_ar_svr4 archive
        | CPIOFormatWriter -> write_set_format_cpio archive
        | CPIONEWCFormatWriter -> write_set_format_cpio_newc archive
        | GnuTARFormatWriter -> write_set_format_gnutar archive
        | ISO9660FormatWriter -> write_set_format_iso9660 archive
        | MtreeFormatWriter -> write_set_format_mtree archive
        | PAXFormatWriter -> write_set_format_pax archive
        | RawFormatWriter -> write_set_format_raw archive
        | SharFormatWriter -> write_set_format_shar archive
        | USTARFormatWriter -> write_set_format_ustar archive
        | V7TARFormatWriter -> write_set_format_v7tar archive
        | XARFormatWriter -> write_set_format_xar archive
        | ZipFormatWriter -> write_set_format_zip archive

let read_new_configured formats filters =
        let handle = read_new () in
        let format_status = List.map (apply_read_format handle) formats in
        let filter_status = List.map (apply_read_filter handle) filters in
        (* TODO: check return codes for != Ok *)
        ignore format_status;
        ignore filter_status;
        (* TODO: return configured_read_archive type *)
        handle

let write_new_configured format filters =
        let handle = write_new () in
        let format_status = apply_write_format handle format in
        let filter_status = List.map (apply_write_filter handle) filters in
        (* TODO: check return codes for != Ok *)
        ignore format_status;
        ignore filter_status;
        (* TODO: return configured_write_archive type *)
        handle
