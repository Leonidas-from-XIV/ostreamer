#include <stdlib.h>
#include <archive.h>
#include <archive_entry.h>

int main(void)
{
    struct archive* a = archive_read_new();
    struct archive_entry* e = archive_entry_new();

    archive_read_support_filter_all(a);
    archive_read_support_format_all(a);

    FILE *fh = fopen("test.gz", "rb");
    fseek(fh, 0L, SEEK_END);
    long l = ftell(fh);
    rewind(fh);
    char* content = malloc(l);
    fread(content, l, 1, fh);
    int retval;

    retval = archive_read_open_memory(a, content, l);
    printf("%d\n", retval);
    archive_read_next_header(a, &e);
    printf("%s\n", archive_entry_pathname(e));


    /*
        ignore (Archive.read_open_memory handle content l);
        ignore (Archive.read_next_header handle entry);
        (* print_endline (Archive.entry_pathname entry); *)
        ignore (Archive.read_data handle decompressed ldec);
        print_endline decompressed;
        Archive.read_free handle;
    */
    return 0;
}
