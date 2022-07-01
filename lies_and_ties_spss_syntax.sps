* Encoding: UTF-8.
* Sophie van der Zee, Ronald Poppe
* Lies and Ties: The Effect of Familiarity and Relationship Type on Deception Detection Accuracy.

* Note: Open data before running analyses.

* Load complete dataset.
*GET FILE 'lies_and_ties_scores_per_person.sav'.
DATASET NAME Lies_and_Ties WINDOW = FRONT.


* RQ1: Familiarity and judgement accuracy =========================================================.

* Select Wave 2 data for those participants that have judged videos of both familiar and unfamiliar persons.
COMPUTE filter_wave_2_both_fam_and_unfam$ = (E_Dataset_Combined = 2) AND (E_DET_FAM_Count > 0) AND (E_DET_UNFAM_Count > 0).
FILTER BY filter_wave_2_both_fam_and_unfam$.
EXECUTE.
* Output:
    247 cases selected.

* Detection accuracy familiar (E_DET_FAM_T_TG + E_DET_FAM_L_LG) / E_DET_FAM_Count.  
DESCRIPTIVES VARIABLES = E_DET_FAM_T_TG E_DET_FAM_L_LG E_DET_FAM_Count
  /STATISTICS=SUM.
  
* Detection accuracy unfamiliar (E_DET_UNFAM_T_TG + E_DET_UNFAM_L_LG) / E_DET_UNFAM_Count.  
DESCRIPTIVES VARIABLES = E_DET_UNFAM_T_TG E_DET_UNFAM_L_LG E_DET_UNFAM_Count
  /STATISTICS=SUM.

* Calculate difference in detection rate for familiar and unfamiliar.
COMPUTE E_DET_FAM_UNFAM_Difference_Percentage = (E_DET_FAM_Percentage - E_DET_UNFAM_Percentage).
EXECUTE.

* Pre-test: test distribution normality of accuracy judgements of familiar and unfamiliar people.
EXAMINE VARIABLES=E_DET_FAM_Percentage E_DET_UNFAM_Percentage E_DET_FAM_UNFAM_Difference_Percentage
  /PLOT NPPLOT 
  /STATISTICS NONE 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.
  * Output:
    Familiar: W(247) = 0.862, p = 0.00 (median = 50.00%)
    Unfamiliar: W(247) = 0.967, p = 0.00 (median = 50.00%)
    Difference: W(247) = 0.970, p = 0.084.

* Test RQ1: Detection scores for familiar vs. unfamiliar (paired-samples t-test).
T-TEST PAIRS=E_DET_FAM_Percentage WITH E_DET_UNFAM_Percentage (PAIRED) 
  /CRITERIA=CI(.9500).CI.
* Output:
    t(246) = 0.859, P = 0.391.

* Test RQ1: Detection scores familiar vs. unfamiliar (Wilcoxon signed-rank).
NPAR TESTS 
  /WILCOXON=E_DET_FAM_Percentage WITH E_DET_UNFAM_Percentage (PAIRED) 
  /STATISTICS DESCRIPTIVES QUARTILES 
  /MISSING ANALYSIS.
* Output:
    Z(247) = -0.742, p = 0.458.




* RQ2: Familiarity and truth bias =================================================================.

* Truth bias for familiar (E_DET_FAM_T_TG + E_DET_FAM_L_TG) / E_DET_FAM_Count.  
DESCRIPTIVES VARIABLES = E_DET_FAM_T_TG E_DET_FAM_L_TG E_DET_FAM_Count
  /STATISTICS=SUM.
  
* Truth bias for unfamiliar (E_DET_UNFAM_T_TG + E_DET_UNFAM_L_TG) / E_DET_UNFAM_Count.  
DESCRIPTIVES VARIABLES = E_DET_UNFAM_T_TG E_DET_UNFAM_L_TG E_DET_UNFAM_Count
  /STATISTICS=SUM.

* Calculate difference in truth bias for familiar and unfamiliar.
COMPUTE E_TRUTH_BIAS_FAM_UNFAM_Difference = (E_TRUTH_BIAS_FAM - E_TRUTH_BIAS_UNFAM).
EXECUTE.

