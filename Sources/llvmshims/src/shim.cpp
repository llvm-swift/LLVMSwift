#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/Function.h"

extern "C" {
  size_t LLVMSwiftCountIntrinsics(void);
  const char *LLVMSwiftGetIntrinsicAtIndex(size_t index);
  unsigned LLVMLookupIntrinsicID(const char *Name, size_t NameLen);
}

size_t LLVMSwiftCountIntrinsics(void) {
  return llvm::Intrinsic::num_intrinsics;
}

const char *LLVMSwiftGetIntrinsicAtIndex(size_t index) {
  return llvm::Intrinsic::getName(static_cast<llvm::Intrinsic::ID>(index)).data();
}

unsigned LLVMLookupIntrinsicID(const char *Name, size_t NameLen) {
  return llvm::Function::lookupIntrinsicID({Name, NameLen});
}
