(*
 * Pipe - Operators and functions to deal with chaining OStreamer operations
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

let construct str =
  ErrorMonad.Success(str)

let decompress str =
  let handle = Archive.read_new_configured
      [Archive.AllFormatReader; Archive.RawFormatReader]
      [Archive.AllFilterReader] in
  let populated = Archive.feed_data handle str in
  Archive.extract_all populated

let compress fmt filters entries =
  let handle = Archive.write_new_configured fmt filters in
  let opened = Archive.write_open_memory handle in
  let written = List.fold_left (fun h e -> Archive.write_entry h e) opened entries in
  Archive.write_close written

(*
 * construct "raw" |> decompress |> compress |> writeout
 *)

(* Maybe use >>= directly? *)
let (|>) = ErrorMonad.bind
