; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --include-generated-funcs
; RUN: if [ %llvmver -lt 16 ]; then %opt < %s %loadEnzyme -enzyme -enzyme-preopt=false -mem2reg -gvn -early-cse-memssa -instcombine -instsimplify -simplifycfg -adce -licm -correlated-propagation -instcombine -correlated-propagation -adce -instsimplify -correlated-propagation -jump-threading -instsimplify -early-cse -simplifycfg -S | FileCheck %s; fi
; RUN: %opt < %s %newLoadEnzyme -passes="enzyme,function(mem2reg,gvn,early-cse-memssa,instcombine,instsimplify,simplifycfg,adce,licm,correlated-propagation,instcombine,correlated-propagation,adce,instsimplify,correlated-propagation,jump-threading,instsimplify,early-cse,simplifycfg)" -enzyme-preopt=false -S | FileCheck %s

; #include <stdlib.h>
; #include <stdio.h>
; struct n {
;     double *values;
;     struct n *next;
; };
; __attribute__((noinline))
; double sum_list(const struct n *__restrict node, unsigned long times) {
;     double sum = 0;
;     for(const struct n *val = node; val != 0; val = val->next) {
;         for(int i=0; i<=times; i++) {
;             sum += val->values[i];
;         }
;     }
;     return sum;
; }

%struct.n = type { double*, %struct.n* }
%struct.Gradients = type { double, double, double }

; Function Attrs: noinline norecurse nounwind readonly uwtable
define dso_local double @sum_list(%struct.n* noalias readonly %node, i64 %times) local_unnamed_addr #0 {
entry:
  %cmp18 = icmp eq %struct.n* %node, null
  br i1 %cmp18, label %for.cond.cleanup, label %for.cond1.preheader

for.cond1.preheader:                              ; preds = %for.cond.cleanup4, %entry
  %val.020 = phi %struct.n* [ %1, %for.cond.cleanup4 ], [ %node, %entry ]
  %sum.019 = phi double [ %add, %for.cond.cleanup4 ], [ 0.000000e+00, %entry ]
  %values = getelementptr inbounds %struct.n, %struct.n* %val.020, i64 0, i32 0
  %0 = load double*, double** %values, align 8, !tbaa !2
  br label %for.body5

for.cond.cleanup:                                 ; preds = %for.cond.cleanup4, %entry
  %sum.0.lcssa = phi double [ 0.000000e+00, %entry ], [ %add, %for.cond.cleanup4 ]
  ret double %sum.0.lcssa

for.cond.cleanup4:                                ; preds = %for.body5
  %next = getelementptr inbounds %struct.n, %struct.n* %val.020, i64 0, i32 1
  %1 = load %struct.n*, %struct.n** %next, align 8, !tbaa !7
  %cmp = icmp eq %struct.n* %1, null
  br i1 %cmp, label %for.cond.cleanup, label %for.cond1.preheader

for.body5:                                        ; preds = %for.body5, %for.cond1.preheader
  %indvars.iv = phi i64 [ 0, %for.cond1.preheader ], [ %indvars.iv.next, %for.body5 ]
  %sum.116 = phi double [ %sum.019, %for.cond1.preheader ], [ %add, %for.body5 ]
  %arrayidx = getelementptr inbounds double, double* %0, i64 %indvars.iv
  %2 = load double, double* %arrayidx, align 8, !tbaa !8
  %add = fadd fast double %2, %sum.116
  %indvars.iv.next = add nuw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv, %times
  br i1 %exitcond, label %for.cond.cleanup4, label %for.body5
}

; Function Attrs: nounwind
declare dso_local noalias i8* @malloc(i64) local_unnamed_addr #2

; Function Attrs: noinline nounwind uwtable
define dso_local %struct.Gradients @derivative(%struct.n* %x, %struct.n* %xp1, %struct.n* %xp2, %struct.n* %xp3, i64 %n) {
entry:
  %0 = tail call %struct.Gradients (double (%struct.n*, i64)*, ...) @__enzyme_fwddiff(double (%struct.n*, i64)* nonnull @sum_list, metadata !"enzyme_width", i64 3, %struct.n* %x, %struct.n* %xp1, %struct.n* %xp2, %struct.n* %xp3, i64 %n)
  ret %struct.Gradients %0
}

; Function Attrs: nounwind
declare %struct.Gradients @__enzyme_fwddiff(double (%struct.n*, i64)*, ...) #4


