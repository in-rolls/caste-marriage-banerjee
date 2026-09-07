#delimit;
cap log close;
set mem 2000m;
set matsize 1200;
set more off;
log using log/stable, replace;

*GENERATE WEIGHTS FOR THE REGRESSIONS SUCH THAT THEY REPRESENT THE OVERALL RATIO OF LETTERS CONSIDERED AND UNCONSIDERED IN THE FULL SET OF LETTERS RECEIVED;
use data/interview_AEJ;
keep SI responses_with_info responses_mail responses_planned considered_info unconsidered_info;
gen weight_considered=(responses_planned/responses_mail)*(responses_with_info/considered_info);
replace weight_considered=0 if responses_planned==0;
gen weight_unconsidered=(responses_with_info/unconsidered_info)-(considered_info*weight_considered/unconsidered_info);
replace weight_unconsidered=0 if unconsidered_info==0|responses_planned==responses_mail;
keep SI weight*;
sort SI;
save data/weights, replace;

use data/interview_AEJ;
keep SI outcome;
gen found=outcome<6;
gen agreed=outcome==1|outcome==3 if outcome<5;
drop outcome;
sort SI;
save data/attrition, replace;

use data/ads_ads_AEJ;

foreach i in main_caste_rank nocaste noedu res nores nofamily_origin noage noheight nofield caste{;
gen same`i'=`i'_male==`i'_female;
replace same`i'=0 if `i'_male==0 | `i'_female==0;
};

replace samecaste=1 if caste_male==1 & main_caste_rank_female==1;
replace samecaste=1 if caste_female==1 & main_caste_rank_male==1;
replace samecaste=1 if caste_male==18 & main_caste_rank_female==2;
replace samecaste=1 if caste_female==18 & main_caste_rank_male==2;
replace samecaste=1 if caste_male==9 & main_caste_rank_female==3;
replace samecaste=1 if caste_female==9 & main_caste_rank_male==3;
replace samecaste=1 if caste_male==20 & main_caste_rank_female==4 & caste_female~=24 & caste_female~=83 & caste_female~=87 & caste_female~=101;
replace samecaste=1 if caste_female==20 & main_caste_rank_male==4 & caste_male~=24 & caste_male~=83 & caste_male~=87 & caste_male~=101;
replace samecaste=1 if caste_male==16 & (caste_female==17|caste_female==100);
replace samecaste=1 if caste_female==16 & (caste_male==17 & caste_male==100);
replace samecaste=1 if caste_male==25 & ((caste_female>=26 & caste_female<=30)|caste_female==35|caste_female==37|caste_female==39|caste_female==100|caste_female==105);
replace samecaste=1 if caste_female==25 & ((caste_male>=26 & caste_male<=30)|caste_male==35|caste_male==37|caste_male==39|caste_male==100|caste_male==105);
replace samecaste=1 if caste_male==31 & (caste_female==32|caste_female==33|caste_female==40|caste_female==41|caste_female==85);
replace samecaste=1 if caste_female==31 & (caste_male==32|caste_male==33|caste_male==40|caste_male==41|caste_male==85);
replace samecaste=1 if caste_male==34 & caste_female==35;
replace samecaste=1 if caste_female==34 & caste_male==35;
replace samecaste=1 if caste_male==36 & caste_female==37;
replace samecaste=1 if caste_female==36 & caste_male==37;
replace samecaste=1 if caste_male==38 & caste_female==39;
replace samecaste=1 if caste_female==38 & caste_male==39;
replace samecaste=1 if caste_male==42 & caste_female==43;
replace samecaste=1 if caste_female==42 & caste_male==43;
replace samecaste=1 if caste_male==44 & (caste_female==45|caste_female==46);
replace samecaste=1 if caste_female==44 & (caste_male==45|caste_male==46);
replace samecaste=1 if caste_male==53 & caste_female==54;
replace samecaste=1 if caste_female==53 & caste_male==54;
replace samecaste=1 if caste_male==56 & caste_female==57;
replace samecaste=1 if caste_female==56 & caste_male==57;
replace samecaste=1 if caste_male==58 & caste_female>=59 & caste_female<=63;
replace samecaste=1 if caste_female==58 & caste_male>=59 & caste_male<=63;
replace samecaste=1 if caste_male==79 & main_caste_rank_female==8;
replace samecaste=1 if caste_female==79 & main_caste_rank_male==8;

replace samecaste=0 if samemain_caste_rank==0;
replace nofield_male=1 if human_male==0 & science_male==0 & comm_male==0 & otherfield_male==0;
replace nofield_female=1 if human_female==0 & science_female==0 & comm_female==0 & otherfield_female==0;
gen sameedu_max=edu_max_male==edu_max_female;
replace sameedu_max=0 if noedu_male==1 |noedu_female==1;
gen samefamily_origin=family_origin_male==family_origin_female;
replace samefamily_origin=0 if nofamily_origin_male==1 | nofamily_origin_female==1;

gen diffcaste=-(main_caste_rank_male-main_caste_rank_female);
replace diffcaste=0 if main_caste_rank_male==0 | main_caste_rank_female==0;
gen abovecaste=main_caste_rank_male<main_caste_rank_female & nocaste_female==0 & nocaste_male==0;
gen belowcaste=main_caste_rank_male>main_caste_rank_female & nocaste_female==0 & nocaste_male==0;
gen diff_above=diffcaste*abovecaste;
gen diff_below=diffcaste*belowcaste;

gen diffedu=edu_max_male-edu_max_female;
replace diffedu=0 if edu_max_male==0|edu_max_female==0;
gen diffage=age_male-age_female;
replace diffage=0 if age_male==0|age_female==0;
gen diffheight=height_male-height_female;
replace diffheight=0 if height_male==0|height_female==0;

gen diffagesq=diffage^2;
gen diffheightsq=diffheight^2;

gen age_age=age_female*age_male;
gen age_noage=age_female*noage_male;
gen noage_age=noage_female*age_male;
gen height_height=height_female*height_male;
gen height_noheight=height_female*noheight_male;
gen noheight_height=noheight_female*height_male;

gen nodem_caste=nodemand_caste;
gen casteimportant=demand_caste;
gen castenotimp=(nodem_caste==0 & demand_caste==0);

gen casteimportantmatch=demand_caste*samemain;
gen casteimportantdiff=demand_caste*diffcaste;
gen casteimportantno=demand_caste*nocaste_female if brides==1;
replace casteimportantno=demand_caste*nocaste_male if brides==0;

gen castenotimpmatch=(nodem_caste==1)*samemain;
gen castenotimpdiff=(nodem_caste==1)*diffcaste;
gen castenotimpno=(nodem_caste==1)*nocaste_female if brides==1;
replace castenotimpno=(nodem_caste==1)*nocaste_male if brides==0;

replace res_male=res_male-1 if res_male>0;
replace res_female=res_female-1 if res_female>0;

rename vbeautiful_female vbeauty_female;
rename vbeautiful_male vbeauty_male;
rename beautiful_female beauty_female;
rename beautiful_male beauty_male;

tab main_caste_rank_male, gen(caste_no);
tab main_caste_rank_female, gen(caste_nof);
tab edu_max_female, gen(edu_female);
tab edu_max_male, gen(edu_male);

gen moreedu=edu_max_male>edu_max_female;
replace moreedu=0 if edu_max_male==0|edu_max_female==0;

rename other_edu_female otheredu_dum_female;
rename other_edu_male otheredu_dum_male;
rename sameres sameresstatus;

xtreg chosen caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight edu_female3-edu_female7 sameedu_max moreedu otheredu_dum_female science_female comm_female otherfield_female samenoedu noedu_female nofield_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female if brides==1, fe i(si);
estimates store considered_big_brides;
xtreg chosen caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3-edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male if brides==0, fe i(si);
estimates store considered_big_grooms;

clogit chosen caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight edu_female3-edu_female7 sameedu_max moreedu otheredu_dum_female science_female comm_female otherfield_female samenoedu noedu_female nofield_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female if brides==1, group(si);
estimates store considered_big_brides_logit;
clogit chosen caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3-edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male if brides==0, group(si);
estimates store considered_big_grooms_logit;

estout * using tab/table_C8A.txt, keep(samecaste diff_above diff_below casteimportantmatch casteimportantdiff castenotimpmatch castenotimpdiff diffage diffagesq diffheight diffheightsq edu_male3 edu_male4 edu_male5 edu_male6 edu_male7 edu_female3 edu_female4 edu_female5 edu_female6 edu_female7 sameedu_max moreedu otheredu_dum_male otheredu_dum_female comm_male science_male otherfield_male comm_female science_female otherfield_female skinrank_female logincome_male calcutta_male calcutta_female sameresstatus family_origin_male family_origin_female samefamily_origin  beauty_female vbeauty_female logwage_male) stats(r2_a N, fmt(%9.4f %9.0g))cells(b(star fmt(%9.4f)) se(par fmt(%9.4f)) ) starlevels(* 0.10 ** 0.05 *** 0.01) style(tex) replace notype mlabels(, numbers );
estimates clear;

