/*
 * Archive_stubs - low level C wrappers for libarchive
 * Copyright (C) 2013 Marek Kubica <marek@xivilization.net>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version,
 * with the special exception on linking described in file COPYING.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

/* OCaml C FFI stubs that convert from OCaml values to C values,
 * call C functions and return results as OCaml values back
 * to the calling code
 */

/* C standard headers */
#include <string.h>

/* OCaml headers */
#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/custom.h>

/* libarchive  headers */
#include <archive.h>
#include <archive_entry.h>

/* local headers */
#include "ost_write_open_memory.h"

/* debug print stackoverflow.com/questions/1644868/ */
#ifndef DEBUG
#define DEBUG 0
#endif /* DEBUG */

#define debug_printf(fmt, s...) \
            do { if (DEBUG) fprintf(stderr, fmt, ## s); } while (0)

/* libarchive does not typedef the archive types, but we do.
 * The extent of typedef-ing (only typedef the struct? add a pointer to it?)
 * was inspired from ocaml-archive and works rather well
 */
typedef struct archive* archive;
typedef struct archive_entry* entry;

/* accessor macros that convert OCaml values into the C types that libarchive
 * exports
 */
#define Archive_val(v) ((struct archive**)(Data_custom_val(v)))
#define Entry_val(v) ((struct archive_entry**)(Data_custom_val(v)))
#define Write_buffer_val(v) ((char**)(Data_custom_val(v)))
#define Written_ptr_val(v) ((size_t*)(Data_custom_val(v)))
/* an OCaml ref is the first entry of a field. Can also be used as lvalue */
#define Ref_val(v) (Field((v),0))

/* prototypes, required for the callbacks */
static void ost_archive_free(value a);
static void ost_entry_free(value e);
static void ost_write_buffer_free(value b);
static void ost_written_ptr_free(value w);

/* custom blocks for the two types that libarchive uses: archive and entry */
static struct custom_operations archive_ops = {
    identifier: "archive",
    finalize: ost_archive_free,
    compare: custom_compare_default,
    hash: custom_hash_default,
    serialize: custom_serialize_default,
    deserialize: custom_deserialize_default
};

/* an own entry needs to be freed by this binding */
static struct custom_operations own_entry_ops = {
    identifier: "own_entry",
    /* finalize is set accordingly */
    finalize: ost_entry_free,
    compare: custom_compare_default,
    hash: custom_hash_default,
    serialize: custom_serialize_default,
    deserialize: custom_deserialize_default
};

/* a shared entry is returned by libarchive and freed by libarchive */
static struct custom_operations shared_entry_ops = {
    identifier: "shared_entry",
    /* finalize is set to the default value, so it does not free */
    finalize: custom_finalize_default,
    compare: custom_compare_default,
    hash: custom_hash_default,
    serialize: custom_serialize_default,
    deserialize: custom_deserialize_default
};

static struct custom_operations write_buffer_ops = {
    identifier: "write_buffer",
    finalize: ost_write_buffer_free,
    compare: custom_compare_default,
    hash: custom_hash_default,
    serialize: custom_serialize_default,
    deserialize: custom_deserialize_default
};

static struct custom_operations written_ptr_ops = {
    identifier: "written_ptr",
    finalize: ost_written_ptr_free,
    compare: custom_compare_default,
    hash: custom_hash_default,
    serialize: custom_serialize_default,
    deserialize: custom_deserialize_default
};

/* these values mirror the values for the ost_status type in OCaml.
 * the order has to be exactly the same as in the OCaml code.
 * these values also mirror the return values of libarchive status error
 * codes: ARCHIVE_OK, ARCHIVE_EOF, but only by name, not value.
 * We consider the values in libarchive implementation-dependent so we just
 * depend on the symbolic names. See map_errorcode for a translation function.
 */
typedef enum _ost_status {
    OST_OK,
    OST_EOF,
    OST_RETRY,
    OST_WARN,
    OST_FAILED,
    OST_FATAL
} ost_status;

/* These values represent the Unix.file_kind type and map to the exact same
 * values that OCaml uses to represent Unix.file_kind. Order matters.
 */
/* TODO: check if this is accessible directly from a header file */
typedef enum _ost_file_kind {
    S_REG,
    S_DIR,
    S_CHR,
    S_BLK,
    S_LNK,
    S_FIFO,
    S_SOCK
} ost_file_kind;

/* Maps the libarchive ARCHIVE_* error code to an OST_* error code that can be
 * represented by the ost_status type in OCaml.
 * Every C function that returns a status code from libarchive MUST call this,
 * to translate the libarchive error code into an ost_status error code.
 *
 * This function is not exported so no namespece pollution occurs.
 */
static int map_errorcode(int retval)
{
    /* This function is not fancy at all */
    switch (retval)
    {
        case ARCHIVE_OK:
            return OST_OK;
        case ARCHIVE_EOF:
            return OST_EOF;
        case ARCHIVE_RETRY:
            return OST_RETRY;
        case ARCHIVE_WARN:
            return OST_WARN;
        case ARCHIVE_FAILED:
            return OST_FAILED;
        case ARCHIVE_FATAL:
            return OST_FATAL;
    }
    return OST_FATAL;
}

value ost_version_number(value u)
{
    CAMLparam1(u);
    CAMLlocal1(r);
    int version_number = archive_version_number();
    r = Val_int(version_number);
    CAMLreturn(r);
}

value ost_version_string(value u)
{
    CAMLparam1(u);
    CAMLlocal1(r);
    const char* version_string = archive_version_string();
    r = caml_copy_string(version_string);
    CAMLreturn(r);
}

/* Function to create a new archive handle that is generated by a callback
 * function. This function is not exported and only used by ost_read_new and
 * ost_write_new.
 */
static value ost_new(archive (*new)(void))
{
    /* create a CAML value instance */
    CAMLlocal1(ml_value);
    /* allocate a custom block */
    ml_value = caml_alloc_custom(&archive_ops, sizeof(archive), 0, 1);
    /* get C value from custom block */
    archive* ptr = Archive_val(ml_value);
    /* get a new libarchive 'archive' instance and store it in the block */
    *ptr = new();
    return ml_value;
}

/* create and return a read handle */
value ost_read_new(value u)
{
    CAMLparam1(u);
    CAMLreturn(ost_new(archive_read_new));
}

/* This function frees an archive. It is not exposed to the OCaml interface
 * so it doesn't return an unit type but void, since it is called by the
 * custom block handler
 */
static void ost_archive_free(value a)
{
    CAMLparam1(a);
    archive* handle = Archive_val(a);
    /* requires libarchive >= 3ae99fbc24 as archive_free was added there */
    archive_free(*handle);
    CAMLreturn0;
}

/* Function for setting setting filters/formats. It is not exposed directly to
 * the OCaml interface but used internally for callbacks by other functions
 * like ost_read_support_filter_all to avoid writing the same code all the
 * time replacing one single function call.
 */
static value ost_archive_configure(value a, int (*set)(struct archive*))
{
    CAMLparam1(a);
    CAMLlocal1(r);
    archive* handle = Archive_val(a);
    int retval = set(*handle);
    r = Val_int(map_errorcode(retval));
    CAMLreturn(r);
}

/* configuration functions, they set format or filter support by calling
 * ost_archive_configure and returning its return value
 */
value ost_read_support_filter_all(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_filter_all);
    CAMLreturn(r);
}

/* read filters: they add support for detecting and reading an archive
 * that is compressed using this filter.
 *
 * Most of the time you just want to use all filters.
 */

value ost_read_support_filter_bzip2(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_filter_bzip2);
    CAMLreturn(r);
}