* Pre-test: test distribution normality of truth bias variables.
EXAMINE VARIABLES=E_TRUTH_BIAS_ALL E_TRUTH_BIAS_FAM E_TRUTH_BIAS_UNFAM E_TRUTH_BIAS_FAM_UNFAM_Difference
  /PLOT NPPLOT 
  /STATISTICS NONE 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.
  * Output:
    Overall: (W247) = 0.984, p=0.007 (median = 50.00%)
    Familiar: W(247) = 0.861, p = 0.00 (median = 50.00%)
    Unfamiliar: W(247) = 0.954, p = 0.00 (median = 40.00%)
    Difference: W(247) = 0.979, p = 0.01.

* Pre-test: Truth bias overall (one-sample Wilcoxon signed-rank).
NPTESTS 
  /ONESAMPLE TEST (E_TRUTH_BIAS_ALL) WILCOXON(TESTVALUE=0.5) 
  /MISSING SCOPE=ANALYSIS USERMISSING=EXCLUDE 
  /CRITERIA ALPHA=0.05 CILEVEL=95  SEED=RANDOM.
* Output:
    Z = -7.278, p = 0.000 (observed median = 41.67%).

* Test: Regression truth bias with age.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT E_TRUTH_BIAS_ALL
  /METHOD=ENTER A_AgeCorrectedCombined
  /PARTIALPLOT ALL
  /SCATTERPLOT=(E_TRUTH_BIAS_ALL ,*ADJPRED).
* Output:
    R^2 = 0.111, F(1, 245) = 30.72, p = 0.000.

* Figure 2: Truth bias vs. age, with fitted line.
GGRAPH 
  /GRAPHDATASET NAME="figure2" VARIABLES=A_AgeCorrectedCombined E_TRUTH_BIAS_ALL
    filter_wave_2_both_fam_and_unfam$[name="filter_wave_2_both_fam_and_unfam_"] MISSING=LISTWISE 
    REPORTMISSING=NO DATAFILTER=filter_wave_2_both_fam_and_unfam$(VALUES=ALL UNLABELED=INCLUDE) 
  /GRAPHSPEC SOURCE=INLINE 
  /FITLINE TOTAL=YES. 
BEGIN GPL 
  SOURCE: s=userSource(id("figure2")) 
  DATA: A_AgeCorrectedCombined=col(source(s), name("A_AgeCorrectedCombined")) 
  DATA: E_TRUTH_BIAS_ALL=col(source(s), name("E_TRUTH_BIAS_ALL")) 
  GUIDE: axis(dim(1), label("Age")) 
  GUIDE: axis(dim(2), label("Truth bias")) 
  ELEMENT: point(position(A_AgeCorrectedCombined*E_TRUTH_BIAS_ALL)) 
END GPL.

* Test RQ2: Truth bias familiar vs. unfamiliar (Wilcoxon signed-rank).
NPAR TESTS 
  /WILCOXON=E_TRUTH_BIAS_FAM WITH E_TRUTH_BIAS_UNFAM (PAIRED) 
  /STATISTICS DESCRIPTIVES QUARTILES 
  /MISSING ANALYSIS.
* Output:
    Z(247) = -0.619, p = 0.536.

* Alternative test RQ2: Truth bias familiar vs. unfamiliar (paired-samples t-test).
T-TEST PAIRS=E_TRUTH_BIAS_FAM WITH E_TRUTH_BIAS_UNFAM (PAIRED) 
  /CRITERIA=CI(.9500).CI.
* Output:
    t(246) = -0.408, P = 0.684.




* RQ3: Ties and judgement accuracy ================================================================.

* Load ties data.
*GET FILE 'lies_and_ties_scores_per_person_per_tie.sav'.
DATASET NAME Lies_and_Ties_per_Tie WINDOW = FRONT.

* Filter: parent tie.
COMPUTE filter_tie_parent$ = (E_tie_category_coarse = 1).
FILTER BY filter_tie_parent$.
EXECUTE.
* Output:
    88 cases selected.

