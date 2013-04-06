type archive
type 'a r = archive ErrorMonad.t
type write_buffer_ptr
type written_ptr
type 'a w = (archive * write_buffer_ptr * written_ptr) ErrorMonad.t
type entry
type entry_metadata =
  {
    pathname: string;
    filetype: Unix.file_kind;
    atime: float option;
    birthtime: float option;
    ctime: float option;
    mtime: float option;
    gid: int64;
    gname: string option;
    size: int64 option;
    uid: int64;
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

type read_filter =
  | AllFilterReader
  | BZip2FilterReader
  | CompressFilterReader
  | GRZipFilterReader
  | GZipFilterReader
  | LRZipFilterReader
  | LZipFilterReader
  | LZMAFilterReader
  | LZOPFilterReader
  | NoneFilterReader
  | RPMFilterReader
  | UUFilterReader
  | XZFilterReader
type read_format =
  | SevenZipFormatReader
  | AllFormatReader
  | ARFormatReader
  | CABFormatReader
  | CPIOFormatReader
  | GnuTARFormatReader
  | ISO9660FormatReader
  | LHAFormatReader
  | MtreeFormatReader
  | RARFormatReader
  | RawFormatReader
  | TARFormatReader
  | XARFormatReader
  | ZipFormatReader

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
  | UUFilterWriter
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
external read_support_filter_bzip2: archive -> status = "ost_read_support_filter_bzip2"
external read_support_filter_compress: archive -> status = "ost_read_support_filter_compress"
external read_support_filter_grzip: archive -> status = "ost_read_support_filter_grzip"
external read_support_filter_gzip: archive -> status = "ost_read_support_filter_gzip"
external read_support_filter_lrzip: archive -> status = "ost_read_support_filter_lrzip"
external read_support_filter_lzip: archive -> status = "ost_read_support_filter_lzip"
external read_support_filter_lzma: archive -> status = "ost_read_support_filter_lzma"
external read_support_filter_lzop: archive -> status = "ost_read_support_filter_lzop"
external read_support_filter_none: archive -> status = "ost_read_support_filter_none"
external read_support_filter_rpm: archive -> status = "ost_read_support_filter_rpm"
external read_support_filter_uu: archive -> status = "ost_read_support_filter_uu"
external read_support_filter_xz: archive -> status = "ost_read_support_filter_xz"
external read_support_format_7zip: archive -> status = "ost_read_support_format_7zip"
external read_support_format_all: archive -> status = "ost_read_support_format_all"
external read_support_format_ar: archive -> status = "ost_read_support_format_ar"
external read_support_format_cab: archive -> status = "ost_read_support_format_cab"
external read_support_format_cpio: archive -> status = "ost_read_support_format_cpio"
external read_support_format_gnutar: archive -> status = "ost_read_support_format_gnutar"
external read_support_format_iso9660: archive -> status = "ost_read_support_format_iso9660"
external read_support_format_lha: archive -> status = "ost_read_support_format_lha"
external read_support_format_mtree: archive -> status = "ost_read_support_format_mtree"
external read_support_format_rar: archive -> status = "ost_read_support_format_rar"
external read_support_format_raw: archive -> status = "ost_read_support_format_raw"
external read_support_format_tar: archive -> status = "ost_read_support_format_tar"
external read_support_format_xar: archive -> status = "ost_read_support_format_xar"
external read_support_format_zip: archive -> status = "ost_read_support_format_zip"
external read_open_memory: archive -> string -> int -> status = "ost_read_open_memory"
external read_next_header: archive -> entry -> status = "ost_read_next_header"
(* TODO: determine whether to use int or int64 *)
external read_data: archive -> string ref -> int -> int = "ost_read_data"
(* TODO: remove binding *)
external read_data_block: archive -> string ref -> int ref -> int ref -> int = "ost_read_data_block"

external entry_new: unit -> entry = "ost_entry_new"
external entry_new_shared: unit -> entry = "ost_entry_new_shared"
external entry_set_filetype: entry -> Unix.file_kind -> unit = "ost_entry_set_filetype"
external entry_set_pathname: entry -> string -> unit = "ost_entry_set_pathname"
external entry_set_size: entry -> int64 -> unit = "ost_entry_set_size"
external entry_set_mtime: entry -> float -> unit = "ost_entry_set_mtime"
external entry_set_atime: entry -> float -> unit = "ost_entry_set_atime"
external entry_set_ctime: entry -> float -> unit = "ost_entry_set_ctime"
external entry_set_birthtime: entry -> float -> unit = "ost_entry_set_birthtime"
external entry_set_uid: entry -> int64 -> unit = "ost_entry_set_uid"
external entry_set_gid: entry -> int64 -> unit = "ost_entry_set_gid"
external entry_set_uname: entry -> string -> unit = "ost_entry_set_uname"
external entry_set_gname: entry -> string -> unit = "ost_entry_set_gname"
external entry_pathname: entry -> string = "ost_entry_pathname"
external entry_size: entry -> int64 option = "ost_entry_size"
external entry_mtime: entry -> float option = "ost_entry_mtime"
external entry_atime: entry -> float option = "ost_entry_atime"
external entry_ctime: entry -> float option = "ost_entry_ctime"
external entry_birthtime: entry -> float option = "ost_entry_birthtime"
external entry_uid: entry -> int64 = "ost_entry_uid"
external entry_gid: entry -> int64 = "ost_entry_gid"
external entry_uname: entry -> string option = "ost_entry_uname"
external entry_gname: entry -> string option = "ost_entry_gname"
external entry_filetype: entry -> Unix.file_kind = "ost_entry_filetype"

external write_new: unit -> archive = "ost_write_new"
external write_open_memory_c: archive -> write_buffer_ptr -> written_ptr -> status = "ost_write_open_memory"
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
external write_close_c: archive -> status = "ost_write_close"

external print_pointer: entry -> unit = "ost_print_pointer"

external written_ptr_new: unit -> written_ptr = "ost_written_ptr_new"
external written_ptr_free: written_ptr -> unit = "ost_written_ptr_free"
external written_ptr_read: written_ptr -> int = "ost_written_ptr_read"

external write_buffer_new: unit -> write_buffer_ptr = "ost_write_buffer_new"
external write_buffer_read: write_buffer_ptr -> written_ptr -> string = "ost_write_buffer_read"
external write_buffer_free: write_buffer_ptr -> unit = "ost_write_buffer_free"

(* TODO: add remaining arguments *)
let generate_metadata ?(filetype=Unix.S_REG) pathname =
{
  pathname = pathname;
  filetype = filetype;
  atime = None;
  birthtime = None;
  ctime = None;
  mtime = None;
  gid = Int64.one;
  gname = None;
  size = None;
  uid = Int64.one;
  uname = None;
}

let write_close writehandle =
  ErrorMonad.bind writehandle (fun (archive, buff, written) ->
    let retval = write_close_c archive in
    match retval with
    | Ok -> let content = write_buffer_read buff written in
    (* Gc.full_major (); *)
      ErrorMonad.Success(content)
    | _ -> let errcode = errno archive in
      let errstr = error_string archive in
      ErrorMonad.Failure(errcode, errstr))

let write_open_memory writehandle =
  ErrorMonad.bind writehandle (fun (archive, buff, written) ->
    let retval = write_open_memory_c archive buff written in
    match retval with
    | Ok -> ErrorMonad.Success (archive, buff, written)
    | _ -> let errcode = errno archive in
      let errstr = error_string archive in
      ErrorMonad.Failure(errcode, errstr))

let archive_status_error_wrapper fn archive =
  let retval = fn archive in
  match retval with
  | Ok -> ErrorMonad.Success(archive)
  | _ -> let errcode = errno archive in
    let errstr = error_string archive in
    ErrorMonad.Failure(errcode, errstr)

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

let feed_data handlemonad data =
  ErrorMonad.bind handlemonad (fun handle ->
    let len = String.length data in
    let retval = read_open_memory handle data len in
    match retval with
    | Ok -> ErrorMonad.Success(handle)
    | _ -> let errcode = errno handle in
      let errstr = error_string handle in
      ErrorMonad.Failure(errcode, errstr))

let extract_all = function
  | ErrorMonad.Success (archive) -> (let entry = entry_new_shared () in
          (*
           * go through the whole archive until you reach Eof and convert raw data
           * into structured OCaml types
           *)
      let rec read_all () : ost_entry list ErrorMonad.t =
        let err = read_next_header archive entry in
        match err with
        | Ok -> let metadata = read_meta_data entry in
          (match metadata.filetype with
           | Unix.S_REG -> let content = read_entire_data archive in
             let head = File (content, metadata) in
             let tail = read_all () in
             (match tail with
              | ErrorMonad.Success (cont) ->
                ErrorMonad.Success (head::cont)
              | err -> err)
           | Unix.S_DIR -> let head = Directory metadata in
             let tail = read_all () in
             (match tail with
              | ErrorMonad.Success (cont) ->
                ErrorMonad.Success (head::cont)
              | err -> err)
           | _ -> (read_all ()))
        | Eof -> ErrorMonad.Success ([])
        | _ -> let errcode = errno archive in
          let errstr = error_string archive in
          ErrorMonad.Failure(errcode, errstr) in
      read_all ())
  | ErrorMonad.Failure (code, str) -> ErrorMonad.Failure(code, str)


let write_entire_data archive content =
  let length = String.length content in
  let written = write_data archive content length in
  if length = written then
    ErrorMonad.Success (archive)
  else
    ErrorMonad.Failure (0, "Data written does not match")

(* inspired by Batteries' Option module, function may *)
let may f = function
  | Some content -> f content
  | None -> ()

(* sets all the fields that were passed in the metadata to the fields in the
 * entry. unset option types are ignored
*)
let set_metadata entry meta =
  entry_set_pathname entry meta.pathname;
  entry_set_filetype entry meta.filetype;
  may (entry_set_size entry) meta.size;
  may (entry_set_mtime entry) meta.mtime;
  may (entry_set_atime entry) meta.atime;
  may (entry_set_ctime entry) meta.ctime;
  may (entry_set_birthtime entry) meta.birthtime;
  entry_set_uid entry meta.uid;
  entry_set_gid entry meta.gid;
  may (entry_set_uname entry) meta.uname;
  may (entry_set_gname entry) meta.gname

let write_header_wrapper archive entry =
  let retval = write_header archive entry in
  match retval with
  | Ok -> ErrorMonad.Success (archive)
  | _ -> let errcode = errno archive in
    let errstr = error_string archive in
    ErrorMonad.Failure (errcode, errstr)

let write_entry handle file = match handle with
  | ErrorMonad.Success (archive, buff, written) -> let entry = entry_new () in
    (match file with
     | File (content, metadata) ->
       set_metadata entry metadata;
       let header_written = write_header_wrapper archive entry in
       let data_written = ErrorMonad.bind header_written (fun arc -> write_entire_data arc content) in
       (match data_written with
        | ErrorMonad.Success (arc) -> ErrorMonad.Success(arc, buff, written)
        | ErrorMonad.Failure (code, str) -> ErrorMonad.Failure(code, str))
     | Directory metadata -> ErrorMonad.Failure (0, "Directory failed"))
  | ErrorMonad.Failure (code, str) -> ErrorMonad.Failure(code, str)

let apply_read_filter fmt archive = match fmt with
  | AllFilterReader -> archive_status_error_wrapper read_support_filter_all archive
  | BZip2FilterReader -> archive_status_error_wrapper read_support_filter_bzip2 archive
  | CompressFilterReader -> archive_status_error_wrapper read_support_filter_compress archive
  | GRZipFilterReader -> archive_status_error_wrapper read_support_filter_grzip archive
  | GZipFilterReader -> archive_status_error_wrapper read_support_filter_gzip archive
  | LRZipFilterReader -> archive_status_error_wrapper read_support_filter_lrzip archive
  | LZipFilterReader -> archive_status_error_wrapper read_support_filter_lzip archive
  | LZMAFilterReader -> archive_status_error_wrapper read_support_filter_lzma archive
  | LZOPFilterReader -> archive_status_error_wrapper read_support_filter_lzop archive
  | NoneFilterReader -> archive_status_error_wrapper read_support_filter_none archive
  | RPMFilterReader -> archive_status_error_wrapper read_support_filter_rpm archive
  | UUFilterReader -> archive_status_error_wrapper read_support_filter_uu archive
  | XZFilterReader -> archive_status_error_wrapper read_support_filter_xz archive

let apply_read_format (fmt : read_format) (archive : archive) : archive ErrorMonad.t = match fmt with
  | SevenZipFormatReader -> archive_status_error_wrapper read_support_format_7zip archive
  | AllFormatReader -> archive_status_error_wrapper read_support_format_all archive
  | ARFormatReader -> archive_status_error_wrapper read_support_format_ar archive
  | CABFormatReader -> archive_status_error_wrapper read_support_format_cab archive
  | CPIOFormatReader -> archive_status_error_wrapper read_support_format_cpio archive
  | GnuTARFormatReader -> archive_status_error_wrapper read_support_format_gnutar archive
  | ISO9660FormatReader -> archive_status_error_wrapper read_support_format_iso9660 archive
  | LHAFormatReader -> archive_status_error_wrapper read_support_format_lha archive
  | MtreeFormatReader -> archive_status_error_wrapper read_support_format_mtree archive
  | RARFormatReader -> archive_status_error_wrapper read_support_format_rar archive
  | RawFormatReader -> archive_status_error_wrapper read_support_format_raw archive
  | TARFormatReader -> archive_status_error_wrapper read_support_format_tar archive
  | XARFormatReader -> archive_status_error_wrapper read_support_format_xar archive
  | ZipFormatReader -> archive_status_error_wrapper read_support_format_zip archive

let apply_write_filter fmt archive = match fmt with
  | Base64FilterWriter -> archive_status_error_wrapper write_add_filter_b64encode archive
  | BZip2FilterWriter -> archive_status_error_wrapper write_add_filter_bzip2 archive
  | CompressFilterWriter -> archive_status_error_wrapper write_add_filter_compress archive
  | GRZipFilterWriter -> archive_status_error_wrapper write_add_filter_grzip archive
  | GZipFilterWriter -> archive_status_error_wrapper write_add_filter_gzip archive
  | LRZipFilterWriter -> archive_status_error_wrapper write_add_filter_lrzip archive
  | LZipFilterWriter -> archive_status_error_wrapper write_add_filter_lzip archive
  | LZMAFilterWriter -> archive_status_error_wrapper write_add_filter_lzma archive
  | LZOPFilterWriter -> archive_status_error_wrapper write_add_filter_lzop archive
  | NoneFilterWriter -> archive_status_error_wrapper write_add_filter_none archive
  | UUFilterWriter -> archive_status_error_wrapper write_add_filter_uuencode archive
  | XZFilterWriter -> archive_status_error_wrapper write_add_filter_xz archive

let apply_write_format fmt archive = match fmt with
  | SevenZipFormatWriter -> archive_status_error_wrapper write_set_format_7zip archive
  | ARBSDFormatWriter -> archive_status_error_wrapper write_set_format_ar_bsd archive
  | ARSVR4FormatWriter -> archive_status_error_wrapper write_set_format_ar_svr4 archive
  | CPIOFormatWriter -> archive_status_error_wrapper write_set_format_cpio archive
  | CPIONEWCFormatWriter -> archive_status_error_wrapper write_set_format_cpio_newc archive
  | GnuTARFormatWriter -> archive_status_error_wrapper write_set_format_gnutar archive
  | ISO9660FormatWriter -> archive_status_error_wrapper write_set_format_iso9660 archive
  | MtreeFormatWriter -> archive_status_error_wrapper write_set_format_mtree archive
  | PAXFormatWriter -> archive_status_error_wrapper write_set_format_pax archive
  | RawFormatWriter -> archive_status_error_wrapper write_set_format_raw archive
  | SharFormatWriter -> archive_status_error_wrapper write_set_format_shar archive
  | USTARFormatWriter -> archive_status_error_wrapper write_set_format_ustar archive
  | V7TARFormatWriter -> archive_status_error_wrapper write_set_format_v7tar archive
  | XARFormatWriter -> archive_status_error_wrapper write_set_format_xar archive
  | ZipFormatWriter -> archive_status_error_wrapper write_set_format_zip archive

let read_new_configured formats filters =
  let handle = read_new () in
  let formatted_handle : archive ErrorMonad.t =
    let folder (m: archive ErrorMonad.t) (fmt: read_format) : archive ErrorMonad.t =
      ErrorMonad.bind m (apply_read_format fmt) in
    List.fold_left folder (ErrorMonad.Success handle) formats in
  let filtered_handle =
    let folder m flt = ErrorMonad.bind m (apply_read_filter flt) in
    List.fold_left folder formatted_handle filters in
  filtered_handle

let write_new_configured format filters =
  let handle = write_new () in
  (* Gc.full_major (); *)
  let buffer = write_buffer_new () in
  let written = written_ptr_new () in
  let formatted_handle = apply_write_format format handle in
  let filtered_handle =
    let folder m flt = ErrorMonad.bind m (apply_write_filter flt) in
    List.fold_left folder formatted_handle filters in
  match filtered_handle with
  | ErrorMonad.Success (archive) -> ErrorMonad.Success (archive, buffer, written)
  | ErrorMonad.Failure (code,str) -> ErrorMonad.Failure (code, str)
