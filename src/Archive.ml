type archive
type status =
    | Ok
    | Eof
    | Retry
    | Warn
    | Failed
    | Fatal

external version_number: unit -> int = "ost_version_number"
external version_string: unit -> string = "ost_version_string"
external read_new: unit -> archive = "ost_read_new"
external read_free: archive -> unit = "ost_read_free"
external read_support_filter_all: archive -> int = "ost_read_support_filter_all"
external read_support_format_all: archive -> int = "ost_read_support_format_all"
external read_open_memory: archive -> string -> int -> int = "ost_read_open_memory"
