#include <stddef.h>
#include "llvm-c/Types.h"
#include "llvm-c/Object.h"

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

typedef struct LLVMOpaqueBinary *LLVMBinaryRef;

LLVMBinaryType LLVMBinaryGetType(LLVMBinaryRef BR);
LLVMBinaryRef LLVMCreateBinary(LLVMMemoryBufferRef MemBuf, LLVMContextRef Context);
void LLVMDisposeBinary(LLVMBinaryRef BR);

LLVMBinaryRef LLVMUniversalBinaryGetObjectForArchitecture(LLVMBinaryRef BR, const char *Arch, size_t ArchLen);

LLVMSectionIteratorRef LLVMObjectFileGetSections(LLVMBinaryRef BR);

LLVMBool LLVMObjectFileIsSectionIteratorAtEnd(LLVMBinaryRef BR,
                                              LLVMSectionIteratorRef SI);
LLVMSymbolIteratorRef LLVMObjectFileGetSymbols(LLVMBinaryRef BR);

LLVMBool LLVMObjectFileIsSymbolIteratorAtEnd(LLVMBinaryRef BR,
                                             LLVMSymbolIteratorRef SI);

#endif /* LLVMSWIFT_LLVM_SHIM_H */
