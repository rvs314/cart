#include <algorithm>
#include <cctype>
#include <cstdio>
#include <cstdlib>
#include <llvm/ADT/APFloat.h>
#include <llvm/ADT/STLExtras.h>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/Verifier.h>
#include <map>
#include <memory>
#include <string>
#include <vector>

using namespace llvm;

static std::unique_ptr<LLVMContext> TheContext;

int main(void) {
  ConstantFP *b = ConstantFP::get(*TheContext, APFloat(2.0));
  printf("b: %f\n", b->getValue().convertToFloat());
}