*GENERATE AN INDICATOR OF WHETHER ANY RESPONSE WERE MADE TO CASTES ABOVE/BELOW;

keep if si~=. & chosen==1;
collapse (max)abovecaste (max)belowcaste (mean)brides, by(si);
gen abovecaste_dum=abovecaste if brides==0;
replace abovecaste_dum=belowcaste if brides==1;
gen belowcaste_dum=belowcaste if brides==0;
replace belowcaste_dum=abovecaste if brides==1;
drop abovecaste belowcaste brides;
rename si SI;
sort SI;
save data/caste_ads_ads, replace;
clear;

*TABLE 1 & C4;

use data/allads_AEJ;
foreach var in main_caste_rank age height edu_max logwage logincome{;
replace `var'=. if `var'==0;
};
replace human=. if nofield==1;
replace comm=. if nofield==1;
replace science=. if nofield==1;
replace otherfield=. if nofield==1;
replace calcutta=. if nores==1;
replace family_origin=. if nofamily==1;
replace skinrank=. if noskin==1;
replace beautiful=. if nobeauty==1;
replace vbeautiful=. if nobeauty==1;

tab main_caste_rank, gen(caste_dum);
tab edu_max, gen(edu_dum);
sum caste_dum* age height edu_dum* other_edu logwage logincome calcutta family_origin casteimportant castenotimp nodowry if brides==0;
sum nocaste noage noheight noedu nofield nores nofamily nowage noincome if brides==0;

sum caste_dum* age height skinrank vbeautiful beautiful edu_dum* other_edu logwage logincome calcutta family_origin casteimportant castenotimp nodowry if brides==1;
sum nocaste noage noheight noskin nobeauty noedu nofield nores nofamily nowage noincome if brides==1;

clear;

use data/ads_AEJ;

foreach var in main_caste_rank age height edu_max logwage logincome{;
replace `var'=. if `var'==0;
};
rename res calcutta;
rename beauty_fem beautiful;
rename vbeauty_fem vbeautiful;
rename otheredu_dum other_edu;
gen casteimportant=demand_caste;
gen castenotimp=(nodem_caste==0 & demand_caste==0);
replace other_edu=. if noedu==1;
replace beautiful=0 if vbeautiful==1;
replace human=. if nofield==1;
replace comm=. if nofield==1;
replace science=. if nofield==1;
replace otherfield=. if nofield==1;
replace calcutta=. if nores==1;
replace family_origin=. if nofamily_origin==1;
replace skinrank=. if noskin==1;
replace beautiful=. if nobeauty==1;
replace vbeautiful=. if nobeauty==1;

tab main_caste_rank, gen(caste_dum);
tab edu_max, gen(edu_dum);
sum caste_dum* age height edu_dum* other_edu logwage logincome calcutta family_origin casteimportant castenotimp nodowry if brides==0;
sum nocaste noage noheight noedu nofield nores nofamily_origin nowage noincome if brides==0;

sum caste_dum* age height skinrank vbeautiful beautiful edu_dum* other_edu logwage logincome calcutta family_origin casteimportant castenotimp nodowry if brides==1;
sum nocaste noage noheight noskin nobeauty noedu nofield nores nofamily_origin nowage noincome if brides==1;

sort SI;
merge SI using data/attrition;
tab _merge;
drop _merge;

*TABLE C1;

sum caste_dum* age height edu_dum* other_edu comm human science otherfield logwage logincome calcutta family_origin casteimportant castenotimp nodowry nocaste noage noheight noedu nofield nores nofamily_origin nowage noincome if brides==0 & found==1;
sum caste_dum* age height edu_dum* other_edu comm human science otherfield logwage logincome calcutta family_origin casteimportant castenotimp nodowry nocaste noage noheight noedu nofield nores nofamily_origin nowage noincome if brides==0 & found==0;
foreach var of varlist caste_dum* age height edu_dum* other_edu comm human science otherfield logwage logincome calcutta family_origin casteimportant castenotimp nodowry nocaste noage noheight noedu nofield nores nofamily_origin nowage noincome{;
ttest `var', by(found), if brides==0;
};

sum caste_dum* age height skinrank vbeautiful beautiful edu_dum* other_edu comm human science otherfield logwage logincome calcutta family_origin casteimportant castenotimp nodowry nocaste noage noheight noskin nobeauty noedu nofield nores nofamily_origin nowage noincome if brides==1 & found==1;
sum caste_dum* age height skinrank vbeautiful beautiful edu_dum* other_edu comm human science otherfield logwage logincome calcutta family_origin casteimportant castenotimp nodowry nocaste noage noheight noskin nobeauty noedu nofield nores nofamily_origin nowage noincome if brides==1 & found==0;
foreach var of varlist caste_dum* age height skinrank vbeautiful beautiful edu_dum* other_edu comm human science otherfield logwage logincome calcutta family_origin casteimportant castenotimp nodowry nocaste noage noheight noskin nobeauty noedu nofield nores nofamily_origin nowage noincome{;
ttest `var', by(found), if brides==1;
};

*TABLE C2;

sum caste_dum* age height edu_dum* other_edu comm human science otherfield logwage logincome calcutta family_origin casteimportant castenotimp nodowry nocaste noage noheight noedu nofield nores nofamily_origin nowage noincome if brides==0 & agreed==1;
sum caste_dum* age height edu_dum* other_edu comm human science otherfield logwage logincome calcutta family_origin casteimportant castenotimp nodowry nocaste noage noheight noedu nofield nores nofamily_origin nowage noincome if brides==0 & agreed==0 & found==1;
foreach var of varlist caste_dum* age height edu_dum* other_edu comm human science otherfield logwage logincome calcutta family_origin casteimportant castenotimp nodowry nocaste noage noheight noedu nofield nores nofamily_origin nowage noincome{;
ttest `var', by(agreed), if brides==0;
};

sum caste_dum* age height skinrank vbeautiful beautiful edu_dum* other_edu comm human science otherfield logwage logincome calcutta family_origin casteimportant castenotimp nodowry nocaste noage noheight noskin nobeauty noedu nofield nores nofamily_origin nowage noincome if brides==1 & agreed==1;
sum caste_dum* age height skinrank vbeautiful beautiful edu_dum* other_edu comm human science otherfield logwage logincome calcutta family_origin casteimportant castenotimp nodowry nocaste noage noheight noskin nobeauty noedu nofield nores nofamily_origin nowage noincome if brides==1 & agreed==0 & found==1;
foreach var of varlist caste_dum* age height skinrank vbeautiful beautiful edu_dum* other_edu comm human science otherfield logwage logincome calcutta family_origin casteimportant castenotimp nodowry nocaste noage noheight noskin nobeauty noedu nofield nores nofamily_origin nowage noincome{;
ttest `var', by(agreed), if brides==1;
};

clear;

*MERGE MATCH AND LETTERS DATA;

use data/match_AEJ;
*MAKE ALL BEAUTY CHARACTERISTICS THE AVERAGE ONES SO ONE CAN COMPUTE THE QUALITY INDEX;
gen skinrank=1.293025 if brides==0; 
gen noskin=0.1432556 if brides==0;
gen beauty_fem=0.3326572 if brides==0;
gen vbeauty_fem=0.0717546 if brides==0;
gen nobeauty_fem=0.3605477 if brides==0;

keep SI responseid main_caste_rank nocaste outcaste edu_max otheredu_dum noedu age noage height noheight skinrank noskin logincome noincome resstatus res
nores family_origin nofamily_origin beauty_fem vbeauty_fem nobeauty_fem logwage nowage bride human comm science otherfield nofield match caste;
rename beauty_fem beauty;
rename vbeauty_fem vbeauty;
rename nobeauty_fem nobeauty;
save data/stable, replace;

*ADD IN THE LETTERS DATA;

use data/letters_AEJ;
keep nopersona nogotra homely smart charming good cultured handsome richfam aristocrat conservative educated smallfam nofamily_back gotra slim nobody
skilledmusic skilledhouse skilledarts noskills skilledother SI responseid rank considered_info unconsidered_info rank_u considered main_caste_rank nocaste
outcaste edu_max otheredu_dum noedu age noage height noheight skinrank noskin logincome noincome resstatus res nores family_origin nofamily_origin beauty_fem
vbeauty_fem nobeauty_fem logwage nowage bride human comm science otherfield nofield nodowry caste;
rename beauty_fem beauty;
rename vbeauty_fem vbeauty;
rename nobeauty_fem nobeauty;
replace brides=1-brides;
append using data/stable;
sort SI;
save data/stable, replace;

