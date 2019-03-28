#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/ARMTargetParser.h"

extern "C" {
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

LLVMARMProfileKind LLVMARMParseArchProfile(const char *Name, size_t NameLen) {
  return static_cast<LLVMARMProfileKind>(llvm::ARM::parseArchProfile({Name, NameLen}));
}

unsigned LLVMARMParseArchVersion(const char *Name, size_t NameLen) {
  return llvm::ARM::parseArchVersion({Name, NameLen});
}

const char *LLVMGetARMCanonicalArchName(const char *Name, size_t NameLen) {
  return llvm::ARM::getCanonicalArchName({Name, NameLen}).data();
}
