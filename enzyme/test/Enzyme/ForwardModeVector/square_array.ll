; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function fwddiffe3squared --function-signature --include-generated-funcs
; RUN: if [ %llvmver -lt 16 ]; then %opt < %s %loadEnzyme -enzyme -enzyme-preopt=false -mem2reg -simplifycfg -early-cse -S | FileCheck %s; fi
; RUN: if [ %llvmver -ge 16 ]; then %opt < %s %newLoadEnzyme -passes="enzyme,function(mem2reg,simplifycfg,early-cse)" -enzyme-preopt=false -S | FileCheck %s; fi

%struct.Gradients = type { { double, double }, { double, double }, { double, double } }

define { double, double } @squared(double %x) {
entry:
  %mul = fmul double %x, %x
  %mul2 = fmul double %mul, %x
  %.fca.0.insert = insertvalue { double, double } undef, double %mul, 0
  %.fca.1.insert = insertvalue { double, double } %.fca.0.insert, double %mul2, 1
  ret { double, double } %.fca.1.insert
}

define %struct.Gradients @dsquared(double %x) {
entry:
  %call = call %struct.Gradients (i8*, ...) @__enzyme_fwddiff(i8* bitcast ({ double, double } (double)* @squared to i8*), metadata !"enzyme_width", i64 3, double %x, double 1.0, double 2.0, double 3.0)
  ret %struct.Gradients %call
}

declare %struct.Gradients @__enzyme_fwddiff(i8*, ...)

; CHECK: define {{[^@]+}}@fwddiffe3squared(double [[X:%.*]], [3 x double] %"x'")
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[MUL:%.*]] = fmul double [[X]], [[X]]
; CHECK-NEXT:    [[TMP0:%.*]] = extractvalue [3 x double] %"x'", 0
; CHECK-NEXT:    [[TMP1:%.*]] = fmul fast double [[TMP0]], [[X]]
; CHECK-NEXT:    [[TMP2:%.*]] = fadd fast double [[TMP1]], [[TMP1]]
; CHECK-NEXT:    [[TMP3:%.*]] = insertvalue [3 x double] undef, double [[TMP2]], 0
; CHECK-NEXT:    [[TMP4:%.*]] = extractvalue [3 x double] %"x'", 1
; CHECK-NEXT:    [[TMP5:%.*]] = fmul fast double [[TMP4]], [[X]]
; CHECK-NEXT:    [[TMP6:%.*]] = fadd fast double [[TMP5]], [[TMP5]]
; CHECK-NEXT:    [[TMP7:%.*]] = insertvalue [3 x double] [[TMP3]], double [[TMP6]], 1
; CHECK-NEXT:    [[TMP8:%.*]] = extractvalue [3 x double] %"x'", 2
; CHECK-NEXT:    [[TMP9:%.*]] = fmul fast double [[TMP8]], [[X]]
; CHECK-NEXT:    [[TMP10:%.*]] = fadd fast double [[TMP9]], [[TMP9]]
; CHECK-NEXT:    [[TMP12:%.*]] = fmul fast double [[TMP2]], [[X]]
; CHECK-NEXT:    [[TMP13:%.*]] = fmul fast double [[TMP0]], [[MUL]]
; CHECK-NEXT:    [[TMP14:%.*]] = fadd fast double [[TMP12]], [[TMP13]]
; CHECK-NEXT:    [[TMP15:%.*]] = insertvalue [3 x double] undef, double [[TMP14]], 0
; CHECK-NEXT:    [[TMP16:%.*]] = fmul fast double [[TMP6]], [[X]]
; CHECK-NEXT:    [[TMP17:%.*]] = fmul fast double [[TMP4]], [[MUL]]
; CHECK-NEXT:    [[TMP18:%.*]] = fadd fast double [[TMP16]], [[TMP17]]
; CHECK-NEXT:    [[TMP19:%.*]] = insertvalue [3 x double] [[TMP15]], double [[TMP18]], 1
; CHECK-NEXT:    [[TMP20:%.*]] = fmul fast double [[TMP10]], [[X]]
; CHECK-NEXT:    [[TMP21:%.*]] = fmul fast double [[TMP8]], [[MUL]]
; CHECK-NEXT:    [[TMP22:%.*]] = fadd fast double [[TMP20]], [[TMP21]]
; CHECK-NEXT:    %".fca.0.insert'ipiv" = insertvalue { double, double } zeroinitializer, double [[TMP2]], 0
; CHECK-NEXT:    [[TMP24:%.*]] = insertvalue [3 x { double, double }] undef, { double, double } %".fca.0.insert'ipiv", 0
; CHECK-NEXT:    %".fca.0.insert'ipiv1" = insertvalue { double, double } zeroinitializer, double [[TMP6]], 0
; CHECK-NEXT:    [[TMP25:%.*]] = insertvalue [3 x { double, double }] [[TMP24]], { double, double } %".fca.0.insert'ipiv1", 1
; CHECK-NEXT:    %".fca.0.insert'ipiv2" = insertvalue { double, double } zeroinitializer, double [[TMP10]], 0
; CHECK-NEXT:    %".fca.1.insert'ipiv" = insertvalue { double, double } %".fca.0.insert'ipiv", double [[TMP14]], 1
; CHECK-NEXT:    [[TMP27:%.*]] = insertvalue [3 x { double, double }] undef, { double, double } %".fca.1.insert'ipiv", 0
; CHECK-NEXT:    %".fca.1.insert'ipiv3" = insertvalue { double, double } %".fca.0.insert'ipiv1", double [[TMP18]], 1
; CHECK-NEXT:    [[TMP28:%.*]] = insertvalue [3 x { double, double }] [[TMP27]], { double, double } %".fca.1.insert'ipiv3", 1
; CHECK-NEXT:    %".fca.1.insert'ipiv4" = insertvalue { double, double } %".fca.0.insert'ipiv2", double [[TMP22]], 1
; CHECK-NEXT:    [[TMP29:%.*]] = insertvalue [3 x { double, double }] [[TMP28]], { double, double } %".fca.1.insert'ipiv4", 2
; CHECK-NEXT:    ret [3 x { double, double }] [[TMP29]]
;
