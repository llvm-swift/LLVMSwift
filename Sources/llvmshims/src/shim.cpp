#include "llvm-c/Object.h"
#include "llvm/IR/DebugInfo.h"
#include "llvm/IR/DIBuilder.h"
#include "llvm-c/Core.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/ARMTargetParser.h"
#include "llvm/Object/MachOUniversal.h"
#include "llvm/Object/ObjectFile.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Transforms/Utils.h"
#include "llvm/Transforms/IPO.h"

extern "C" {
  typedef struct LLVMOpaqueBinary *LLVMBinaryRef;

  // https://reviews.llvm.org/D59697
  unsigned LLVMLookupIntrinsicID(const char *Name, size_t NameLen);

  // Not to be upstreamed: They support the hacks that power our dynamic member
  // lookup machinery for intrinsics.
  const char *LLVMSwiftGetIntrinsicAtIndex(size_t index);
  size_t LLVMSwiftCountIntrinsics(void);

  // Not to be upstreamed: There's no value in this without a full Triple
  // API.  And we have chosen to port instead of wrap.
  const char *LLVMGetARMCanonicalArchName(const char *Name, size_t NameLen);

  typedef enum {
    LLVMARMProfileKindInvalid = 0,
    LLVMARMProfileKindA,
    LLVMARMProfileKindR,
    LLVMARMProfileKindM
  } LLVMARMProfileKind;

  LLVMARMProfileKind LLVMARMParseArchProfile(const char *Name, size_t NameLen);
  unsigned LLVMARMParseArchVersion(const char *Name, size_t NameLen);

  // https://reviews.llvm.org/D60366
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

  LLVMBinaryType LLVMBinaryGetType(LLVMBinaryRef BR);

  // https://reviews.llvm.org/D60322
  LLVMBinaryRef LLVMCreateBinary(LLVMMemoryBufferRef MemBuf, LLVMContextRef Context, char **ErrorMessage);
  LLVMMemoryBufferRef LLVMBinaryCopyMemoryBuffer(LLVMBinaryRef BR);
  void LLVMDisposeBinary(LLVMBinaryRef BR);

  // https://reviews.llvm.org/D60378
  LLVMBinaryRef LLVMUniversalBinaryCopyObjectForArchitecture(LLVMBinaryRef BR, const char *Arch, size_t ArchLen, char **ErrorMessage);

  // https://reviews.llvm.org/D60407
  LLVMSectionIteratorRef LLVMObjectFileCopySectionIterator(LLVMBinaryRef BR);

  LLVMBool LLVMObjectFileIsSectionIteratorAtEnd(LLVMBinaryRef BR,
                                                LLVMSectionIteratorRef SI);
  LLVMSymbolIteratorRef LLVMObjectFileCopySymbolIterator(LLVMBinaryRef BR);

  LLVMBool LLVMObjectFileIsSymbolIteratorAtEnd(LLVMBinaryRef BR,
                                               LLVMSymbolIteratorRef SI);

  // https://reviews.llvm.org/D60481
  LLVMMetadataRef LLVMInstructionGetDebugLoc(LLVMValueRef Inst);
  void LLVMInstructionSetDebugLoc(LLVMValueRef Inst, LLVMMetadataRef Loc);

  // https://reviews.llvm.org/D60484
  LLVMMetadataRef LLVMGetCurrentDebugLocation2(LLVMBuilderRef Builder);
  void LLVMSetCurrentDebugLocation2(LLVMBuilderRef Builder, LLVMMetadataRef Loc);

  // https://reviews.llvm.org/D60489
  LLVMMetadataRef LLVMDIScopeGetFile(LLVMMetadataRef Scope);
  const char *LLVMDIFileGetDirectory(LLVMMetadataRef File, unsigned *Len);
  const char *LLVMDIFileGetFilename(LLVMMetadataRef File, unsigned *Len);
  const char *LLVMDIFileGetSource(LLVMMetadataRef File, unsigned *Len);

  // https://reviews.llvm.org/D60527
  void LLVMBuilderSetDefaultFPMathTag(LLVMBuilderRef Builder,
                                      LLVMMetadataRef FPMathTag);
  LLVMMetadataRef LLVMBuilderGetDefaultFPMathTag(LLVMBuilderRef Builder);

  // https://reviews.llvm.org/D60524
  LLVMMetadataRef LLVMMDNodeInContext2(LLVMContextRef C, LLVMMetadataRef *MDs,
                                       unsigned Count);

  // Not to be upstreamed: It's not clear there's value in having this outside
  // of PGO passes.
  uint64_t LLVMGlobalGetGUID(LLVMValueRef Global);

  // https://reviews.llvm.org/D59658
  void LLVMAppendExistingBasicBlock(LLVMValueRef Fn,
                                    LLVMBasicBlockRef BB);

  // https://reviews.llvm.org/D58624
  void LLVMAddAddDiscriminatorsPass(LLVMPassManagerRef PM);

  // https://reviews.llvm.org/D62456
  void LLVMAddInternalizePassWithMustPreservePredicate(
   LLVMPassManagerRef PM, void *Context,
   LLVMBool (*MustPreserve)(LLVMValueRef, void *));
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
  class BinaryTypeMapper final : public Binary {
  public:
    static LLVMBinaryType mapBinaryTypeToLLVMBinaryType(unsigned Kind) {
      switch (Kind) {
      case ID_Archive:
        return LLVMBinaryTypeArchive;
      case ID_MachOUniversalBinary:
        return LLVMBinaryTypeMachOUniversalBinary;
      case ID_COFFImportFile:
        return LLVMBinaryTypeCOFFImportFile;
      case ID_IR:
        return LLVMBinaryTypeIR;
      case ID_WinRes:
        return LLVMBinaryTypeWinRes;
      case ID_COFF:
        return LLVMBinaryTypeCOFF;
      case ID_ELF32L:
        return LLVMBinaryTypeELF32L;
      case ID_ELF32B:
        return LLVMBinaryTypeELF32B;
      case ID_ELF64L:
        return LLVMBinaryTypeELF64L;
      case ID_ELF64B:
        return LLVMBinaryTypeELF64B;
      case ID_MachO32L:
        return LLVMBinaryTypeMachO32L;
      case ID_MachO32B:
        return LLVMBinaryTypeMachO32B;
      case ID_MachO64L:
        return LLVMBinaryTypeMachO64L;
      case ID_MachO64B:
        return LLVMBinaryTypeMachO64B;
      case ID_Wasm:
        return LLVMBinaryTypeWasm;
      default:
        llvm_unreachable("Unknown binary kind!");
      }
    }
  };
  return BinaryTypeMapper::mapBinaryTypeToLLVMBinaryType(unwrap(BR)->getType());
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

LLVMMemoryBufferRef LLVMBinaryCopyMemoryBuffer(LLVMBinaryRef BR) {
  auto Buf = unwrap(BR)->getMemoryBufferRef();
  return wrap(llvm::MemoryBuffer::getMemBuffer(
                Buf.getBuffer(), Buf.getBufferIdentifier(),
                /*RequiresNullTerminator*/false).release());
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

LLVMSectionIteratorRef LLVMObjectFileCopySectionIterator(LLVMBinaryRef BR) {
  auto OF = cast<ObjectFile>(unwrap(BR));
  auto sections = OF->sections();
  if (sections.begin() == sections.end())
    return nullptr;
  return wrap(new section_iterator(sections.begin()));
}

LLVMBool LLVMObjectFileIsSectionIteratorAtEnd(LLVMBinaryRef BR,
                                              LLVMSectionIteratorRef SI) {
  auto OF = cast<ObjectFile>(unwrap(BR));
  return (*unwrap(SI) == OF->section_end()) ? 1 : 0;
}

LLVMSymbolIteratorRef LLVMObjectFileCopySymbolIterator(LLVMBinaryRef BR) {
  auto OF = cast<ObjectFile>(unwrap(BR));
  auto symbols = OF->symbols();
  if (symbols.begin() == symbols.end())
    return nullptr;
  return wrap(new symbol_iterator(symbols.begin()));
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

LLVMMetadataRef LLVMInstructionGetDebugLoc(LLVMValueRef Inst) {
  return wrap(unwrap<Instruction>(Inst)->getDebugLoc().getAsMDNode());
}

void LLVMInstructionSetDebugLoc(LLVMValueRef Inst, LLVMMetadataRef Loc) {
  if (Loc)
    unwrap<Instruction>(Inst)->setDebugLoc(DebugLoc(unwrap<MDNode>(Loc)));
  else
    unwrap<Instruction>(Inst)->setDebugLoc(DebugLoc());
}

LLVMMetadataRef LLVMGetCurrentDebugLocation2(LLVMBuilderRef Builder) {
  return wrap(unwrap(Builder)->getCurrentDebugLocation().getAsMDNode());
}

void LLVMSetCurrentDebugLocation2(LLVMBuilderRef Builder, LLVMMetadataRef Loc) {
  if (Loc)
    unwrap(Builder)->SetCurrentDebugLocation(DebugLoc(unwrap<MDNode>(Loc)));
  else
    unwrap(Builder)->SetCurrentDebugLocation(DebugLoc());
}

const char *LLVMDIFileGetDirectory(LLVMMetadataRef File, unsigned *Len) {
  auto Dir = unwrap<DIFile>(File)->getDirectory();
  *Len = Dir.size();
  return Dir.data();
}

const char *LLVMDIFileGetFilename(LLVMMetadataRef File, unsigned *Len) {
  auto Dir = unwrap<DIFile>(File)->getFilename();
  *Len = Dir.size();
  return Dir.data();
}

const char *LLVMDIFileGetSource(LLVMMetadataRef File, unsigned *Len) {
  if (auto Dir = unwrap<DIFile>(File)->getSource()) {
    *Len = Dir->size();
    return Dir->data();
  }
  *Len = 0;
  return "";
}

LLVMMetadataRef LLVMDIScopeGetFile(LLVMMetadataRef Scope) {
  return wrap(unwrap<DIScope>(Scope)->getFile());
}

void LLVMBuilderSetDefaultFPMathTag(LLVMBuilderRef Builder,
                                    LLVMMetadataRef FPMathTag) {

  unwrap(Builder)->setDefaultFPMathTag(FPMathTag
                                       ? unwrap<MDNode>(FPMathTag)
                                       : nullptr);
}

LLVMMetadataRef LLVMBuilderGetDefaultFPMathTag(LLVMBuilderRef Builder) {
  return wrap(unwrap(Builder)->getDefaultFPMathTag());
}

LLVMMetadataRef LLVMMDNodeInContext2(LLVMContextRef C, LLVMMetadataRef *MDs,
                                     unsigned Count) {
  return wrap(MDNode::get(*unwrap(C), ArrayRef<Metadata*>(unwrap(MDs), Count)));
}

uint64_t LLVMGlobalGetGUID(LLVMValueRef Glob) {
  return unwrap<GlobalValue>(Glob)->getGUID();
}

void LLVMAppendExistingBasicBlock(LLVMValueRef Fn,
                                  LLVMBasicBlockRef BB) {
  unwrap<Function>(Fn)->getBasicBlockList().push_back(unwrap(BB));
}

void LLVMAddAddDiscriminatorsPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createAddDiscriminatorsPass());
}

void LLVMAddInternalizePassWithMustPreservePredicate(
  LLVMPassManagerRef PM, void *Context,
  LLVMBool (*Pred)(LLVMValueRef, void *)) {
  unwrap(PM)->add(createInternalizePass([=](const GlobalValue &GV) {
    return Pred(wrap(&GV), Context) == 0 ? false : true;
  }));
}
