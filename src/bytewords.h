#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

// A very short-lived native function.
//
// For very short-lived functions, it is fine to call them on the main isolate.
// They will block the Dart execution while running the native function, so
// only do this for native functions which are guaranteed to be short-lived.
FFI_PLUGIN_EXPORT intptr_t sum(intptr_t a, intptr_t b);

// A longer lived native function, which occupies the thread calling it.
//
// Do not call these kind of native functions in the main isolate. They will
// block Dart execution. This will cause dropped frames in Flutter applications.
// Instead, call these native functions on a separate isolate.
FFI_PLUGIN_EXPORT intptr_t sum_long_running(intptr_t a, intptr_t b);

//
//  bc-bytewords.h
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

#ifndef BC_BYTEWORDS_H
#define BC_BYTEWORDS_H

#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum bw_style_e {
    bw_standard,
    bw_uri,
    bw_minimal
} bw_style;

// Encodes `in_buf` as a Bytewords string according to `style`.
//
// Arguments:
//    `style`: The style of the output string.
//    `in_buf`: The buffer of bytes to be encoded.
//    `in_len`: The number of bytes to be encoded.
//
// Returns:
//    A string containing the encoded words. The number of words will be
//    `in_len` + 4 including the 4-byte checksum.
//
// **Note:** The caller is responsible for calling free() on the returned string.
FFI_PLUGIN_EXPORT char* bytewords_encode(bw_style style, const uint8_t* in_buf, size_t in_len);

// Decodes `in_string` in the bytewords format specified by `style`.
//
// Arguments:
//    `style`: The style of the input string.
//    `in_string`: The string to be decoded.
//    `out_buf`: Where to store the decoded bytes.
//    `out_len`: The number of bytes decoded.
//
// Returns:
//    True upon a successful decode, false otherwise.
//
// **Note:** The caller is responsible for calling free() on the returned `out_buf`.
// The memory pointed to `out_buf` and `out_len` will not be changed if the decode fails.
FFI_PLUGIN_EXPORT bool bytewords_decode(bw_style style, const char* in_string, uint8_t** out_buf, size_t* out_len);

// Get byteword at specified index
// Arguments:
//    `index`: index in byteword list
//    `word`: byteword at that index (allocate 5 bytes)
FFI_PLUGIN_EXPORT void bytewords_get_word(uint8_t index, char* word);

#ifdef __cplusplus
}
#endif

#endif // BC_BYTEWORDS_H