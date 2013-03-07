#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/custom.h>
#include <string.h>
#include <archive.h>
#include <archive_entry.h>

#include "ost_write_open_memory.h"

typedef struct archive* archive;
typedef struct archive_entry* entry;
#define Archive_val(v) ((struct archive**)(Data_custom_val(v)))
#define Entry_val(v) ((struct archive_entry**)(Data_custom_val(v)))
#define Ref_val(v) (Field((v),0))

void ost_read_free(value a);
void ost_entry_free(value e);

static struct custom_operations archive_ops = {
    identifier: "archive",
    finalize: ost_read_free,
    compare: custom_compare_default,
    hash: custom_hash_default,
    serialize: custom_serialize_default,
    deserialize: custom_deserialize_default
};

static struct custom_operations entry_ops = {
    identifier: "entry",
    finalize: ost_entry_free,
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
    CAMLlocal1(ml_value);
    ml_value = caml_alloc_custom(&archive_ops, sizeof(archive), 0, 1);
    archive* ptr = Data_custom_val(ml_value);
    *ptr = archive_read_new();
    return ml_value;
}

void ost_read_free(value a)
{
    archive* handle = Archive_val(a);
    archive_read_free(*handle);
}

CAMLprim value ost_read_support_filter_all(value a)
{
    archive* handle = Archive_val(a);
    int retval = archive_read_support_filter_all(*handle);
    return Val_int(retval);
}

CAMLprim value ost_read_support_format_all(value a)
{
    archive* handle = Archive_val(a);
    int retval = archive_read_support_format_all(*handle);
    return Val_int(retval);
}

CAMLprim value ost_read_support_format_raw(value a)
{
    archive* handle = Archive_val(a);
    int retval = archive_read_support_format_raw(*handle);
    return Val_int(retval);
}

CAMLprim value ost_write_new(value unit)
{
    CAMLlocal1(ml_value);
    ml_value = caml_alloc_custom(&archive_ops, sizeof(archive), 0, 1);
    archive* ptr = Data_custom_val(ml_value);
    *ptr = archive_write_new();
    return ml_value;
}

CAMLprim value ost_write_open_memory(value a, value b, value w)
{
    archive* handle = Archive_val(a);
    char** bufptr = (char**)b;
    size_t* wptr = (size_t*)w;

    int retval = ost_write_open_dynamic_memory(*handle, bufptr, wptr);

    return Val_int(retval);
}

CAMLprim value ost_written_ptr_new(value u)
{
    size_t* written = malloc(sizeof (size_t*));
    /* TODO: error handling */
    *written = 0;
    return (value)written;
}

CAMLprim value ost_written_ptr_read(value w)
{
    size_t* written = (size_t*)w;
    return Val_int(*written);
}

CAMLprim value ost_written_ptr_free(value w)
{
    size_t* written = (size_t*)w;
    free(written);
    return Val_unit;
}

CAMLprim value ost_write_buffer_new(value u)
{
    char** buffer = malloc(sizeof (char**));
    /* Initialize to "uninitialized" */
    *buffer = NULL;
    return (value)buffer;
}

CAMLprim value ost_write_buffer_read(value b, value w)
{
    CAMLlocal1(ml_data);
    char** buffer = (char**)b;
    size_t* written = (size_t*)w;

    ml_data = caml_alloc_string(*written);
    memcpy(String_val(ml_data), *buffer, *written);
    return ml_data;
}

CAMLprim value ost_write_buffer_free(value b)
{
    char** buffer = (char**)b;
    free(*buffer);
    free(buffer);
    return Val_unit;
}

CAMLprim value ost_write_header(value a, value e)
{
    archive* handle = Archive_val(a);
    entry* entry = Entry_val(e);

    int retval = archive_write_header(*handle, *entry);
    return Val_int(retval);
}

CAMLprim value ost_write_data(value a, value b, value s)
{
    archive* handle = Archive_val(a);
    char* buffer = String_val(b);
    size_t size = Int_val(s);
    printf("Writing size: %zu\n", size);
    //fwrite(buffer, 1, size, stderr);

    int retval = archive_write_data(*handle, buffer, size);
    printf("Retval write_data = %d\n", retval);
    printf("Error: %s\n", archive_error_string(*handle));
    return Val_int(retval);
}

CAMLprim value ost_write_close(value a)
{
    archive* handle = Archive_val(a);
    int retval = archive_write_close(*handle);
    return Val_int(retval);
}

CAMLprim value ost_write_set_format_raw(value a)
{
    archive* handle = Archive_val(a);
    int retval = archive_write_set_format_raw(*handle);
    return Val_int(retval);
}

