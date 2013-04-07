/*
 * ost_write_open_memory - a dynamically growing output buffer
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

#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <assert.h>

#include <archive.h>

static int ost_mem_open(struct archive*, void*);
static int ost_mem_close(struct archive*, void*);
static ssize_t ost_mem_write(struct archive*, void*, const void* buff, size_t);

#define OST_BUFSIZE 4096

struct ost_write_memory_data {
    /* number of bytes that the current buffer is filled */
    size_t* written;
    /* size of the currently allocated buffer */
    size_t current_size;
    /* the address of the current buffer that we have allocated */
    char** current_buffer;
};

int ost_write_open_dynamic_memory(struct archive* a, char** location, size_t* written)
{
    struct ost_write_memory_data* mine;
    mine = (struct ost_write_memory_data*)calloc(1, sizeof (*mine));
    if (mine == NULL) {
        archive_set_error(a, ENOMEM, "No memory");
        return (ARCHIVE_FATAL);
    }
    mine->current_buffer = location;
    mine->written = written;
    mine->current_size = 0;

    /* "magic" code taken from archive_write_open_memory.c */
    /* disable padding */
    if (-1 == archive_write_get_bytes_in_last_block(a)) {
        archive_write_set_bytes_in_last_block(a, 1);
    }

    return (archive_write_open(a, mine, ost_mem_open, ost_mem_write, ost_mem_close));
}

static int ost_mem_open(struct archive* a, void* client_data)
{
    struct ost_write_memory_data* mine = client_data;

    char* initial_buffer = malloc(OST_BUFSIZE * sizeof (char));
    if (initial_buffer == NULL) {
        archive_set_error(a, ENOMEM, "Allocating initial buffer failed");
        return (ARCHIVE_FATAL);
    }
    *(mine->current_buffer) = initial_buffer;
    *(mine->written) = 0;
    mine->current_size = OST_BUFSIZE;

    return (ARCHIVE_OK);
}

static int ost_mem_close(struct archive* a, void* client_data)
{
    struct ost_write_memory_data* mine = client_data;
    
    free(mine);
    return (ARCHIVE_OK);
}

static ssize_t ost_mem_write(struct archive* a, void* client_data, const void* buff, size_t length)
{
    struct ost_write_memory_data* mine = client_data;
    size_t remaining = mine->current_size - *mine->written;

    if (remaining < length) {
        /* the current buffer is too small, reallocate a bigger one */
        /* http://stackoverflow.com/questions/2269063 */
        size_t candidate_size = mine->current_size * 1.5;
        if (candidate_size - *mine->written < length) {
            candidate_size += length;
        }
        /* make sure we can fit the new buff in the new to-be-allocated buffer */
        assert(candidate_size - *mine->written >= length);

        /* resize the buffer */
        char* new_buffer = realloc(*mine->current_buffer, candidate_size);
        if (new_buffer == NULL) {
            archive_set_error(a, ENOMEM, "Resizing write buffer failed");
            return (-1);
        }

        /* management stuff: adjust the size and set the new buffer address */
        mine->current_size = candidate_size;
        *mine->current_buffer = new_buffer;
    }

    /* add the new data to the end of the old data */
    memcpy(*mine->current_buffer + *mine->written, buff, length);
    *mine->written += length;

    return (length);
}
