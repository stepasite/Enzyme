; RUN: if [ %llvmver -lt 16 ]; then %opt < %s %loadEnzyme -preserve-nvvm -enzyme -enzyme-preopt=false -mem2reg -simplifycfg -early-cse -S | FileCheck %s ; fi
; RUN: if [ %llvmver -ge 16 ]; then %opt < %s %newLoadEnzyme -passes="preserve-nvvm,enzyme,function(mem2reg,simplifycfg,early-cse)" -enzyme-preopt=false -S | FileCheck %s ; fi

source_filename = "exer2.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@__enzyme_register_splitderivative_add = dso_local local_unnamed_addr global [3 x i8*] [i8* bitcast (double (double, double)* @add to i8*), i8* bitcast ({ i8*, double, double } (double, double)* @add_aug to i8*), i8* bitcast ({ double, double } (double, double, double, double, i8*)* @add_err to i8*)], align 16

declare double @add(double %x, double %y) #0

declare { i8*, double, double } @add_aug(double %v1, double %v2)

declare { double, double } @add_err(double %v1, double %v1err, double %v2, double %v2err, i8* %tape)

; Function Attrs: norecurse nounwind readnone uwtable willreturn
define double @f(double %x) {
entry:
  %call = call double @add(double %x, double %x)
  ret double %call
}

; Function Attrs: nounwind uwtable
define double @caller(double %x, double %dx) {
entry:
  %call = call double (i8*, ...) @__enzyme_fwdsplit(i8* bitcast (double (double)* @f to i8*), double %x, double %dx, i8* null)
  ret double %call
}

declare dso_local double @__enzyme_fwdsplit(i8*, ...)

attributes #0 = { norecurse nounwind readnone }


; CHECK: define internal i8* @augmented_f(double %x, double %"x'")
; CHECK-NEXT: entry:
; CHECK-NEXT:   %malloccall = tail call noalias nonnull dereferenceable(8) dereferenceable_or_null(8) i8* @malloc(i64 8)
; CHECK-NEXT:   %tapemem = bitcast i8* %malloccall to i8**
; CHECK-NEXT:   %call_augmented = call { i8*, double, double } @add_aug(double %x, double %x)
; CHECK-NEXT:   %subcache = extractvalue { i8*, double, double } %call_augmented, 0
; CHECK-NEXT:   store i8* %subcache, i8** %tapemem
; CHECK-NEXT:   ret i8* %malloccall
; CHECK-NEXT: }

; CHECK: define internal double @fwddiffef(double %x, double %"x'", i8* %tapeArg1)
; CHECK-NEXT: entry:
; CHECK-NEXT:   %0 = call fast double @fixderivative_add(double %x, double %"x'", double %x, double %"x'", i8* %tapeArg1)
; CHECK-NEXT:   ret double %0
; CHECK-NEXT: }

; CHECK: define internal double @fixderivative_add(double %v1, double %v1err, double %v2, double %v2err, i8* %tape)
; CHECK-NEXT: entry:
; CHECK-NEXT:   %0 = call { double, double } @add_err(double %v1, double %v1err, double %v2, double %v2err, i8* %tape)
; CHECK-NEXT:   %1 = extractvalue { double, double } %0, 1
; CHECK-NEXT:   ret double %1
; CHECK-NEXT: }