value ost_read_support_filter_compress(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_filter_compress);
    CAMLreturn(r);
}

value ost_read_support_filter_grzip(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_filter_grzip);
    CAMLreturn(r);
}

value ost_read_support_filter_gzip(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_filter_gzip);
    CAMLreturn(r);
}

value ost_read_support_filter_lrzip(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_filter_lrzip);
    CAMLreturn(r);
}

value ost_read_support_filter_lzip(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_filter_lzip);
    CAMLreturn(r);
}

value ost_read_support_filter_lzma(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_filter_lzma);
    CAMLreturn(r);
}

value ost_read_support_filter_lzop(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_filter_lzop);
    CAMLreturn(r);
}

value ost_read_support_filter_none(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_filter_none);
    CAMLreturn(r);
}

value ost_read_support_filter_rpm(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_filter_rpm);
    CAMLreturn(r);
}

value ost_read_support_filter_uu(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_filter_uu);
    CAMLreturn(r);
}

value ost_read_support_filter_xz(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_filter_xz);
    CAMLreturn(r);
}

/* read formats. Add support for detecting and reading specific archive
 * formats.
 * Most of the time you want to detect and read all possible formats.
 * Note: All formats exclude the raw format, so in case you want to read
 * the raw format (e.g. file.gz) you need to enable the raw format explicitly
 */

