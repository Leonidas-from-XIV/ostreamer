type 'a r
type 'a w
type read_format = AllFormatReader | RawFormatReader
type read_filter = AllFilterReader
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
val version_string: unit -> string
val version_number: unit -> int
val generate_metadata: ?filetype:Unix.file_kind -> string -> entry_metadata
val read_new_configured: read_format list -> read_filter list -> [`Empty] r
val feed_data: [`Empty] r -> string -> [`Populated] r
val extract_all: [`Populated] r -> ost_entry list ErrorMonad.t
val write_new_configured: write_format -> write_filter list -> [`Closed] w
val write_open_memory: [`Closed] w -> [`Open] w
val write_entry: [`Open] w -> ost_entry -> [`Open] w
val write_close: [`Open] w -> string ErrorMonad.t
