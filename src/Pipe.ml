let construct str =
  ErrorMonad.Success(str)

let decompress str =
  let handle = Archive.read_new_configured
      [Archive.AllFormatReader; Archive.RawFormatReader]
      [Archive.AllFilterReader] in
  let populated = Archive.feed_data handle str in
  Archive.extract_all populated

(*
 * construct "raw" |> decompress |> compress |> writeout
 *)

(* Maybe use >>= directly? *)
let (|>) = ErrorMonad.bind
