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
LLVMBinaryRef LLVMCreateBinary(LLVMMemoryBufferRef MemBuf, LLVMContextRef Context, char **ErrorMessage);
LLVMMemoryBufferRef LLVMBinaryCopyMemoryBuffer(LLVMBinaryRef BR);
void LLVMDisposeBinary(LLVMBinaryRef BR);

LLVMBinaryRef LLVMUniversalBinaryCopyObjectForArchitecture(LLVMBinaryRef BR, const char *Arch, size_t ArchLen, char **ErrorMessage);

LLVMSectionIteratorRef LLVMObjectFileCopySectionIterator(LLVMBinaryRef BR);

LLVMBool LLVMObjectFileIsSectionIteratorAtEnd(LLVMBinaryRef BR,
                                              LLVMSectionIteratorRef SI);
LLVMSymbolIteratorRef LLVMObjectFileCopySymbolIterator(LLVMBinaryRef BR);

LLVMBool LLVMObjectFileIsSymbolIteratorAtEnd(LLVMBinaryRef BR,
                                             LLVMSymbolIteratorRef SI);

LLVMMetadataRef LLVMInstructionGetDebugLoc(LLVMValueRef Inst);
void LLVMInstructionSetDebugLoc(LLVMValueRef Inst, LLVMMetadataRef Loc);

LLVMMetadataRef LLVMGetCurrentDebugLocation2(LLVMBuilderRef Builder);
void LLVMSetCurrentDebugLocation2(LLVMBuilderRef Builder, LLVMMetadataRef Loc);

LLVMMetadataRef LLVMDIScopeGetFile(LLVMMetadataRef Scope);
const char *LLVMDIFileGetDirectory(LLVMMetadataRef File, unsigned *Len);
const char *LLVMDIFileGetFilename(LLVMMetadataRef File, unsigned *Len);
const char *LLVMDIFileGetSource(LLVMMetadataRef File, unsigned *Len);

#endif /* LLVMSWIFT_LLVM_SHIM_H */
