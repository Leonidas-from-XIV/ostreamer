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

external errno: archive -> int = "ost_errno"
external error_string: archive -> string = "ost_error_string"

external read_new: unit -> archive = "ost_read_new"
external read_support_filter_all: archive -> int = "ost_read_support_filter_all"
external read_support_format_all: archive -> int = "ost_read_support_format_all"
external read_support_format_raw: archive -> int = "ost_read_support_format_raw"
external read_open_memory: archive -> string -> int -> int = "ost_read_open_memory"
external read_next_header: archive -> entry -> int = "ost_read_next_header"
external read_data: archive -> string ref -> int -> int = "ost_read_data"
external read_data_block: archive -> string ref -> int ref -> int ref -> int = "ost_read_data_block"

external entry_new: unit -> entry = "ost_entry_new"
external entry_set_filetype: entry -> Unix.file_kind -> unit = "ost_entry_set_filetype"
external entry_pathname: entry -> string = "ost_entry_pathname"

external write_new: unit -> archive = "ost_write_new"
external write_open_memory: archive -> string ref -> int -> int ref -> int = "ost_write_open_memory"
external write_header: archive -> entry -> int ="ost_write_header"
external write_set_format_raw: archive -> int = "ost_write_set_format_raw"
external write_add_filter_gzip: archive -> int = "ost_write_add_filter_gzip"
external write_data: archive -> string -> int -> int = "ost_write_data"
external write_close: archive -> int = "ost_write_close"

external print_pointer: entry -> unit = "ost_print_pointer"

let read_entire_data archive =
        let c_buffer_size = 1024 in
        let c_buffer = ref (String.create c_buffer_size) in
        let buffer = Buffer.create 16 in
        let read = ref (read_data archive c_buffer c_buffer_size) in
        while !read = c_buffer_size do
                Buffer.add_string buffer !c_buffer;
                read := read_data archive c_buffer c_buffer_size
        done;
        Buffer.add_string buffer !c_buffer;
        Buffer.contents buffer