use data/ads_AEJ;
keep nopersona nogotra gotra slim nobody richfam aristocrat conservative educated smallfam nofamily_back noskills handsome fair healthy otherphys_M 
nophysical homely smart charming good cultured nopersona skilledmusic skilledhouse skilledarts skilledother SI demand_caste nodem_caste main_caste_rank 
nocaste outcaste edu_max otheredu_dum noedu age noage height noheight skinrank noskin logincome noincome resstatus res nores family_origin nofamily_origin
beauty_fem vbeauty_fem nobeauty_fem logwage nowage bride human comm science otherfield nofield nodowry caste responses_mail;
rename beauty_fem beauty;
rename vbeauty_fem vbeauty;
rename nobeauty_fem nobeauty;
foreach i in nogotra gotra slim nobody richfam aristocrat conservative educated smallfam nofamily_back nopersona noskills handsome fair healthy otherphys_M
nophysical homely smart charming good cultured skilledmusic skilledhouse skilledarts skilledother main_caste_rank nocaste outcaste edu_max otheredu_dum noedu
age noage height noheight skinrank noskin logincome noincome resstatus res nores family_origin nofamily_origin beauty vbeauty nobeauty logwage nowage human comm
science otherfield nofield nodowry caste{;
rename `i' `i'_self;
};
sort SI;
merge SI using data/stable, uniqmaster;
keep if _merge==3;
drop _merge;
sort SI;
save data/stable, replace;

replace family_origin=0 if nofamily_origin==1;
foreach i in nopersona nogotra homely smart charming good cultured handsome richfam aristocrat conservative educated smallfam nofamily_back gotra slim nobody
skilledmusic skilledhouse skilledarts noskills skilledother main_caste_rank nocaste outcaste edu_max otheredu_dum noedu age noage height noheight skinrank noskin
logincome noincome resstatus res nores family_origin nofamily_origin beauty vbeauty nobeauty logwage nowage human comm science otherfield nofield nodowry caste{;
gen `i'_female=`i' if brides==0;
replace `i'_female=`i'_self if brides==1;
gen `i'_male=`i' if brides==1;
replace `i'_male=`i'_self if brides==0;
};
keep demand_caste nodem_caste *_male *_female SI responseid rank considered brides match responses_mail;
sort SI;
merge SI using data/weights;
tab _merge;
drop _merge;
gen weight=weight_unconsidered if considered==0;
replace weight=weight_considered if considered==1;
replace brides=1-brides;
save data/stable, replace;

*GENERATE VARIABLES TO CHARACTERIZE THE PAIRINGS;
foreach i in main_caste_rank nocaste noedu resstatus nores nofamily_origin noage noheight nofield nodowry caste{;
gen same`i'=`i'_male==`i'_female;
replace same`i'=0 if `i'_male==0 | `i'_female==0;
};

replace samecaste=1 if caste_male==1 & main_caste_rank_female==1;
replace samecaste=1 if caste_female==1 & main_caste_rank_male==1;
replace samecaste=1 if caste_male==18 & main_caste_rank_female==2;
replace samecaste=1 if caste_female==18 & main_caste_rank_male==2;
replace samecaste=1 if caste_male==9 & main_caste_rank_female==3;
replace samecaste=1 if caste_female==9 & main_caste_rank_male==3;
replace samecaste=1 if caste_male==20 & main_caste_rank_female==4 & caste_female~=24 & caste_female~=83 & caste_female~=87 & caste_female~=101;
replace samecaste=1 if caste_female==20 & main_caste_rank_male==4 & caste_male~=24 & caste_male~=83 & caste_male~=87 & caste_male~=101;
replace samecaste=1 if caste_male==16 & (caste_female==17|caste_female==100);
replace samecaste=1 if caste_female==16 & (caste_male==17 & caste_male==100);
replace samecaste=1 if caste_male==25 & ((caste_female>=26 & caste_female<=30)|caste_female==35|caste_female==37|caste_female==39|caste_female==100|caste_female==105);
replace samecaste=1 if caste_female==25 & ((caste_male>=26 & caste_male<=30)|caste_male==35|caste_male==37|caste_male==39|caste_male==100|caste_male==105);
replace samecaste=1 if caste_male==31 & (caste_female==32|caste_female==33|caste_female==40|caste_female==41|caste_female==85);
replace samecaste=1 if caste_female==31 & (caste_male==32|caste_male==33|caste_male==40|caste_male==41|caste_male==85);
replace samecaste=1 if caste_male==34 & caste_female==35;
replace samecaste=1 if caste_female==34 & caste_male==35;
replace samecaste=1 if caste_male==36 & caste_female==37;
replace samecaste=1 if caste_female==36 & caste_male==37;
replace samecaste=1 if caste_male==38 & caste_female==39;
replace samecaste=1 if caste_female==38 & caste_male==39;
replace samecaste=1 if caste_male==42 & caste_female==43;
replace samecaste=1 if caste_female==42 & caste_male==43;
replace samecaste=1 if caste_male==44 & (caste_female==45|caste_female==46);
replace samecaste=1 if caste_female==44 & (caste_male==45|caste_male==46);
replace samecaste=1 if caste_male==53 & caste_female==54;
replace samecaste=1 if caste_female==53 & caste_male==54;
replace samecaste=1 if caste_male==56 & caste_female==57;
replace samecaste=1 if caste_female==56 & caste_male==57;
replace samecaste=1 if caste_male==58 & caste_female>=59 & caste_female<=63;
replace samecaste=1 if caste_female==58 & caste_male>=59 & caste_male<=63;
replace samecaste=1 if caste_male==79 & main_caste_rank_female==8;
replace samecaste=1 if caste_female==79 & main_caste_rank_male==8;

replace samecaste=0 if samemain_caste_rank==0;

tab samecaste;

gen samefield=(human_male==1 & human_female==1)|(comm_male==1 & comm_female==1)|(science_male==1 & science_female==1);
replace nofield_male=1 if human_male==0 & science_male==0 & comm_male==0 & otherfield_male==0;
replace nofield_female=1 if human_female==0 & science_female==0 & comm_female==0 & otherfield_female==0;
gen sameedu_max=edu_max_male==edu_max_female;
replace sameedu_max=0 if noedu_male==1 |noedu_female==1;
gen sameres=res_male==1 & res_female==1;
gen samefamily_origin=family_origin_male==family_origin_female;
replace samefamily_origin=0 if nofamily_origin_male==1 | nofamily_origin_female==1;

gen diffcaste=-(main_caste_rank_male-main_caste_rank_female);
replace diffcaste=0 if main_caste_rank_male==0 | main_caste_rank_female==0;
gen abovecaste=main_caste_rank_male<main_caste_rank_female & nocaste_female==0 & nocaste_male==0;
gen belowcaste=main_caste_rank_male>main_caste_rank_female & nocaste_female==0 & nocaste_male==0;
gen diff_above=diffcaste*abovecaste;
gen diff_below=diffcaste*belowcaste;

gen diffage=age_male-age_female;
replace diffage=0 if age_male==0|age_female==0;
gen diffageabs=abs(diffage);
gen diffheight=height_male-height_female;
replace diffheight=0 if height_male==0|height_female==0;
gen diffheightabs=abs(diffheight);

gen diffagesq=diffage^2;
gen diffheightsq=diffheight^2;

gen age_age=age_female*age_male;
gen age_noage=age_female*noage_male;
gen noage_age=noage_female*age_male;
gen height_height=height_female*height_male;
gen height_noheight=height_female*noheight_male;
gen noheight_height=noheight_female*height_male;

gen casteimportant=demand_caste;
gen castenotimp=(nodem_caste==0 & demand_caste==0);

gen casteimportantmatch=demand_caste*samecaste;
gen casteimportantdiff=demand_caste*diffcaste;
gen casteimportantno=demand_caste*nocaste_female if brides==1;
replace casteimportantno=demand_caste*nocaste_male if brides==0;

gen castenotimpmatch=(nodem_caste==0&demand_caste==0)*samecaste;
gen castenotimpdiff=(nodem_caste==0&demand_caste==0)*diffcaste;
gen castenotimpno=(nodem_caste==0&demand_caste==0)*nocaste_female if brides==1;
replace castenotimpno=(nodem_caste==0&demand_caste==0)*nocaste_male if brides==0;

gen calcutta_male=resstatus_male==1;
gen calcutta_female=resstatus_female==1;

tab main_caste_rank_male, gen(caste_no);
tab main_caste_rank_female, gen(caste_nof);
tab edu_max_female, gen(edu_female);
tab edu_max_male, gen(edu_male);

gen samegotra=gotra_male==gotra_female & gotra_male~=0;
gen samenogotra=nogotra_male==1 & nogotra_female==1;

gen moreedu=edu_max_male>edu_max_female;
replace moreedu=0 if edu_max_male==0|edu_max_female==0;

