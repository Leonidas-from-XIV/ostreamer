(*
 * Archive - low and medium level wrappers for libarchive
 * Copyright (C) 2013 Marek Kubica <marek@xivilization.net>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version,
 * with the special exception on linking described in file COPYING.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 *)

type 'a r
type 'a w
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
