capture log close
set mem 500m
set matsize 800
set more off
log using log/correlations_stable, replace
#delimit ;

use data/stable;
replace family_origin_male=. if nofamily_origin_male==1;
replace resstatus_male=. if nores_male==1;
replace age_male=. if noage_male==1;
replace skinrank_male=. if noskin_male==1;
replace main_caste_rank_male=. if nocaste_male==1;
replace calcutta_male=. if nores_male==1;
replace height_male=. if noheight_male==1;
replace vbeauty_male=. if nobeauty_male==1;
replace beauty_male=. if nobeauty_male==1;
replace edu_max_male=. if edu_max_male==0;
replace otheredu_dum_male=. if noedu_male==1;
replace logincome_male=. if noincome_male==1;
replace logwage_male=. if nowage_male==1;
replace logincome_male=exp(logincome_male);
replace human_male=. if nofield_male==1;
replace comm_male=. if nofield_male==1;
replace science_male=. if nofield_male==1;
replace otherfield_male=. if nofield_male==1;


replace family_origin_female=. if nofamily_origin_female==1;
replace resstatus_female=. if nores_female==1;
replace age_female=. if noage_female==1;
replace skinrank_female=. if noskin_female==1;
replace main_caste_rank_female=. if nocaste_female==1;
replace calcutta_female=. if nores_female==1;
replace height_female=. if noheight_female==1;
replace vbeauty_female=. if nobeauty_female==1;
replace beauty_female=. if nobeauty_female==1;
replace edu_max_female=. if edu_max_female==0;
replace otheredu_dum_female=. if noedu_female==1;
replace logincome_female=. if noincome_female==1;
replace logwage_female=. if nowage_female==1;
replace logincome_female=exp(logincome_female);
replace human_female=. if nofield_female==1;
replace comm_female=. if nofield_female==1;
replace science_female=. if nofield_female==1;
replace otherfield_female=. if nofield_female==1;

gen qual_female=cons_female_b_nocaste;
gen qual_male=cons_male_b_nocaste;

keep human_male human_female comm_female comm_male science_male science_female otherfield_male otherfield_female age_male age_female height_male height_female main_caste_rank_male main_caste_rank_female caste_male caste_female edu_max_male edu_max_female calcutta_male calcutta_female resstatus_male resstatus_female family_origin_male family_origin_female logwage_male logincome_male logwage_female logincome_female skinrank_female vbeauty_female beauty_female qual_male qual_female diff* same* outcome_good brides num considered match; 
drop sameno* samemain_* samefield sameres samecaste_*;
save data/stable_bootstrap, replace;

bsample _N;
keep if brides==1;
keep if num==1;
keep *_male outcome_good;
gen single=1-outcome_good;
collapse *_male, by(single);
foreach i of varlist main_caste_rank_male-qual_male{;
gen d_`i'=`i'-`i'[_n-1];
};
keep if single==1;
save matlab/means_males_observed, replace;

local j=2;
while `j'<1001{;
use data/stable_bootstrap;
bsample _N;
keep if brides==1;
keep if num==1;
keep *_male outcome_good;
gen single=1-outcome_good;
collapse *_male, by(single);
foreach i of varlist main_caste_rank_male-qual_male{;
gen d_`i'=`i'-`i'[_n-1];
};
keep if single==1;
append using matlab/means_males_observed;
save matlab/means_males_observed, replace;
local j=`j'+1;
};

use data/stable_bootstrap;
bsample _N;
keep if brides==0;
keep if num==1;
keep *_female outcome_good;
gen single=1-outcome_good;
collapse *_female, by(single);
foreach i of varlist main_caste_rank_female-qual_female{;
gen d_`i'=`i'-`i'[_n-1];
};
keep if single==1;
save matlab/means_females_observed, replace;

local j=2;
while `j'<1001{;
use data/stable_bootstrap;
bsample _N;
keep if brides==0;
keep if num==1;
keep *_female outcome_good;
gen single=1-outcome_good;
collapse *_female, by(single);
foreach i of varlist main_caste_rank_female-qual_female{;
gen d_`i'=`i'-`i'[_n-1];
};
keep if single==1;
append using matlab/means_females_observed;
save matlab/means_females_observed, replace;
local j=`j'+1;
};


use data/stable_bootstrap;
keep if considered==1| match==1;
bsample _N;
foreach k in logwage logincome age height family_origin resstatus edu_max calcutta main_caste_rank qual{;
gen diff_`k'_cons=`k'_male-`k'_female if considered==1;
gen prod_`k'=`k'_male*`k'_female if considered==1;
egen mean_`k'_male=mean(`k'_male) if prod_`k'~=. & considered==1;
egen mean_`k'_female=mean(`k'_female) if prod_`k'~=. & considered==1;
egen mean_`k'_prod=mean(prod_`k');
egen sd_`k'_male=sd(`k'_male) if prod_`k'~=. & considered==1;
egen sd_`k'_female=sd(`k'_female) if prod_`k'~=. & considered==1;
egen size_`k'=count(prod_`k');
gen corr_`k'_cons=((mean_`k'_prod-(mean_`k'_male*mean_`k'_female))*size_`k')/((size_`k'-1)*(sd_`k'_male)*(sd_`k'_female));
drop mean* prod* sd* size*;
};

