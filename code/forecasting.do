clear
set more off
set scheme s1color

cd ${synthesis_root}

import excel "data/Gene Synthesis Data.xlsx", sheet("By Firm Price") firstrow case(lower)

*Dropping firms with no data and empty rows
drop if mi(firm) | mi(year)

*Keeping only full gene synthesis data
keep if synthesistype=="C"

label var costperbase "Cost per Base ($)"

*Gen log cost per base vars
gen ln_costperbase = ln(costperbase)

gen log10_costperbase = log10(costperbase)

gen log2_costperbase = ln(costperbase)/ln(2)

**Collapsing firm level data
gen carlson = firm == "Carlson Average"

collapse costperbase ln_costperbase log10_costperbase log2_costperbase, by(carlson year)


label var costperbase "Cost per Base ($)"
label var ln_costperbase "Ln(costperbase)"
label var log10_costperbase "Log_10(costperbase)"
label var log2_costperbase "Log_2(costperbase)"

*Checking which costperbase functional form has the best R^2

*Firm data
reg costperbase year if carlson ==0
twoway (scatter costperbase year if carlson ==0) (lfit costperbase year if carlson==0)

reg ln_costperbase year if carlson==0
twoway (scatter ln_costperbase year if carlson ==0) (lfit ln_costperbase year if carlson==0)

reg log10_costperbase year if carlson==0
twoway (scatter log10_costperbase year if carlson ==0) (lfit log10_costperbase year if carlson==0)

reg log2_costperbase year if carlson==0
twoway (scatter log2_costperbase year if carlson ==0) (lfit log2_costperbase year if carlson==0)


*Carlson Data
reg costperbase year if carlson ==1
twoway (scatter costperbase year if carlson ==1) (lfit costperbase year if carlson==1)

reg ln_costperbase year if carlson==1
twoway (scatter ln_costperbase year if carlson ==1) (lfit ln_costperbase year if carlson==1)

reg log11_costperbase year if carlson==1
twoway (scatter log11_costperbase year if carlson ==1) (lfit log11_costperbase year if carlson==1)

reg log2_costperbase year if carlson==0
twoway (scatter log2_costperbase year if carlson ==0) (lfit log2_costperbase year if carlson==0)