value ost_read_support_format_7zip(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_format_7zip);
    CAMLreturn(r);
}

value ost_read_support_format_all(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_format_all);
    CAMLreturn(r);
}

value ost_read_support_format_ar(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_format_ar);
    CAMLreturn(r);
}

value ost_read_support_format_cab(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_format_cab);
    CAMLreturn(r);
}

value ost_read_support_format_cpio(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_format_cpio);
    CAMLreturn(r);
}

value ost_read_support_format_gnutar(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_format_gnutar);
    CAMLreturn(r);
}

value ost_read_support_format_iso9660(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_format_iso9660);
    CAMLreturn(r);
}

value ost_read_support_format_lha(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_format_lha);
    CAMLreturn(r);
}

value ost_read_support_format_mtree(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_format_mtree);
    CAMLreturn(r);
}

value ost_read_support_format_rar(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_format_rar);
    CAMLreturn(r);
}

value ost_read_support_format_raw(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_format_raw);
    CAMLreturn(r);
}

value ost_read_support_format_tar(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_format_tar);
    CAMLreturn(r);
}

value ost_read_support_format_xar(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_format_xar);
    CAMLreturn(r);
}

value ost_read_support_format_zip(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_read_support_format_zip);
    CAMLreturn(r);
}

/* create a new archive handle that can be used for writing archives
 */
value ost_write_new(value u)
{
    CAMLparam1(u);
    CAMLlocal1(r);
    r = ost_new(archive_write_new);
    CAMLreturn(r);
}

/* open a block of memory for the write handle, so it knows where to
 * write the decompressed data to.
 * This function is not the same as archive_write_open_memory but uses a
 * data structure that grows automatically.
 * This function takes a write handle, a pointer to the buffer and a
 * pointer to how many bytes were written. The latter two types are
 * opaque and can be created by write_buffer_new and written_ptr_new from
 * the OCaml code. Both have to be freed manually from the OCaml code,
 * too.
 */
value ost_write_open_memory(value a, value b, value w)
{
    CAMLparam3(a, b, w);
    CAMLlocal1(r);
    archive* handle = Archive_val(a);
    char** bufptr = Write_buffer_val(b);
    size_t* wptr = Written_ptr_val(w);

    int retval = ost_write_open_dynamic_memory(*handle, bufptr, wptr);

    r = Val_int(map_errorcode(retval));
    CAMLreturn(r);
}

/* creates a pointer marking the write progress. Returns an opaque type
 * to OCaml. The exact contents don't matter for OCaml code but it needs
 * to be passed around.
 */
