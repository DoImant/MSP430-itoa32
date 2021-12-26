#ifndef _ITOA32_H_
#define _ITOA32_H_

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus

extern char* itoa32(char* const strBuf, int32_t val);
extern char* uitoa32(char* const strBuf, uint32_t val);
extern void strrev(char* pLeft, uint8_t r_len);

#ifdef __cplusplus
}
#endif //__cplusplus

#endif
