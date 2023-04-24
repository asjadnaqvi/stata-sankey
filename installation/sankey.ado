*! sankey v1.4 (23 Apr 2023)
*! Asjad Naqvi (asjadnaqvi@gmail.com)

*v1.4  (23 Apr 2023): fix unbalanced. fixed gaps. Added column labels. Add custom color option.
*v1.31 (04 Apr 2023): fix to how colors are defined.
*v1.3  (26 Feb 2023): sortby() option added. Node bundling.
*v1.21 (15 Feb 2023): labcolor() added, gap fix
*v1.2  (02 Feb 2023): Outgoing flows now displace properly. Categories going to empty and starting from empty added. Various fixes
*v1.1  (13 Dec 2022): valformat() renamed to format(). offset() option added to displaced x-axis for rotated labels.
*v1.0  (08 Dec 2022): Beta release.


// A detailed Medium guide on Sankey diagrams is here:
// https://medium.com/the-stata-guide/stata-graphs-sankey-diagram-ecddd112aca1


cap program drop sankey

program sankey, sortpreserve

version 15
 
	syntax varlist(numeric max=1) [if] [in], From(varname) To(varname) by(varname) ///
		[ palette(string) smooth(numlist >=1 <=8) gap(real 5) RECENter(string) colorby(string)  alpha(real 75) ]  ///
		[ LABAngle(string) LABSize(string) LABPOSition(string) LABGap(string) SHOWTOTal  ] ///
		[ VALSize(string)  VALCONDition(real 0) format(string) VALGap(string) NOVALues ]  ///
		[ LWidth(string) LColor(string)  	 ]  ///
		[ offset(real 0) LABColor(string) 	 ]  ///  // added v1.1
		[ sortby(string) BOXWidth(string)	 ]  ///  // added v1.3
		[ wrap(real 7) CTITLEs(string asis) CTGap(real -5) CTSize(real 2.5) colorvar(varname) colorvarmiss(string) colorboxmiss(string)  ] ///  // v1.4 options
		[ title(passthru) subtitle(passthru) note(passthru) scheme(passthru) name(passthru) xsize(passthru) ysize(passthru)		] 
		

	// check dependencies
	cap findfile colorpalette.ado
	if _rc != 0 {
		display as error "The palettes package is missing. Install the {stata ssc install palettes, replace:palettes} and {stata ssc install colrspace, replace:colrspace} packages."
		exit
	}
	
	
	marksample touse, strok
	
	
	// error checks
	if "`colorby'" != "" & "`colorvar'" != "" {
		di as err "Both colorby() and colorvar() are not allowed."
		exit 198
	}
	
	if "`colorvar'" != "" {
		tempvar _temp
		qui gen `_temp' = mod(`colorvar',1)
		summ `_temp', meanonly
		if r(max) > 0 {
			di as err "colorvar() needs to be integers starting at 1."
			exit 198
		}
	}
	

	// layer = combination of x pairs
	// x     = points in the vertical for each id
	// grp   = a set of labels which are together
	// id    = sequence of points that form a shape.



qui {
preserve 	
	
	keep if `touse'
	
	drop if `varlist' ==.
	
	if "`colorvar'" != "" {
		ren `colorvar' clrlvl
		recode clrlvl . = 0
	}
	else {
		gen clrlvl = .
	}
	
	
	keep `varlist' `from' `to' `by' clrlvl
	
	collapse (sum) `varlist' (mean) clrlvl , by(`from' `to' `by')
	
	ren `by' x1
	summ x1, meanonly
	replace x1 = x1 - r(min) // rebase to 0

	sort x1

	ren `from' 		lab1
	ren `to'		lab2
	ren `varlist' 	val1
	
	gen val2 	=   val1
	
	
	gen x2 = x1 + 1
	
	gen order1 = .
	gen order2 = .
	
	// add sorting routine here
		
		bysort lab1: egen l0total = sum(val1) if x1==0
		
		if "`sortby'" == "" | "`sortby'" == "value" {
			sort x1 l0total lab1	// numerical
		}
		if "`sortby'" == "name" {
			sort x1 lab1 lab2		// alphabetical
		}
		
		summ x2, meanonly
		local lastlvl = r(max)

		
		
		// get the order of layer 0
		egen tag1 = tag(lab1) if x2==1
		recode tag1 (0=.) if x2!=1
		gen sort1 = sum(tag1) if x2==1
		replace order1 = sort1 if x2==1
		drop tag1 sort1 l0total
	
		if "`sortby'" == "" | "`sortby'" == "value" {
			sort x1 order1 val2		// numerical
		}
		if "`sortby'" == "name" {
			sort x1 order1 lab2		// alphabetical
		}
		
		
	
		// fix the remaining layers
		levelsof x2, local(lvls)
		local items = r(r)
		

			foreach x of numlist 1/`items' {
			
				local y = `x' + 1
				
				// group to0 to from0
				egen tag`x' = tag(lab2) if x2==`x'
				recode tag`x' (0=.) if x2!=`x'
				gen sort`x' = sum(tag`x') if x2==`x'

				
				// pass to0 to from1
				gen     name`x' = lab2 if x2==`x'
				replace name`x' = lab1 if x2==`y'

				if "`sortby'" == "" | "`sortby'" == "value" {
					sort name`x' sort`x' val2	// numerical
				}
				if "`sortby'" == "name" {
					sort name`x' sort`x' lab2	// alphabetical
				}
				
				by name`x': replace sort`x' = sort`x'[1]

				replace order2 = sort`x' if x2==`x'
				replace order1 = sort`x' if x2==`y'
				
				
				// new routine for the correct order			

				levelsof name`x' if order1==. & x2==`y', local(new)
				
				
				summ sort`x', meanonly
				local counter = r(max) + 1
				
				foreach z of local new {
					replace order1 = `counter' if order1==. &  x2==`y'
					local counter = `counter' + 1
				}
				
				drop name* tag* sort*
			
			}
	

	sort x1 order1 order2

	
	// check point after sorting
	gen id = _n
	order id
	
	
	
	egen grp1 = group(x1 order1)  // out grp by layer
	egen grp2 = group(x1 order2)  //  in grp by layer


	sort x1 grp1 grp2
	by x1: gen y1 = sum(val1)  // take cumulative sum of out val

	sort x2 grp2 grp1
	by x2: gen y2 = sum(val2)  // take cumulative sum of in val 

	sort x1 order1 order2
	gen layer = x1 + 1
	
	
	reshape long x val lab grp y order, i(id layer) j(tt)
	drop tt
	sort layer x y
	by layer x: gen y1 = y[_n-1]
	
	recode y1 (.=0)
	ren y y2
	drop grp
	
	order layer  id lab x y1 y2 val	
	
	//////////////////////////// alignment fix for varying group sizes
	
	
	sort layer id x
	
	levelsof layer
	
	if `r(r)' > 1 {
		
		local tlayers = r(r)	
		forval i = 1/`tlayers' {
			
			local here = `i' - 1
			local next = `i'
			
			local mark1 0
			local mark2 0
			
			levelsof id if layer==`i', local(lvls)
			
			foreach x of local lvls {
				
				// value originating
				summ order if id==`x' & layer==`i' & x==`here'			      , meanonly
				local mygrp = r(mean)
				summ val if id==`x' & layer==`i' & x==`here' & order==`mygrp' , meanonly
				local myval = r(sum)
				
				// total value of ending group
				summ order if id==`x' & layer==`i' & x==`next'	, meanonly
				local togrp = r(mean)
				summ val if 		  layer==`i' & x==`next' & order==`togrp' , meanonly
				local toval = r(sum)
				
				
				// sending value of ending group
				local j = `i' + 1
				summ val if 		  layer==`j' & x==`next' & order==`togrp' , meanonly
				local outval = r(sum)

				
				if (`toval' >= `outval') {
					local off  = `toval' - `outval'  

					if !inlist(`togrp',`mark1') {
						
						qui replace y1 = y1 + `off' if layer==`j' & x==`next' & order>`togrp' 
						qui replace y2 = y2 + `off' if layer==`j' & x==`next' & order>`togrp' 
						local mark1 `mark1', `togrp'
					}
					
				}

				if (`outval' > `toval') {
					local off  = `outval' - `toval'  

					if !inlist(`togrp',`mark2') {
						
						qui replace y1 = y1 + `off' if layer==`i' & x==`next' & order>=`togrp' 
						qui replace y2 = y2 + `off' if layer==`i' & x==`next' & order>=`togrp' 
						local mark2 `mark2', `togrp'
					}
				
				}
			}	
		}	
	}

	
	
	
	//// add gaps
	
	sort layer id x
	
	cap drop tag
	egen tag = tag(layer x order)

	sort layer x order id 
	by layer x: replace tag = sum(tag)	
	
	
	levelsof x, local(lvls)

	local hival = 0 // track the value

	foreach x of local lvls {

		summ y2 if x==`x', meanonly
		if r(max) > `hival' {
			local hilayer = `x'
			local hival = r(max)
		}
	}	
	
	local propgap = `hival' * `gap' / 100
	gen offset = (order - 1) * `propgap' 
	
	replace y1 = y1 + offset
	replace y2 = y2 + offset

	
	
	
	///////////////////////////	
	
	*** transform the groups to be at the mid points	

	sort x id y1 y2
	gen y1t = .
	gen y2t = .


	levelsof layer
	local tlayers = r(r) - 1


	forval i = 1/`tlayers' {
		
		local left  = `i'	
		local right = `i' + 1

			
		levelsof order if layer== `left', local(lleft)  // y:   to in the  first cut 
		levelsof order if layer==`right', local(lright) // x: from in the second cut


		foreach y of local lleft {  // left
			foreach x of local lright {      // right
					
				if "`x'" == "`y'" {  // check if the groups are equal
				
					// in layer range	
					summ y1 if order==`x' & layer==`left' & x==`left', meanonly 
						local y1max = cond(r(N) > 0, r(max), 0)
						local y1min = cond(r(N) > 0, r(min), 0)		

					summ y2 if order==`x' & layer==`left' & x==`left', meanonly 
						local y2max =cond(r(N) > 0, r(max), 0)
						local y2min =cond(r(N) > 0, r(min), 0)
						
					local l1max = max(`y1max',`y2max')
					local l1min = min(`y1min',`y2min')
					
					// out layer range		
					summ y1 if order==`x' & layer==`right' & x==`left', meanonly 
						local y1max =cond(r(N) > 0, r(max), 0)
						local y1min =cond(r(N) > 0, r(min), 0)

					summ y2 if order==`x' & layer==`right' & x==`left', meanonly 
						local y2max =cond(r(N) > 0, r(max), 0)
						local y2min =cond(r(N) > 0, r(min), 0)	
						
					local l2max = max(`y1max',`y2max')
					local l2min = min(`y1min',`y2min')				
						
					
					// calculate the displacement	
					
					if (`l1max' - `l1min') >= (`l2max' - `l2min') {
						local displace = ((`l1max' - `l1min') - (`l2max' - `l2min')) / 2
						replace y1t = y1 + `displace' + `l1min' - `l2min' if layer==`right' & order==`x' & x==`left' 			
						replace y2t = y2 + `displace' + `l1min' - `l2min' if layer==`right' & order==`x' & x==`left' 
					}
					else {
						local displace = ((`l2max' - `l2min') - (`l1max' - `l1min')) / 2
						replace y1t = y1 + `displace' + `l2min' - `l1min' if layer==`left' & order==`x' & x==`left' 			
						replace y2t = y2 + `displace' + `l2min' - `l1min' if layer==`left' & order==`x' & x==`left' 
					}
				}
			}	
		}
	}

	
	replace y1t = y1 if y1t==.
	replace y2t = y2 if y2t==.
	
	drop y1 y2

	ren y1t y1	
	ren y2t y2
	
	
	//recenter
	
	*** recenter to middle

	// mark the highest value and the layer

	levelsof x, local(lvls)

	local hival = 0 // track the value

	foreach x of local lvls {

		summ y2 if x==`x', meanonly
		if r(max) > `hival' {
			local hilayer = `x'
			local hival = r(max)
		}
	}

	levelsof x, local(lvls)		
			
	foreach x of local lvls {
		
		qui summ y1 if x==`x', meanonly
		local ymin = r(min)
		qui summ y2 if x==`x', meanonly
		local ymax = r(max)
		
		if "`recenter'" == "bottom" | "`recenter'" == "bot"  | "`recenter'" == "b" { 		
			local displace = cond(`ymin' < 0, `ymin' * -1, 0)
		}
			
		if "`recenter'" == "" | "`recenter'" == "middle" | "`recenter'" == "mid"  | "`recenter'" == "m" { 
			local displace = (`hival' - `ymax') / 2
		}
			
		if "`recenter'" == "top" | "`recenter'" == "t"  {
			local displace = `hival' - `ymax'
		}		
		
		replace y1 = y1 + `displace' if x==`x'
		replace y2 = y2 + `displace' if x==`x'
	}
	
	// update the value of starting layer to total
	
	cap drop sums
	bysort layer x lab: egen sums = sum(val)
	
	
	*** generate the curves	
	local newobs = 30	
	expand `newobs'
	sort id x
	cap drop xtemp
	bysort id: gen xtemp =  (_n / (`newobs' * 2))

	if "`smooth'" == "" local smooth = 4
	
	gen ytemp =  (1 / (1 + (xtemp / (1 - xtemp))^-`smooth'))

	gen y1temp = .
	gen y2temp = .

	levelsof layer	, local(cuts)
	levelsof id		, local(lvls)

	foreach x of local lvls {   // each id is looped over

		foreach y of local cuts {

			summ ytemp if id==`x' & layer==`y', meanonly
			
			if r(N) > 0 {
				local ymin = r(min)
				local ymax = r(max)
			}	
			else {
				local ymin = 0
				local ymax = 0
			}

			sum x if layer==`y', meanonly
				local x0 = r(min)
				local x1 = r(max)

			
			summ y1 if id==`x' & x==`x0' & layer==`y', meanonly
			if r(N) > 0 {
				local y1min = r(min)
			}
			else {
				local y1min = 0
			}
				
			summ y1 if id==`x' & x==`x1' & layer==`y', meanonly
			if r(N) > 0 {
				local y1max = r(max)
			}
			else {
				local y1max = 0	
			}
			
			replace y1temp = (`y1max' - `y1min') * (ytemp - `ymin') / (`ymax' - `ymin') + `y1min' if id==`x' & layer==`y'
			
			summ y2 if id==`x' & x==`x0' & layer==`y', meanonly
			if r(N) > 0 {
				local y2min = r(min)
			}
			else {
				local y2min = 0
			}	
			
			summ y2 if id==`x' & x==`x1' & layer==`y', meanonly
			if r(N) > 0 {
				local y2max = r(max)
			}
			else {
				local y2max = 0.0000001	
			}
					
			replace y2temp = (`y2max' - `y2min') * (ytemp - `ymin') / (`ymax' - `ymin') + `y2min' if id==`x' & layer==`y'
		}
	}

	replace xtemp = xtemp + layer - 1


	***** mid points for wedges
			 
	cap drop tag
	encode lab, gen(labels)
	egen tag = tag(x labels)
			 
	cap gen midy = .

	levelsof x, local(lvls)
	foreach x of local lvls {

	levelsof labels	if x ==`x', local(odrs)

		foreach y of local odrs {
		
		summ y1 if x==`x' & labels==`y', meanonly
		local min = r(min)
		
		summ y2 if x==`x' & labels==`y', meanonly
		local max = r(max)
		
		replace midy = (`min' + `max') / 2 if tag==1 & x==`x' & labels==`y'
		
		}
	}


	***** mid points for sankey labels

	egen tagp = tag(id)
	cap gen midp   = .  // outgoing
	cap gen midpin = .  // incoming
	cap gen xin = .

	levelsof id, local(lvls)
	foreach x of local lvls {

		// outbound values
		summ x if id==`x', meanonly
		local xval = r(min)
		
		summ y1 if id==`x' & x==`xval', meanonly
		local min = r(min)
		
		summ y2 if id==`x'  & x==`xval', meanonly
		local max = r(max)
		
		replace midp = (`min' + `max') / 2 if id==`x' & tagp==1
		
		// inbound values
		summ x if id==`x', meanonly
		local xval = r(max)
		
		summ y1 if id==`x' & x==`xval', meanonly
		local min = r(min)
		
		summ y2 if id==`x'  & x==`xval', meanonly
		local max = r(max)
		
		replace midpin = (`min' + `max') / 2 if id==`x' & tagp==1		
		replace xin = x + 1 if id==`x' & tagp==1	
	}

	*** fix boxes
						
	sort layer order x y1 y2
	bysort x labels: egen ymin = min(y1)
	bysort x labels: egen ymax = max(y2)
	
	
	
	egen wedge = group(x labels)		 
	egen tagw = tag(wedge)		
			
	egen clrgrp = group(lab)
	
	
	********************
	*** final plot   ***
	********************

		if "`palette'" == "" {
			local palette tableau
		}
		else {
			tokenize "`palette'", p(",")
			local palette  `1'
			local poptions `3'
		}

		
		if "`colorby'" == "layer" | "`colorby'" == "level" {
			local switch 1
		}
		if "`colorby'" == "" {
			local switch 0
		}		
		
		if "`colorvar'" != "" {
			local switch 2
		}

	sort layer x order xtemp y1temp y2temp


	// boxes

	if "`boxwidth'"    	== "" local boxwidth 3.2
	if "`colorboxmiss'" == "" local colorboxmiss gs10
	
	local boxes



	levelsof wedge, local(lvls)
	local items = r(r)		

	
	if `switch' == 2 {
		summ clrlvl, meanonly
		local items = r(max)
	}
	
	local zz = 1

	foreach x of local lvls {


		if `switch' == 0 { 	
			summ clrgrp if wedge==`x', meanonly
			local clr = r(mean) 
		}
		if `switch' == 1 { 		// by layer
			summ x if wedge==`x', meanonly
			local clr = r(mean) + 1
		}

		if `switch' == 2 { 	
			summ clrlvl if  wedge==`x', meanonly	
			local clr = r(max)
			
			local ++zz
		}
				
			if `clr' > 0 {
				colorpalette `palette' , n(`items') nograph `poptions'
				local myclr  `r(p`clr')'
			}
			else {
				local myclr  `colorboxmiss'
			}
		
		
		
		local boxes `boxes' (rspike ymin ymax x if wedge==`x' & tagw==1, lcolor("`myclr'%100") lw(`boxwidth')) ||
		
	}

	// arcs

	if "`lcolor'"    == "" local lcolor white
	if "`labcolor'"  == "" local labcolor black
	if "`lwidth'"    == "" local lwidth none	
	if "`colorvarmiss'" == "" local colorvarmiss gs12
	
	
	levelsof wedge
	local groups = r(r)
		
	local shapes	

		
	levelsof id, local(lvls)

	foreach x of local lvls {
		
		if `switch' == 0 {	 {  					// by category
			qui sum x if id==`x'
			qui sum clrgrp if id==`x' & x == r(min)
		}
		if `switch' == 1 {		 	// by layer
			qui sum layer if id==`x'
		}
		
		if `switch' == 2 {		 	// by layer
			qui sum x if id==`x'
			qui sum clrlvl if id==`x' & x == r(min)
		}
		
		
		if r(N) > 0 {
			local clr = r(mean)
			
			if `clr' > 0 {
				colorpalette `palette' , n(`items') nograph `poptions'
				local myclr  `r(p`clr')'
			}
			else {
				local myclr  `colorvarmiss'
			}
		
			local shapes `shapes' (rarea y1temp y2temp xtemp if id==`x', lc(`lcolor') lw(`lwidth') fi(100) fcolor("`myclr'%`alpha'"))  ||
		}
	}	
	
	
	**** fix the title lists
	
	if `"`ctitles'"' != "" {
		
		local clabs `"`ctitles'"'
		local len : word count `clabs'


		gen title_x 	= .
		gen title_y 	= `ctgap' in 1/`len'
		gen title_name 	= ""


		forval i = 1/`len' {
			replace title_x = `i' - 1 in `i' 
			
			local aa : word `i' of `clabs'
			replace title_name =  `"`:word `i' of `clabs''"' in `i'
		}
	}
	

	**** PLOT EVERYTHING ***
	
	if "`labangle'" 	== "" local labangle 90
	if "`labsize'"  	== "" local labsize 2	
	if "`labposition'"  == "" local labposition 0	
	if "`labgap'" 		== "" local labgap 0
	if "`valsize'"  	== "" local valsize 1.5
	if "`valgap'" 	 	== "" local valgap 2
	if "`format'" 		== "" local format "%12.0f"	
	format val `format'
	

	summ ymax, meanonly
	local yrange = r(max)
	
	if "`showtotal'" != "" {
		gen lab2 = lab + " (" + string(sums, "`format'") + ")" if tag==1
	}
	else {
		gen lab2 = lab if tag==1
	}
	
	
	*local wrap2 = `wrap' + 2
	*replace lab2 = substr(lab2, 1, `wrap') + "`=char(10)`=char(39)'" + substr(lab2, `wrap2', .)  if tag==1
	
	if "`novalues'" == "" {
		local values `values' (scatter midp   x    if val >= `valcondition', msymbol(none) mlabel(val) mlabsize(`valsize') mlabpos(3) mlabgap(`valgap') mlabcolor(`labcolor')) ///
		
		local values `values' (scatter midpin xin  if val >= `valcondition', msymbol(none) mlabel(val) mlabsize(`valsize') mlabpos(9) mlabgap(`valgap') mlabcolor(`labcolor')) ///
		
	}
	
	if `"`ctitles'"' != "" {
		local lvllab (scatter title_y title_x, msymbol(none) mlabel(title_name) mlabpos(0) mlabsize(`ctsize')) ///
		
	}

	
	// offset
	
	summ x, meanonly
	local xrmin = r(min)
	local xrmax = r(max) + ((r(max) - r(min)) * `offset' / 100) 
	
	// final plot
		
	twoway ///
		`shapes' ///
		`boxes'  ///
			(scatter midy   x if tag==1 & val >= `valcondition',  msymbol(none) mlabel(lab2) mlabsize(`labsize') mlabpos(`labposition') mlabgap(`labgap') mlabangle(`labangle') mlabcolor(`labcolor')) ///
			`values' ///
			`lvllab' ///
			, ///
				legend(off) ///
					xlabel(, nogrid) ylabel(0 `yrange' , nogrid)     ///
					xscale(off range(`xrmin' `xrmax')) yscale(off)	 ///
					`title' `subtitle' `note' `scheme' `name' ///
					`xsize' `ysize'

*/
restore
}
		
end




*********************************
******** END OF PROGRAM *********
*********************************


