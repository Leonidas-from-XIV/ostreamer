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

    return 0;
}
