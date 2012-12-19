#include <caml/mlvalues.h>
#include <archive.h>

CAMLprim value ost_version_number(value unit)
{
    printf("%d\n", archive_version_number());
    return Val_unit;
}
