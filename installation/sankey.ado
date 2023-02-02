*! sankey v1.2 (02 Feb 2023)
*! Asjad Naqvi 

*v1.2 02 Feb 2023: Outgoing flows now properly displace. Categories going to empty and starting from empty added. Various fixes
*v1.1 13 Dec 2022: valformat() renamed to format(). offset() option added to displaced x-axis for rotated labels.
*v1.0 08 Dec 2022: Beta release.

* A detailed Medium guide on Sankey diagrams is here:
* https://medium.com/the-stata-guide/stata-graphs-sankey-diagram-ecddd112aca1


cap program drop sankey

program sankey, // sortpreserve

version 15
 
	syntax varlist(numeric max=1) [if] [in], From(varname) To(varname) by(varname) ///
		[ palette(string) smooth(numlist >=1 <=8) gap(real 5) RECENter(string) colorby(string)  alpha(real 75) ]  ///
		[ LABAngle(string) LABSize(string) LABPOSition(string) LABGap(string) SHOWTOTal  ] ///
		[ VALSize(string)  VALCONDition(string) format(string) VALGap(string) NOVALues ]  ///
		[ LWidth(string) LColor(string)  ]  ///
		[ offset(real 0) ]  ///  // added options v1.1
		[ title(passthru) subtitle(passthru) note(passthru) scheme(passthru) name(passthru) xsize(passthru) ysize(passthru)		] 
		

	// check dependencies
	cap findfile colorpalette.ado
	if _rc != 0 {
		display as error "The palettes package is missing. Install the {stata ssc install palettes, replace:palettes} and {stata ssc install colrspace, replace:colrspace} packages."
		exit
	}
	
	
	marksample touse, strok
	

// layer = combination of x pairs
// x     = points in the vertical for each id
// grp   = a set of labels which are together
// id    = sequence of points that form a shape.



qui {
preserve 	

	keep if `touse'
	keep `varlist' `from' `to' `by'
	
	collapse (sum) `varlist', by(`from' `to' `by')
	
	ren `by' x1
	summ x1, meanonly
	replace x1 = x1 - r(min) // rebase to 0

	
	gen x2 = x1 + 1
	ren `from' 		lab1
	ren `to'		lab2
	ren `varlist' 	val1
	gen val2 	=   val1

	
	// check point
	
	
	sort x1 lab1 lab2  // this affects the draw order
	gen id = _n
	order id
	
	egen grp1 = group(x1 lab1)  // out grp by layer
	egen grp2 = group(x1 lab2)  //  in grp by layer


	sort x1 grp1 grp2
	by x1: gen y1 = sum(val1)  // take cumulative sum of out val

	sort x2 grp2 grp1
	by x2: gen y2 = sum(val2)  // take cumulative sum of in val 

	sort x1 lab1 lab2
	gen layer = x1 + 1
	
	
	reshape long x val lab grp y , i(id layer) j(tt)
	drop tt
		
	sort layer x y
	by layer x: gen y1 = y[_n-1]
	
	recode y1 (.=0)
	ren y y2

	order layer grp id lab x y1 y2 val

    
	// lines added below
	drop grp
	egen grp = group(lab)

	order layer  id lab grp x y1 y2 val	
	
	
	//////////////////////////// alignment fix for varying group sizes
	

	sort layer id x

	local mark1 0
	local mark2 0

	levelsof layer
	local tlayers = r(r)

		
	forval i = 1/`tlayers' {
		
		local here = `i' - 1
		local next = `i'
				
		levelsof id if layer==`i', local(lvls)
		
		foreach x of local lvls {
			
			// value originating
			summ grp if id==`x' & layer==`i' & x==`here'			    , meanonly
			local mygrp = r(mean)
			summ val if id==`x' & layer==`i' & x==`here' & grp==`mygrp' , meanonly
			local myval = r(sum)
			
			// total value of ending group
			summ grp if id==`x' & layer==`i' & x==`next'	, meanonly
			local togrp = r(mean)
			summ val if 		  layer==`i' & x==`next' & grp==`togrp' , meanonly
			local toval = r(sum)
			
			
			// sending value of ending group
			local j = `i' + 1
			summ val if 		  layer==`j' & x==`next' & grp==`togrp' , meanonly
			local outval = r(sum)

			
			if (`toval' > `outval') {
				local off  = `toval' - `outval'  
						
				if !inlist(`togrp',`mark1') {
					qui replace y1 = y1 + `off' if layer==`j' & x==`next' & grp>`togrp' 
					qui replace y2 = y2 + `off' if layer==`j' & x==`next' & grp>`togrp' 
					local mark1 `mark1', `togrp'
				}
				
			}

			if (`outval' > `toval') {
				local off  = `outval' - `toval'  

				if !inlist(`togrp',`mark2') {
					qui replace y1 = y1 + `off' if layer==`i' & x==`next' & grp>=`togrp' 
					qui replace y2 = y2 + `off' if layer==`i' & x==`next' & grp>=`togrp' 
					local mark2 `mark2', `togrp'
				}
			}
		}	
	}	

	
