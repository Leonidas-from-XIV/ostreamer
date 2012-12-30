#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <archive.h>
#include <archive_entry.h>

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

CAMLprim value ost_read_support_format_raw(value sentinel)
{
    struct archive* handle = (struct archive*)sentinel;
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

CAMLprim value ost_read_open_memory(value archive, value buff, value size)
{
    struct archive* handle = (struct archive*)archive;
    char *buffer = String_val(buff);
    size_t len = Int_val(size);
    printf("ost_read_open_memory len: %lu\n", len);
    printf("ost_read_open_memory buffer: ");
    dump_buffer(buffer, len);
    printf("\n");
    int retval = archive_read_open_memory(handle, buffer, len);
    printf("ost_read_open_memory retval: %d\n", retval);
    return Val_int(retval);
}

CAMLprim value ost_archive_entry_new(value unit)
{
    struct archive_entry* entry = archive_entry_new();
    return (value)entry;
}

CAMLprim value ost_read_next_header(value archive, value entry)
{
    struct archive* handle = (struct archive*)archive;
    struct archive_entry* ent = (struct archive_entry*)Field(entry, 0);
    printf("ent: %p\n", ent);
    int retval = archive_read_next_header(handle, &ent);
    printf("ent: %p\n", ent);
    printf("retval: %d\n", retval);
    Field(entry, 0) = (value)ent;
    return Val_int(retval);
}

CAMLprim value ost_read_data(value archive, value buff, value size)
{
    struct archive* handle = (struct archive*)archive;
    char* buffer = (char*)buff;
    int s = Val_int(size);
    int retval = archive_read_data(handle, buffer, s);
    return Val_int(retval);
}

CAMLprim value ost_entry_pathname(value entry)
{
    struct archive_entry* ent = (struct archive_entry*)entry;
    const char* name = archive_entry_pathname(ent);
    printf("name: %s\n", archive_entry_pathname(ent));
    return caml_copy_string(name);
}

CAMLprim value ost_read_data_block(value archive, value buff, value size, value offset)
{
    struct archive* handle = (struct archive*)archive;
    const void* b = (const void*)Field(buff, 0);
    size_t s = (size_t)Field(size, 0);
    int64_t o = (size_t)Field(offset, 0);
    int retval = archive_read_data_block(handle, &b, &s, &o);
    Field(buff, 0) = (value)b;
    Field(size, 0) = (value)s;
    Field(offset, 0) = (value)o;
    return Val_int(retval);
}

CAMLprim value ost_print_pointer(value pointer)
{
    struct archive_entry* entry = (struct archive_entry*)pointer;
    printf("Entry: %p\n", entry);
    return Val_unit;
}
