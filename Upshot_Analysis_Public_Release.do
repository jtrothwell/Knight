***This Stata code was written by Jonathan Rothwell of Gallup to do analysis for The New York Times Upshot.
***Email jonathan_rothwell@gallup.com for corrections of questions.

cd ["ENTER YOUR FILE LOCATION"]
use "NewsLens_Experiment1_Public_Release.dta", clear

***CREATE VARIABLES****

***Experimental groups****
destring channel_id, replace ignore(null)
drop if channel_id==.

gen blind=1 if channel_id==1 | channel_id==3 
replace blind=0 if channel_id==2 | channel_id==4

***No photo content was shown for no-image group
gen image=1 if channel_id==3 | channel_id==4 
replace image=0 if channel_id==1 | channel_id==2

*Trump approval
gen trump=1 if q1_approval_trump==1
replace trump=0 if q1_approval_trump==2

*Measure of civic knowledge
egen informed=rowmean(q16_next_inline_potus q17_branches_us_gov q19_num_senators_state q21_johnroberts_position q22_num_seats_by_party q23_num_women_justices q24_sanctuary_cities)

*Generate number of ratings by article and by article-group
bysort content_id: egen N_content=count(rating_scale_response)
bysort content_id blind: egen N_content_by_group=count(rating_scale_response)

*Generate less biased measure of article's trustworthiness
bysort content_id: egen truthx=mean(rating_scale_response) if blind==1
bysort content_id: egen truth=max(truthx)

*Main measure of bias="bias"
gen bias=abs(truth-rating_scale_response)
gen bias_neg=truth-rating_scale_response
gen bias_pos=rating_scale_response-truth

**Create binary variables for main demographic items 
foreach x in q26_trust_media demo_gender demo_ethnicity demo_marital_status demo_political_affiliation demo_race_2015_new demo_education_new {
tab `x', gen(T`x')
}

*Binary variables specifically for political views
gen vlib=1 if q34_political_views==1
replace vlib=0 if q34_political_views!=1 & q34_political_views<=5
gen lib=1 if q34_political_views==2
replace lib=0 if q34_political_views!=2 & q34_political_views<=5
gen mod=1 if q34_political_views==3
replace mod=0 if q34_political_views!=3 & q34_political_views<=5
gen con=1 if q34_political_views==4
replace con=0 if q34_political_views!=4 & q34_political_views<=5
gen vcon=1 if q34_political_views==5
replace vcon=0 if q34_political_views!=5 & q34_political_views<=5

**Change in political views
gen more_con=1 if q9_change_political_view==1
replace more_con=0 if q9_change_political_view==2 |  q9_change_political_view==3
gen more_lib=1 if q9_change_political_view==3
replace more_lib=0 if q9_change_political_view==2 |  q9_change_political_view==1

*Extent of media consumption
gen news_not_closely=1 if q8_follow_news==3 | q8_follow_news==4
replace news_not_closely=0 if q8_follow_news==2 | q8_follow_news==1
gen news_very_closely=1 if q8_follow_news==1
replace news_very_closely=0 if q8_follow_news>=2 & q8_follow_news<5
gen hour_or_more=1 if  q25_time_spent_news>=4 & q25_time_spent_news<=6
replace hour_or_more=0 if  q25_time_spent_news<4

*Age and square term to check for non-linearity
gen age_sq=demo_age^2