* Calculate difference in parent tie and others judgement accuracy.
COMPUTE E_detection_score_parent_rest_Difference = (E_detection_score_tie - E_detection_score_rest).
EXECUTE.

* Pre-test: test distribution normality of parent tie and others judgement accuracy.
EXAMINE VARIABLES=E_detection_score_tie E_detection_score_rest E_detection_score_parent_rest_Difference
  /PLOT NPPLOT 
  /STATISTICS NONE 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.
  * Output:
    Tie: W(88) = 0.794, p = 0.000 (median = 50.00%)
    Other: W(88) = 0.983, p = 0.297 (median = 56.00%)
    Difference: W(88) = 0.944, p = 0.001.

* Test: Judgement accuracy parent vs. others (Wilcoxon signed-rank).
NPAR TESTS 
  /WILCOXON=E_detection_score_tie WITH E_detection_score_rest (PAIRED) 
  /STATISTICS DESCRIPTIVES QUARTILES 
  /MISSING ANALYSIS.
* Output:
    Z(88) = -0.315, p = 0.753.

* Calculate truth bias for parent tie, rest and difference.
COMPUTE E_truth_bias_parent_tie = (E_detection_tie_T_TG + E_detection_tie_L_TG) / (E_detection_tie_T_TG + E_detection_tie_T_LG + E_detection_tie_L_TG + E_detection_tie_L_LG).
COMPUTE E_truth_bias_parent_rest = (E_detection_rest_T_TG + E_detection_rest_L_TG) / (E_detection_rest_T_TG + E_detection_tie_T_LG + E_detection_rest_L_TG + E_detection_rest_L_LG).
COMPUTE E_truth_bias_parent_tie_rest_Difference = (E_truth_bias_parent_tie - E_truth_bias_parent_rest).
EXECUTE.

* Pre-test: test distribution normality of parent tie and others truth bias.
EXAMINE VARIABLES=E_truth_bias_parent_tie E_truth_bias_parent_rest E_truth_bias_parent_tie_rest_Difference
  /PLOT NPPLOT
  /STATISTICS NONE 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.
  * Output:
    Tie: W(88) = 0.794, p = 0.000 (median = 50.00%) / average = 48.67%
    Other: W(88) = 0.973, p = 0.058 (median = 57.14%) / average = 58.67%
    Difference: W(88) = 0.943, p = 0.001.

* Test: Truth bias parent vs. others (Wilcoxon signed-rank).
NPAR TESTS 
  /WILCOXON=E_truth_bias_parent_tie WITH E_truth_bias_parent_rest (PAIRED) 
  /STATISTICS DESCRIPTIVES QUARTILES 
  /MISSING ANALYSIS.
* Output:
    Z(88) = -2.199, p = 0.028.



* Filter: child tie.
COMPUTE filter_tie_child$ = (E_tie_category_coarse = 2).
FILTER BY filter_tie_child$.
EXECUTE.
* Output:
    109 cases selected.

* Calculate difference in child tie and others judgement accuracy.
COMPUTE E_detection_score_child_rest_Difference = (E_detection_score_tie - E_detection_score_rest).
EXECUTE.

* Pre-test: test distribution normality of child tie and others judgement accuracy.
EXAMINE VARIABLES=E_detection_score_tie E_detection_score_rest E_detection_score_child_rest_Difference
  /PLOT NPPLOT
  /STATISTICS NONE 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.
  * Output:
    Tie: W(109) = 0.724, p = 0.000 (median = 50.00%)
    Other: W(109) = 0.987, p = 0.405 (median = 55.00%)
    Difference: W(109) = 0.935, p = 0.000.

* Test: Judgement accuracy child vs. others (Wilcoxon signed-rank).
NPAR TESTS 
  /WILCOXON=E_detection_score_tie WITH E_detection_score_rest (PAIRED) 
  /STATISTICS DESCRIPTIVES QUARTILES 
  /MISSING ANALYSIS.
* Output:
    Z(109) = -0.280, p = 0.780.