attributes #0 = { noinline norecurse nounwind readonly uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-jump-tables"="false" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #1 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-jump-tables"="false" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #2 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #3 = { noinline nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="true" "no-jump-tables"="false" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" "use-soft-float"="false" }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 7.1.0 "}
!2 = !{!3, !4, i64 0}
!3 = !{!"n", !4, i64 0, !4, i64 8}
!4 = !{!"any pointer", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}
!7 = !{!3, !4, i64 8}
!8 = !{!9, !9, i64 0}
!9 = !{!"double", !5, i64 0}
!10 = !{!4, !4, i64 0}


; CHECK: define {{[^@]+}}@fwddiffe3sum_list(%struct.n* noalias readonly [[NODE:%.*]], [3 x %struct.n*] %"node'", i64 [[TIMES:%.*]]) 
; CHECK-NEXT:  [[ENTRY:.*]]:
; CHECK-NEXT:    [[CMP18:%.*]] = icmp eq %struct.n* [[NODE]], null
; CHECK-NEXT:    br i1 [[CMP18]], label [[FOR_COND_CLEANUP:%.*]], label %for.cond1.preheader.preheader

; CHECK: for.cond1.preheader.preheader: 
; CHECK-NEXT:   [[n0:%.*]] = extractvalue [3 x %struct.n*] %"node'", 0
; CHECK-NEXT:   [[n1:%.*]] = extractvalue [3 x %struct.n*] %"node'", 1
; CHECK-NEXT:   [[n2:%.*]] = extractvalue [3 x %struct.n*] %"node'", 2
; CHECK-NEXT:   br label %for.cond1.preheader

