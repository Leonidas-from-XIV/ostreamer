type archive
type entry
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
external read_support_filter_all: archive -> int = "ost_read_support_filter_all"
external read_support_format_all: archive -> int = "ost_read_support_format_all"
external read_support_format_raw: archive -> int = "ost_read_support_format_raw"
external read_open_memory: archive -> string -> int -> int = "ost_read_open_memory"
external entry_new: unit -> entry = "ost_entry_new"
external read_next_header: archive -> entry -> int = "ost_read_next_header"
external read_data: archive -> string -> int -> int = "ost_read_data"
external entry_pathname: entry -> string = "ost_entry_pathname"
external read_data_block: archive -> string ref -> int ref -> int ref -> int = "ost_read_data_block"
external errno: archive -> int = "ost_errno"
external error_string: archive -> string = "ost_error_string"
external write_set_format_raw: archive -> int = "ost_write_set_format_raw"
external write_add_filter_gzip: archive -> int = "ost_write_add_filter_gzip"

external print_pointer: entry -> unit = "ost_print_pointer"