value ost_written_ptr_new(value u)
{
    CAMLparam1(u);
    CAMLlocal1(ml_value);
    ml_value = caml_alloc_custom(&written_ptr_ops, sizeof(size_t*), 0, 1);
    size_t* written = Written_ptr_val(ml_value);
    /* allocate one block on the heap to store a value */
    /* size_t* written = malloc(sizeof (size_t*)); */
    /* TODO: error handling when malloc fails */
    /* set the contents to zero, since nothing was written yet */
    *written = 0;
    /* return opaque type */
    CAMLreturn(ml_value);
}

/* Reads the stored value in a written_ptr and returns an OCaml type
 * containing the value.
 *
 * This function can be used for debugging, it is not required to ever read
 * the stored value in OCaml.
 */
value ost_written_ptr_read(value w)
{
    CAMLparam1(w);
    CAMLlocal1(r);
    size_t* written = Written_ptr_val(w);
    /* TODO int64? */
    r = Val_int(*written);
    CAMLreturn(r);
}

/* Frees the pointers storage from the heap. After calling this function,
 * the OCaml value is INVALID and should not be used, because it points
 * to a freed memory region which might contain anything.
 */
static void ost_written_ptr_free(value w)
{
    /* This function is strictly speaking not really required */
    CAMLparam1(w);
    size_t* written = Written_ptr_val(w);
    debug_printf("Freeing written_ptr\n");
    CAMLreturn0;
}

/* Creates a block that holds the pointer to the buffer which will contain
 * the data that is written out
 */
value ost_write_buffer_new(value u)
{
    CAMLparam1(u);
    CAMLlocal1(ml_value);
    ml_value = caml_alloc_custom(&write_buffer_ops, sizeof(char**), 0, 1);
    char** buffer = Write_buffer_val(ml_value);
    /* char** buffer = malloc(sizeof (char**)); */
    /* TODO: error handling */
    /* Initialize to "uninitialized" */
    *buffer = NULL;
    /* return opaque type */
    CAMLreturn(ml_value);
}

/* return an OCaml string that contains the data in the buffer */
value ost_write_buffer_read(value b, value w)
{
    CAMLparam2(b, w);
    CAMLlocal1(ml_data);
    char** buffer = Write_buffer_val(b);
    size_t* written = Written_ptr_val(w);

    /* create an OCaml string that is *written bytes long */
    ml_data = caml_alloc_string(*written);
    /* copy the contents from the C string to the OCaml string */
    memcpy(String_val(ml_data), *buffer, *written);
    CAMLreturn(ml_data);
}

/* Free the C buffer as well as the buffer pointer. */
static void ost_write_buffer_free(value b)
{
    char** buffer = Write_buffer_val(b);
    debug_printf("Freeing write buffer\n");
    /* Free only if memory was opened, so it doesn't contain NULL */
    if (*buffer != NULL) {
        free(*buffer);
    }
}

value ost_write_header(value a, value e)
{
    CAMLparam2(a, e);
    CAMLlocal1(r);
    archive* handle = Archive_val(a);
    entry* entry = Entry_val(e);

    int retval = archive_write_header(*handle, *entry);
    /* map the errorcode from libarchive to OStreamer and return as OCaml
     * int */
    r = Val_int(map_errorcode(retval));
    CAMLreturn(r);
}

/* writes the file content after storing the header.
 * Takes a write handle, the data in an OCaml string and the
 * size as integer
 */
value ost_write_data(value a, value b, value s)
{
    CAMLparam3(a, b, s);
    CAMLlocal1(r);
    archive* handle = Archive_val(a);
    char* buffer = String_val(b);
    /* TODO: use int64 instead? */
    size_t size = Int_val(s);

    ssize_t written = archive_write_data(*handle, buffer, size);
    /* returns the number of bytes that were written as an integer,
     * NOT a status value */
    /* TODO: return int64 instead? */
    r = Val_int(written);
    CAMLreturn(r);
}

