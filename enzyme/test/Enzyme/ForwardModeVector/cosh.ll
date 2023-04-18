; RUN: if [ %llvmver -lt 16 ]; then %opt < %s %loadEnzyme -enzyme -enzyme-preopt=false -mem2reg -instsimplify -simplifycfg -S | FileCheck %s; fi
; RUN: %opt < %s %newLoadEnzyme -passes="enzyme,function(mem2reg,instsimplify,simplifycfg)" -enzyme-preopt=false -S | FileCheck %s

%struct.Gradients = type { double, double }

; Function Attrs: nounwind
declare %struct.Gradients @__enzyme_fwddiff(double (double)*, ...)

; Function Attrs: nounwind readnone uwtable
define double @tester(double %x) {
entry:
  %0 = tail call fast double @cosh(double %x)
  ret double %0
}

define %struct.Gradients @test_derivative(double %x) {
entry:
  %0 = tail call %struct.Gradients (double (double)*, ...) @__enzyme_fwddiff(double (double)* nonnull @tester, metadata !"enzyme_width", i64 2, double %x, double 0.000000e+00, double 1.000000e+00)
  ret %struct.Gradients %0
}

; Function Attrs: nounwind readnone speculatable
declare double @cosh(double)


; CHECK: define internal [2 x double] @fwddiffe2tester(double %x, [2 x double] %"x'")
; CHECK-NEXT: entry:
; CHECK-NEXT:   %0 = call fast double @sinh(double %x)
; CHECK-NEXT:   %1 = extractvalue [2 x double] %"x'", 0
; CHECK-NEXT:   %2 = fmul fast double %1, %0
; CHECK-NEXT:   %[[i4:.+]] = extractvalue [2 x double] %"x'", 1
; CHECK-NEXT:   %[[i5:.+]] = fmul fast double %[[i4]], %0
; CHECK-NEXT:   %[[i3:.+]] = insertvalue [2 x double] undef, double %2, 0
; CHECK-NEXT:   %[[i6:.+]] = insertvalue [2 x double] %[[i3]], double %[[i5]], 1
; CHECK-NEXT:   ret [2 x double] %[[i6]]
; CHECK-NEXT: }