*GENERATE INDICATOR VARIABLES FOR THE ADPLACER AND WHETHER THEY HAD LETTERS ABOVE/BELOW THEIR CAST;

bysort SI: egen samecaste_ind=sum(samecaste);
bysort SI: egen abovecaste_ind=sum(abovecaste);
bysort SI: egen belowcaste_ind=sum(belowcaste);

replace samecaste_ind=samecaste_ind>0;
replace belowcaste_ind=belowcaste_ind>0;
replace abovecaste_ind=abovecaste_ind>0;

bysort SI: egen maxrank=max(rank);
replace rank=. if maxrank>=16;
replace rank=16-rank;

bysort SI: egen count=count(responseid) if rank~=.;

save data/stable, replace;

*TABLE 4;
areg considered caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight edu_female3-edu_female7 sameedu_max moreedu otheredu_dum_female science_female comm_female otherfield_female samenoedu noedu_female nofield_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female if brides==1 & match~=1, absorb(SI), [aw=weight];
estimates store considered_big_brides;
testparm caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno; 
areg considered age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight edu_female3-edu_female7 sameedu_max moreedu otheredu_dum_female science_female comm_female otherfield_female samenoedu noedu_female nofield_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female if brides==1 & match~=1, absorb(SI), [aw=weight];
estimates store considered_nocaste_brides;
areg considered caste_nof3-caste_nof9 samecaste samemain_caste_rank diff_above diff_below abovecaste nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight edu_female3-edu_female7 sameedu_max moreedu otheredu_dum_female science_female comm_female otherfield_female samenoedu noedu_female nofield_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female if brides==1 & match~=1, absorb(SI), [aw=weight];
estimates store considered_sbig_brides;
testparm caste_nof3-caste_nof9 samecaste samemain_caste_rank diff_above diff_below abovecaste nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno;

preserve;
keep if brides==1 & match!=1;
xi i.SI;

gen byte cons=1;
foreach X of varlist considered logincome_female edu_female3-edu_female7 otheredu_dum_female science_female comm_female otherfield_female noedu_female nofield_female logwage_female nowage_female caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female _I* cons{;
replace `X'=`X'*sqrt(weight);
};
reg logincome_female edu_female3-edu_female7 otheredu_dum_female science_female comm_female otherfield_female noedu_female nofield_female logwage_female nowage_female cons if noincome_female==0, nocons;
predict income_pred_female;
predict double e, res, if noincome_female==0;
replace e=0 if noincome_female==1;
matrix V1=e(V);

reg considered caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight income_pred_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female _I* cons, nocons;
matrix V_c=e(V);
predict double u, res;
matrix accum s2=u, nocons;
matrix s2=s2/e(df_r);
matrix accum Vr=caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight income_pred_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female _I* cons, nocons;
matrix V2=inv(Vr);
scalar zz=_b[income_pred_female];

matrix accum C=edu_female3-edu_female7 otheredu_dum_female science_female comm_female otherfield_female noedu_female nofield_female logwage_female nowage_female cons caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight income_pred_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female _I* cons [iw=zz*u*u], nocons;
matrix accum R=edu_female3-edu_female7 otheredu_dum_female science_female comm_female otherfield_female noedu_female nofield_female logwage_female nowage_female cons caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight income_pred_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female _I* cons [iw=e*u], nocons;

matrix C=C[15..335, 1..14];
matrix R=R[15..335, 1..14];

