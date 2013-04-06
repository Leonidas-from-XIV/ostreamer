open OUnit

let equ = assert_equal

let test_version_getting _ =
  let version = Archive.version_string () in
  let name = String.sub version 0 10 in
  equ name "libarchive"

let raw_gz_file =
  "\x1f\x8b\x08\x00\xcd\x65\x42\x51\x00\x03\x0b\xc9\xc8\x2c\x56\x00\xa2\x44\
   \x85\x92\xd4\xe2\x12\x85\xb4\xcc\x9c\x54\x2e\x8f\xd4\x9c\x9c\x7c\x2e\x00\
   \xd2\xc2\x5e\x1b\x1a\x00\x00\x00"
let raw_file = "This is a test file\nHello\n"

let test_decompress_raw_single_file _ =
  let handle = Archive.read_new_configured
      [Archive.RawFormatReader]
      [Archive.AllFilterReader] in
  let populated = Archive.feed_data handle raw_gz_file in
  let archive_contents = Archive.extract_all populated in
  Gc.full_major ();
  match archive_contents with
  | ErrorMonad.Success (xs) -> let first = List.hd xs in
    (match first with
     | Archive.File (content, meta) -> equ content raw_file
     | _ -> assert_failure "Did not get a single file")
  | ErrorMonad.Failure (code, str) -> assert_failure "Decompression failed"

let test_nocompress_single_file _ =
  let handle = Archive.write_new_configured
      Archive.RawFormatWriter [Archive.NoneFilterWriter] in
  let openhandle = Archive.write_open_memory handle in
  let meta = Archive.generate_metadata "foo" in
  let entry = Archive.File(raw_file, meta) in
  let written = Archive.write_entry openhandle entry in
  let res = Archive.write_close written in
  match res with
  | ErrorMonad.Success (res) -> equ res raw_file
  | ErrorMonad.Failure (code, str) -> assert_failure "Compression failed"

let test_compress_uncompress_single_file _ =
  let handle = Archive.write_new_configured
    Archive.RawFormatWriter [Archive.GZipFilterWriter] in
  let openhandle = Archive.write_open_memory handle in
  let meta = {
    Archive.pathname = "foo";
    filetype = Unix.S_REG;
    atime = None;
    birthtime = None;
    ctime = None;
    mtime = None;
    gid = Int64.one;
    gname = None;
    size = None;
    uid = Int64.one;
    uname = None;
  } in
  let entry = Archive.File(raw_file, meta) in
  let written = Archive.write_entry openhandle entry in
  let res = Archive.write_close written in
  match res with
  | ErrorMonad.Success (res) ->
      let readhandle = Archive.read_new_configured
        [Archive.RawFormatReader] [Archive.AllFilterReader] in
      let populated = Archive.feed_data readhandle res in
      let contents = Archive.extract_all populated in
      (match contents with
      | ErrorMonad.Success (xs) -> let first = List.hd xs in
          (match first with
          | Archive.File (content, meta) -> assert_equal content raw_file
          | _ -> assert_failure "Did not get a file")
      | ErrorMonad.Failure (code, str) -> assert_failure "Decompression failed")
  | ErrorMonad.Failure (code, str) -> assert_failure "Compression failed"

let test_pipe_decompress _ =
  let (|>) = Pipe.(|>) in
  match Pipe.construct raw_gz_file |> Pipe.decompress with
  | ErrorMonad.Success (entries) -> let first = List.hd entries in
    (match first with
    | Archive.File (content, meta) -> assert_equal content raw_file
    | _ -> assert_failure "Did not decompress to a file")
  | ErrorMonad.Failure (code, str) -> assert_failure "Decompression failed"

let suite = "Simple tests" >::: [
  "test_version_getting" >:: test_version_getting;
  "test_decompress_raw_single_file" >:: test_decompress_raw_single_file;
  (* "test_nocompress_single_file" >:: test_nocompress_single_file; *)
  (* "test_compress_uncompress_single_file" >:: test_compress_uncompress_single_file; *)
  (* "test_pipe_decompress" >:: test_pipe_decompress; *)
]

let _ =
  at_exit Gc.full_major;
  run_test_tt_main suite
