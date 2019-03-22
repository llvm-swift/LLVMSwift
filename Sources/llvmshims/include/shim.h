#include <stddef.h>

#ifndef LLVMSWIFT_LLVM_SHIM_H
#define LLVMSWIFT_LLVM_SHIM_H

size_t LLVMSwiftCountIntrinsics(void);
const char *LLVMSwiftGetIntrinsicAtIndex(size_t index);
unsigned LLVMLookupIntrinsicID(const char *Name, size_t NameLen);


#endif /* LLVMSWIFT_LLVM_SHIM_H */