matrix M = s2*V2 + (V2*(C*V1*C'-R*V1*C'-C*V1*R')*V2);
matrix M=M[1..44,1..44];
capture program drop doit;
matrix b=e(b);
matrix b=b[1,1..44];
program define doit, eclass;
	ereturn post b M;
	ereturn local vcetype "Mtopel";
	ereturn display;
end;
doit;

restore;

xtlogit considered caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight edu_female3-edu_female7 sameedu_max moreedu otheredu_dum_female science_female comm_female otherfield_female samenoedu noedu_female nofield_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female if brides==1 & match~=1, fe i(SI);
estimates store considered_logit_brides;
testparm caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno;

estout * using tab/table4.txt, keep(samecaste samemain_caste_rank diff_above diff_below casteimportantmatch casteimportantdiff castenotimpmatch castenotimpdiff diffage diffagesq diffheight diffheightsq edu_female3 edu_female4 edu_female5 edu_female6 edu_female7 sameedu_max moreedu otheredu_dum_female comm_female science_female otherfield_female calcutta_female sameresstatus samefamily_origin skinrank_female vbeauty_female beauty_female) stats(r2_a N, fmt(%9.4f %9.0g))cells(b(star fmt(%9.4f)) se(par fmt(%9.4f)) ) starlevels(* 0.10 ** 0.05 *** 0.01) style(tex) replace notype margin mlabels(, numbers );
estimates clear;

*TABLE 3;
areg considered caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3-edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male if brides==0 & match~=1, absorb(SI), [aw=weight];
estimates store considered_big_grooms;
testparm caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno;
areg considered age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3-edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male if brides==0 & match~=1, absorb(SI), [aw=weight];
estimates store considered_nocaste_grooms;
areg considered caste_no3-caste_no9 samecaste samemain_caste_rank diff_above diff_below abovecaste nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3-edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male if brides==0 & match~=1, absorb(SI), [aw=weight];
estimates store considered_sbig_grooms;
testparm caste_no3-caste_no9 samecaste samemain_caste_rank diff_above diff_below abovecaste nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno;
preserve;
keep if brides==0 & match!=1;
xi i.SI;

gen byte cons=1;
foreach X of varlist considered logincome_male edu_male3-edu_male7 otheredu_dum_male science_male comm_male otherfield_male noedu_male nofield_male logwage_male nowage_male caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin _I* cons{;
replace `X'=`X'*sqrt(weight);
};


reg logincome_male edu_male3-edu_male7 otheredu_dum_male science_male comm_male otherfield_male noedu_male nofield_male logwage_male nowage_male cons if noincome_male==0, nocons;
predict income_pred_male;
predict double e, res, if noincome_male==0;
replace e=0 if noincome_male==1;
matrix V1=e(V);

reg considered caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight income_pred_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin _I* cons, nocons;
matrix V_c=e(V);
predict double u, res;
matrix accum s2=u, nocons;
matrix s2=s2/e(df_r);
matrix accum Vr=caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight income_pred_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin _I* cons, nocons;
matrix V2=inv(Vr);
scalar zz=_b[income_pred_male];

matrix accum C=edu_male3-edu_male7 otheredu_dum_male science_male comm_male otherfield_male noedu_male nofield_male logwage_male nowage_male cons caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight income_pred_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin _I* cons [iw=zz*u*u], nocons;
matrix accum R=edu_male3-edu_male7 otheredu_dum_male science_male comm_male otherfield_male noedu_male nofield_male logwage_male nowage_male cons caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight income_pred_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin _I* cons [iw=e*u], nocons;

matrix C=C[15..559, 1..14];
matrix R=R[15..559, 1..14];

matrix M = s2*V2 + (V2 * (C*V1*C' - R*V1*C' - C*V1*R') * V2);
matrix b=e(b);
matrix M=M[1..39,1..39];
matrix b=b[1,1..39];

doit;

restore;

xtlogit considered caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3-edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male if brides==0 & match~=1, fe i(SI);
estimates store considered_logit_grooms;
testparm caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno;

estout * using tab/table3.txt, keep(samecaste samemain_caste_rank diff_above diff_below casteimportantmatch casteimportantdiff castenotimpmatch castenotimpdiff diffage diffagesq diffheight diffheightsq edu_male3 edu_male4 edu_male5 edu_male6 edu_male7 sameedu_max moreedu otheredu_dum_male comm_male science_male otherfield_male calcutta_male sameresstatus samefamily_origin logwage_male logincome_male) stats(r2_a N, fmt(%9.4f %9.0g))cells(b(star fmt(%9.4f)) se(par fmt(%9.4f)) ) starlevels(* 0.10 ** 0.05 *** 0.01) style(tex) replace notype margin mlabels(, numbers );
estimates clear;

*TABLE C10;

areg considered caste_nof3-caste_nof9 samecaste diffcaste nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight edu_female3-edu_female7 sameedu_max moreedu otheredu_dum_female science_female comm_female otherfield_female samenoedu noedu_female nofield_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female, absorb(SI), if brides==1 & main_caste_rank_male<=4 & nocaste_male~=1 & main_caste_rank_female<=4 & nocaste_female~=1 [aw=weight];
estimates store cons_lowcaste_brides;
clogit considered caste_nof3-caste_nof9 samecaste diffcaste nocaste_female samenocaste age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight edu_female3-edu_female7 sameedu_max moreedu otheredu_dum_female science_female comm_female otherfield_female samenoedu noedu_female nofield_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female, group(SI) ltolerance(1e-4) tolerance(1e-4) iterate(1000), if brides==1 & main_caste_rank_male<=4 & nocaste_male~=1 & main_caste_rank_female<=4 & nocaste_female~=1;
estimates store cons_logit_brides;
areg considered caste_no3-caste_no9 samecaste diffcaste nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3-edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male, absorb(SI), if brides==0 & main_caste_rank_female<=4 & nocaste_female~=1 & main_caste_rank_male<=4 & nocaste_male~=1 [aw=weight];
estimates store cons_lowcaste_grooms;
clogit considered caste_no3-caste_no9 samecaste diffcaste nocaste_male samenocaste age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3-edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male, ltolerance(1e-4) tolerance(1e-4) iterate(1000) group(SI), if brides==0 & main_caste_rank_female<=4 & nocaste_female~=1 & main_caste_rank_male<=4 & nocaste_male~=1;
estimates store cons_logit_grooms;

areg rank caste_nof3-caste_nof9 samecaste diffcaste nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight edu_female3-edu_female7 sameedu_max moreedu otheredu_dum_female science_female comm_female otherfield_female samenoedu noedu_female nofield_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female, absorb(SI), if brides==1 & main_caste_rank_male<=4 & nocaste_male~=1 [aw=weight];
estimates store rank_lowcaste_brides;
areg rank caste_no3-caste_no9 samecaste diffcaste nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3-edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male, absorb(SI), if brides==0 & main_caste_rank_female<=4 & nocaste_female~=1 [aw=weight];
estimates store rank_lowcaste_grooms;

estout * using tab/table_C10.txt, keep(samecaste diffcaste casteimportantmatch casteimportantdiff castenotimpmatch castenotimpdiff diffage diffagesq diffheight diffheightsq edu_male3 edu_male4 edu_male5 edu_male6 edu_male7 sameedu_max moreedu otheredu_dum_male comm_male science_male otherfield_male calcutta_male sameresstatus samefamily_origin logwage_male logincome_male edu_female3 edu_female4 edu_female5 edu_female6 edu_female7 otheredu_dum_female comm_female science_female otherfield_female calcutta_female skinrank_female vbeauty_female beauty_female) stats(r2_a N, fmt(%9.4f %9.0g))cells(b(star fmt(%9.4f)) se(par fmt(%9.4f)) ) starlevels(* 0.10 ** 0.05 *** 0.01) style(tex) replace notype margin mlabels(, numbers );
estimates clear;

*TABLE C11;

foreach i in caste_no3 caste_no4 caste_no5 caste_no6 caste_no7 caste_no8 caste_no9 samecaste diff_above diff_below nocaste_male samenocaste age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3 edu_male4 edu_male5 edu_male6 edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male{;
gen `i'_inter=`i'*nodowry_male;
};
 
areg considered caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3-edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male nodowry_male samenodowry *_inter, absorb(SI), if brides==0 & match~=1 [aw=weight];
estimates store considered_wdowry_grooms;
testparm *_inter;

drop *_inter;

reg logincome_female edu_female3-edu_female7 otheredu_dum_female science_female comm_female otherfield_female noedu_female nofield_female logwage_female nowage_female if noincome_female==0;
predict income_pred_female;

reg logincome_male edu_male3-edu_male7 otheredu_dum_male science_male comm_male otherfield_male noedu_male nofield_male logwage_male nowage_male if noincome_male==0;
predict income_pred_male;

foreach i in caste_no3 caste_no4 caste_no5 caste_no6 caste_no7 caste_no8 caste_no9 samecaste diff_above diff_below nocaste_male samenocaste age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight income_pred_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin {;
gen `i'_inter=`i'*nodowry_male;
};

areg considered caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight income_pred_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin nodowry_male samenodowry *_inter if brides==0 & match~=1, absorb(SI), [aw=weight];
estimates store considered_iv_dow_grooms;
testparm *_inter;

estout * using tab/table_C11.txt, keep(samecaste diff_above diff_below diffage diffagesq diffheight diffheightsq edu_male3 edu_male4 edu_male5 edu_male6 edu_male7 sameedu_max moreedu otheredu_dum_male comm_male science_male otherfield_male calcutta_male sameresstatus samefamily_origin logwage_male logincome_male nodowry_male *_inter) stats(r2_a N, fmt(%9.4f %9.0g))cells(b(star fmt(%9.4f)) se(par fmt(%9.4f)) ) starlevels(* 0.10 ** 0.05 *** 0.01) style(tex) replace notype margin mlabels(, numbers );
estimates clear;

drop *_inter;

bysort SI: egen num=rank(considered), unique;

sort SI;
merge SI using data/caste_ads_ads;
tab _merge;
drop _merge;

reg considered caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight edu_female3-edu_female7 sameedu_max moreedu otheredu_dum_female science_female comm_female otherfield_female samenoedu noedu_female nofield_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female if brides==1 & match~=1;
predict cons_female if brides==1;
reg considered caste_nof3-caste_nof9 nocaste_female age_female noage_female height_female noheight_female edu_female3-edu_female7 otheredu_dum_female science_female comm_female otherfield_female noedu_female nofield_female calcutta_female nores_female family_origin_female nofamily_origin_female vbeauty_female beauty_female nobeauty_female skinrank_female noskin_female if brides==1 & match~=1;
predict cons_female_b;
reg considered caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3-edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male if brides==0 & match~=1 [aw=weight];
predict cons_male if brides==0;
reg considered caste_no3-caste_no9 nocaste_male age_male noage_male height_male noheight_male edu_male3-edu_male7 otheredu_dum_male science_male comm_male otherfield_male noedu_male nofield_male logincome_male noincome_male calcutta_male nores_male family_origin_male nofamily_origin_male logwage_male nowage_male if brides==0 & match~=1 [aw=weight], cluster(SI);
predict cons_male_b;
reg considered age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight edu_female3-edu_female7 sameedu_max moreedu otheredu_dum_female science_female comm_female otherfield_female samenoedu noedu_female nofield_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female if brides==1 & match~=1 [aw=weight];
predict cons_female_nocaste;
reg considered age_female noage_female height_female noheight_female edu_female3-edu_female7 otheredu_dum_female science_female comm_female otherfield_female noedu_female nofield_female calcutta_female nores_female family_origin_female nofamily_origin_female beauty_female vbeauty_female nobeauty_female skinrank_female noskin_female if brides==1 & match~=1 [aw=weight];
predict cons_female_b_nocaste;
reg considered age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3-edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male if brides==0 & match~=1 [aw=weight];
predict cons_male_nocaste;
reg considered age_male noage_male height_male noheight_male edu_male3-edu_male7 otheredu_dum_male science_male comm_male otherfield_male noedu_male nofield_male logincome_male noincome_male calcutta_male nores_male family_origin_male nofamily_origin_male logwage_male nowage_male if brides==0 & match~=1 [aw=weight];
predict cons_male_b_nocaste;
areg considered caste_nof3-caste_nof9 nocaste_female age_female noage_female height_female noheight_female edu_female3-edu_female7 otheredu_dum_female science_female comm_female otherfield_female noedu_female nofield_female calcutta_female nores_female family_origin_female nofamily_origin_female vbeauty_female beauty_female nobeauty_female skinrank_female noskin_female if brides==1 & match~=1, absorb(SI), [aw=weight];
estimates store considered_noint_brides;
areg considered caste_no3-caste_no9 nocaste_male age_male noage_male height_male noheight_male edu_male3-edu_male7 otheredu_dum_male science_male comm_male otherfield_male noedu_male nofield_male logincome_male noincome_male calcutta_male nores_male family_origin_male nofamily_origin_male logwage_male nowage_male if brides==0 & match~=1, absorb(SI), [aw=weight];
estimates store considered_noint_grooms;

gen qual_adplacer=cons_female_b_nocaste if brides==0;
replace qual_adplacer=cons_male_b_nocaste if brides==1;

gen qual_adplacer_sq=qual_adplacer^2;

gen qual_response=cons_female_b_nocaste if brides==1;
replace qual_response=cons_male_b_nocaste if brides==0;

xtile qual_ad_quant_females=cons_female_b_nocaste, nq(5), if brides==0;
xtile qual_ad_quant_males=cons_male_b_nocaste, nq(5), if brides==1;
gen qual_ad_quant=qual_ad_quant_females if brides==0;
replace qual_ad_quant=qual_ad_quant_males if brides==1;
drop qual_ad_quant_females qual_ad_quant_males;
xtile qual_resp_quant_females=qual_response, nq(5), if brides==1;
xtile qual_resp_quant_males=qual_response, nq(5), if brides==0;
gen qual_resp_quant=qual_resp_quant_females if brides==1;
replace qual_resp_quant=qual_resp_quant_males if brides==0;
drop qual_resp_quant_females qual_resp_quant_males;

*FIGURE 2;
forvalues x=1/5{;
bysort qual_resp_quant brides: egen prop_considered_ad`x'=mean(considered) if qual_ad_quant==`x';
label variable prop_considered_ad`x' "Ad quality of quantile `x'";
tab prop_considered_ad`x' qual_resp_quant if brides==1;
tab prop_considered_ad`x' qual_resp_quant if brides==0;
};

scatter prop_considered_ad1 prop_considered_ad2 prop_considered_ad3 prop_considered_ad4 prop_considered_ad5 qual_resp_quant if brides==1, ytitle("% considered") xtitle("Quantile of the letter's quality") c(lllll) sort;
scatter prop_considered_ad1 prop_considered_ad2 prop_considered_ad3 prop_considered_ad4 prop_considered_ad5 qual_resp_quant if brides==0, ytitle("% considered") xtitle("Quantile of the letter's quality") c(lllll) sort;
estimates clear;

*TABLE C9;
reg responses_mail caste_nof3-caste_nof9 nocaste_female age_female noage_female height_female noheight_female edu_female3-edu_female7 otheredu_dum_female science_female comm_female otherfield_female noedu_female nofield_female calcutta_female nores_female family_origin_female nofamily_origin_female vbeauty_female beauty_female nobeauty_female skinrank_female noskin_female if brides==0 & num==1;
estimates store responses_brides;
reg responses_mail caste_no3-caste_no9 nocaste_male age_male noage_male height_male noheight_male edu_male3-edu_male7 otheredu_dum_male science_male comm_male otherfield_male noedu_male nofield_male logincome_male noincome_male calcutta_male nores_male family_origin_male nofamily_origin_male logwage_male nowage_male if brides==1 & num==1;
estimates store responses_grooms;

poisson responses_mail caste_nof3-caste_nof9 nocaste_female age_female noage_female height_female noheight_female edu_female3-edu_female7 otheredu_dum_female science_female comm_female otherfield_female noedu_female nofield_female calcutta_female nores_female family_origin_female nofamily_origin_female vbeauty_female beauty_female nobeauty_female skinrank_female noskin_female if brides==0 & num==1;
estimates store responses_brides_p;
poisson responses_mail caste_no3-caste_no9 nocaste_male age_male noage_male height_male noheight_male edu_male3-edu_male7 otheredu_dum_male science_male comm_male otherfield_male noedu_male nofield_male logincome_male noincome_male calcutta_male nores_male family_origin_male nofamily_origin_male logwage_male nowage_male if brides==1 & num==1;
estimates store responses_grooms_p;

estout * using tab/table_C9.txt, keep(caste_no3 caste_no4 caste_no5 caste_no6 caste_no7 caste_no8 caste_no9 caste_nof3 caste_nof4 caste_nof5 caste_nof6 caste_nof7 caste_nof8 caste_nof9 age_male age_female height_male height_female edu_male3 edu_male4 edu_male5 edu_male6 edu_male7 edu_female3 edu_female4 edu_female5 edu_female6 edu_female7 otheredu_dum_male otheredu_dum_female comm_male science_male otherfield_male comm_female science_female otherfield_female skinrank_female logincome_male calcutta_male calcutta_female family_origin_male family_origin_female beauty_female vbeauty_female logwage_male) stats(r2_a N, fmt(%9.4f %9.0g))cells(b(star fmt(%9.4f)) se(par fmt(%9.4f)) ) starlevels(* 0.1 ** 0.05 *** 0.01) style(tex) replace notype margin mlabels(, numbers );
estimates clear;

*TABLE 5;

*PANEL A;

reg cons_female_b_nocaste abovecaste_ind if brides==1 & match==1;
estimates store match_above_female;
reg cons_male_b_nocaste abovecaste_ind if brides==0 & match==1;
estimates store match_above_male;
reg cons_female_b_nocaste belowcaste_ind if brides==1 & match==1;
estimates store match_below_female;
reg cons_male_b_nocaste belowcaste_ind if brides==0 & match==1;
estimates store match_below_male;

reg qual_adplacer abovecaste_ind if brides==1 & num==1;
estimates store adplacer_above_female;
reg qual_adplacer abovecaste_ind if brides==0 & num==1;
estimates store adplacer_above_male;
reg qual_adplacer belowcaste_ind if brides==1 & num==1;
estimates store adplacer_below_female;
reg qual_adplacer belowcaste_ind if brides==0 & num==1;
estimates store adplacer_below_male;

sum abovecaste_ind belowcaste_ind if brides==1 & num==1;
sum abovecaste_ind belowcaste_ind if brides==0 & num==1;

*PANEL B;

reg qual_adplacer abovecaste_dum if brides==1 & num==1;
estimates store adplacer_aboved_female;
reg qual_adplacer abovecaste_dum if brides==0 & num==1;
estimates store adplacer_aboved_male;
reg qual_adplacer belowcaste_dum if brides==1 & num==1;
estimates store adplacer_belowd_female; 
reg qual_adplacer belowcaste_dum if brides==0 & num==1;
estimates store adplacer_belowd_male;

reg cons_female_b_nocaste abovecaste_dum if brides==1 & match==1;
estimates store match_aboved_female;
reg cons_male_b_nocaste abovecaste_dum if brides==0 & match==1;
estimates store match_aboved_male;
reg cons_female_b_nocaste belowcaste_dum if brides==1 & match==1;
estimates store match_belowd_female;
reg cons_male_b_nocaste belowcaste_dum if brides==0 & match==1;
estimates store match_belowd_male;

sum abovecaste_dum belowcaste_dum if brides==1 & num==1;
sum abovecaste_dum belowcaste_dum if brides==0 & num==1;

estout * using tab/table5.txt, keep(abovecaste* belowcaste*) stats(r2_a N, fmt(%9.4f %9.0g))cells(b(star fmt(%9.4f)) se(par fmt(%9.4f)) ) starlevels(* 0.1 ** 0.05 *** 0.01) style(tex) replace notype margin mlabels(, numbers );
estimates clear;

*TABLE C7;
areg rank caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight edu_female3-edu_female7 sameedu_max moreedu otheredu_dum_female science_female comm_female otherfield_female samenoedu noedu_female nofield_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female if brides==1 & match~=1, absorb(SI), [aw=weight];
estimates store rank_big_brides;
areg rank age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight edu_female3-edu_female7 sameedu_max moreedu otheredu_dum_female science_female comm_female otherfield_female samenoedu noedu_female nofield_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female if brides==1 & match~=1, absorb(SI), [aw=weight];
estimates store rank_nocaste_brides;
areg rank caste_nof3-caste_nof9 samecaste samemain_caste_rank diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight edu_female3-edu_female7 sameedu_max moreedu otheredu_dum_female science_female comm_female otherfield_female samenoedu noedu_female nofield_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female if brides==1 & match~=1, absorb(SI), [aw=weight];
estimates store rank_sbig_brides;
areg rank caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight income_pred_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female if brides==1 & match~=1, absorb(SI), [aw=weight];
estimates store rank_limited_brides;
preserve;
drop income_pred_female income_pred_male;
keep if brides==1 & match!=1;
xi i.SI;

gen byte cons=1;
foreach X of varlist rank logincome_female edu_female3-edu_female7 otheredu_dum_female science_female comm_female otherfield_female noedu_female nofield_female logwage_female nowage_female caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female _I* cons{;
replace `X'=`X'*sqrt(weight);
};
reg logincome_female edu_female3-edu_female7 otheredu_dum_female science_female comm_female otherfield_female noedu_female nofield_female logwage_female nowage_female cons if noincome_female==0, nocons;
predict income_pred_female;
predict double e, res, if noincome_female==0;
replace e=0 if noincome_female==1;
matrix V1=e(V);

reg rank caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight income_pred_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female _I* cons, nocons;
matrix V_c=e(V);
predict double u, res;
matrix accum s2=u, nocons;
matrix s2=s2/e(df_r);
matrix accum Vr=caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight income_pred_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female _I* cons, nocons;
matrix V2=inv(Vr);
scalar zz=_b[income_pred_female];

matrix accum C=edu_female3-edu_female7 otheredu_dum_female science_female comm_female otherfield_female noedu_female nofield_female logwage_female nowage_female cons caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight income_pred_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female _I* cons [iw=zz*u*u], nocons;
matrix accum R=edu_female3-edu_female7 otheredu_dum_female science_female comm_female otherfield_female noedu_female nofield_female logwage_female nowage_female cons caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight income_pred_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female _I* cons [iw=e*u], nocons;

matrix C=C[15..335, 1..14];
matrix R=R[15..335, 1..14];

matrix M = s2*V2 + (V2*(C*V1*C'-R*V1*C'-C*V1*R')*V2);
matrix M=M[1..44,1..44];
capture program drop doit;
matrix b=e(b);
matrix b=b[1,1..44];
program define doit, eclass;
	ereturn post b M;
	ereturn local vcetype "Mtopel";
	ereturn display;
end;
doit;

restore;
xi i.SI;
oprobit rank caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight edu_female3-edu_female7 sameedu_max moreedu otheredu_dum_female science_female comm_female otherfield_female samenoedu noedu_female nofield_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female _I* if brides==1 & match~=1 [aw=weight];
estimates store rank_oprobit_brides;
drop _I*;

estout * using tab/table_C7.txt, keep(samecaste samemain_caste_rank diff_above diff_below casteimportantmatch casteimportantdiff castenotimpmatch castenotimpdiff diffage diffagesq diffheight diffheightsq edu_female3 edu_female4 edu_female5 edu_female6 edu_female7 sameedu_max moreedu otheredu_dum_female comm_female science_female otherfield_female calcutta_female sameresstatus samefamily_origin skinrank_female vbeauty_female beauty_female) stats(r2_a N, fmt(%9.4f %9.0g))cells(b(star fmt(%9.4f)) se(par fmt(%9.4f)) ) starlevels(* 0.10 ** 0.05 *** 0.01) style(tex) replace notype margin mlabels(, numbers );
estimates clear;

*TABLE C6;
areg rank caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3-edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male if brides==0 & match~=1, absorb(SI), [aw=weight];
estimates store rank_big_grooms;
areg rank age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3-edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male if brides==0 & match~=1, absorb(SI), [aw=weight];
estimates store rank_nocaste_grooms;
areg rank caste_no3-caste_no9 samecaste samemain_caste_rank diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3-edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male if brides==0 & match~=1, absorb(SI), [aw=weight];
estimates store rank_sbig_grooms;
areg rank caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight income_pred_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin if brides==0 & match~=1, absorb(SI), [aw=weight];
estimates store rank_limited_grooms;
preserve;
drop income_pred_female income_pred_male;
keep if brides==0 & match!=1;
xi i.SI;

gen byte cons=1;
foreach X of varlist rank logincome_male edu_male3-edu_male7 otheredu_dum_male science_male comm_male otherfield_male noedu_male nofield_male logwage_male nowage_male caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin _I* cons{;
replace `X'=`X'*sqrt(weight);
};

reg logincome_male edu_male3-edu_male7 otheredu_dum_male science_male comm_male otherfield_male noedu_male nofield_male logwage_male nowage_male cons if noincome_male==0, nocons;
predict income_pred_male;
predict double e, res, if noincome_male==0;
replace e=0 if noincome_male==1;
matrix V1=e(V);

reg rank caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight income_pred_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin _I* cons, nocons;
matrix V_c=e(V);
predict double u, res;
matrix accum s2=u, nocons;
matrix s2=s2/e(df_r);
matrix accum Vr=caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight income_pred_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin _I* cons, nocons;
matrix V2=inv(Vr);
scalar zz=_b[income_pred_male];

matrix accum C=edu_male3-edu_male7 otheredu_dum_male science_male comm_male otherfield_male noedu_male nofield_male logwage_male nowage_male cons caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight income_pred_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin _I* cons [iw=zz*u*u], nocons;
matrix accum R=edu_male3-edu_male7 otheredu_dum_male science_male comm_male otherfield_male noedu_male nofield_male logwage_male nowage_male cons caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight income_pred_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin _I* cons [iw=e*u], nocons;

matrix C=C[15..559, 1..14];
matrix R=R[15..559, 1..14];

matrix M = s2*V2 + (V2 * (C*V1*C' - R*V1*C' - C*V1*R') * V2);
matrix b=e(b);
matrix M=M[1..39,1..39];
matrix b=b[1,1..39];

doit;

restore;
xi i.SI;
oprobit rank caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste casteimportantmatch casteimportantdiff casteimportantno castenotimpmatch castenotimpdiff castenotimpno age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3-edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male _I* if brides==0 & match~=1 [aw=weight];
estimates store rank_oprobit_grooms;

clear;

estout * using tab/table_C6.txt, keep(samecaste samemain_caste_rank diff_above diff_below casteimportantmatch casteimportantdiff castenotimpmatch castenotimpdiff diffage diffagesq diffheight diffheightsq edu_male3 edu_male4 edu_male5 edu_male6 edu_male7 sameedu_max moreedu otheredu_dum_male comm_male science_male otherfield_male calcutta_male sameresstatus samefamily_origin logwage_male logincome_male) stats(r2_a N, fmt(%9.4f %9.0g))cells(b(star fmt(%9.4f)) se(par fmt(%9.4f)) ) starlevels(* 0.10 ** 0.05 *** 0.01) style(tex) replace notype margin mlabels(, numbers );
estimates clear;

*TABLE C8;

use data/reverse_bridewanted_AEJ;

foreach i in main_caste_rank nocaste edu_max noedu res nores nofamily noage noheight caste{;
gen same`i'=`i'_male==`i'_female;
replace same`i'=0 if `i'_male==0 | `i'_female==0;
};

replace samecaste=1 if caste_male==1 & main_caste_rank_female==1;
replace samecaste=1 if caste_female==1 & main_caste_rank_male==1;
replace samecaste=1 if caste_male==18 & main_caste_rank_female==2;
replace samecaste=1 if caste_female==18 & main_caste_rank_male==2;
replace samecaste=1 if caste_male==9 & main_caste_rank_female==3;
replace samecaste=1 if caste_female==9 & main_caste_rank_male==3;
replace samecaste=1 if caste_male==20 & main_caste_rank_female==4 & caste_female~=24 & caste_female~=83 & caste_female~=87 & caste_female~=101;
replace samecaste=1 if caste_female==20 & main_caste_rank_male==4 & caste_male~=24 & caste_male~=83 & caste_male~=87 & caste_male~=101;
replace samecaste=1 if caste_male==16 & (caste_female==17|caste_female==100);
replace samecaste=1 if caste_female==16 & (caste_male==17 & caste_male==100);
replace samecaste=1 if caste_male==25 & ((caste_female>=26 & caste_female<=30)|caste_female==35|caste_female==37|caste_female==39|caste_female==100|caste_female==105);
replace samecaste=1 if caste_female==25 & ((caste_male>=26 & caste_male<=30)|caste_male==35|caste_male==37|caste_male==39|caste_male==100|caste_male==105);
replace samecaste=1 if caste_male==31 & (caste_female==32|caste_female==33|caste_female==40|caste_female==41|caste_female==85);
replace samecaste=1 if caste_female==31 & (caste_male==32|caste_male==33|caste_male==40|caste_male==41|caste_male==85);
replace samecaste=1 if caste_male==34 & caste_female==35;
replace samecaste=1 if caste_female==34 & caste_male==35;
replace samecaste=1 if caste_male==36 & caste_female==37;
replace samecaste=1 if caste_female==36 & caste_male==37;
replace samecaste=1 if caste_male==38 & caste_female==39;
replace samecaste=1 if caste_female==38 & caste_male==39;
replace samecaste=1 if caste_male==42 & caste_female==43;
replace samecaste=1 if caste_female==42 & caste_male==43;
replace samecaste=1 if caste_male==44 & (caste_female==45|caste_female==46);
replace samecaste=1 if caste_female==44 & (caste_male==45|caste_male==46);
replace samecaste=1 if caste_male==53 & caste_female==54;
replace samecaste=1 if caste_female==53 & caste_male==54;
replace samecaste=1 if caste_male==56 & caste_female==57;
replace samecaste=1 if caste_female==56 & caste_male==57;
replace samecaste=1 if caste_male==58 & caste_female>=59 & caste_female<=63;
replace samecaste=1 if caste_female==58 & caste_male>=59 & caste_male<=63;
replace samecaste=1 if caste_male==79 & main_caste_rank_female==8;
replace samecaste=1 if caste_female==79 & main_caste_rank_male==8;

replace samecaste=0 if samemain_caste_rank==0;

gen diffcaste=-(main_caste_rank_male-main_caste_rank_female);
replace diffcaste=0 if main_caste_rank_male==0 | main_caste_rank_female==0;

gen diffedu=edu_max_male-edu_max_female;
replace diffedu=0 if edu_max_male==0|edu_max_female==0;
gen diffage=age_male-age_female;
replace diffage=0 if age_male==0|age_female==0;
gen diffheight=height_male-height_female;
replace diffheight=0 if height_male==0|height_female==0;

gen diffagesq=diffage^2;
gen diffheightsq=diffheight^2;

gen moreedu=edu_max_male>edu_max_female;
replace moreedu=0 if edu_max_male==0|edu_max_female==0;

replace res_male=res_male-1;
gen city_male=res_male==2;
gen wbengal_male=res_male==3;
gen otherres_male=res_male==4|res_male==5;

gen samefamily_origin=family_origin_male==family_origin_female & samenofamily==0;
gen wbmatch=family_origin_male*samefamily_origin;
gen ebmatch=(1-family_origin_male)*samefamily_origin;

rename sameres sameresstatus;
rename nofamily_male nofamily_origin_male;
rename samenofamily samenofamily_origin;

tab main_caste_rank_male, gen(caste_no);
tab edu_max_male, gen(edu_male);

rename other_edu_male otheredu_dum_male;

gen feid=si*100+responseid;

gen abovecaste=main_caste_rank_male<main_caste_rank_female & nocaste_female==0 & nocaste_male==0;
gen belowcaste=main_caste_rank_male>main_caste_rank_female & nocaste_female==0 & nocaste_male==0;
gen diff_above=diffcaste*abovecaste;
gen diff_below=diffcaste*belowcaste;

gen age_age=age_female*age_male;
gen age_noage=age_female*noage_male;
gen noage_age=noage_female*age_male;
gen height_height=height_female*height_male;
gen height_noheight=height_female*noheight_male;
gen noheight_height=noheight_female*height_male;

xtreg considered caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3-edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male if sample==1, fe i(feid);
estimates store considered_big_grooms;

clogit considered caste_no3-caste_no9 samecaste diff_above diff_below nocaste_male samenocaste age_noage noage_age diffage diffagesq noage_male samenoage height_noheight noheight_height diffheight diffheightsq noheight_male samenoheight edu_male3-edu_male7 sameedu_max moreedu otheredu_dum_male science_male comm_male otherfield_male noedu_male samenoedu nofield_male logincome_male noincome_male calcutta_male sameresstatus nores_male samenores family_origin_male samefamily_origin nofamily_origin_male samenofamily_origin logwage_male nowage_male, group(feid) iter(200), if sample==1;
estimates store considered_big_logit_grooms;

clear;
use data/reverse_groomwanted_AEJ;

foreach i in main_caste_rank nocaste edu_max noedu res nores nofamily noage noheight caste{;
gen same`i'=`i'_male==`i'_female;
replace same`i'=0 if `i'_male==0 | `i'_female==0;
};

replace samecaste=1 if caste_male==1 & main_caste_rank_female==1;
replace samecaste=1 if caste_female==1 & main_caste_rank_male==1;
replace samecaste=1 if caste_male==18 & main_caste_rank_female==2;
replace samecaste=1 if caste_female==18 & main_caste_rank_male==2;
replace samecaste=1 if caste_male==9 & main_caste_rank_female==3;
replace samecaste=1 if caste_female==9 & main_caste_rank_male==3;
replace samecaste=1 if caste_male==20 & main_caste_rank_female==4 & caste_female~=24 & caste_female~=83 & caste_female~=87 & caste_female~=101;
replace samecaste=1 if caste_female==20 & main_caste_rank_male==4 & caste_male~=24 & caste_male~=83 & caste_male~=87 & caste_male~=101;
replace samecaste=1 if caste_male==16 & (caste_female==17|caste_female==100);
replace samecaste=1 if caste_female==16 & (caste_male==17 & caste_male==100);
replace samecaste=1 if caste_male==25 & ((caste_female>=26 & caste_female<=30)|caste_female==35|caste_female==37|caste_female==39|caste_female==100|caste_female==105);
replace samecaste=1 if caste_female==25 & ((caste_male>=26 & caste_male<=30)|caste_male==35|caste_male==37|caste_male==39|caste_male==100|caste_male==105);
replace samecaste=1 if caste_male==31 & (caste_female==32|caste_female==33|caste_female==40|caste_female==41|caste_female==85);
replace samecaste=1 if caste_female==31 & (caste_male==32|caste_male==33|caste_male==40|caste_male==41|caste_male==85);
replace samecaste=1 if caste_male==34 & caste_female==35;
replace samecaste=1 if caste_female==34 & caste_male==35;
replace samecaste=1 if caste_male==36 & caste_female==37;
replace samecaste=1 if caste_female==36 & caste_male==37;
replace samecaste=1 if caste_male==38 & caste_female==39;
replace samecaste=1 if caste_female==38 & caste_male==39;
replace samecaste=1 if caste_male==42 & caste_female==43;
replace samecaste=1 if caste_female==42 & caste_male==43;
replace samecaste=1 if caste_male==44 & (caste_female==45|caste_female==46);
replace samecaste=1 if caste_female==44 & (caste_male==45|caste_male==46);
replace samecaste=1 if caste_male==53 & caste_female==54;
replace samecaste=1 if caste_female==53 & caste_male==54;
replace samecaste=1 if caste_male==56 & caste_female==57;
replace samecaste=1 if caste_female==56 & caste_male==57;
replace samecaste=1 if caste_male==58 & caste_female>=59 & caste_female<=63;
replace samecaste=1 if caste_female==58 & caste_male>=59 & caste_male<=63;
replace samecaste=1 if caste_male==79 & main_caste_rank_female==8;
replace samecaste=1 if caste_female==79 & main_caste_rank_male==8;

replace samecaste=0 if samemain_caste_rank==0;

gen diffcaste=-(main_caste_rank_male-main_caste_rank_female);
replace diffcaste=0 if main_caste_rank_male==0 | main_caste_rank_female==0;
gen abovecaste=main_caste_rank_male<main_caste_rank_female & nocaste_female==0 & nocaste_male==0;
gen belowcaste=main_caste_rank_male>main_caste_rank_female & nocaste_female==0 & nocaste_male==0;
gen diff_above=diffcaste*abovecaste;
gen diff_below=diffcaste*belowcaste;

gen diffedu=edu_max_male-edu_max_female;
replace diffedu=0 if edu_max_male==0|edu_max_female==0;
gen diffage=age_male-age_female;
replace diffage=0 if age_male==0|age_female==0;
gen diffheight=height_male-height_female;
replace diffheight=0 if height_male==0|height_female==0;

gen diffagesq=diffage^2;
gen diffheightsq=diffheight^2;

gen moreedu=edu_max_male>edu_max_female;
replace moreedu=0 if edu_max_male==0|edu_max_female==0;

replace res_female=res_female-1;
gen city_female=res_female==2;
gen wbengal_female=res_female==3;
gen otherres_female=res_female==4|res_female==5;

gen samefamily_origin=family_origin_male==family_origin_female & samenofamily==0;
gen wbmatch=family_origin_male*samefamily_origin;
gen ebmatch=(1-family_origin_male)*samefamily_origin;

rename vbeautiful_female vbeauty_female;
rename beautiful_female beauty_female;

tab main_caste_rank_female, gen(caste_nof);
tab edu_max_female, gen(edu_female);
rename other_edu_female otheredu_dum_female;

rename sameres sameresstatus;
rename nofamily_female nofamily_origin_female;
rename samenofamily samenofamily_origin;

gen feid=si*100+responseid;

gen age_age=age_female*age_male;
gen age_noage=age_female*noage_male;
gen noage_age=noage_female*age_male;
gen height_height=height_female*height_male;
gen height_noheight=height_female*noheight_male;
gen noheight_height=noheight_female*height_male;

xtreg considered caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight edu_female3-edu_female7 sameedu_max moreedu otheredu_dum_female science_female comm_female otherfield_female samenoedu noedu_female nofield_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female if sample==1, fe i(feid);
estimates store considered_big_brides;
clogit considered caste_nof3-caste_nof9 samecaste diff_above diff_below nocaste_female samenocaste age_noage noage_age diffage diffagesq noage_female samenoage height_noheight noheight_height diffheight diffheightsq noheight_female samenoheight edu_female3-edu_female7 sameedu_max moreedu otheredu_dum_female science_female comm_female otherfield_female samenoedu noedu_female nofield_female skinrank_female noskin_female calcutta_female sameresstatus nores_female samenores family_origin_female samefamily_origin nofamily_origin_female samenofamily_origin beauty_female vbeauty_female nobeauty_female, group(feid) iter(200), if sample==1;
estimates store considered_big_logit_brides;

estout * using tab/table_C8B.txt, keep(samecaste diff_above diff_below diffage diffagesq diffheight diffheightsq edu_male3 edu_male4 edu_male5 edu_male6 edu_male7 edu_female3 edu_female4 edu_female5 edu_female6 edu_female7 sameedu_max moreedu otheredu_dum_male otheredu_dum_female comm_male science_male otherfield_male comm_female science_female otherfield_female skinrank_female logincome_male calcutta_male calcutta_female sameresstatus family_origin_male family_origin_female samefamily_origin  beauty_female vbeauty_female logwage_male) stats(r2_a N, fmt(%9.4f %9.0g))cells(b(star fmt(%9.4f)) se(par fmt(%9.4f)) ) starlevels(* 0.10 ** 0.05 *** 0.01) style(tex) replace notype mlabels(, numbers );
estimates clear;