/* Closes an archive write handle */
value ost_write_close(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    archive* handle = Archive_val(a);
    int retval = archive_write_close(*handle);
    r = Val_int(map_errorcode(retval));
    CAMLreturn(r);
}

/* configure the format which to write. Setting more than one format causes
 * the previous setting to be overwritten
 */

value ost_write_set_format_7zip(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_set_format_7zip);
    CAMLreturn(r);
}

value ost_write_set_format_ar_bsd(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_set_format_ar_bsd);
    CAMLreturn(r);
}

value ost_write_set_format_ar_svr4(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_set_format_ar_svr4);
    CAMLreturn(r);
}

value ost_write_set_format_cpio(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_set_format_cpio);
    CAMLreturn(r);
}

value ost_write_set_format_cpio_newc(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_set_format_cpio_newc);
    CAMLreturn(r);
}

value ost_write_set_format_gnutar(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_set_format_gnutar);
    CAMLreturn(r);
}

value ost_write_set_format_iso9660(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_set_format_iso9660);
    CAMLreturn(r);
}

value ost_write_set_format_mtree(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_set_format_mtree);
    CAMLreturn(r);
}

value ost_write_set_format_pax(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_set_format_pax);
    CAMLreturn(r);
}

value ost_write_set_format_raw(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    /* TODO: replace by simpler callback version when libarchive ships
     * the new header with archive_write_set_format_raw */
    archive* handle = Archive_val(a);
    int retval = archive_write_set_format_raw(*handle);
    r = Val_int(map_errorcode(retval));
    CAMLreturn(r);
}

value ost_write_set_format_shar(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_set_format_shar);
    CAMLreturn(r);
}

value ost_write_set_format_ustar(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_set_format_ustar);
    CAMLreturn(r);
}

value ost_write_set_format_v7tar(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_set_format_v7tar);
    CAMLreturn(r);
}

value ost_write_set_format_xar(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_set_format_xar);
    CAMLreturn(r);
}

value ost_write_set_format_zip(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_set_format_zip);
    CAMLreturn(r);
}

/* Filters for write handles. Multiple filters can be added, I think. */
value ost_write_add_filter_b64encode(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_add_filter_b64encode);
    CAMLreturn(r);
}

value ost_write_add_filter_bzip2(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_add_filter_bzip2);
    CAMLreturn(r);
}

value ost_write_add_filter_compress(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_add_filter_compress);
    CAMLreturn(r);
}

value ost_write_add_filter_grzip(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_add_filter_grzip);
    CAMLreturn(r);
}

value ost_write_add_filter_gzip(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_add_filter_gzip);
    CAMLreturn(r);
}

value ost_write_add_filter_lrzip(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_add_filter_lrzip);
    CAMLreturn(r);
}

value ost_write_add_filter_lzip(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_add_filter_lzip);
    CAMLreturn(r);
}

value ost_write_add_filter_lzma(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_add_filter_lzma);
    CAMLreturn(r);
}

value ost_write_add_filter_lzop(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_add_filter_lzop);
    CAMLreturn(r);
}

value ost_write_add_filter_none(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_add_filter_none);
    CAMLreturn(r);
}

value ost_write_add_filter_uuencode(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_add_filter_uuencode);
    CAMLreturn(r);
}

value ost_write_add_filter_xz(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    r = ost_archive_configure(a, archive_write_add_filter_xz);
    CAMLreturn(r);
}

void dump_buffer(char* buffer, size_t len)
{
    int position = 0;
    while (position != len)
    {
        putchar(buffer[position++]);
    }
}

/* Opens a read handle: basically set the buffer from which to read data */
value ost_read_open_memory(value a, value buff, value size)
{
    CAMLparam3(a, buff, size);
    CAMLlocal1(r);
    archive* handle = Archive_val(a);
    char *buffer = String_val(buff);
    /* TODO: int64? */
    size_t len = Int_val(size);
    int retval = archive_read_open_memory(*handle, buffer, len);
    r = Val_int(map_errorcode(retval));
    CAMLreturn(r);
}

