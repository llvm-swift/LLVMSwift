#include "llvm-c/Object.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/ARMTargetParser.h"
#include "llvm/Object/MachOUniversal.h"
#include "llvm/Object/ObjectFile.h"
#include "llvm/ADT/SmallVector.h"

extern "C" {
  typedef struct LLVMOpaqueBinary *LLVMBinaryRef;

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

  typedef enum {
    LLVMBinaryTypeArchive,
    LLVMBinaryTypeMachOUniversalBinary,
    LLVMBinaryTypeCOFFImportFile,
    // LLVM IR
    LLVMBinaryTypeIR,
    LLVMBinaryTypeMinidump,

    // Windows resource (.res) file.
    LLVMBinaryTypeWinRes,

    // Object and children.
    LLVMBinaryTypeCOFF,

    // ELF 32-bit, little endian
    LLVMBinaryTypeELF32L,
    // ELF 32-bit, big endian
    LLVMBinaryTypeELF32B,
    // ELF 64-bit, little endian
    LLVMBinaryTypeELF64L,
    // ELF 64-bit, big endian
    LLVMBinaryTypeELF64B,

    // MachO 32-bit, little endian
    LLVMBinaryTypeMachO32L,
    // MachO 32-bit, big endian
    LLVMBinaryTypeMachO32B,
    // MachO 64-bit, little endian
    LLVMBinaryTypeMachO64L,
    // MachO 64-bit, big endian
    LLVMBinaryTypeMachO64B,

    LLVMBinaryTypeWasm,
  } LLVMBinaryType;

  LLVMBinaryType LLVMBinaryGetType(LLVMBinaryRef BR);
  LLVMBinaryRef LLVMCreateBinary(LLVMMemoryBufferRef MemBuf, LLVMContextRef Context, char **ErrorMessage);
  void LLVMDisposeBinary(LLVMBinaryRef BR);

  LLVMBinaryRef LLVMUniversalBinaryCopyObjectForArchitecture(LLVMBinaryRef BR, const char *Arch, size_t ArchLen, char **ErrorMessage);

  LLVMSectionIteratorRef LLVMObjectFileGetSections(LLVMBinaryRef BR);

  LLVMBool LLVMObjectFileIsSectionIteratorAtEnd(LLVMBinaryRef BR,
                                                LLVMSectionIteratorRef SI);
  LLVMSymbolIteratorRef LLVMObjectFileGetSymbols(LLVMBinaryRef BR);

  LLVMBool LLVMObjectFileIsSymbolIteratorAtEnd(LLVMBinaryRef BR,
                                               LLVMSymbolIteratorRef SI);
}

using namespace llvm;
using namespace llvm::object;

inline Binary *unwrap(LLVMBinaryRef OF) {
  return reinterpret_cast<Binary *>(OF);
}

inline static LLVMBinaryRef wrap(const Binary *OF) {
  return reinterpret_cast<LLVMBinaryRef>(const_cast<Binary *>(OF));
}

inline static section_iterator *unwrap(LLVMSectionIteratorRef SI) {
  return reinterpret_cast<section_iterator*>(SI);
}

inline static LLVMSectionIteratorRef
wrap(const section_iterator *SI) {
  return reinterpret_cast<LLVMSectionIteratorRef>
  (const_cast<section_iterator*>(SI));
}

inline static symbol_iterator *unwrap(LLVMSymbolIteratorRef SI) {
  return reinterpret_cast<symbol_iterator*>(SI);
}

inline static LLVMSymbolIteratorRef
wrap(const symbol_iterator *SI) {
  return reinterpret_cast<LLVMSymbolIteratorRef>
  (const_cast<symbol_iterator*>(SI));
}

