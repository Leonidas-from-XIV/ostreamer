type process = Data of string | Archive of handle | Decompress | Decompressed of string list | Compress

let (|>) a b = match (a, b) with
  | (Data (s), Decompress) -> "foo"
  | _ -> "bar"