* Calculate truth bias for child tie, rest and difference.
COMPUTE E_truth_bias_child_tie = (E_detection_tie_T_TG + E_detection_tie_L_TG) / (E_detection_tie_T_TG + E_detection_tie_T_LG + E_detection_tie_L_TG + E_detection_tie_L_LG).
COMPUTE E_truth_bias_child_rest = (E_detection_rest_T_TG + E_detection_rest_L_TG) / (E_detection_rest_T_TG + E_detection_tie_T_LG + E_detection_rest_L_TG + E_detection_rest_L_LG).
COMPUTE E_truth_bias_child_tie_rest_Difference = (E_truth_bias_parent_tie - E_truth_bias_parent_rest).
EXECUTE.

* Pre-test: test distribution normality of child tie and others truth bias.
EXAMINE VARIABLES=E_truth_bias_child_tie E_truth_bias_child_rest E_truth_bias_child_tie_rest_Difference
  /PLOT NPPLOT
  /STATISTICS NONE 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.
  * Output:
    Tie: W(109) = 0.635, p = 0.000 (median = 0.00%) / average = 26.61%
    Other: W(109) = 0.963, p = 0.004 (median = 50.00%) / average = 48.22%
    Difference: W(109) = 0.904, p = 0.000.

* Test: Truth bias child vs. others (Wilcoxon signed-rank).
NPAR TESTS 
  /WILCOXON=E_truth_bias_child_tie WITH E_truth_bias_child_rest (PAIRED) 
  /STATISTICS DESCRIPTIVES QUARTILES 
  /MISSING ANALYSIS.
* Output:
    Z(109) = -4.893, p = 0.000.



* Filter: sibling tie.
COMPUTE filter_tie_sibling$ = (E_tie_category_coarse = 3).
FILTER BY filter_tie_sibling$.
EXECUTE.
* Output:
    104 cases selected.

* Calculate difference in sibling tie and others judgement accuracy.
COMPUTE E_detection_score_sibling_rest_Difference = (E_detection_score_tie - E_detection_score_rest).
EXECUTE.

* Pre-test: test distribution normality of sibling tie and others judgement accuracy.
EXAMINE VARIABLES=E_detection_score_tie E_detection_score_rest E_detection_score_sibling_rest_Difference
  /PLOT NPPLOT 
  /STATISTICS NONE 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.
  * Output:
    Tie: W(104) = 0.626, p = 0.000 (median = 100.00%)
    Other: W(104) = 0.989, p = 0.581 (median = 50.00%)
    Difference: W(104) = 0.866, p = 0.000.

* Test: Judgement accuracy sibling vs. others (Wilcoxon signed-rank).
NPAR TESTS 
  /WILCOXON=E_detection_score_tie WITH E_detection_score_rest (PAIRED) 
  /STATISTICS DESCRIPTIVES QUARTILES 
  /MISSING ANALYSIS.
* Output:
    Z(104) = -2.148, p = 0.032.

* Calculate truth bias for sibling tie, rest and difference.
COMPUTE E_truth_bias_sibling_tie = (E_detection_tie_T_TG + E_detection_tie_L_TG) / (E_detection_tie_T_TG + E_detection_tie_T_LG + E_detection_tie_L_TG + E_detection_tie_L_LG).
COMPUTE E_truth_bias_sibling_rest = (E_detection_rest_T_TG + E_detection_rest_L_TG) / (E_detection_rest_T_TG + E_detection_tie_T_LG + E_detection_rest_L_TG + E_detection_rest_L_LG).
COMPUTE E_truth_bias_sibling_tie_rest_Difference = (E_truth_bias_sibling_tie - E_truth_bias_sibling_rest).
EXECUTE.

* Pre-test: test distribution normality of sibling tie and others truth bias.
EXAMINE VARIABLES=E_truth_bias_sibling_tie E_truth_bias_sibling_rest E_truth_bias_sibling_tie_rest_Difference
  /PLOT NPPLOT
  /STATISTICS NONE 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.
  * Output:
    Tie: W(104) = 0.670, p = 0.000 (median = 0.00%) / average = 42.79%
    Other: W(104) = 0.953, p = 0.001 (median = 50.00%) / average = 50.31%
    Difference: W(104) = 0.928, p = 0.000.

