#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <string.h>
#include <archive.h>
#include <archive_entry.h>

typedef struct archive* archive;
typedef struct archive_entry* entry;
#define Archive_val(v) ((struct archive*)(v))
#define Entry_val(v) ((struct archive_entry*)(v))

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
    archive handle = archive_read_new();
    return (value)handle;
}

CAMLprim value ost_read_free(value a)
{
    archive handle = Archive_val(a);
    archive_read_free(handle);
    return Val_unit;
}

CAMLprim value ost_read_support_filter_all(value a)
{
    archive handle = Archive_val(a);
    int retval = archive_read_support_filter_all(handle);
    return Val_int(retval);
}

CAMLprim value ost_read_support_format_all(value a)
{
    archive handle = Archive_val(a);
    int retval = archive_read_support_format_all(handle);
    return Val_int(retval);
}

CAMLprim value ost_read_support_format_raw(value a)
{
    archive handle = Archive_val(a);
    int retval = archive_read_support_format_raw(handle);
    return Val_int(retval);
}

void dump_buffer(char* buffer, size_t len)
{
    int position = 0;
    while (position != len)
    {
        putchar(buffer[position++]);
    }
}

CAMLprim value ost_read_open_memory(value a, value buff, value size)
{
    archive handle = Archive_val(a);
    char *buffer = String_val(buff);
    size_t len = Int_val(size);
    int retval = archive_read_open_memory(handle, buffer, len);
    return Val_int(retval);
}

CAMLprim value ost_archive_entry_new(value unit)
{
    entry ent = archive_entry_new();
    return (value)ent;
}

CAMLprim value ost_read_next_header(value a, value e)
{
    archive handle = Archive_val(a);
    entry ent = Entry_val(Field(e, 0));
    int retval = archive_read_next_header(handle, &ent);
    Field(e, 0) = (value)ent;
    return Val_int(retval);
}

CAMLprim value ost_read_data(value a, value buff, value size)
{
    archive handle = Archive_val(a);
    char* buffer = (char*)buff;
    int s = Val_int(size);
    int retval = archive_read_data(handle, buffer, s);
    return Val_int(retval);
}

CAMLprim value ost_entry_pathname(value e)
{
    entry ent = Entry_val(e);
    const char* name = archive_entry_pathname(ent);
    return caml_copy_string(name);
}

CAMLprim value ost_read_data_block(value a, value buff, value size, value offset)
{
    CAMLlocal1(ml_buff);
    archive handle = Archive_val(a);
    const void* b = (const void*)Field(buff, 0);
    size_t s = (size_t)Field(size, 0);
    int64_t o = (size_t)Field(offset, 0);

    int retval = archive_read_data_block(handle, &b, &s, &o);
    ml_buff = caml_alloc_string(s);
    memcpy(String_val(ml_buff), b, s);
    Field(buff, 0) = ml_buff;
    Field(size, 0) = (value)s;
    Field(offset, 0) = (value)o;
    return Val_int(retval);
}

CAMLprim value ost_print_pointer(value pointer)
{
    entry ent = Entry_val(pointer);
    printf("Entry: %p\n", ent);
    return Val_unit;
}

CAMLprim value ost_errno(value a)
{
    archive handle = Archive_val(a);
    return Val_int(archive_errno(handle));
}

CAMLprim value ost_error_string(value a)
{
    archive handle = Archive_val(a);
    return caml_copy_string(archive_error_string(handle));
}
