#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/custom.h>
#include <string.h>
#include <archive.h>
#include <archive_entry.h>

typedef struct archive* archive;
typedef struct archive_entry* entry;
#define Archive_val(v) ((struct archive*)(v))
#define Entry_val(v) ((struct archive_entry*)(v))
#define Ref_val(v) (Field((v),0))

static struct custom_operations entry_ops = {
    identifier: "entry",
    finalize: custom_finalize_default,
    compare: custom_compare_default,
    hash: custom_hash_default,
    serialize: custom_serialize_default,
    deserialize: custom_deserialize_default
};

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
    CAMLlocal1(ml_value);
    struct archive_entry* ent = archive_entry_new();
    printf("Entry allocd: %p\n", ent);
    ml_value = caml_alloc_custom(&entry_ops, sizeof(struct archive_entry*), 0, 1);
    entry* ptr = Data_custom_val(ml_value);
    printf("Dataval allocd: %p\n", ptr);
    *ptr = ent;

    return ml_value;
}

CAMLprim value ost_read_next_header(value a, value e)
{
    archive handle = Archive_val(a);
    //entry ent = Entry_val(Ref_val(e));
    entry* ent = Data_custom_val(e);

    int retval = archive_read_next_header(handle, ent);
    //Ref_val(e) = (value)ent;
    //TODO
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
    //entry ent = Entry_val(e);
    entry* ent = Data_custom_val(e);
    const char* name = archive_entry_pathname(*ent);
    return caml_copy_string(name);
}

CAMLprim value ost_read_data_block(value a, value buff, value size, value offset)
{
    CAMLlocal1(ml_buff);
    archive handle = Archive_val(a);
    const void* b = (const void*)Ref_val(buff);
    size_t s = (size_t)Ref_val(size);
    int64_t o = (size_t)Ref_val(offset);

    int retval = archive_read_data_block(handle, &b, &s, &o);
    ml_buff = caml_alloc_string(s);
    memcpy(String_val(ml_buff), b, s);
    Ref_val(buff) = ml_buff;
    Ref_val(size) = (value)s;
    Ref_val(offset) = (value)o;
    return Val_int(retval);
}

CAMLprim value ost_print_pointer(value pointer)
{
    entry* ent = Data_custom_val(pointer);
    printf("Entry: %p\n", *ent);
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
