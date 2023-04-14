; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --include-generated-funcs
; RUN: if [ %llvmver -lt 16 ]; %opt < %s %loadEnzyme -enzyme -enzyme-preopt=false -mem2reg -sroa -instsimplify -adce -correlated-propagation -simplifycfg -S | FileCheck %s; fi
; RUN: if [ %llvmver -ge 16 ]; %opt < %s %newLoadEnzyme -passes="enzyme,function(mem2reg,sroa,instsimplify,adce,correlated-propagation,simplifycfg)" -enzyme-preopt=false -S | FileCheck %s; fi

%struct.Gradients = type { double*, double*, double* }

; Function Attrs: nounwind
declare %struct.Gradients @__enzyme_fwddiff(i8*, ...)


; Function Attrs: noinline norecurse nounwind uwtable
define dso_local zeroext i1 @metasubf(double* nocapture %x) local_unnamed_addr #0 {
entry:
  %arrayidx = getelementptr inbounds double, double* %x, i64 1
  store double 3.000000e+00, double* %arrayidx, align 8
  %0 = load double, double* %x, align 8
  %cmp = fcmp fast oeq double %0, 2.000000e+00
  ret i1 %cmp
}

; Function Attrs: noinline norecurse nounwind uwtable
define dso_local zeroext i1 @othermetasubf(double* nocapture %x) local_unnamed_addr #0 {
entry:
  %arrayidx = getelementptr inbounds double, double* %x, i64 1
  store double 4.000000e+00, double* %arrayidx, align 8
  %0 = load double, double* %x, align 8
  %cmp = fcmp fast oeq double %0, 3.000000e+00
  ret i1 %cmp
}

; Function Attrs: noinline norecurse nounwind uwtable
define dso_local zeroext i1 @subf(double* nocapture %x) local_unnamed_addr #0 {
entry:
  %0 = load double, double* %x, align 8
  %mul = fmul fast double %0, 2.000000e+00
  store double %mul, double* %x, align 8
  %call = tail call zeroext i1 @metasubf(double* %x)
  %call1 = tail call zeroext i1 @othermetasubf(double* %x)
  %res = and i1 %call, %call1
  ret i1 %res
}

; Function Attrs: noinline norecurse nounwind uwtable
define dso_local void @f(double* nocapture %x) #0 {
entry:
  %call = tail call zeroext i1 @subf(double* %x)
  store double 2.000000e+00, double* %x, align 8
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local %struct.Gradients @dsumsquare(double* %x, double* %xp1, double* %xp2, double* %xp3) local_unnamed_addr #1 {
entry:
  %call = tail call %struct.Gradients (i8*, ...) @__enzyme_fwddiff(i8* bitcast (void (double*)* @f to i8*), metadata !"enzyme_width", i64 3, double* %x, double* %xp1, double* %xp2, double* %xp3)
  ret %struct.Gradients %call
}