**Selected preferred sources with large N sizes and hypotheisized effects on bias
gen Fox_News=1 if q28_name_trusted_source_cleaned=="Fox News"
replace Fox_News=0 if q28_name_trusted_source_cleaned!="Fox News"
gen Rush=1 if q28_name_trusted_source_cleaned=="Rush Limbaugh"
replace Rush=0 if q28_name_trusted_source_cleaned!="Rush Limbaugh"
gen MSNBC=1 if q28_name_trusted_source_cleaned=="MSNBC"
replace MSNBC=0 if q28_name_trusted_source_cleaned!="MSNBC"
gen NYT=1 if q28_name_trusted_source_cleaned=="New York Times"
replace NYT=0 if q28_name_trusted_source_cleaned!="New York Times"
gen NPR=1 if q28_name_trusted_source_cleaned=="NPR"
replace NPR=0 if q28_name_trusted_source_cleaned!="NPR"
gen PBS=1 if q28_name_trusted_source_cleaned=="PBS"
replace PBS=0 if q28_name_trusted_source_cleaned!="PBS"
gen WSJ=1 if q28_name_trusted_source_cleaned=="Wall Street Journal"
replace WSJ=0 if q28_name_trusted_source_cleaned!="Wall Street Journal"
gen CNN=1 if q28_name_trusted_source_cleaned=="CNN"
replace CNN=0 if q28_name_trusted_source_cleaned!="CNN"
gen WAPOST=1 if q28_name_trusted_source_cleaned=="Washington Post"
replace WAPOST=0 if q28_name_trusted_source_cleaned!="Washington Post"

**Create value labels for trust of media item and political views
destring q26_trust_media, replace
label define q26_label 1 "A great deal" 2 "A fair amount" 3 "Not very much" 4 "None at all"
label values q26_trust_media q26_label
label define q34_label 1 "Very liberal" 2 "Liberal" 3 "Moderate" 4 "Conservative" 5 "Very conservative"
label values q34_political_views q34_label

*Trust of media?
gen trust_media=1 if q26_trust_media==1
replace trust_media=0 if q26_trust_media==2 | q26_trust_media==3 | q26_trust_media==4
gen fair_media=1 if q26_trust_media==2
replace fair_media=0 if q26_trust_media==1 | q26_trust_media==3 | q26_trust_media==4
gen notmuch_media=1 if q26_trust_media==3
replace notmuch_media=0 if q26_trust_media==1 | q26_trust_media==2 | q26_trust_media==4
gen distrust_media=1 if q26_trust_media==4
replace distrust_media=0 if q26_trust_media==3 | q26_trust_media==2 | q26_trust_media==1

*Classification of article content
tab content_category, gen(topic)
rename topic1 economy
rename topic3 science

*More on article content--identify text in title or body
foreach x in Trump Clinton Democrat Republican GOP Administration political voters  campaign {
gen T_`x' = regexm(content_title_clean, "`x'")
gen C_`x' = regexm(content_body_clean, "`x'")
gen mention_`x'=1 if T_`x'==1 | C_`x'==1
replace mention_`x'=0 if T_`x'==0 & C_`x'==0
drop T_* C_*
}

foreach x in "climate" "abortion"  "unarmed" "immigration" "trade" "immigrants" "border" "terrorist" "attack"  "NRA"  "sanctuary"  {
gen T_`x' = regexm(content_title_clean, "`x'")
gen C_`x' = regexm(content_body_clean, "`x'")
gen mention_`x'=1 if T_`x'==1 | C_`x'==1
replace mention_`x'=0 if T_`x'==0 & C_`x'==0
drop T_* C_*
}

foreach x in socialist fascist communist "nationalist"  {
gen T_`x' = regexm(content_title_clean, "`x'")
gen C_`x' = regexm(content_body_clean, "`x'")
gen mention_`x'=1 if T_`x'==1 | C_`x'==1
replace mention_`x'=0 if T_`x'==0 & C_`x'==0
drop T_* C_*
}
sum mention_*

gen mention_NRA_2 = regexm(content_body_clean, "National Rile Association")
gen mention_BLM = regexm(content_body_clean, "Black Lives")
gen mention_2A = regexm(content_body_clean, "Second Amendment")
mvencode mention_NRA_2 mention_BLM mention_2A, mv(0) override

save "Cleaned_for_Analysis_Data_NewsLens_Experiment1.dta", replace

**The next sections use the re-coded data to create small files
*with summary statistics for relevant groups; at the end, I use
*multi-variable regression analysis to see which correlations are strongest in the face of confounding variables

