#include <stddef.h>
#include "llvm-c/Types.h"
#include "llvm-c/Object.h"
#include "llvm-c/DebugInfo.h"

#ifndef LLVMSWIFT_LLVM_SHIM_H
#define LLVMSWIFT_LLVM_SHIM_H

size_t LLVMSwiftCountIntrinsics(void);
const char *LLVMSwiftGetIntrinsicAtIndex(size_t index);
const char *LLVMGetARMCanonicalArchName(const char *Name, size_t NameLen);

typedef enum {
  LLVMARMProfileKindInvalid = 0,
  LLVMARMProfileKindA,
  LLVMARMProfileKindR,
  LLVMARMProfileKindM
} LLVMARMProfileKind;
LLVMARMProfileKind LLVMARMParseArchProfile(const char *Name, size_t NameLen);
unsigned LLVMARMParseArchVersion(const char *Name, size_t NameLen);

uint64_t LLVMGlobalGetGUID(LLVMValueRef Global);

void LLVMAddGlobalsAAWrapperPass(LLVMPassManagerRef PM);

typedef enum {
  LLVMTailCallKindNone,
  LLVMTailCallKindTail,
  LLVMTailCallKindMustTail,
  LLVMTailCallKindNoTail
} LLVMTailCallKind;

LLVMTailCallKind LLVMGetTailCallKind(LLVMValueRef CallInst);
void LLVMSetTailCallKind(LLVMValueRef CallInst, LLVMTailCallKind TCK);

#endif /* LLVMSWIFT_LLVM_SHIM_H */
