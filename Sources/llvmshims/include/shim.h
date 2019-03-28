#include <stddef.h>

#ifndef LLVMSWIFT_LLVM_SHIM_H
#define LLVMSWIFT_LLVM_SHIM_H

size_t LLVMSwiftCountIntrinsics(void);
const char *LLVMSwiftGetIntrinsicAtIndex(size_t index);
unsigned LLVMLookupIntrinsicID(const char *Name, size_t NameLen);
const char *LLVMGetARMCanonicalArchName(const char *Name, size_t NameLen);

typedef enum {
  LLVMARMProfileKindInvalid = 0,
  LLVMARMProfileKindA,
  LLVMARMProfileKindR,
  LLVMARMProfileKindM
} LLVMARMProfileKind;
LLVMARMProfileKind LLVMARMParseArchProfile(const char *Name, size_t NameLen);
unsigned LLVMARMParseArchVersion(const char *Name, size_t NameLen);

#endif /* LLVMSWIFT_LLVM_SHIM_H */
