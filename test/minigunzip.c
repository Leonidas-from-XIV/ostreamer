#include <stdlib.h>
#include <archive.h>
#include <archive_entry.h>

int main(void)
{
    struct archive* a = archive_read_new();
    struct archive_entry* e = archive_entry_new();

    archive_read_support_filter_all(a);
    archive_read_support_format_all(a);
    archive_read_support_format_raw(a);

    FILE *fh = fopen("test.gz", "rb");
    fseek(fh, 0L, SEEK_END);
    long l = ftell(fh);
    rewind(fh);
    char* content = malloc(l);
    fread(content, l, 1, fh);
    int retval;

    retval = archive_read_open_memory(a, content, l);
    //retval = archive_read_open_filename(a, "test.gz", 512);
    //retval = archive_read_open_FILE(a, fh);
    printf("read_open retval: %d\n", retval);
    if (retval != ARCHIVE_OK) {
        printf("retval error: %s\n", archive_error_string(a));
    }

    archive_read_next_header(a, &e);
    printf("Pathname: %s\n", archive_entry_pathname(e));

    const void* b;
    size_t size;
    int64_t offset;
    retval = archive_read_data_block(a, &b, &size, &offset);
    printf("read_data_block retval: %d\n", retval);

    printf("buff: %s\n", b);
    archive_read_close(a);
    // read part finished, now write

    a = archive_write_new();
    archive_write_add_filter_gzip(a);
    archive_write_set_format_raw(a);

    size_t compressed_size = 100;
    char* compressed[compressed_size];
    size_t out_used;
    archive_write_open_memory(a, compressed, compressed_size, &out_used);
    e = archive_entry_new();
    archive_entry_set_filetype(e, AE_IFREG);
    retval = archive_write_header(a, e);
    printf("write_header retval: %d\n", retval);
    if (retval != ARCHIVE_OK) {
        printf("Error: %s\n", archive_error_string(a));
    }
    archive_write_data(a, b, size);
    printf("write_data retval: %d\n", retval);
    printf("out_used before close: %d\n", out_used);
    archive_write_close(a);
    printf("out_used after close: %d\n", out_used);
    fwrite(compressed, 1, out_used, stderr);
    archive_write_free(a);

    return 0;
}
