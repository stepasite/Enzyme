; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --include-generated-funcs
; RUN: if [ %llvmver -lt 16 ]; then %opt < %s %loadEnzyme -enzyme -enzyme-preopt=false -mem2reg -instcombine -correlated-propagation -adce -instcombine -simplifycfg -early-cse -simplifycfg -loop-unroll -instcombine -simplifycfg -gvn -jump-threading -instcombine -simplifycfg -S | FileCheck %s; fi
; RUN: %opt < %s %newLoadEnzyme -passes="enzyme,function(mem2reg,instcombine,correlated-propagation,adce,instcombine,simplifycfg,early-cse,simplifycfg,loop-unroll,instcombine,simplifycfg,gvn,jump-threading,instcombine,simplifycfg)" -enzyme-preopt=false -S | FileCheck %s

%struct.Gradients = type { double, double, double }

; Function Attrs: nounwind
declare %struct.Gradients @__enzyme_fwddiff(i8*, ...)

; Function Attrs: noinline nounwind uwtable
define dso_local double @f(double* nocapture readonly %x, i64 %n) #0 {
entry:
  br label %for.body

for.body:                                         ; preds = %if.end, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %if.end ]
  %data.016 = phi double [ 0.000000e+00, %entry ], [ %add5, %if.end ]
  %cmp2 = fcmp fast ogt double %data.016, 1.000000e+01
  br i1 %cmp2, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  %arrayidx = getelementptr inbounds double, double* %x, i64 %n
  %0 = load double, double* %arrayidx, align 8
  %add = fadd fast double %0, %data.016
  br label %cleanup

if.end:                                           ; preds = %for.body
  %arrayidx4 = getelementptr inbounds double, double* %x, i64 %indvars.iv
  %1 = load double, double* %arrayidx4, align 8
  %add5 = fadd fast double %1, %data.016
  %indvars.iv.next = add nuw i64 %indvars.iv, 1
  %cmp = icmp ult i64 %indvars.iv, %n
  br i1 %cmp, label %for.body, label %cleanup

cleanup:                                          ; preds = %if.end, %if.then
  %data.1 = phi double [ %add, %if.then ], [ %add5, %if.end ]
  ret double %data.1
}

; Function Attrs: noinline nounwind uwtable
define dso_local %struct.Gradients @dsumsquare(double* %x, double* %xp1, double* %xp2, double* %xp3, i64 %n) #0 {
entry:
  %call = call %struct.Gradients (i8*, ...) @__enzyme_fwddiff(i8* bitcast (double (double*, i64)* @f to i8*), metadata !"enzyme_width", i64 3, double* %x, double* %xp1, double* %xp2, double* %xp3, i64 %n)
  ret %struct.Gradients %call
}


attributes #0 = { noinline nounwind uwtable }