* Test: Truth bias sibling vs. others (Wilcoxon signed-rank).
NPAR TESTS 
  /WILCOXON=E_truth_bias_sibling_tie WITH E_truth_bias_sibling_rest (PAIRED) 
  /STATISTICS DESCRIPTIVES QUARTILES 
  /MISSING ANALYSIS.
* Output:
    Z(104) = -1.813, p = 0.070.



* Filter: partner tie.
COMPUTE filter_tie_partner$ = (E_tie_category_coarse = 4).
FILTER BY filter_tie_partner$.
EXECUTE.
* Output:
   46 cases selected.

* Calculate difference in partner tie and others judgement accuracy.
COMPUTE E_detection_score_partner_rest_Difference = (E_detection_score_tie - E_detection_score_rest).
EXECUTE.

* Pre-test: test distribution normality of partner tie and others judgement accuracy.
EXAMINE VARIABLES=E_detection_score_tie E_detection_score_rest E_detection_score_partner_rest_Difference
  /PLOT NPPLOT 
  /STATISTICS NONE 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.
  * Output:
    Tie: W(46) = 0.636, p = 0.000 (median = 100.00%)
    Other: W(46) = 0.971, p = 0.305 (median = 55.00%)
    Difference: W(46) = 0.858, p = 0.000.

* Test: Judgement accuracy partner vs. others (Wilcoxon signed-rank).
NPAR TESTS 
  /WILCOXON=E_detection_score_tie WITH E_detection_score_rest (PAIRED) 
  /STATISTICS DESCRIPTIVES QUARTILES 
  /MISSING ANALYSIS.
* Output:
    Z(46) = -0.683, p = 0.494.

* Calculate truth bias for partner tie, rest and difference.
COMPUTE E_truth_bias_partner_tie = (E_detection_tie_T_TG + E_detection_tie_L_TG) / (E_detection_tie_T_TG + E_detection_tie_T_LG + E_detection_tie_L_TG + E_detection_tie_L_LG).
COMPUTE E_truth_bias_partner_rest = (E_detection_rest_T_TG + E_detection_rest_L_TG) / (E_detection_rest_T_TG + E_detection_tie_T_LG + E_detection_rest_L_TG + E_detection_rest_L_LG).
COMPUTE E_truth_bias_partner_tie_rest_Difference = (E_truth_bias_partner_tie - E_truth_bias_partner_rest).
EXECUTE.

* Pre-test: test distribution normality of partner tie and others truth bias.
EXAMINE VARIABLES=E_truth_bias_partner_tie E_truth_bias_partner_rest E_truth_bias_partner_tie_rest_Difference
  /PLOT NPPLOT
  /STATISTICS NONE 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.
  * Output:
    Tie: W(46) = 0.620, p = 0.000 (median = 0.00%) / average = 39.13%
    Other: W(46) = 0.940, p = 0.020 (median = 62.50%) / average = 62.30%
    Difference: W(46) = 0.845, p = 0.000.

* Test: Truth bias partner vs. others (Wilcoxon signed-rank).
NPAR TESTS 
  /WILCOXON=E_truth_bias_partner_tie WITH E_truth_bias_partner_rest (PAIRED) 
  /STATISTICS DESCRIPTIVES QUARTILES 
  /MISSING ANALYSIS.
* Output:
    Z(46) = -3.696, p = 0.000.



* Filter: friend tie.
COMPUTE filter_tie_friend$ = (E_tie_category_coarse = 5).
FILTER BY filter_tie_friend$.
EXECUTE.
* Output:
   30 cases selected.

* Calculate difference in friend tie and others judgement accuracy.
COMPUTE E_detection_score_friend_rest_Difference = (E_detection_score_tie - E_detection_score_rest).
EXECUTE.

* Pre-test: test distribution normality of friend tie and others judgement accuracy.
EXAMINE VARIABLES=E_detection_score_tie E_detection_score_rest E_detection_score_friend_rest_Difference
  /PLOT NPPLOT 
  /STATISTICS NONE 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.
  * Output:
    Tie: W(30) = 0.759, p = 0.000 (median = 16.50%)
    Other: W(30) = 0.910, p = 0.015 (median = 45.00%)
    Difference: W(30) = 0.910, p = 0.015.

