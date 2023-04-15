; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --include-generated-funcs
; RUN: if [ %llvmver -lt 16 ]; then %opt < %s %loadEnzyme -enzyme -enzyme-preopt=false -inline -mem2reg -instsimplify -adce -loop-deletion -correlated-propagation -simplifycfg -early-cse -S | FileCheck %s; fi
; RUN: if [ %llvmver -ge 16 ]; then %opt < %s %newLoadEnzyme -passes="enzyme,function(inline,mem2reg,instsimplify,adce,loop-deletion,correlated-propagation,simplifycfg,early-cse)" -enzyme-preopt=false -S | FileCheck %s; fi

%struct.Gradients = type { double, double, double }

; Function Attrs: nounwind
declare %struct.Gradients @__enzyme_fwddiff(double (double*, i64)*, ...)

; Function Attrs: norecurse nounwind readonly uwtable
define dso_local double @sumsquare(double* nocapture readonly %x, i64 %n) #0 {
entry:
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body
  ret double %add

for.body:                                         ; preds = %entry, %for.body
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %total.011 = phi double [ 0.000000e+00, %entry ], [ %add, %for.body ]
  %arrayidx = getelementptr inbounds double, double* %x, i64 %indvars.iv
  %0 = load double, double* %arrayidx
  %mul = fmul fast double %0, %0
  %add = fadd fast double %mul, %total.011
  %indvars.iv.next = add nuw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv, %n
  br i1 %exitcond, label %for.cond.cleanup, label %for.body
}

; Function Attrs: nounwind uwtable
define dso_local %struct.Gradients @dsumsquare(double* %x, double* %xp1, double* %xp2, double* %xp3, i64 %n) local_unnamed_addr #1 {
entry:
  %0 = tail call %struct.Gradients (double (double*, i64)*, ...) @__enzyme_fwddiff(double (double*, i64)* nonnull @sumsquare, metadata !"enzyme_width", i64 3, double* %x, double* %xp1, double* %xp2, double* %xp3, i64 %n)
  ret %struct.Gradients %0
}


attributes #0 = { norecurse nounwind readonly uwtable }
attributes #1 = { nounwind uwtable }
attributes #2 = { nounwind }



; CHECK: define {{[^@]+}}@dsumsquare(double* [[X:%.*]], double* [[XP1:%.*]], double* [[XP2:%.*]], double* [[XP3:%.*]], i64 [[N:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_BODY_I:%.*]]
; CHECK:       for.body.i:
; CHECK-NEXT:    [[TMP0_0:%.*]] = phi {{(fast )?}}double [ 0.000000e+00, [[ENTRY:%.*]] ], [ [[TMP9:%.*]], [[FOR_BODY_I]] ]
; CHECK-NEXT:    [[TMP0_1:%.*]] = phi {{(fast )?}}double [ 0.000000e+00, [[ENTRY:%.*]] ], [ [[TMP12:%.*]], [[FOR_BODY_I]] ]
; CHECK-NEXT:    [[TMP0_2:%.*]] = phi {{(fast )?}}double [ 0.000000e+00, [[ENTRY:%.*]] ], [ [[TMP15:%.*]], [[FOR_BODY_I]] ]
; CHECK-NEXT:    [[IV_I:%.*]] = phi i64 [ [[IV_NEXT_I:%.*]], [[FOR_BODY_I]] ], [ 0, [[ENTRY]] ]
; CHECK-NEXT:    [[IV_NEXT_I]] = add nuw nsw i64 [[IV_I]], 1
; CHECK-NEXT:    %"arrayidx'ipg.i" = getelementptr inbounds double, double* [[XP1]], i64 [[IV_I]]
; CHECK-NEXT:    %"arrayidx'ipg1.i" = getelementptr inbounds double, double* [[XP2]], i64 [[IV_I]]
; CHECK-NEXT:    %"arrayidx'ipg2.i" = getelementptr inbounds double, double* [[XP3]], i64 [[IV_I]]
; CHECK-NEXT:    [[ARRAYIDX_I:%.*]] = getelementptr inbounds double, double* [[X]], i64 [[IV_I]]
; CHECK-NEXT:    %"'ipl.i" = load double, double* %"arrayidx'ipg.i"
; CHECK-NEXT:    %"'ipl3.i" = load double, double* %"arrayidx'ipg1.i"
; CHECK-NEXT:    %"'ipl4.i" = load double, double* %"arrayidx'ipg2.i"
; CHECK-NEXT:    [[TMP1:%.*]] = load double, double* [[ARRAYIDX_I]]
; CHECK-NEXT:    [[TMP2:%.*]] = fmul fast double %"'ipl.i", [[TMP1]]
; CHECK-NEXT:    [[TMP3:%.*]] = fadd fast double [[TMP2]], [[TMP2]]
; CHECK-NEXT:    [[TMP4:%.*]] = fmul fast double %"'ipl3.i", [[TMP1]]
; CHECK-NEXT:    [[TMP5:%.*]] = fadd fast double [[TMP4]], [[TMP4]]
; CHECK-NEXT:    [[TMP6:%.*]] = fmul fast double %"'ipl4.i", [[TMP1]]
; CHECK-NEXT:    [[TMP7:%.*]] = fadd fast double [[TMP6]], [[TMP6]]
; CHECK-NEXT:    [[TMP9]] = fadd fast double [[TMP3]], [[TMP0_0]]
; CHECK-NEXT:    [[TMP12]] = fadd fast double [[TMP5]], [[TMP0_1]]
; CHECK-NEXT:    [[TMP15]] = fadd fast double [[TMP7]], [[TMP0_2]]
; CHECK-NEXT:    [[EXITCOND_I:%.*]] = icmp eq i64 [[IV_I]], [[N]]
; CHECK-NEXT:    br i1 [[EXITCOND_I]], label [[FWDDIFFE3SUMSQUARE_EXIT:%.*]], label [[FOR_BODY_I]]
; CHECK:       fwddiffe3sumsquare.exit:
; CHECK-NEXT:    [[TMP17:%.*]] = insertvalue [[STRUCT_GRADIENTS:%.*]] zeroinitializer, double [[TMP9]], 0
; CHECK-NEXT:    [[TMP18:%.*]] = insertvalue [[STRUCT_GRADIENTS]] [[TMP17]], double [[TMP12]], 1
; CHECK-NEXT:    [[TMP19:%.*]] = insertvalue [[STRUCT_GRADIENTS]] [[TMP18]], double [[TMP15]], 2
; CHECK-NEXT:    ret [[STRUCT_GRADIENTS]] [[TMP19]]
;