//// add gaps
	
	sort layer id x
	
	cap drop tag
	egen tag = tag(lab layer)
	

	sort layer x lab id 
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
	gen offset = (tag - 1) * `propgap' 
	
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

			
		levelsof lab if layer== `left', local(lleft)  // y:   to in the  first cut 
		levelsof lab if layer==`right', local(lright) // x: from in the second cut


		foreach y of local lleft {  // left
			foreach x of local lright {      // right

			
				if "`x'" == "`y'" {  // check if the groups are equal
				
					// in layer range	
					summ y1 if lab=="`x'" & layer==`left' & x==`left', meanonly   
						local y1max =cond(r(N) > 0, `r(max)', 0)
						local y1min =cond(r(N) > 0, `r(min)', 0)
						
					summ y2 if lab=="`x'" & layer==`left' & x==`left', meanonly   
						local y2max =cond(r(N) > 0, `r(max)', 0)
						local y2min =cond(r(N) > 0, `r(min)', 0)
						
					local l1max = max(`y1max',`y2max')
					local l1min = min(`y1min',`y2min')
					
					// out layer range		
					summ y1 if lab=="`x'" & layer==`right' & x==`left', meanonly 
						local y1max =cond(r(N) > 0, `r(max)', 0)
						local y1min =cond(r(N) > 0, `r(min)', 0)

					summ y2 if lab=="`x'" & layer==`right' & x==`left', meanonly 
						local y2max =cond(r(N) > 0, `r(max)', 0)
						local y2min =cond(r(N) > 0, `r(min)', 0)	
						
					local l2max = max(`y1max',`y2max')
					local l2min = min(`y1min',`y2min')				
						
					
					// calculate the displacement	
					
					if (`l1max' - `l1min') >= (`l2max' - `l2min') {
						local displace = ((`l1max' - `l1min') - (`l2max' - `l2min')) / 2
						replace y1t = y1 + `displace' + `l1min' - `l2min' if layer==`right' & lab=="`x'" & x==`left' 			
						replace y2t = y2 + `displace' + `l1min' - `l2min' if layer==`right' & lab=="`x'" & x==`left' 
					}
					else {
						local displace = ((`l2max' - `l2min') - (`l1max' - `l1min')) / 2
						replace y1t = y1 + `displace' + `l2min' - `l1min' if layer==`left' & lab=="`x'" & x==`left' 			
						replace y2t = y2 + `displace' + `l2min' - `l1min' if layer==`left' & lab=="`x'" & x==`left' 
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
	encode lab, gen(order)
	egen tag = tag(x order)
			 
	cap gen midy = .

	levelsof x, local(lvls)
	foreach x of local lvls {

	levelsof order	if x ==`x', local(odrs)

		foreach y of local odrs {
		
		summ y1 if x==`x' & order==`y', meanonly
		local min = r(min)
		
		summ y2 if x==`x' & order==`y', meanonly
		local max = r(max)
		
		replace midy = (`min' + `max') / 2 if tag==1 & x==`x' & order==`y'
		
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
						
	sort layer grp x y1 y2
	bysort x order: egen ymin = min(y1)
	bysort x order: egen ymax = max(y2)
			 
	egen wedge = group(x order)		 
	egen tagw = tag(wedge)		
			

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
		else {
			local switch 0
		}		

	sort layer x order xtemp y1temp y2temp


	// boxes

	local boxes

	levelsof wedge, local(lvls)
	local items = r(r)


	foreach x of local lvls {

		if `switch' == 1 { 		// by layer
			summ x if wedge==`x', meanonly
			local clr = r(mean) + 1
		}
		else {  				// by category
			summ order if wedge==`x', meanonly
			local clr = r(mean) 
		}
		
		colorpalette `palette' , n(`items') nograph `poptions'
		local boxes `boxes' (rspike ymin ymax x if wedge==`x' & tagw==1, lcolor("`r(p`clr')'%100") lw(3.2)) ||
		
	}

	// arcs

	if "`lcolor'"  == "" local lcolor white
	if "`lwidth'"  == "" local lwidth none	
	
	levelsof wedge
	local groups = r(r)
		
	local shapes	

		
	levelsof id, local(lvls)

	foreach x of local lvls {
		
		if `switch' == 1 {		 	// by layer
			qui sum layer if id==`x'
		}
		else {  					// by category
			qui sum x if id==`x'
			qui sum order if id==`x' & x == r(min)
		}
		
		if r(N) > 0 {
			local clr = r(mean)
		colorpalette `palette' , n(`items') nograph `poptions'
		
			local shapes `shapes' (rarea y1temp y2temp xtemp if id==`x', lc(`lcolor') lw(`lwidth') fi(100) fcolor("`r(p`clr')'%`alpha'"))  ||
		}
	}	
			
	**** PLOT EVERYTHING ***
	
	if "`labangle'" 	== "" local labangle 90
	if "`labsize'"  	== "" local labsize 2	
	if "`labposition'"  == "" local labposition 0	
	if "`labgap'" 		== "" local labgap 0
	
	if "`valsize'"  == "" local valsize 1.5
	if "`valcondition'"  == "" {
		local labcon "if val >= 0"
	}
	else {
		local labcon "if val `valcondition'"
	}
	
	if "`format'" == "" local format "%12.0f"	
	format val `format'
	
	if "`valgap'" 	 == "" local valgap 2
	
	summ ymax, meanonly
	local yrange = r(max)
	
	if "`showtotal'" != "" {
		gen lab2 = lab + " (" + string(sums, "`format'") + ")"
		local lab lab2
	}
	else {
		local lab lab
	}
	
	if "`novalues'" == "" {
		local values `values' (scatter midp   x   `labcon', msymbol(none) mlabel(val) mlabsize(`valsize') mlabpos(3)             mlabgap(`valgap')                       mlabcolor(black)) ///
		
		local values `values' (scatter midpin xin `labcon', msymbol(none) mlabel(val) mlabsize(`valsize') mlabpos(9)             mlabgap(`valgap')                       mlabcolor(black)) ///
		
	}
	
	// offset
	
	summ x, meanonly
	local xrmin = r(min)
	local xrmax = r(max) + ((r(max) - r(min)) * `offset' / 100) 
	
	// final plot
		
	twoway ///
		`shapes' ///
		`boxes'  ///
			(scatter midy   x if tag==1,  msymbol(none) mlabel(`lab') mlabsize(`labsize') mlabpos(`labposition') mlabgap(`labgap') mlabangle(`labangle') mlabcolor(black)) ///
			`values' ///
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