/* Creates a new entry element out of nowhere. */
value ost_entry_new(value unit)
{
    CAMLparam1(unit);
    CAMLlocal1(ml_value);
    entry ent = archive_entry_new();
    ml_value = caml_alloc_custom(&own_entry_ops, sizeof(entry), 0, 1);
    /* get C value out of OCaml entry type */
    entry* ptr = Entry_val(ml_value);
    /* and set its contents to the C entry type */
    *ptr = ent;

    CAMLreturn(ml_value);
}

/* an unpopulated entry, does not need to be freed, will be freed by
 * libarchive */
value ost_entry_new_shared(value unit)
{
    CAMLparam1(unit);
    CAMLlocal1(ml_value);
    ml_value = caml_alloc_custom(&shared_entry_ops, sizeof(entry), 0, 1);
    CAMLreturn(ml_value);
}

/* frees a handle. This needs to be called on all handles created by
 * entry_new, but not on ones that libarchive returns
 */
static void ost_entry_free(value e)
{
    entry* ent = Entry_val(e);
    debug_printf("Freeing entry\n");
    archive_entry_free(*ent);
}

value ost_entry_set_filetype(value e, value t)
{
    CAMLparam2(e, t);
    entry* entry = Entry_val(e);
    int ocaml_type = Int_val(t);
    unsigned int type = 0;

    switch (ocaml_type)
    {
        case S_REG:
            type = AE_IFREG;
            break;
        case S_DIR:
            type = AE_IFDIR;
            break;
        /* TODO: others */
    }

    archive_entry_set_filetype(*entry, type);

    CAMLreturn(Val_unit);
}

value ost_entry_filetype(value e)
{
    CAMLparam1(e);
    CAMLlocal1(r);
    entry* ent = Entry_val(e);
    __LA_MODE_T mode = archive_entry_filetype(*ent);
    int kind = 0;

    switch (mode)
    {
        case AE_IFREG:
            kind = S_REG;
            break;
        case AE_IFDIR:
            kind = S_DIR;
            break;
        case AE_IFCHR:
            kind = S_CHR;
            break;
        case AE_IFBLK:
            kind = S_BLK;
            break;
        case AE_IFLNK:
            kind = S_LNK;
            break;
        case AE_IFIFO:
            kind = S_FIFO;
            break;
        case AE_IFSOCK:
            kind = S_SOCK;
            break;
    }

    r = Val_int(kind);
    CAMLreturn(r);
}

value ost_read_next_header(value a, value e)
{
    CAMLparam2(a, e);
    CAMLlocal1(r);
    archive* handle = Archive_val(a);
    entry* ent = Entry_val(e);

    int retval = archive_read_next_header(*handle, ent);
    r = Val_int(map_errorcode(retval));
    CAMLreturn(r);
}

value ost_read_data(value a, value buff, value size)
{
    CAMLparam3(a, buff, size);
    CAMLlocal1(r);
    archive* handle = Archive_val(a);
    char* buffer = (char*)Ref_val(buff);
    int s = Int_val(size);

    int read = archive_read_data(*handle, buffer, s);
    r = Val_int(read);
    CAMLreturn(r);
}

value ost_entry_pathname(value e)
{
    CAMLparam1(e);
    CAMLlocal1(r);
    entry* ent = Entry_val(e);
    const char* name = archive_entry_pathname(*ent);
    r = caml_copy_string(name);
    CAMLreturn(r);
}

#define Val_none Val_int(0)

static value Val_some(value v)
{
    CAMLparam1(v);
    CAMLlocal1(some);
    some = caml_alloc(1, 0);
    Store_field(some, 0, v);
    CAMLreturn(some);
}