**Describe sample: How many unqiue articles were rated?
use "Cleaned_for_Analysis_Data_NewsLens_Experiment1.dta", clear
sum rating_scale_response
duplicates drop content_id, force
sum rating_scale_response

**Describe sample: How many unqiue users?
use "Cleaned_for_Analysis_Data_NewsLens_Experiment1.dta", clear
duplicates drop external_user_id, force
sum blind
sum rating_scale_response

**Describe reduced sample: Describe sample: How many unqiue users and articles?
**Remove articles with less than 5 reviews
use "Cleaned_for_Analysis_Data_NewsLens_Experiment1.dta", clear
drop if N_content<5
sum rating_scale_response
duplicates drop content_id, force
sum rating_scale_response
use "Cleaned_for_Analysis_Data_NewsLens_Experiment1.dta", clear
drop if N_content<5
duplicates drop external_user_id, force
sum blind
sum rating_scale_response

*Party
use "Cleaned_for_Analysis_Data_NewsLens_Experiment1.dta", clear
**Remove articles with less than 5 reviews
drop if N_content<5
keep if blind==0

*Calculate number of unique users by variable
bysort demo_political_affiliation external_user_id: gen nvals = _n ==1
bysort demo_political_affiliation: replace nvals = sum(nvals)
bysort demo_political_affiliation: replace nvals = nvals[_N] 

*Large bias thresholds
gen bias3ppt=1 if bias>=3 & bias<=5
replace bias3ppt=0 if bias<3
gen bias2ppt=1 if bias>=2 & bias<=5
replace bias2ppt=0 if bias<2
gen bias15ppt=1 if bias>=1.5 & bias<=5
replace bias15ppt=0 if bias<1.5
gen bias1ppt=1 if bias>=1 & bias<=5
replace bias1ppt=0 if bias<1

ren Tdemo_political_affiliation1 DEM
ren Tdemo_political_affiliation2 none
ren Tdemo_political_affiliation3 indie
ren Tdemo_political_affiliation4 leanDEM
ren Tdemo_political_affiliation5 leanGOP
ren Tdemo_political_affiliation6 GOP

*Generate standardized bias metric, where weight is the number of reviews/article 
sum bias [aw=N_content_by_group], detail
gen MEAN=r(mean)
gen STD=r(sd)
gen Zbias=(bias-MEAN)/STD

collapse (count) N=bias (first) nvals (mean) bias15ppt Zbias bias (semean) sebias15ppt=bias15ppt seZbias=Zbias [aw=N_content_by_group], by(demo_political_affiliation)
gsort -Zbias
gen up_bias=bias15ppt+(sebias15ppt*1.96)
gen low_bias=bias15ppt-(sebias15ppt*1.96)
order demo_political_affiliation bias15ppt low_bias up_bias
outsheet using "bias_by_party.csv", c replace

*Ideology
use "Cleaned_for_Analysis_Data_NewsLens_Experiment1.dta", clear
**Remove articles with less than 5 reviews
drop if N_content<5
keep if blind==0

*Calculate number of unique users by variable
bysort q34_political_views external_user_id: gen nvals = _n ==1
bysort q34_political_views: replace nvals = sum(nvals)
bysort q34_political_views: replace nvals = nvals[_N] 

*Generate standardized bias metric, where weight is the number of reviews/article 
sum bias [aw=N_content_by_group], detail
gen MEAN=r(mean)
gen STD=r(sd)
gen Zbias=(bias-MEAN)/STD

gen bias15ppt=1 if bias>=1.5 & bias<=5
replace bias15ppt=0 if bias<1.5

collapse (count) N=bias (first) nvals (mean) Zbias bias bias15ppt (semean) sebias15ppt=bias15ppt  seZbias=Zbias [aw=N_content_by_group], by(q34_political_views)
gsort -Zbias
gen up_bias=bias15ppt+(sebias15ppt*1.96)
gen low_bias=bias15ppt-(sebias15ppt*1.96)
edit
order q34_political_views bias15ppt low_bias up_bias
outsheet using "bias_by_ideology.csv", c replace