* Test: Judgement accuracy friend vs. others (Wilcoxon signed-rank).
NPAR TESTS 
  /WILCOXON=E_detection_score_tie WITH E_detection_score_rest (PAIRED) 
  /STATISTICS DESCRIPTIVES QUARTILES 
  /MISSING ANALYSIS.
* Output:
    Z(30) = -1.696, p = 0.090.

* Calculate truth bias for friend tie, rest and difference.
COMPUTE E_truth_bias_friend_tie = (E_detection_tie_T_TG + E_detection_tie_L_TG) / (E_detection_tie_T_TG + E_detection_tie_T_LG + E_detection_tie_L_TG + E_detection_tie_L_LG).
COMPUTE E_truth_bias_friend_rest = (E_detection_rest_T_TG + E_detection_rest_L_TG) / (E_detection_rest_T_TG + E_detection_tie_T_LG + E_detection_rest_L_TG + E_detection_rest_L_LG).
COMPUTE E_truth_bias_friend_tie_rest_Difference = (E_truth_bias_friend_tie - E_truth_bias_friend_rest).
EXECUTE.

* Pre-test: test distribution normality of friend tie and others truth bias.
EXAMINE VARIABLES=E_truth_bias_friend_tie E_truth_bias_friend_rest E_truth_bias_friend_tie_rest_Difference
  /PLOT NPPLOT
  /STATISTICS NONE 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.
  * Output:
    Tie: W(30) = 0.781, p = 0.000 (median = 50.00%) / average = 50.00%
    Other: W(30) = 0.932, p = 0.057 (median = 60.00%) / average = 55.13%
    Difference: W(30) = 0.922, p = 0.030.

* Test: Truth bias friend vs. others (Wilcoxon signed-rank).
NPAR TESTS 
  /WILCOXON=E_truth_bias_friend_tie WITH E_truth_bias_friend_rest (PAIRED) 
  /STATISTICS DESCRIPTIVES QUARTILES 
  /MISSING ANALYSIS.
* Output:
    Z(30) = -0.753, p = 0.452.




* Discussion: detection rates for co-located vs. not co-located participants ======================.

DATASET NAME Lies_and_Ties WINDOW = FRONT.

* Select Wave 2 data.
COMPUTE filter_wave_2$ = (E_Dataset_Combined = 2).
FILTER BY filter_wave_2$.
EXECUTE.
* Output:
    264 cases selected.

* Calculate difference between truth and lie detection accuracy for all, familiar and unfamiliar participants.
COMPUTE E_DET_ALL_Truth_Lie_Difference = (E_DET_ALL_Truth_Score - E_DET_ALL_Lie_Score).
COMPUTE E_DET_FAM_Truth_Lie_Difference = (E_DET_FAM_Truth_Score - E_DET_FAM_Lie_Score).
COMPUTE E_DET_UNFAM_Truth_Lie_Difference = (E_DET_UNFAM_Truth_Score - E_DET_UNFAM_Lie_Score).
EXECUTE.

* Pre-test: test distribution normality of lie and truth dectection accuracy for all people.
EXAMINE VARIABLES= E_DET_ALL_Truth_Score E_DET_ALL_Lie_Score E_DET_ALL_Truth_Lie_Difference
  /PLOT NPPLOT 
  /STATISTICS NONE 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.
  * Output:
    Truth: W(264) = 0.970, p = 0.000 (median = 40.00%)
    Lie: W(264) = 0.976, p = 0.000 (median = 60.00%)
    Difference: W(264) = 0.985, p = 0.008.

* Test: Detection scores truth vs. lie detection accuracy for all people (Wilcoxon signed-rank).
NPAR TESTS 
  /WILCOXON=E_DET_ALL_Truth_Score WITH E_DET_ALL_Lie_Score (PAIRED) 
  /STATISTICS DESCRIPTIVES QUARTILES 
  /MISSING ANALYSIS.
* Output:
   Z(264) = -7.776, p = 0.000.