value ost_entry_size(value e)
{
    CAMLparam1(e);
    CAMLlocal2(r, r1);
    entry* ent = Entry_val(e);
    __LA_INT64_T size;
    if (archive_entry_size_is_set(*ent)) {
        size = archive_entry_size(*ent);
        r1 = caml_copy_int64(size);
        r = Val_some(r1);
    } else {
        r = Val_none;
    }
    CAMLreturn(r);
}

/* get the entry, the callback to check for existance and the callback to get the value */
static value ost_entry_read_time(value e, int (*check)(struct archive_entry *),
        time_t (*retrieve)(struct archive_entry*))
{
    CAMLparam1(e);
    CAMLlocal2(r, r1);
    entry* ent = Entry_val(e);
    double unixtime;
    time_t t;
    if (check(*ent)) {
        t = retrieve(*ent);
        /* TODO: unportable */
        unixtime = (double)t;
        r1 = caml_copy_double(unixtime);
        r = Val_some(r1);
    } else {
        r = Val_none;
    }
    CAMLreturn(r);
}

value ost_entry_mtime(value e)
{
    CAMLparam1(e);
    CAMLlocal1(r);
    r = ost_entry_read_time(e, archive_entry_mtime_is_set,
            archive_entry_mtime);
    CAMLreturn(r);
}

value ost_entry_atime(value e)
{
    CAMLparam1(e);
    CAMLlocal1(r);
    r = ost_entry_read_time(e, archive_entry_atime_is_set,
            archive_entry_atime);
    CAMLreturn(r);
}

value ost_entry_ctime(value e)
{
    CAMLparam1(e);
    CAMLlocal1(r);
    r = ost_entry_read_time(e, archive_entry_ctime_is_set,
            archive_entry_ctime);
    CAMLreturn(r);
}

value ost_entry_birthtime(value e)
{
    CAMLparam1(e);
    CAMLlocal1(r);
    r = ost_entry_read_time(e, archive_entry_birthtime_is_set,
            archive_entry_birthtime);
    CAMLreturn(r);
}

value ost_entry_set_pathname(value e, value p)
{
    CAMLparam2(e, p);
    entry* ent = Entry_val(e);
    char* path = String_val(p);

    archive_entry_set_pathname(*ent, path);
    CAMLreturn(Val_unit);
}

value ost_entry_set_size(value e, value s)
{
    CAMLparam2(e, s);
    entry* ent = Entry_val(e);
    __LA_INT64_T size = Int64_val(s);

    archive_entry_set_size(*ent, size);
    CAMLreturn(Val_unit);
}

static value ost_entry_set_time(value e, value t, void (*set)(struct archive_entry*, time_t, long))
{
    CAMLparam2(e, t);
    entry* ent = Entry_val(e);
    double sec = Double_val(t);
    /* TODO, evil cast */
    time_t ref = (time_t)sec;
    /* TODO: yeah, exactly zero nanoseconds! */
    set(*ent, ref, 0L);

    CAMLreturn(Val_unit);
}

value ost_entry_set_mtime(value e, value t)
{
    CAMLparam2(e, t);
    CAMLlocal1(r);
    r = ost_entry_set_time(e, t, archive_entry_set_mtime);
    CAMLreturn(r);
}

value ost_entry_set_atime(value e, value t)
{
    CAMLparam2(e, t);
    CAMLlocal1(r);
    r = ost_entry_set_time(e, t, archive_entry_set_atime);
    CAMLreturn(r);
}

value ost_entry_set_ctime(value e, value t)
{
    CAMLparam2(e, t);
    CAMLlocal1(r);
    r = ost_entry_set_time(e, t, archive_entry_set_ctime);
    CAMLreturn(r);
}

value ost_entry_set_birthtime(value e, value t)
{
    CAMLparam2(e, t);
    CAMLlocal1(r);
    r = ost_entry_set_time(e, t, archive_entry_set_birthtime);
    CAMLreturn(r);
}