*by trust of media
use "Cleaned_for_Analysis_Data_NewsLens_Experiment1.dta", clear
drop if N_content<5
keep if blind==0

tab q26_trust_media

bysort q26_trust_media external_user_id: gen nvals = _n ==1
bysort q26_trust_media: replace nvals = sum(nvals)
bysort q26_trust_media: replace nvals = nvals[_N] 

*Generate standardized bias metric, where weight is the number of reviews/article 
sum bias [aw=N_content_by_group], detail
gen MEAN=r(mean)
gen STD=r(sd)
gen Zbias=(bias-MEAN)/STD

gen bias15ppt=1 if bias>=1.5 & bias<=5
replace bias15ppt=0 if bias<1.5

collapse (count) N=bias (first) nvals (mean) Zbias bias bias15ppt trump (semean) sebias15ppt=bias15ppt  seZbias=Zbias [aw=N_content_by_group], by(q26_trust_media)
gsort -Zbias
gen up_bias=bias15ppt+(sebias15ppt*1.96)
gen low_bias=bias15ppt-(sebias15ppt*1.96)

order q26_trust_media bias15ppt low_bias up_bias
outsheet using "bias_by_trust_media.csv", c replace

*Education
use "Cleaned_for_Analysis_Data_NewsLens_Experiment1.dta", clear
drop if N_content<5
keep if blind==0

bysort demo_education_new external_user_id: gen nvals = _n ==1
bysort demo_education_new: replace nvals = sum(nvals)
bysort demo_education_new: replace nvals = nvals[_N] 

gen MEAN=r(mean)
gen STD=r(sd)
gen Zbias=(bias-MEAN)/STD
gen bias15ppt=1 if bias>=1.5 & bias<=5
replace bias15ppt=0 if bias<1.5

collapse (count) N=bias (first) nvals (mean) Zbias bias bias15ppt trump (semean) sebias15ppt=bias15ppt  seZbias=Zbias [aw=N_content_by_group], by(demo_education_new)
gsort -Zbias
gen up_bias=bias15ppt+(sebias15ppt*1.96)
gen low_bias=bias15ppt-(sebias15ppt*1.96)

order demo_education_new bias15ppt low_bias up_bias nvals

edit
outsheet using "bias_by_edu.csv", c replace

*Trump
use "Cleaned_for_Analysis_Data_NewsLens_Experiment1.dta", clear
drop if N_content<5
keep if blind==0

bysort trump external_user_id: gen nvals = _n ==1
bysort trump: replace nvals = sum(nvals)
bysort trump: replace nvals = nvals[_N] 

sum bias [aw=N_content_by_group], detail
gen MEAN=r(mean)
gen STD=r(sd)
gen Zbias=(bias-MEAN)/STD
gen bias15ppt=1 if bias>=1.5 & bias<=5
replace bias15ppt=0 if bias<1.5

collapse (count) N=bias (first) nvals (mean) Zbias bias bias15ppt  (semean) sebias15ppt=bias15ppt  seZbias=Zbias [aw=N_content_by_group], by(trump)
gsort -Zbias
gen up_bias=bias15ppt+(sebias15ppt*1.96)
gen low_bias=bias15ppt-(sebias15ppt*1.96)

order trump bias15ppt low_bias up_bias
edit
outsheet using "bias_by_trump.csv", c replace

*by preferred source
use "Cleaned_for_Analysis_Data_NewsLens_Experiment1.dta", clear
drop if N_content<5
keep if blind==0

bysort q28_name_trusted_source_cleaned external_user_id: gen nvals = _n ==1
bysort q28_name_trusted_source_cleaned: replace nvals = sum(nvals)
bysort q28_name_trusted_source_cleaned: replace nvals = nvals[_N] 

gen bias15ppt=1 if bias>=1.5 & bias<=5
replace bias15ppt=0 if bias<1.5
sum bias15ppt [aw=N_content_by_group]

