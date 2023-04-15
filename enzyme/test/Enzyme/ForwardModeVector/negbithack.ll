; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --include-generated-funcs
; RUN: if [ %llvmver -lt 16 ]; then %opt < %s %loadEnzyme -enzyme -enzyme-preopt=false -mem2reg -instsimplify -simplifycfg -S | FileCheck %s; fi
; RUN: if [ %llvmver -ge 16 ]; then %opt < %s %newLoadEnzyme -passes="enzyme,function(mem2reg,instsimplify,simplifycfg)" -enzyme-preopt=false -S | FileCheck %s; fi

%struct.Gradients = type { double, double, double }

; Function Attrs: noinline nounwind readnone uwtable
define double @tester(double %x) {
entry:
  %cstx = bitcast double %x to i64
  %negx = xor i64 %cstx, -9223372036854775808
  %csty = bitcast i64 %negx to double
  ret double %csty
}

define %struct.Gradients @test_derivative(double %x, double %dx1, double %dx2, double %dx3) {
entry:
  %0 = tail call %struct.Gradients (double (double)*, ...) @__enzyme_fwddiff(double (double)* nonnull @tester, metadata !"enzyme_width", i64 3, double %x, double %dx1, double %dx2, double %dx3)
  ret %struct.Gradients %0
}

; Function Attrs: nounwind
declare %struct.Gradients @__enzyme_fwddiff(double (double)*, ...)

; CHECK: define {{[^@]+}}@fwddiffe3tester(double [[X:%.*]], [3 x double] %"x'")
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = extractvalue [3 x double] %"x'", 0
; CHECK-NEXT:    [[TMP1:%.*]] = extractvalue [3 x double] %"x'", 1
; CHECK-NEXT:    [[TMP2:%.*]] = extractvalue [3 x double] %"x'", 2
; CHECK-NEXT:    [[TMP3:%.*]] = {{(fsub fast double \-0.000000e\+00,|fneg fast double)}} [[TMP0]]
; CHECK-NEXT:    [[TMP4:%.*]] = {{(fsub fast double \-0.000000e\+00,|fneg fast double)}} [[TMP1]]
; CHECK-NEXT:    [[TMP5:%.*]] = {{(fsub fast double \-0.000000e\+00,|fneg fast double)}} [[TMP2]]
; CHECK-NEXT:    [[TMP6:%.*]] = insertvalue [3 x double] undef, double [[TMP3]], 0
; CHECK-NEXT:    [[TMP7:%.*]] = insertvalue [3 x double] [[TMP6]], double [[TMP4]], 1
; CHECK-NEXT:    [[TMP8:%.*]] = insertvalue [3 x double] [[TMP7]], double [[TMP5]], 2
; CHECK-NEXT:    ret [3 x double] [[TMP8]]
;