* Pre-test: test distribution normality of lie and truth dectection accuracy for all familiar people.
EXAMINE VARIABLES= E_DET_FAM_Truth_Score E_DET_FAM_Lie_Score E_DET_FAM_Truth_Lie_Difference
  /PLOT NPPLOT 
  /STATISTICS NONE 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.
  * Output:
    Truth: W(153) = 0.744, p = 0.000 (median = 50.00%)
    Lie: W(153) = 0.748, p = 0.000 (median = 100.00%)
    Difference: W(153) = 0.912, p = 0.000.

* Test: Detection scores truth vs. lie detection accuracy for familiar people (Wilcoxon signed-rank).
NPAR TESTS 
  /WILCOXON=E_DET_FAM_Truth_Score WITH E_DET_FAM_Lie_Score (PAIRED) 
  /STATISTICS DESCRIPTIVES QUARTILES 
  /MISSING ANALYSIS.
* Output:
   Z(153) = -3.263, p = 0.001.



* Detection rate for co-located (E_DET_TABLE_T_TG + E_DET_TABLE_L_LG) / E_DET_TABLE_Count.  
DESCRIPTIVES VARIABLES = E_DET_TABLE_T_TG E_DET_TABLE_L_LG E_DET_TABLE_Count
  /STATISTICS=SUM.
  
* Detection rate for not co-located (E_DET_NO_TABLE_T_TG + E_DET_NO_TABLE_L_LG) / E_DET_NO_TABLE_Count.  
DESCRIPTIVES VARIABLES = E_DET_NOTABLE_T_TG E_DET_NOTABLE_L_LG E_DET_NOTABLE_Count
  /STATISTICS=SUM.

* Calculate difference in detection accuracy for videos of co-located and not co-located.
COMPUTE E_DET_TABLE_NOTABLE_Difference_Percentage = (E_DET_TABLE_Percentage - E_DET_NOTABLE_Percentage).
EXECUTE.

* Pre-test: test distribution normality of accuracy judgements of co-located and not co-located people.
EXAMINE VARIABLES=E_DET_TABLE_Percentage E_DET_NOTABLE_Percentage E_DET_TABLE_NOTABLE_Difference_Percentage
  /PLOT NPPLOT 
  /STATISTICS NONE 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.
  * Output:
    Co-located: W(262) = 0.907, p = 0.000 (median = 50.00%)
    Not co-located: W(262) = 0.955, p = 0.000 (median = 50.00%)
    Difference: W(262) = 0.982, p = 0.002.

* Test: Detection scores co-located vs. not co-located (Wilcoxon signed-rank).
NPAR TESTS 
  /WILCOXON=E_DET_TABLE_Percentage WITH E_DET_NOTABLE_Percentage (PAIRED) 
  /STATISTICS DESCRIPTIVES QUARTILES 
  /MISSING ANALYSIS.
* Output:
   Z(262) = -0.335, p = 0.737.



* Calculate difference in truth bias of videos of co-located and not co-located.
COMPUTE E_TRUTH_BIAS_TABLE_NOTABLE_Difference = (E_TRUTH_BIAS_TABLE - E_TRUTH_BIAS_NOTABLE).
EXECUTE.

* Pre-test: test distribution normality of truth bias of videos of co-located and not co-located.
EXAMINE VARIABLES=E_TRUTH_BIAS_TABLE E_TRUTH_BIAS_NOTABLE E_TRUTH_BIAS_TABLE_NOTABLE_Difference
  /PLOT NPPLOT 
  /STATISTICS NONE 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.
  * Output:
    Co-located: W(262) = 0.911, p = 0.000 (median = 50.00%)
    Not co-located: W(262) = 0.936, p = 0.000 (median = 37.50%)
    Difference: W(262) = 0.987, p = 0.015.

* Test: Truth bias co-located vs. not co-located (Wilcoxon signed-rank).
NPAR TESTS 
  /WILCOXON=E_TRUTH_BIAS_TABLE WITH E_TRUTH_BIAS_NOTABLE (PAIRED) 
  /STATISTICS DESCRIPTIVES QUARTILES 
  /MISSING ANALYSIS.
* Output:
   Z(262) = -0.335, p = 0.737.