ren Tdemo_political_affiliation1 DEM
ren Tdemo_political_affiliation2 none
ren Tdemo_political_affiliation3 indie
ren Tdemo_political_affiliation4 leanDEM
ren Tdemo_political_affiliation5 leanGOP
ren Tdemo_political_affiliation6 GOP

sum bias [aw=N_content_by_group], detail
gen MEAN=r(mean)
gen STD=r(sd)
gen Zbias=(bias-MEAN)/STD

collapse (count) N=bias (first) nvals (mean) mod vlib vcon Zbias bias bias15ppt trump (semean) sebias15ppt=bias15ppt  seZbias=Zbias  [aw=N_content_by_group], by(q28_name_trusted_source_cleaned)
gsort -Zbias
gen up_bias=bias15ppt+(sebias15ppt*1.96)
gen low_bias=bias15ppt-(sebias15ppt*1.96)

*keep if >=5
keep if nvals>5
order q28_name_trusted_source_cleaned  bias15ppt low_bias up_bias
outsheet using "bias_by_trusted_news_source.csv", c replace
edit

*by gender
use "Cleaned_for_Analysis_Data_NewsLens_Experiment1.dta", clear
drop if N_content<5
keep if blind==0

gen bias15ppt=1 if bias>=1.5 & bias<=5
replace bias15ppt=0 if bias<1.5

bysort demo_gender external_user_id: gen nvals = _n ==1
bysort demo_gender: replace nvals = sum(nvals)
bysort demo_gender: replace nvals = nvals[_N] 

sum bias [aw=N_content_by_group], detail
gen MEAN=r(mean)
gen STD=r(sd)
gen Zbias=(bias-MEAN)/STD

collapse (count) N=bias (first) nvals (mean) Zbias bias bias15ppt  (semean) sebias15ppt=bias15ppt  seZbias=Zbias [aw=N_content_by_group], by(demo_gender)
gsort -bias
gen up_bias=bias15ppt+(sebias15ppt*1.96)
gen low_bias=bias15ppt-(sebias15ppt*1.96)

order demo_gender bias15ppt low_bias up_bias
outsheet using "bias_by_gender.csv", c replace
edit

*by race
use "Cleaned_for_Analysis_Data_NewsLens_Experiment1.dta", clear
drop if N_content<5
keep if blind==0

gen bias15ppt=1 if bias>=1.5 & bias<=5
replace bias15ppt=0 if bias<1.5

bysort demo_race_2015_new external_user_id: gen nvals = _n ==1
bysort demo_race_2015_new: replace nvals = sum(nvals)
bysort demo_race_2015_new: replace nvals = nvals[_N] 

sum bias [aw=N_content_by_group], detail
gen MEAN=r(mean)
gen STD=r(sd)
gen Zbias=(bias-MEAN)/STD

collapse (count) N=bias (first) nvals (mean) Zbias bias bias15ppt  (semean) sebias15ppt=bias15ppt  seZbias=Zbias [aw=N_content_by_group], by(demo_race_2015_new)
gsort -bias
gen up_bias=bias15ppt+(sebias15ppt*1.96)
gen low_bias=bias15ppt-(sebias15ppt*1.96)

order demo_race_2015_new bias15ppt low_bias up_bias
outsheet using "bias_by_race.csv", c replace
edit

*by AGE
use "Cleaned_for_Analysis_Data_NewsLens_Experiment1.dta", clear
drop if N_content<5
keep if blind==0

gen bias15ppt=1 if bias>=1.5 & bias<=5
replace bias15ppt=0 if bias<1.5

egen ageg=cut(demo_age), at(17,30,40,50,65,100)

bysort ageg external_user_id: gen nvals = _n ==1
bysort ageg: replace nvals = sum(nvals)
bysort ageg: replace nvals = nvals[_N] 

sum bias [aw=N_content_by_group], detail
gen MEAN=r(mean)
gen STD=r(sd)
gen Zbias=(bias-MEAN)/STD

