#ifndef _ITOA32_H_
#define _ITOA32_H_

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus

//#define BASE 10U
//#define BUFFER_SIZE_L 11U

extern char* itoa32(char* const buffer, int32_t val);
extern char* uitoa32(char* const buffer, uint32_t val);
extern void strrev(char* pLeft, uint8_t r_len);

#ifdef __cplusplus
}
#endif //__cplusplus

#endif