static value ost_entry_set_usergroup(value e, value u, void (*set)(struct archive_entry*, __LA_INT64_T))
{
    CAMLparam2(e, u);
    entry* ent = Entry_val(e);
    __LA_INT64_T val = Int64_val(u);
    set(*ent, val);
    CAMLreturn(Val_unit);
}

value ost_entry_set_uid(value e, value u)
{
    CAMLparam2(e, u);
    CAMLlocal1(r);
    r = ost_entry_set_usergroup(e, u, archive_entry_set_uid);
    CAMLreturn(r);
}

value ost_entry_set_gid(value e, value g)
{
    CAMLparam2(e, g);
    CAMLlocal1(r);
    r = ost_entry_set_usergroup(e, g, archive_entry_set_gid);
    CAMLreturn(r);
}

static value ost_entry_set_usergroupname(value e, value n, void (*set)(struct archive_entry*, const char*))
{
    CAMLparam2(e, n);
    entry* ent = Entry_val(e);
    const char* name = String_val(n);
    set(*ent, name);

    CAMLreturn(Val_unit);
}

value ost_entry_set_uname(value e, value n)
{
    CAMLparam2(e, n);
    CAMLlocal1(r);
    r = ost_entry_set_usergroupname(e, n, archive_entry_set_uname);
    CAMLreturn(r);
}

value ost_entry_set_gname(value e, value n)
{
    CAMLparam2(e, n);
    CAMLlocal1(r);
    r = ost_entry_set_usergroupname(e, n, archive_entry_set_gname);
    CAMLreturn(r);
}

static value ost_entry_usergroup(value e, __LA_INT64_T (*retrieve)(struct archive_entry *))
{
    CAMLparam1(e);
    CAMLlocal1(r);
    entry* ent = Entry_val(e);
    __LA_INT64_T val = retrieve(*ent);
    r = caml_copy_int64(val);
    CAMLreturn(r);
}

value ost_entry_uid(value e)
{
    CAMLparam1(e);
    CAMLlocal1(r);
    r = ost_entry_usergroup(e, archive_entry_uid);
    CAMLreturn(r);
}

value ost_entry_gid(value e)
{
    CAMLparam1(e);
    CAMLlocal1(r);
    r = ost_entry_usergroup(e, archive_entry_gid);
    CAMLreturn(r);
}

static value ost_entry_usergroupname(value e, const char* (*retrieve)(struct archive_entry *))
{
    CAMLparam1(e);
    CAMLlocal2(r, r1);
    entry* ent = Entry_val(e);
    const char* name = retrieve(*ent);
    if (name != NULL) {
        r1 = caml_copy_string(name);
        r = Val_some(r1);
    } else {
        r = Val_none;
    }
    CAMLreturn(r);
}

value ost_entry_uname(value e)
{
    CAMLparam1(e);
    CAMLlocal1(r);
    r = ost_entry_usergroupname(e, archive_entry_uname);
    CAMLreturn(r);
}

value ost_entry_gname(value e)
{
    CAMLparam1(e);
    CAMLlocal1(r);
    r = ost_entry_usergroupname(e, archive_entry_gname);
    CAMLreturn(r);
}

value ost_read_data_block(value a, value buff, value size, value offset)
{
    CAMLparam4(a, buff, size, offset);
    CAMLlocal2(r, ml_buff);
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
    r = Val_int(retval);
    CAMLreturn(r);
}

value ost_print_pointer(value pointer)
{
    CAMLparam1(pointer);
    entry* ent = Entry_val(pointer);
    printf("Entry: %p\n", *ent);
    CAMLreturn(Val_unit);
}

value ost_errno(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    archive* handle = Archive_val(a);
    r = Val_int(archive_errno(*handle));
    CAMLreturn(r);
}

value ost_error_string(value a)
{
    CAMLparam1(a);
    CAMLlocal1(r);
    archive* handle = Archive_val(a);
    r = caml_copy_string(archive_error_string(*handle));
    CAMLreturn(r);
}