; CHECK: define {{[^@]+}}@fwddiffe3f(double* nocapture [[X:%.*]], [3 x double*] %"x'")
; CHECK-NEXT:  entry:
; CHECK-NEXT:    call void @fwddiffe3subf(double* [[X]], [3 x double*] %"x'")
; CHECK-NEXT:    store double 2.000000e+00, double* [[X]], align 8
; CHECK-NEXT:    [[TMP0:%.*]] = extractvalue [3 x double*] %"x'", 0
; CHECK-NEXT:    store double 0.000000e+00, double* [[TMP0]], align 8
; CHECK-NEXT:    [[TMP1:%.*]] = extractvalue [3 x double*] %"x'", 1
; CHECK-NEXT:    store double 0.000000e+00, double* [[TMP1]], align 8
; CHECK-NEXT:    [[TMP2:%.*]] = extractvalue [3 x double*] %"x'", 2
; CHECK-NEXT:    store double 0.000000e+00, double* [[TMP2]], align 8
; CHECK-NEXT:    ret void
;
;
; CHECK: define {{[^@]+}}@fwddiffe3subf(double* nocapture [[X:%.*]], [3 x double*] %"x'") 
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = extractvalue [3 x double*] %"x'", 0
; CHECK-NEXT:    %"'ipl" = load double, double* [[TMP0]], align 8
; CHECK-NEXT:    [[TMP1:%.*]] = extractvalue [3 x double*] %"x'", 1
; CHECK-NEXT:    %"'ipl1" = load double, double* [[TMP1]], align 8
; CHECK-NEXT:    [[TMP2:%.*]] = extractvalue [3 x double*] %"x'", 2
; CHECK-NEXT:    %"'ipl2" = load double, double* [[TMP2]], align 8
; CHECK-NEXT:    [[TMP3:%.*]] = load double, double* [[X]], align 8
; CHECK-NEXT:    [[MUL:%.*]] = fmul fast double [[TMP3]], 2.000000e+00
; CHECK-NEXT:    [[TMP4:%.*]] = fmul fast double %"'ipl", 2.000000e+00
; CHECK-NEXT:    [[TMP5:%.*]] = fmul fast double %"'ipl1", 2.000000e+00
; CHECK-NEXT:    [[TMP6:%.*]] = fmul fast double %"'ipl2", 2.000000e+00
; CHECK-NEXT:    store double [[MUL]], double* [[X]], align 8
; CHECK-NEXT:    [[TMP7:%.*]] = extractvalue [3 x double*] %"x'", 0
; CHECK-NEXT:    store double [[TMP4]], double* [[TMP7]], align 8
; CHECK-NEXT:    [[TMP8:%.*]] = extractvalue [3 x double*] %"x'", 1
; CHECK-NEXT:    store double [[TMP5]], double* [[TMP8]], align 8
; CHECK-NEXT:    [[TMP9:%.*]] = extractvalue [3 x double*] %"x'", 2
; CHECK-NEXT:    store double [[TMP6]], double* [[TMP9]], align 8
; CHECK-NEXT:    call void @fwddiffe3metasubf(double* [[X]], [3 x double*] %"x'")
; CHECK-NEXT:    call void @fwddiffe3othermetasubf(double* [[X]], [3 x double*] %"x'")
; CHECK-NEXT:    ret void
;
; CHECK: define {{[^@]+}}@fwddiffe3metasubf(double* nocapture [[X:%.*]], [3 x double*] %"x'") 
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = extractvalue [3 x double*] %"x'", 0
; CHECK-NEXT:    %"arrayidx'ipg" = getelementptr inbounds double, double* [[TMP0]], i64 1
; CHECK-NEXT:    [[TMP1:%.*]] = extractvalue [3 x double*] %"x'", 1
; CHECK-NEXT:    %"arrayidx'ipg1" = getelementptr inbounds double, double* [[TMP1]], i64 1
; CHECK-NEXT:    [[TMP2:%.*]] = extractvalue [3 x double*] %"x'", 2
; CHECK-NEXT:    %"arrayidx'ipg2" = getelementptr inbounds double, double* [[TMP2]], i64 1
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds double, double* [[X]], i64 1
; CHECK-NEXT:    store double 3.000000e+00, double* [[ARRAYIDX]], align 8
; CHECK-NEXT:    store double 0.000000e+00, double* %"arrayidx'ipg", align 8
; CHECK-NEXT:    store double 0.000000e+00, double* %"arrayidx'ipg1", align 8
; CHECK-NEXT:    store double 0.000000e+00, double* %"arrayidx'ipg2", align 8
; CHECK-NEXT:    ret void
;
;
; CHECK: define {{[^@]+}}@fwddiffe3othermetasubf(double* nocapture [[X:%.*]], [3 x double*] %"x'")
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = extractvalue [3 x double*] %"x'", 0
; CHECK-NEXT:    %"arrayidx'ipg" = getelementptr inbounds double, double* [[TMP0]], i64 1
; CHECK-NEXT:    [[TMP1:%.*]] = extractvalue [3 x double*] %"x'", 1
; CHECK-NEXT:    %"arrayidx'ipg1" = getelementptr inbounds double, double* [[TMP1]], i64 1
; CHECK-NEXT:    [[TMP2:%.*]] = extractvalue [3 x double*] %"x'", 2
; CHECK-NEXT:    %"arrayidx'ipg2" = getelementptr inbounds double, double* [[TMP2]], i64 1
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds double, double* [[X]], i64 1
; CHECK-NEXT:    store double 4.000000e+00, double* [[ARRAYIDX]], align 8
; CHECK-NEXT:    store double 0.000000e+00, double* %"arrayidx'ipg", align 8
; CHECK-NEXT:    store double 0.000000e+00, double* %"arrayidx'ipg1", align 8
; CHECK-NEXT:    store double 0.000000e+00, double* %"arrayidx'ipg2", align 8
; CHECK-NEXT:    ret void
;
