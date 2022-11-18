clear
set more off
set scheme s1color

cd ${synthesis_root}


*Checking which costperbase functional form has the best R^2
use data/derived/cost_clonal_clean, clear

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
