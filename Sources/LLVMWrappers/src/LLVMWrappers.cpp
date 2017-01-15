#define _DEBUG
#define _GNU_SOURCE
#define __STDC_CONSTANT_MACROS
#define __STDC_FORMAT_MACROS
#define __STDC_LIMIT_MACROS

#include <llvm/ExecutionEngine/ExecutionEngine.h>
#include <llvm/ExecutionEngine/RTDyldMemoryManager.h>
#include <llvm/ExecutionEngine/OrcMCJITReplacement.h>
#include <llvm/ExecutionEngine/SectionMemoryManager.h>
#include <llvm/Target/TargetMachine.h>

namespace llvm {

LLVMExecutionEngineRef LLVMCreateOrcMCJITReplacement(LLVMModuleRef module, LLVMTargetMachineRef targetRef) {
  auto target = reinterpret_cast<TargetMachine *>(targetRef);
  EngineBuilder builder(std::unique_ptr<Module>(unwrap(module)));
  builder.setMCJITMemoryManager(make_unique<SectionMemoryManager>());
  builder.setTargetOptions(target->Options);
  builder.setUseOrcMCJITReplacement(true);
  return wrap(builder.create());
}

}
