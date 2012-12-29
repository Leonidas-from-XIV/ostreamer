#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <archive.h>

CAMLprim value ost_version_number(value unit)
{
    int version_number = archive_version_number();
    return Val_int(version_number);
}

CAMLprim value ost_version_string(value unit)
{
    const char* version_string = archive_version_string();
    return caml_copy_string(version_string);
}

CAMLprim value ost_read_new(value unit)
{
    struct archive* handle = archive_read_new();
    return (value)handle;
}

CAMLprim value ost_read_free(value sentinel)
{
    struct archive* handle = (struct archive*)sentinel;
    archive_read_free(handle);
    return Val_unit;
}

CAMLprim value ost_read_support_filter_all(value sentinel)
{
    struct archive* handle = (struct archive*)sentinel;
    int retval = archive_read_support_filter_all(handle);
    return Val_int(retval);
}

CAMLprim value ost_read_support_format_all(value sentinel)
{
    struct archive* handle = (struct archive*)sentinel;
    int retval = archive_read_support_format_all(handle);
    return Val_int(retval);
}

CAMLprim value ost_read_open_memory(value archive, value buff, value size)
{
    struct archive* handle = (struct archive*)archive;
    char *buffer = String_val(buff);
    size_t len = Int_val(size);
    int retval = archive_read_open_memory(handle, buffer, len);
    return Val_int(retval);
}
