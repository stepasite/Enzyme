; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --include-generated-funcs
; RUN: if [ %llvmver -lt 16 ]; then %opt < %s %loadEnzyme -enzyme -enzyme-preopt=false -mem2reg -simplifycfg -S | FileCheck %s; fi
; RUN: if [ %llvmver -ge 16 ]; then %opt < %s %newLoadEnzyme -passes="enzyme,function(mem2reg,simplifycfg)" -enzyme-preopt=false -S | FileCheck %s; fi


@enzyme_width = external global i32, align 4
@enzyme_dupv = external global i32, align 4

define void @square(double* nocapture readonly %x, double* nocapture %out) {
entry:
  %0 = load double, double* %x, align 8
  %mul = fmul double %0, %0
  store double %mul, double* %out, align 8
  ret void
}

define void @dsquare(double* %x, double* %dx, double* %out, double* %dout) {
entry:
  %0 = load i32, i32* @enzyme_width, align 4
  %1 = load i32, i32* @enzyme_dupv, align 4
  call void (i8*, ...) @__enzyme_fwddiff(i8* bitcast (void (double*, double*)* @square to i8*), i32 %0, i32 3, i32 %1, i64 16, double* %x, double* %dx, i32 %1, i64 16, double* %out, double* %dout)
  ret void
}

declare void @__enzyme_fwddiff(i8*, ...)

