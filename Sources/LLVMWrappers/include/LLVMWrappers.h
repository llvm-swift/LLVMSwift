#ifndef LLVMWrappers_h
#define LLVMWrappers_h

#ifdef __cplusplus
extern "C" {
#endif

void *_Nullable LLVMCreateOrcMCJITReplacement(void *_Nonnull module,
																							void *_Nonnull targetRef);
void LLVMLinkInOrcMCJITReplacement(void);

#ifdef __cplusplus
}
#endif

#endif /* LLVMWrappers_hpp */