collapse (count) N=bias (first) nvals (min) mina=demo_age (max) maxa= demo_age (mean) Zbias bias bias15ppt trump (semean) sebias15ppt=bias15ppt  seZbias=Zbias [aw=N_content_by_group], by(ageg)
gsort -bias
gen up_bias=bias15ppt+(sebias15ppt*1.96)
gen low_bias=bias15ppt-(sebias15ppt*1.96)

order ageg bias15ppt low_bias up_bias mina maxa
outsheet using "bias_by_age.csv", c replace

************
*Regression analysis of bias****
**********

use "Cleaned_for_Analysis_Data_NewsLens_Experiment1.dta", clear
drop if N_content<5
keep if blind==0

gen degree=1 if Tdemo_education_new1==1 | Tdemo_education_new5==1 | Tdemo_education_new6==1
gen mod_degree=1 if mod==1 & degree==1 
replace mod_degree=0 if mod==0 & degree!=1 
replace mod_degree=. if demo_education_new=="" | q34_political_views==.

egen extreme=rowmean(vcon vlib)
bysort q28_name_trusted_source_cleaned: egen extreme_source=mean(extreme)
bysort q28_name_trusted_source_cleaned: egen extreme_con=mean(vcon)
bysort q28_name_trusted_source_cleaned: egen extreme_lib=mean(vlib)
bysort q28_name_trusted_source_cleaned: egen mod_source=mean(mod)
bysort q28_name_trusted_source_cleaned: egen mod_deg_source=mean(mod_degree)

bysort q28_name_trusted_source_cleaned external_user_id: gen nvals = _n ==1
bysort q28_name_trusted_source_cleaned: replace nvals = sum(nvals)
bysort q28_name_trusted_source_cleaned: replace nvals = nvals[_N] 

egen Zbias=std(bias) 
egen Zextreme_con=std(extreme_con) 
egen Zextreme_lib=std(extreme_lib) 
sum extreme*

gen bias15ppt=1 if bias>=1.5 & bias<=5
replace bias15ppt=0 if bias<1.5

ci mean bias15ppt [aw=N_content_by_group]
egen ageg=cut(demo_age), at(17,30,40,50,65,100)
tab ageg, gen(age_group)

*bias is lower when articles have more ratings, so weight by # reviews
reg bias N_content_by_group

reg  Zbias trump     ///
age_group1 age_group2 age_group3 age_group4  Tdemo_gender1  ///
Tdemo_political_affiliation1 Tdemo_political_affiliation2 Tdemo_political_affiliation4 Tdemo_political_affiliation5 Tdemo_political_affiliation6 ///
Tdemo_race_2015_new1 Tdemo_race_2015_new2 Tdemo_race_2015_new3 Tdemo_race_2015_new4 ///
Tdemo_education_new1 Tdemo_education_new3 Tdemo_education_new4 Tdemo_education_new5 Tdemo_education_new6 ///
vlib lib con vcon  trust_media fair_media notmuch_media ///
[aw=N_content_by_group]
outreg2 using "Regression_Bias_on_Factors.xls", excel adjr2 replace

***Fixed effects for article***
areg  Zbias trump     ///
age_group1 age_group2 age_group3 age_group4  Tdemo_gender1  ///
Tdemo_political_affiliation1 Tdemo_political_affiliation2 Tdemo_political_affiliation4 Tdemo_political_affiliation5 Tdemo_political_affiliation6 ///
Tdemo_race_2015_new1 Tdemo_race_2015_new2 Tdemo_race_2015_new3 Tdemo_race_2015_new4 ///
Tdemo_education_new1 Tdemo_education_new3 Tdemo_education_new4 Tdemo_education_new5 Tdemo_education_new6 ///
vlib lib con vcon  trust_media fair_media notmuch_media ///
[aw=N_content_by_group], ab(content_id)
outreg2 using "Regression_Bias_on_Factors.xls", excel adjr2 