; CHECK: define {{[^@]+}}@dsquare(double* [[X:%.*]], double* [[DX:%.*]], double* [[OUT:%.*]], double* [[DOUT:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = load i32, i32* @enzyme_width, align 4
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, i32* @enzyme_dupv, align 4
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast double* [[DX]] to i8*
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr i8, i8* [[TMP2]], i64 0
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast i8* [[TMP3]] to double*
; CHECK-NEXT:    [[TMP5:%.*]] = insertvalue [3 x double*] undef, double* [[TMP4]], 0
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast double* [[DX]] to i8*
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr i8, i8* [[TMP6]], i64 16
; CHECK-NEXT:    [[TMP8:%.*]] = bitcast i8* [[TMP7]] to double*
; CHECK-NEXT:    [[TMP9:%.*]] = insertvalue [3 x double*] [[TMP5]], double* [[TMP8]], 1
; CHECK-NEXT:    [[TMP10:%.*]] = bitcast double* [[DX]] to i8*
; CHECK-NEXT:    [[TMP11:%.*]] = getelementptr i8, i8* [[TMP10]], i64 32
; CHECK-NEXT:    [[TMP12:%.*]] = bitcast i8* [[TMP11]] to double*
; CHECK-NEXT:    [[TMP13:%.*]] = insertvalue [3 x double*] [[TMP9]], double* [[TMP12]], 2
; CHECK-NEXT:    [[TMP14:%.*]] = bitcast double* [[DOUT]] to i8*
; CHECK-NEXT:    [[TMP15:%.*]] = getelementptr i8, i8* [[TMP14]], i64 0
; CHECK-NEXT:    [[TMP16:%.*]] = bitcast i8* [[TMP15]] to double*
; CHECK-NEXT:    [[TMP17:%.*]] = insertvalue [3 x double*] undef, double* [[TMP16]], 0
; CHECK-NEXT:    [[TMP18:%.*]] = bitcast double* [[DOUT]] to i8*
; CHECK-NEXT:    [[TMP19:%.*]] = getelementptr i8, i8* [[TMP18]], i64 16
; CHECK-NEXT:    [[TMP20:%.*]] = bitcast i8* [[TMP19]] to double*
; CHECK-NEXT:    [[TMP21:%.*]] = insertvalue [3 x double*] [[TMP17]], double* [[TMP20]], 1
; CHECK-NEXT:    [[TMP22:%.*]] = bitcast double* [[DOUT]] to i8*
; CHECK-NEXT:    [[TMP23:%.*]] = getelementptr i8, i8* [[TMP22]], i64 32
; CHECK-NEXT:    [[TMP24:%.*]] = bitcast i8* [[TMP23]] to double*
; CHECK-NEXT:    [[TMP25:%.*]] = insertvalue [3 x double*] [[TMP21]], double* [[TMP24]], 2
; CHECK-NEXT:    call void @fwddiffe3square(double* [[X]], [3 x double*] [[TMP13]], double* [[OUT]], [3 x double*] [[TMP25]])
; CHECK-NEXT:    ret void
;
;
; CHECK: define {{[^@]+}}@fwddiffe3square(double* nocapture readonly [[X:%.*]], [3 x double*] %"x'", double* nocapture [[OUT:%.*]], [3 x double*] %"out'") 
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = extractvalue [3 x double*] %"x'", 0
; CHECK-NEXT:    %"'ipl" = load double, double* [[TMP0]], align 8
; CHECK-NEXT:    [[TMP1:%.*]] = insertvalue [3 x double] undef, double %"'ipl", 0
; CHECK-NEXT:    [[TMP2:%.*]] = extractvalue [3 x double*] %"x'", 1
; CHECK-NEXT:    %"'ipl1" = load double, double* [[TMP2]], align 8
; CHECK-NEXT:    [[TMP3:%.*]] = insertvalue [3 x double] [[TMP1]], double %"'ipl1", 1
; CHECK-NEXT:    [[TMP4:%.*]] = extractvalue [3 x double*] %"x'", 2
; CHECK-NEXT:    %"'ipl2" = load double, double* [[TMP4]], align 8
; CHECK-NEXT:    [[TMP5:%.*]] = insertvalue [3 x double] [[TMP3]], double %"'ipl2", 2
; CHECK-NEXT:    [[TMP6:%.*]] = load double, double* [[X]], align 8
; CHECK-NEXT:    [[MUL:%.*]] = fmul double [[TMP6]], [[TMP6]]
; CHECK-NEXT:    [[TMP9:%.*]] = fmul fast double %"'ipl", [[TMP6]]
; CHECK-NEXT:    [[TMP10:%.*]] = fmul fast double %"'ipl", [[TMP6]]
; CHECK-NEXT:    [[TMP11:%.*]] = fadd fast double [[TMP9]], [[TMP10]]
; CHECK-NEXT:    [[TMP12:%.*]] = insertvalue [3 x double] undef, double [[TMP11]], 0
; CHECK-NEXT:    [[TMP15:%.*]] = fmul fast double %"'ipl1", [[TMP6]]
; CHECK-NEXT:    [[TMP16:%.*]] = fmul fast double %"'ipl1", [[TMP6]]
; CHECK-NEXT:    [[TMP17:%.*]] = fadd fast double [[TMP15]], [[TMP16]]
; CHECK-NEXT:    [[TMP18:%.*]] = insertvalue [3 x double] [[TMP12]], double [[TMP17]], 1
; CHECK-NEXT:    [[TMP21:%.*]] = fmul fast double %"'ipl2", [[TMP6]]
; CHECK-NEXT:    [[TMP22:%.*]] = fmul fast double %"'ipl2", [[TMP6]]
; CHECK-NEXT:    [[TMP23:%.*]] = fadd fast double [[TMP21]], [[TMP22]]
; CHECK-NEXT:    [[TMP24:%.*]] = insertvalue [3 x double] [[TMP18]], double [[TMP23]], 2
; CHECK-NEXT:    store double [[MUL]], double* [[OUT]], align 8
; CHECK-NEXT:    [[TMP25:%.*]] = extractvalue [3 x double*] %"out'", 0
; CHECK-NEXT:    store double [[TMP11]], double* [[TMP25]], align 8
; CHECK-NEXT:    [[TMP27:%.*]] = extractvalue [3 x double*] %"out'", 1
; CHECK-NEXT:    store double [[TMP17]], double* [[TMP27]], align 8
; CHECK-NEXT:    [[TMP29:%.*]] = extractvalue [3 x double*] %"out'", 2
; CHECK-NEXT:    store double [[TMP23]], double* [[TMP29]], align 8
; CHECK-NEXT:    ret void
;