; CHECK:       for.cond1.preheader:
; CHECK-NEXT:    [[TMP0_0:%.*]] = phi {{(fast )?}}double [ [[TMP19_0:%.*]], [[FOR_COND_CLEANUP4:%.*]] ], [ 0.000000e+00, [[PH:%.*]] ]
; CHECK-NEXT:    [[TMP0_1:%.*]] = phi {{(fast )?}}double [ [[TMP19_1:%.*]], [[FOR_COND_CLEANUP4]] ], [ 0.000000e+00, [[PH]] ]
; CHECK-NEXT:    [[TMP0_2:%.*]] = phi {{(fast )?}}double [ [[TMP19_2:%.*]], [[FOR_COND_CLEANUP4]] ], [ 0.000000e+00, [[PH]] ]
; CHECK-NEXT:    [[TMP1_0:%.*]] = phi %struct.n* [ [[TMP8_0:%.*]], [[FOR_COND_CLEANUP4]] ], [ [[n0]], [[PH]] ]
; CHECK-NEXT:    [[TMP1_1:%.*]] = phi %struct.n* [ [[TMP8_1:%.*]], [[FOR_COND_CLEANUP4]] ], [ [[n1]], [[PH]] ]
; CHECK-NEXT:    [[TMP1_2:%.*]] = phi %struct.n* [ [[TMP8_2:%.*]], [[FOR_COND_CLEANUP4]] ], [ [[n2]], [[PH]] ]
; CHECK-NEXT:    [[VAL_020:%.*]] = phi %struct.n* [ [[TMP9:%.*]], [[FOR_COND_CLEANUP4]] ], [ [[NODE]], [[PH]] ]
; CHECK-NEXT:    %"values'ipg" = getelementptr inbounds [[STRUCT_N:%.*]], %struct.n* [[TMP1_0]], i64 0, i32 0
; CHECK-NEXT:    %"values'ipg3" = getelementptr inbounds [[STRUCT_N]], %struct.n* [[TMP1_1]], i64 0, i32 0
; CHECK-NEXT:    %"values'ipg4" = getelementptr inbounds [[STRUCT_N]], %struct.n* [[TMP1_2]], i64 0, i32 0
; CHECK-NEXT:    %"'ipl" = load double*, double** %"values'ipg", align 8, !tbaa !2
; CHECK-NEXT:    %"'ipl5" = load double*, double** %"values'ipg3", align 8, !tbaa !2
; CHECK-NEXT:    %"'ipl6" = load double*, double** %"values'ipg4", align 8, !tbaa !2
; CHECK-NEXT:    br label [[FOR_BODY5:%.*]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    [[TMP5_0:%.*]] = phi {{(fast )?}}double [ 0.000000e+00, %[[ENTRY]] ], [ [[TMP19_0]], [[FOR_COND_CLEANUP4]] ]
; CHECK-NEXT:    [[TMP5_1:%.*]] = phi {{(fast )?}}double [ 0.000000e+00, %[[ENTRY]] ], [ [[TMP19_1]], [[FOR_COND_CLEANUP4]] ]
; CHECK-NEXT:    [[TMP5_2:%.*]] = phi {{(fast )?}}double [ 0.000000e+00, %[[ENTRY]] ], [ [[TMP19_2]], [[FOR_COND_CLEANUP4]] ]
; CHECK-NEXT:   %[[r12:.+]] = insertvalue [3 x double] undef, double [[TMP5_0]], 0
; CHECK-NEXT:   %[[r13:.+]] = insertvalue [3 x double] %[[r12]], double [[TMP5_1]], 1
; CHECK-NEXT:   %[[r14:.+]] = insertvalue [3 x double] %[[r13]], double [[TMP5_2]], 2
; CHECK-NEXT:   ret [3 x double] %[[r14]]

; CHECK:       for.cond.cleanup4:
; CHECK-NEXT:    %"next'ipg" = getelementptr inbounds [[STRUCT_N]], %struct.n* [[TMP1_0]], i64 0, i32 1
; CHECK-NEXT:    %"next'ipg7" = getelementptr inbounds [[STRUCT_N]], %struct.n* [[TMP1_1]], i64 0, i32 1
; CHECK-NEXT:    %"next'ipg8" = getelementptr inbounds [[STRUCT_N]], %struct.n* [[TMP1_2]], i64 0, i32 1
; CHECK-NEXT:    [[NEXT:%.*]] = getelementptr inbounds [[STRUCT_N]], %struct.n* [[VAL_020]], i64 0, i32 1
; CHECK-NEXT:    %"'ipl9" = load %struct.n*, %struct.n** %"next'ipg", align 8, !tbaa !7
; CHECK-NEXT:    %"'ipl10" = load %struct.n*, %struct.n** %"next'ipg7", align 8, !tbaa !7
; CHECK-NEXT:    %"'ipl11" = load %struct.n*, %struct.n** %"next'ipg8", align 8, !tbaa !7
; CHECK-NEXT:    [[TMP9]] = load %struct.n*, %struct.n** [[NEXT]], align 8, !tbaa !7
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq %struct.n* [[TMP9]], null
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_COND_CLEANUP]], label [[FOR_COND1_PREHEADER:%.*]]
; CHECK:       for.body5:
; CHECK-NEXT:    [[TMP10_0:%.*]] = phi {{(fast )?}}double [ [[TMP0_0]], [[FOR_COND1_PREHEADER]] ], [ [[TMP19_0]], [[FOR_BODY5]] ]
; CHECK-NEXT:    [[TMP10_1:%.*]] = phi {{(fast )?}}double [ [[TMP0_1]], [[FOR_COND1_PREHEADER]] ], [ [[TMP19_1]], [[FOR_BODY5]] ]
; CHECK-NEXT:    [[TMP10_2:%.*]] = phi {{(fast )?}}double [ [[TMP0_2]], [[FOR_COND1_PREHEADER]] ], [ [[TMP19_2]], [[FOR_BODY5]] ]
; CHECK-NEXT:    [[IV1:%.*]] = phi i64 [ 0, [[FOR_COND1_PREHEADER]] ], [ [[IV_NEXT2:%.*]], [[FOR_BODY5]] ]
; CHECK-NEXT:    [[IV_NEXT2]] = add nuw nsw i64 [[IV1]], 1
; CHECK-NEXT:    %"arrayidx'ipg" = getelementptr inbounds double, double* %"'ipl", i64 [[IV1]]
; CHECK-NEXT:    %"arrayidx'ipg12" = getelementptr inbounds double, double* %"'ipl5", i64 [[IV1]]
; CHECK-NEXT:    %"arrayidx'ipg13" = getelementptr inbounds double, double* %"'ipl6", i64 [[IV1]]
; CHECK-NEXT:    %"'ipl14" = load double, double* %"arrayidx'ipg", align 8, !tbaa !8
; CHECK-NEXT:    %"'ipl15" = load double, double* %"arrayidx'ipg12", align 8, !tbaa !8
; CHECK-NEXT:    %"'ipl16" = load double, double* %"arrayidx'ipg13", align 8, !tbaa !8
; CHECK-NEXT:    [[TMP19_1:%.*]] = fadd fast double %"'ipl14", [[TMP10_0]]
; CHECK-NEXT:    [[TMP19_1:%.*]] = fadd fast double %"'ipl15", [[TMP10_1]]
; CHECK-NEXT:    [[TMP19_2:%.*]] = fadd fast double %"'ipl16", [[TMP10_2]]
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i64 [[IV1]], [[TIMES]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_COND_CLEANUP4]], label [[FOR_BODY5]]
;