foreach k in logwage logincome age height family_origin resstatus edu_max calcutta main_caste_rank qual{;
gen diff_`k'_match=`k'_male-`k'_female if match==1;
gen prod_`k'=`k'_male*`k'_female if match==1;
egen mean_`k'_male=mean(`k'_male) if prod_`k'~=. & match==1;
egen mean_`k'_female=mean(`k'_female) if prod_`k'~=. & match==1;
egen mean_`k'_prod=mean(prod_`k');
egen sd_`k'_male=sd(`k'_male) if prod_`k'~=. & match==1;
egen sd_`k'_female=sd(`k'_female) if prod_`k'~=. & match==1;
egen size_`k'=count(prod_`k');
gen corr_`k'_match=((mean_`k'_prod-(mean_`k'_male*mean_`k'_female))*size_`k')/((size_`k'-1)*(sd_`k'_male)*(sd_`k'_female));
drop mean* prod* sd* size*;
};

gen samefamily_cons=samefamily_origin if considered==1;
gen samefamily_match=samefamily_origin if match==1;
gen sameedu_cons=sameedu_max if considered==1;
gen sameedu_match=sameedu_max if match==1;
gen sameres_cons=sameresstatus if considered==1;
gen sameres_match=sameresstatus if match==1;
gen samecaste_cons=samecaste if considered==1;
gen samecaste_match=samecaste if match==1;

collapse (mean)*_cons (mean)*_match;
save matlab/correlations_stable, replace;

local j=2;
while `j'<1001{;
use data/stable_bootstrap;
bsample _N;
keep if considered==1| match==1;
bsample _N;
foreach k in logwage logincome age height family_origin resstatus edu_max calcutta main_caste_rank qual{;
gen diff_`k'_cons=`k'_male-`k'_female if considered==1;
gen prod_`k'=`k'_male*`k'_female if considered==1;
egen mean_`k'_male=mean(`k'_male) if prod_`k'~=. & considered==1;
egen mean_`k'_female=mean(`k'_female) if prod_`k'~=. & considered==1;
egen mean_`k'_prod=mean(prod_`k');
egen sd_`k'_male=sd(`k'_male) if prod_`k'~=. & considered==1;
egen sd_`k'_female=sd(`k'_female) if prod_`k'~=. & considered==1;
egen size_`k'=count(prod_`k');
gen corr_`k'_cons=((mean_`k'_prod-(mean_`k'_male*mean_`k'_female))*size_`k')/((size_`k'-1)*(sd_`k'_male)*(sd_`k'_female));
drop mean* prod* sd* size*;
};

foreach k in logwage logincome age height family_origin resstatus edu_max calcutta main_caste_rank qual{;
gen diff_`k'_match=`k'_male-`k'_female if match==1;
gen prod_`k'=`k'_male*`k'_female if match==1;
egen mean_`k'_male=mean(`k'_male) if prod_`k'~=. & match==1;
egen mean_`k'_female=mean(`k'_female) if prod_`k'~=. & match==1;
egen mean_`k'_prod=mean(prod_`k');
egen sd_`k'_male=sd(`k'_male) if prod_`k'~=. & match==1;
egen sd_`k'_female=sd(`k'_female) if prod_`k'~=. & match==1;
egen size_`k'=count(prod_`k');
gen corr_`k'_match=((mean_`k'_prod-(mean_`k'_male*mean_`k'_female))*size_`k')/((size_`k'-1)*(sd_`k'_male)*(sd_`k'_female));
drop mean* prod* sd* size*;
};

gen samefamily_cons=samefamily_origin if considered==1;
gen samefamily_match=samefamily_origin if match==1;
gen sameedu_cons=sameedu_max if considered==1;
gen sameedu_match=sameedu_max if match==1;
gen sameres_cons=sameresstatus if considered==1;
gen sameres_match=sameresstatus if match==1;
gen samecaste_cons=samecaste if considered==1;
gen samecaste_match=samecaste if match==1;

collapse (mean)*_cons (mean)*_match;
append using matlab/correlations_stable;
save matlab/correlations_stable, replace;
local j=`j'+1;
};

clear;

use correlations_stable;

foreach k in logwage logincome age height family_origin resstatus edu_max calcutta human comm science otherfield main_caste_rank qual{;
egen p2_diff_`k'=pctile(diff_`k'), p(2.5);
egen p97_diff_`k'=pctile(diff_`k'), p(97.5);

egen p2_corr_`k'=pctile(corr_`k'), p(2.5);
egen p97_corr_`k'=pctile(corr_`k'), p(97.5);
};
foreach k in edu res field family caste{;
egen p2_same`k'=pctile(same`k'), p(2.5);
egen p97_same`k'=pctile(same`k'), p(97.5);
};

foreach k in logwage logincome age height family_origin resstatus edu_max main_caste_rank qual{;
sum diff_`k' p2_diff_`k' p97_diff_`k' corr_`k' p2_corr_`k' p97_corr_`k';
};
foreach k in edu res family caste{;
sum same`k' p2_same`k' p97_same`k';
};





