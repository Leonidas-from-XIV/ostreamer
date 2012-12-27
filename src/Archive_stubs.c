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