LLVMBinaryType LLVMBinaryGetType(LLVMBinaryRef BR) {
  switch (unwrap(BR)->getType()) {
  case 0: //ID_Archive:
    return LLVMBinaryTypeArchive;
  case 1: //ID_MachOUniversalBinary:
    return LLVMBinaryTypeMachOUniversalBinary;
  case 2: //ID_COFFImportFile:
    return LLVMBinaryTypeCOFFImportFile;
  case 3: //ID_IR:
    return LLVMBinaryTypeIR;
  case 4: //ID_Minidump:
    return LLVMBinaryTypeMinidump;
  case 5: //ID_WinRes:
    return LLVMBinaryTypeWinRes;
  case 7: //ID_COFF:
    return LLVMBinaryTypeCOFF;
  case 8: //ID_ELF32L:
    return LLVMBinaryTypeELF32L;
  case 9: //ID_ELF32B:
    return LLVMBinaryTypeELF32B;
  case 10: //ID_ELF64L:
    return LLVMBinaryTypeELF64L;
  case 11: //ID_ELF64B:
    return LLVMBinaryTypeELF64B;
  case 12: //ID_MachO32L:
    return LLVMBinaryTypeMachO32L;
  case 13: //ID_MachO32B:
    return LLVMBinaryTypeMachO32B;
  case 14: //ID_MachO64L:
    return LLVMBinaryTypeMachO64L;
  case 15: //ID_MachO64B:
    return LLVMBinaryTypeMachO64B;
  case 16: //ID_Wasm:
    return LLVMBinaryTypeWasm;
  default:
    llvm_unreachable("Unknown binary kind!");
  }
}

LLVMBinaryRef LLVMCreateBinary(LLVMMemoryBufferRef MemBuf, LLVMContextRef Context, char **ErrorMessage) {
  Expected<std::unique_ptr<Binary>> ObjOrErr(
    createBinary(unwrap(MemBuf)->getMemBufferRef(), unwrap(Context)));
  if (!ObjOrErr) {
    *ErrorMessage = strdup(toString(ObjOrErr.takeError()).c_str());
    return nullptr;
  }

  return wrap(ObjOrErr.get().release());
}

void LLVMDisposeBinary(LLVMBinaryRef BR) {
  delete unwrap(BR);
}

LLVMBinaryRef LLVMUniversalBinaryCopyObjectForArchitecture(LLVMBinaryRef BR, const char *Arch, size_t ArchLen, char **ErrorMessage) {
  assert(LLVMBinaryGetType(BR) == LLVMBinaryTypeMachOUniversalBinary);
  auto universal = cast<MachOUniversalBinary>(unwrap(BR));
  Expected<std::unique_ptr<ObjectFile>> ObjOrErr(
    universal->getObjectForArch({Arch, ArchLen}));
  if (!ObjOrErr) {
    *ErrorMessage = strdup(toString(ObjOrErr.takeError()).c_str());
    return nullptr;
  }
  return wrap(ObjOrErr.get().release());
}

LLVMSectionIteratorRef LLVMObjectFileGetSections(LLVMBinaryRef BR) {
  auto OF = cast<ObjectFile>(unwrap(BR));
  section_iterator SI = OF->section_begin();
  return wrap(new section_iterator(SI));
}

LLVMBool LLVMObjectFileIsSectionIteratorAtEnd(LLVMBinaryRef BR,
                                              LLVMSectionIteratorRef SI) {
  auto OF = cast<ObjectFile>(unwrap(BR));
  return (*unwrap(SI) == OF->section_end()) ? 1 : 0;
}

LLVMSymbolIteratorRef LLVMObjectFileGetSymbols(LLVMBinaryRef BR) {
  auto OF = cast<ObjectFile>(unwrap(BR));
  symbol_iterator SI = OF->symbol_begin();
  return wrap(new symbol_iterator(SI));
}

LLVMBool LLVMObjectFileIsSymbolIteratorAtEnd(LLVMBinaryRef BR,
                                             LLVMSymbolIteratorRef SI) {
  auto OF = cast<ObjectFile>(unwrap(BR));
  return (*unwrap(SI) == OF->symbol_end()) ? 1 : 0;
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