; CHECK: define {{[^@]+}}@fwddiffe3f(double* nocapture readonly [[X:%.*]], [3 x double*] %"x'", i64 [[N:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[IF_END:%.*]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[TMP0_0:%.*]] = phi {{(fast )?}}double [ [[TMP18:%.*]], [[IF_END]] ], [ 0.000000e+00, [[ENTRY]] ]
; CHECK-NEXT:    [[TMP0_1:%.*]] = phi {{(fast )?}}double [ [[TMP21:%.*]], [[IF_END]] ], [ 0.000000e+00, [[ENTRY]] ]
; CHECK-NEXT:    [[TMP0_2:%.*]] = phi {{(fast )?}}double [ [[TMP24:%.*]], [[IF_END]] ], [ 0.000000e+00, [[ENTRY]] ]
; CHECK-NEXT:    [[DATA_016:%.*]] = phi double [ [[ADD5:%.*]], [[IF_END]] ], [ 0.000000e+00, [[ENTRY]] ]
; CHECK-NEXT:    [[CMP2:%.*]] = fcmp fast ogt double [[DATA_016]], 1.000000e+01
; CHECK-NEXT:    br i1 [[CMP2]], label [[IF_THEN:%.*]], label [[IF_END]]
; CHECK:       if.then:
; CHECK-NEXT:    [[TMP1:%.*]] = extractvalue [3 x double*] %"x'", 0
; CHECK-NEXT:    %"arrayidx'ipg" = getelementptr inbounds double, double* [[TMP1]], i64 [[N]]
; CHECK-NEXT:    [[TMP2:%.*]] = extractvalue [3 x double*] %"x'", 1
; CHECK-NEXT:    %"arrayidx'ipg2" = getelementptr inbounds double, double* [[TMP2]], i64 [[N]]
; CHECK-NEXT:    [[TMP3:%.*]] = extractvalue [3 x double*] %"x'", 2
; CHECK-NEXT:    %"arrayidx'ipg3" = getelementptr inbounds double, double* [[TMP3]], i64 [[N]]
; CHECK-NEXT:    %"'ipl" = load double, double* %"arrayidx'ipg", align 8
; CHECK-NEXT:    %"'ipl4" = load double, double* %"arrayidx'ipg2", align 8
; CHECK-NEXT:    %"'ipl5" = load double, double* %"arrayidx'ipg3", align 8
; CHECK-NEXT:    [[TMP5:%.*]] = fadd fast double %"'ipl", [[TMP0_0]]
; CHECK-NEXT:    [[TMP8:%.*]] = fadd fast double %"'ipl4", [[TMP0_1]]
; CHECK-NEXT:    [[TMP11:%.*]] = fadd fast double %"'ipl5", [[TMP0_2]]
; CHECK-NEXT:    br label [[CLEANUP:%.*]]
; CHECK:       if.end:
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[TMP13:%.*]] = extractvalue [3 x double*] %"x'", 0
; CHECK-NEXT:    %"arrayidx4'ipg" = getelementptr inbounds double, double* [[TMP13]], i64 [[IV]]
; CHECK-NEXT:    [[TMP14:%.*]] = extractvalue [3 x double*] %"x'", 1
; CHECK-NEXT:    %"arrayidx4'ipg6" = getelementptr inbounds double, double* [[TMP14]], i64 [[IV]]
; CHECK-NEXT:    [[TMP15:%.*]] = extractvalue [3 x double*] %"x'", 2
; CHECK-NEXT:    %"arrayidx4'ipg7" = getelementptr inbounds double, double* [[TMP15]], i64 [[IV]]
; CHECK-NEXT:    [[ARRAYIDX4:%.*]] = getelementptr inbounds double, double* [[X]], i64 [[IV]]
; CHECK-NEXT:    %"'ipl8" = load double, double* %"arrayidx4'ipg", align 8
; CHECK-NEXT:    %"'ipl9" = load double, double* %"arrayidx4'ipg6", align 8
; CHECK-NEXT:    %"'ipl10" = load double, double* %"arrayidx4'ipg7", align 8
; CHECK-NEXT:    [[TMP16:%.*]] = load double, double* [[ARRAYIDX4]], align 8
; CHECK-NEXT:    [[ADD5]] = fadd fast double [[TMP16]], [[DATA_016]]
; CHECK-NEXT:    [[TMP18]] = fadd fast double %"'ipl8", [[TMP0_0]]
; CHECK-NEXT:    [[TMP21]] = fadd fast double %"'ipl9", [[TMP0_1]]
; CHECK-NEXT:    [[TMP24]] = fadd fast double %"'ipl10", [[TMP0_2]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i64 [[IV]], [[N]]
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[CLEANUP]]
; CHECK:       cleanup:
; CHECK-NEXT:    [[TMP26_0:%.*]] = phi {{(fast )?}}double [ [[TMP5]], [[IF_THEN]] ], [ [[TMP18]], [[IF_END]] ]
; CHECK-NEXT:    [[TMP26_1:%.*]] = phi {{(fast )?}}double [ [[TMP8]], [[IF_THEN]] ], [ [[TMP21]], [[IF_END]] ]
; CHECK-NEXT:    [[TMP26_2:%.*]] = phi {{(fast )?}}double [ [[TMP11]], [[IF_THEN]] ], [ [[TMP24]], [[IF_END]] ]
; CHECK-NEXT:    %[[i19:.+]] = insertvalue [3 x double] undef, double [[TMP26_0]], 0
; CHECK-NEXT:    %[[i20:.+]] = insertvalue [3 x double] %[[i19]], double [[TMP26_1]], 1
; CHECK-NEXT:    %[[i21:.+]] = insertvalue [3 x double] %[[i20]], double [[TMP26_2]], 2
; CHECK-NEXT:    ret [3 x double] %[[i21]]
;
