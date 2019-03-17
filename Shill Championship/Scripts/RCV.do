***********
* Colin Mortimer
* Shill Bracket RCV Calculator
***********

clear
drop _all

* Change to scripts folder path
cd "/Users/colinmortimer/Documents/Data Projects/Shill Championship/Scripts"

* Dynamically reference project files
global dir `c(pwd)'
global scripts "$dir"
global data "$dir/../Data"
global output "$dir/../Output"
global temp "$dir/../Temp"

* Import vote data
import delimited "$data/Data_3.csv", varnames(1)

* Drop uneeded variables
drop timestamp
drop emailaddress

* Drop invalid ballots
drop if firstchoice == secondchoice
drop if firstchoice == thirdchoice
drop if secondchoice == thirdchoice
foreach var in first second third {
	drop if strpos(`var'choice, ",") > 0
}

* Append Scott bonus
preserve
import delimited "$data/Append.csv", varnames(1) clear
saveold "$temp/append.dta", replace
restore
append using "$temp/append.dta"

* Make all data lowercase
ds, has(type string) 
foreach var in `r(varlist)' { 
    replace `var' = lower(`var') 
}
saveold "$temp/Pre_collapse.dta", replace

* Calculate first round
tab firstchoice

* Reassign the last place votes
gen one = 1
collapse (count) one, by(firstchoice)
gsort -one
global drop = firstchoice[3]
use "$temp/Pre_collapse.dta", clear
replace firstchoice = secondchoice if firstchoice == "`drop'"

* Calculate winner
tab firstchoice

* End DO *