areg  Zbias trump   ///
age_group1 age_group2 age_group3 age_group4  Tdemo_gender1  ///
Tdemo_political_affiliation1 Tdemo_political_affiliation2 Tdemo_political_affiliation4 Tdemo_political_affiliation5 Tdemo_political_affiliation6 ///
Tdemo_race_2015_new1 Tdemo_race_2015_new2 Tdemo_race_2015_new3 Tdemo_race_2015_new4 ///
Tdemo_education_new1 Tdemo_education_new3 Tdemo_education_new4 Tdemo_education_new5 Tdemo_education_new6 ///
vlib lib con vcon  trust_media fair_media notmuch_media ///
Fox_News  MSNBC NYT PBS WSJ   [aw=N_content_by_group], ab(content_id)
outreg2 using "Regression_Bias_on_Factors.xls", excel adjr2 

areg  Zbias trump   ///
age_group1 age_group2 age_group3 age_group4  Tdemo_gender1  ///
Tdemo_political_affiliation1 Tdemo_political_affiliation2 Tdemo_political_affiliation4 Tdemo_political_affiliation5 Tdemo_political_affiliation6 ///
Tdemo_race_2015_new1 Tdemo_race_2015_new2 Tdemo_race_2015_new3 Tdemo_race_2015_new4 ///
Tdemo_education_new1 Tdemo_education_new3 Tdemo_education_new4 Tdemo_education_new5 Tdemo_education_new6 ///
vlib lib con vcon  trust_media fair_media notmuch_media ///
extreme_con ///
if nvals >=5 [aw=N_content_by_group], ab(content_id)
outreg2 using "Regression_Bias_on_Factors.xls", excel adjr2 

areg  Zbias trump   ///
age_group1 age_group2 age_group3 age_group4  Tdemo_gender1  ///
Tdemo_political_affiliation1 Tdemo_political_affiliation2 Tdemo_political_affiliation4 Tdemo_political_affiliation5 Tdemo_political_affiliation6 ///
Tdemo_race_2015_new1 Tdemo_race_2015_new2 Tdemo_race_2015_new3 Tdemo_race_2015_new4 ///
Tdemo_education_new1 Tdemo_education_new3 Tdemo_education_new4 Tdemo_education_new5 Tdemo_education_new6 ///
vlib lib con vcon  trust_media fair_media notmuch_media ///
extreme_con extreme_lib ///
more_con more_lib news_not_closely news_very_closely ///
if nvals >=5 [aw=N_content_by_group], ab(content_id)
outreg2 using "Regression_Bias_on_Factors.xls", excel adjr2 


areg  bias15ppt trump     ///
age_group1 age_group2 age_group3 age_group4  Tdemo_gender1  ///
Tdemo_political_affiliation1 Tdemo_political_affiliation2 Tdemo_political_affiliation4 Tdemo_political_affiliation5 Tdemo_political_affiliation6 ///
Tdemo_race_2015_new1 Tdemo_race_2015_new2 Tdemo_race_2015_new3 Tdemo_race_2015_new4 ///
Tdemo_education_new1 Tdemo_education_new3 Tdemo_education_new4 Tdemo_education_new5 Tdemo_education_new6 ///
vlib lib con vcon  trust_media fair_media notmuch_media ///
[aw=N_content_by_group], ab(content_id)
outreg2 using "Regression_Bias_on_Factors.xls", excel adjr2 

reg  bias15ppt trump     ///
age_group1 age_group2 age_group3 age_group4  Tdemo_gender1  ///
Tdemo_political_affiliation1 Tdemo_political_affiliation2 Tdemo_political_affiliation4 Tdemo_political_affiliation5 Tdemo_political_affiliation6 ///
Tdemo_race_2015_new1 Tdemo_race_2015_new2 Tdemo_race_2015_new3 Tdemo_race_2015_new4 ///
Tdemo_education_new1 Tdemo_education_new3 Tdemo_education_new4 Tdemo_education_new5 Tdemo_education_new6 ///
vlib lib con vcon  trust_media fair_media notmuch_media 
outreg2 using "Regression_Bias_on_Factors.xls", excel adjr2 