CAMLprim value ost_write_add_filter_gzip(value a)
{
    archive* handle = Archive_val(a);
    int retval = archive_write_add_filter_gzip(*handle);
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
    archive* handle = Archive_val(a);
    char *buffer = String_val(buff);
    size_t len = Int_val(size);
    int retval = archive_read_open_memory(*handle, buffer, len);
    return Val_int(retval);
}

CAMLprim value ost_entry_new(value unit)
{
    CAMLlocal1(ml_value);
    entry ent = archive_entry_new();
    ml_value = caml_alloc_custom(&entry_ops, sizeof(entry), 0, 1);
    entry* ptr = Entry_val(ml_value);
    *ptr = ent;

    return ml_value;
}

void ost_entry_free(value e)
{
    entry* ent = Entry_val(e);
    archive_entry_free(*ent);
}

/* TODO: check if this is accessible directly from a header file */
typedef enum _ost_file_kind {
    S_REG = 1,
    S_DIR,
    S_CHR,
    S_BLK,
    S_LNK,
    S_FIFO,
    S_SOCK
} ost_file_kind;

CAMLprim value ost_entry_set_filetype(value e, value t)
{
    entry* entry = Entry_val(e);
    unsigned int type = 0;

    switch (Int_val(t))
    {
        case S_REG:
            type = AE_IFREG;
            break;
    }

    archive_entry_set_filetype(*entry, type);

    return Val_unit;
}

CAMLprim value ost_read_next_header(value a, value e)
{
    archive* handle = Archive_val(a);
    entry* ent = Entry_val(e);

    int retval = archive_read_next_header(*handle, ent);
    return Val_int(retval);
}

CAMLprim value ost_read_data(value a, value buff, value size)
{
    archive* handle = Archive_val(a);
    char* buffer = (char*)Ref_val(buff);
    int s = Int_val(size);

    int retval = archive_read_data(*handle, buffer, s);
    return Val_int(retval);
}

CAMLprim value ost_entry_pathname(value e)
{
    entry* ent = Entry_val(e);
    const char* name = archive_entry_pathname(*ent);
    return caml_copy_string(name);
}

#define Val_none Val_int(0)

static value Val_some(value v)
{
    CAMLlocal1(some);
    some = caml_alloc(1, 0);
    Store_field(some, 0, v);
    return some;
}

CAMLprim value ost_entry_size(value e)
{
    entry* ent = Entry_val(e);
    __LA_INT64_T size;
    if (archive_entry_size_is_set(*ent)) {
        size = archive_entry_size(*ent);
        /* TODO: wrap in better thing than Int_val, 64 bit */
        return Val_some(Val_int(size));
    }
    return Val_none;
}

/* get the entry, the callback to check for existance and the callback to get the value */
CAMLprim value ost_entry_read_time(value e, int (*check)(struct archive_entry *),
        time_t (*retrieve)(struct archive_entry*))
{
    entry* ent = Entry_val(e);
    double unixtime;
    time_t t;
    if (check(*ent)) {
        t = retrieve(*ent);
        /* TODO: unportable */
        unixtime = (double)t;
        return Val_some(caml_copy_double(unixtime));
    }
    return Val_none;
}

CAMLprim value ost_entry_mtime(value e)
{
    return ost_entry_read_time(e, archive_entry_mtime_is_set,
            archive_entry_mtime);
}

CAMLprim value ost_entry_atime(value e)
{
    return ost_entry_read_time(e, archive_entry_atime_is_set,
            archive_entry_atime);
}

CAMLprim value ost_read_data_block(value a, value buff, value size, value offset)
{
    CAMLlocal1(ml_buff);
    archive* handle = Archive_val(a);
    const void* b = (const void*)Ref_val(buff);
    size_t s = (size_t)Ref_val(size);
    int64_t o = (size_t)Ref_val(offset);

    int retval = archive_read_data_block(*handle, &b, &s, &o);
    ml_buff = caml_alloc_string(s);
    memcpy(String_val(ml_buff), b, s);
    Ref_val(buff) = ml_buff;
    Ref_val(size) = Val_int(s);
    Ref_val(offset) = (value)o;
    return Val_int(retval);
}

CAMLprim value ost_print_pointer(value pointer)
{
    entry* ent = Entry_val(pointer);
    printf("Entry: %p\n", *ent);
    return Val_unit;
}

CAMLprim value ost_errno(value a)
{
    archive* handle = Archive_val(a);
    return Val_int(archive_errno(*handle));
}

CAMLprim value ost_error_string(value a)
{
    archive* handle = Archive_val(a);
    return caml_copy_string(archive_error_string(*handle));
}
