*! sankey v1.9 (25 Jun 2025)
*! Asjad Naqvi (asjadnaqvi@gmail.com)

*v1.9  (25 Jun 2025): ctwrap() added. ctgap() is now based on precentage of maximum height. better tolerance of x-axis range. labpos() now accepts lists for fine tuning layers.
*v1.81 (16 Oct 2024): wrap() improved. stock2 added to stock on the right. weights are allowed.
*v1.8  (21 Sep 2024): added align, fill, wrap(), n(). Major code cleanup
*v1.74 (10 Jun 2024): added wrap() option.
*v1.73 (18 Mar 2024): Values determine the order of drawing. Add caution that numbers mean the same across the categories.
*v1.72 (12 Feb 2024): labprop fixes, valcond() fixes. by() changed to optional. Assumes one layer with a warning. ctcolor() added. ctsize() switched to string.
*v1.71 (15 Jan 2024): fixed a bug where value labels of to() and from() were overwriting each other.
*v1.7  (06 Nov 2023): fix valcond() dropping labels in bars, added percent (still in beta), added ctpos() option. minor cleanups  
*v1.61 (22 Jul 2023): Adding saving() option. minor fixes
*v1.6  (11 Jun 2023): Major rewrite of the core routines. Labels added. twp sorts added. Program is faster.
*v1.52 (29 May 2023): Add option where wwn flows are considered stock 
*v1.51 (25 May 2023): from/to string check. Help file updated.
*v1.5  (30 Apr 2023): add labprop, valprop, labscale, novalright novalleft, sortby(, reverse) options, nolab
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
 
	syntax varlist(numeric max=1) [if] [in] [aw fw pw iw/], From(varname) To(varname)  ///
		[ by(varname) palette(string) smooth(numlist max=1 >=1 <=8) gap(real 5) RECENter(string) colorby(string) alpha(real 75) ]  ///
		[ LABAngle(string) LABSize(string) LABPOSition(string) LABGap(string) SHOWTOTal  ] ///
		[ VALSize(string)  VALCONDition(real 0) format(string) VALGap(string) NOVALues   ] ///
		[ LWidth(string) LColor(string)  	 ]  ///
		[ offset(real 0) LABColor(string) 	 ]  ///  // added v1.1
		[ BOXWidth(string)	 				 ]  ///  // added v1.3
		[ CTITLEs(string asis) CTGap(real 0) CTSize(string) colorvar(varname) colorvarmiss(string) colorboxmiss(string)  ] ///  // v1.4 options
		[ valprop labprop valscale(real 0.33333) labscale(real 0.33333) NOVALRight NOVALLeft NOLABels ]      ///  // v1.5
		[ sort1(string) sort2(string)  ]  /// // v1.6
		[ percent ctpos(string) CTColor(string) * ]    /// // v1.7 
		[ align fill wrap(numlist >=0 max=1) n(real 30) stock stock2 ctwrap(numlist >=0 max=1) ] ///	//	v1.8
		[  ]  // v1.9
		

	// check dependencies
	cap findfile colorpalette.ado
	if _rc != 0 {
		display as error "The {bf:palettes} package is missing. Install the {stata ssc install palettes, replace:palettes} and {stata ssc install colrspace, replace:colrspace} packages."
		exit
	}
	
	cap findfile labsplit.ado
	if _rc != 0 {
		display as error "The {bf:graphfunctions} package is missing. Install the {stata ssc install graphfunctions, replace:graphfunctions}."
		exit
	}	
	
	marksample touse, strok
	
	
	// error checks
	
	if "`sort1'" != "" {
		tokenize "`sort1'", p(",")
		local stype1  `1'
		local srev1   `3'
	}	
	
	if "`stype1'" != "" & "`stype1'" != "name" & "`stype1'" != "value" {
		di as err "Valid options for {bf:sort1()} are {it:name (default)} or {it:value}."
		exit 198
	}
	
	if "`sort2'" != "" {
		tokenize "`sort2'", p(",")
		local stype2  `1'
		local srev2   `3'
	}	
	
	
	if "`stype2'" != "" & "`stype2'" != "order" & "`stype2'" != "value" {
		display as error "Valid options for {bf:sort2()} are {it:order (default)} or {it:value}."
		exit 198
	}	
	
	if "`colorby'" != "" & "`colorvar'" != "" {
		display as error "Both colorby() and colorvar() are not allowed."
		exit 198
	}
	
	if "`novalleft'" != "" & "`novalright'" != "" {
		display as error "Both {it:novalleft} and {it:novalright} are not allowed. If you want to hide values use the {it:novalues} option instead."
		exit 198
	}	
	
	if "`colorvar'" != "" {
		tempvar _temp
		qui gen `_temp' = mod(`colorvar',1)
		summ `_temp', meanonly
		if r(max) > 0 {
			display as error "colorvar() needs to be integers starting at 1."
			exit 198
		}
	}
	

	// layer = combination of x pairs
	// x     = points in the vertical for each id
	// grp   = a set of labels which are together
	// id    = sequence of points that form a shape.


quietly {
preserve 	
	
	keep if `touse'
	drop if missing(`varlist')
	
	if "`by'" == "" {
		gen _layer = 1
		local by _layer
		noisily display in yellow "WARNING: No {bf:by()} option specified. Assuming one layer."
	}
	
	
	if "`colorvar'" != "" {
		ren `colorvar' clrlvl
		recode clrlvl (. = 0)
	}
	else {
		gen clrlvl = .
	}
	
	
	keep `varlist' `from' `to' `by' clrlvl `exp'
	
		// drop missing categories
		cap confirm numeric var `from'	
		if !_rc {  
			local fcheck = 0
			drop if `from'==.
			local lab1 : value label `from'
		}
		else {
			local fcheck = 1
			drop if `from'==""
		}
	
		cap confirm numeric var `to'	
		if !_rc {  
			local tcheck = 0
			drop if `to'==.
			local lab2 : value label `to'
		}
		else {
			local tcheck = 1
			drop if `to'==""
		}	
	
		if ("`fcheck'"=="0" & "`tcheck'"=="1") | ("`tcheck'"=="0" & "`fcheck'"=="1") {
			noisily display as error "Format error: {bf:from()} and {bf:to()} have different formats. They should be both either numeric or string variables."
			exit 198
		}
		
				
		if "`lab1'" != "`lab2'" {
			noisily display in yellow "WARNING: {bf:from()} and {bf:to()} have different value labels. {bf:from()} will overwrite {bf:to()} value labels."
		}
		
	
		// if strings, convert to numeric, otherwise leave them alone.
		
		/*
		cap confirm string var `from'
		if !_rc {
			encode `from', gen(_temp1)		
			drop `from'
			ren _temp1 `from'
		}
		
		cap confirm string var `to'
		if !_rc {
			encode `to', gen(_temp2)		
			drop `to'
			ren _temp2 `to'
		}	
			*/

	if "`weight'" != "" local myweight  [`weight' = `exp']		
			
	collapse (sum) `varlist' (first) clrlvl `myweight', by(`from' `to' `by')

	
	gen markme = .
	
	if "`stock'" != "" | "`stock2'"!="" {
		replace markme = `from'== `to'
	}
	
	cap ren `by' xcut
	
	egen layer    = group(xcut)
	replace layer = layer - 1

	ren `from' 		var1
	ren `to'		var2
	ren `varlist' 	val1
	
	gen val2 	=   val1
	
	gen _empty = .	
	
	if "`align'" != "" | "`fill'" != "" {
			
		summ layer, meanonly
				local lmax = `r(max)' - 1
				
		forval i = 0/`lmax' {
			local j = `i' + 1
			qui levelsof var2 if layer==`i', local(lvls)
			
			foreach x of local lvls {
					
				qui count if var1 == "`x'" & layer==`j' 
				
				if `r(N)' == 0 {
					set obs `=_N+1'
					
					replace _empty = 1 in   `=_N'
					replace var1 = "`x'" in `=_N'
					replace var2 = "`x'" in `=_N'
					replace layer = `j'  in `=_N'
					
					
					sum val2 if var2 == "`x'" & layer==`i' , meanonly
					replace val1 = `r(max)' in `=_N'
					replace val2 = `r(max)' in `=_N'
					
					sum xcut if var2 == "`x'" & layer==`i' , meanonly
					replace xcut = `r(max)' in `=_N'
				}
			}
		}	
	}
	
	
	
	if "`percent'" != "" {   
		tempvar aux1 aux2 total
		
		bysort layer (var1 var2): egen double `total' = sum(val1)
		replace val1 = (val1 / `total') * 100
		
		bysort var1 layer clrlvl: egen double `aux1' = sum(val2)
		replace `aux1' = 0 if clrlvl == 0
		bysort layer: egen double `aux2' = sum(`aux1')
		replace val2 = (val2 / `aux2') * 100
		
		gsort layer val1 val2
	}
	
	
	*** let's preserve the order here by aligning the layers (n*n-1 sorts)
	
	gen _sort0 = .
	
	if "`align'" != "" | "`fill'" != "" {
		
		sort layer var1 var2 val1
		
		// parent
		replace _sort0 = _n if layer==0 // base layer
		
		summ layer, meanonly
		local last = `r(max)'
		
		
		forval i = 1/`last' {
			local j = `i' - 1
			levelsof var2 if layer== `j' , local(lvls)
			
			foreach x of local lvls {
				summ _sort0 if layer==`j' & var2=="`x'", meanonly
				replace _sort0=`r(min)' if var1=="`x'" & layer==`i'
			}
		}
		
		
		sort _sort0 layer var1 var2 val1
		
		// children
		forval k = 1/`last' {

			gen _sort`k' = _n if layer==`k'
			local m = `k' + 1
			

			forval i = `m'/`last' {
				local j = `i' - 1
				levelsof var2 if layer== `j' , local(lvls)
				
				foreach x of local lvls {
					summ _sort`k' if layer==`j' & var2=="`x'", meanonly
					replace _sort`k'=`r(min)' if var1=="`x'" & layer==`i'
				}
			}
		}

		recode _sort* (.=0)
		sort _sort*
		
	}

	
	
	
	*** reshape

	gen id = _n
	reshape long var val , i(id layer xcut) j(marker)  // take out _sort*
	
	capture drop _sort*
	
	// variable type check
	
	if substr("`: type var'",1,3) != "str" {
		if "`: value label var '" != "" { 	// has value label
			decode var, gen(name)
		}
		else {								// has no value label
			gen name = string(var)
		}
	}
	else {
		cap ren var name
		encode name, gen(var) // alphabetical organization
	}
	

	gen layer2 = layer
	replace layer2 = layer2 + 1 if marker==2	

	
	sort layer2 var marker

	if "`stock'" != "" {
		bysort layer2 var: egen double val_out_temp = sum(val) if marker==1 // how much value is sent out
		bysort layer2 var: egen double val_in_temp  = sum(val) if marker==2 & markme!=1 // how many value comes in
	}
	else if "`stock2'" != "" {
		bysort layer2 var: egen double val_out_temp = sum(val) if marker==1 & markme!=1 // how much value is sent out
		bysort layer2 var: egen double val_in_temp  = sum(val) if marker==2  // how many value comes in
	}
	else {
		bysort layer2 var: egen double val_out_temp = sum(val) if marker==1 // how much value is sent out
		bysort layer2 var: egen double val_in_temp  = sum(val) if marker==2 // how many value comes in
	}
	 
 	
		bysort layer2 var: egen double val_out = max(val_out_temp)
		bysort layer2 var: egen double val_in  = max(val_in_temp)
		
		drop *temp
		recode val_in val_out (.=0)
		egen double height = rowmax(val_in val_out) // this is the maximum height for each category for each group.

		summ height, meanonly
		local maxheight = r(max)
		
		
	
	
	// sort by name or value

	if "`stype1'"=="value"  {
		if "`srev1'" == "reverse" {
			local ssort1 -height -var
		}
		else {
			local ssort1 height var
		}
		
		gsort layer2 `ssort1'
		
		egen tag1 = tag(layer2 height)
		by layer2: gen order = sum(tag1) // sort by value
		cap drop tag1
	}

	if "`stype1'"=="name" {
		if "`srev1'" == "reverse" {	
			local ssort1 -var
		}
		else {
			local ssort1 var
		}		
		
		gsort layer2  `ssort1' id
		
		egen tag2 = tag(layer2 var)
		by layer2 : gen order = sum(tag2) // sort by alphabetical order
		cap drop tag2
	}
	

	if "`stype1'"=="" & "`align'"=="" & "`fill'"=="" {
		
		if "`srev1'" == "reverse" {	
			local ssort1 -var
		}
		else {
			local ssort1 var
		}	
		
		gsort layer2 `ssort1' id
		
		egen tag2 = tag(layer2 var)
		by layer2 : gen order = sum(tag2) // take it as it is
		cap drop tag2
	
	}
	
	if "`stype1'"=="" & ("`align'"!="" | "`fill'"!="") {
		gsort layer2   id
		
		egen tag2 = tag(layer2 var)
		by layer2 : gen order = sum(tag2) // take it as it is
		cap drop tag2
	
	}		
	
	
	egen temp = tag(layer2 var)
	gen bar_order = sum(temp)
	drop temp
	
	
	
	
	*****************************
	**** generate the boxes   ***
	*****************************

	egen tag = tag(layer2 height order)
	sort layer2 tag order

	by layer2: gen double heightsum = sum(height) if tag==1

	// gen spike coordinates
	bysort layer2: gen double y1 = heightsum[_n-1] if tag==1
	recode y1 (.=0)
	gen double y2 = heightsum


	*** add gap

	tempvar mygap
	summ heightsum if tag==1, meanonly
	local maxval = r(max) * `gap' / 100  
	gen `mygap' = (order - 1) * `maxval' if tag==1 

	replace y1 = y1 + `mygap'
	replace y2 = y2 + `mygap'

	cap drop heightsum


	
	
	
	*************************
	** generate the links  **
	*************************

	sort layer2 var markme marker  

	// marker = 1 = outgoing
	// marker = 2 = incoming

	//////////////////////
	///  second sort   ///
	//////////////////////

	
	if "`stype2'"=="" | "`stype2'"=="order" {
		if "`srev2'" == "reverse" {
			local ssort2 -id // by order	
		}
		else {
			local ssort2 id // by order	
		}
		 
	}
	if "`stype2'"=="value" {
		if "`srev2'" == "reverse" {
			local ssort2 -val // by value	
		}
		else {
			local ssort2 val // by value	
		}
	}
	

	
	gsort layer2 marker var markme `ssort2'   // this determines the second sort

	by layer2 marker var: gen double stack_end   = sum(val) 		  if markme!=1
	by layer2 marker var: gen double stack_start = stack_end[_n - 1]  if markme!=1
	recode stack_start (.=0) if markme!=1	

	
	
	levelsof layer2, local(lvls)

	foreach x of local lvls {

		// outgoing levels
		levelsof var if layer2==`x' & marker==1, local(vars)
		
		foreach y of local vars {
			summ y1 if layer2==`x' & var==`y', meanonly
			local ymin = r(min)
			summ y2 if layer2==`x' & var==`y', meanonly
			local ymax = r(max)
			
			summ stack_end if layer2==`x' & var==`y' & marker==1, meanonly
			local smax = r(max)
			
			local displace = ((`ymax' - `ymin') - `smax' ) / 2
		
			replace stack_start = stack_start + `ymin' + `displace' if layer2==`x' & marker==1 & var==`y'
			replace stack_end   = stack_end   + `ymin' + `displace' if layer2==`x' & marker==1 & var==`y'
			
		}
		
		// incoming levels
		levelsof var if layer2==`x' & marker==2, local(vars)
		
		foreach y of local vars {
			summ y1 if layer2==`x' & var==`y', meanonly
			local ymin = r(min)
			summ y2 if layer2==`x' & var==`y', meanonly
			local ymax = r(max)
			
			summ stack_end if layer2==`x' & var==`y' & marker==2 , meanonly
			local smax = r(max)
			
			local displace = ((`ymax' - `ymin') - `smax' ) / 2
			
			replace stack_start = stack_start + `ymin' + `displace' if layer2==`x' & marker==2 & var==`y'
			replace stack_end   = stack_end   + `ymin' + `displace' if layer2==`x' & marker==2 & var==`y'
			
		}	
	}
	
	
	gen stack_x = layer2
	sort layer2 markme id
	
	
	// mark the highest value and the layer

	summ y2, meanonly
	local hival = r(max)
	
	
	// recenter
	
	*** recenter to middle

	levelsof layer2, local(lvls)		
			
	foreach x of local lvls {
		
		qui summ y1 if layer2==`x', meanonly
		local ymin = r(min)
		qui summ y2 if layer2==`x', meanonly
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
		
		replace y1 = y1 + `displace' if layer2==`x'
		replace y2 = y2 + `displace' if layer2==`x'
		
		replace stack_end   = stack_end   + `displace' if layer2==`x'
		replace stack_start = stack_start + `displace' if layer2==`x'		
	}
	
	
	
	
	// update the value of starting layer to total

	
	
	*** generate the curves	
	local newobs = `n'	
	expand `newobs'
	sort id layer2
	
	tempvar xtemp ytemp

	bysort id: gen double `xtemp' =  (_n / (`newobs' * 2))

	
	if "`smooth'" == "" local smooth = 4
	
	gen double `ytemp' =  (1 / (1 + (`xtemp' / (1 - `xtemp'))^-`smooth'))

	gen archi = .
	gen arclo = .

	
	levelsof layer	, local(cuts)
	levelsof id		, local(lvls)

	foreach x of local lvls {   // each id is looped over

		foreach y of local cuts {

			summ `ytemp' if id==`x' & layer==`y'
		
			
			// x-coordinates
			local ymin = cond(r(N) > 0, r(min), 0)
			local ymax = cond(r(N) > 0, r(max), 0)
			
			summ layer2 if layer==`y', meanonly
				local x0 = r(min)
				local x1 = r(max)

			
			// left y values
			summ stack_start if id==`x' & layer2==`x0' & layer==`y', meanonly
			local y1min = cond(r(N) > 0, r(min), 0)
							
			summ stack_start if id==`x' & layer2==`x1' & layer==`y', meanonly
			local y1max = cond(r(N) > 0, r(max), 0)			
			
			
			replace archi = (`y1max' - `y1min') * (`ytemp' - `ymin') / (`ymax' - `ymin') + `y1min' if id==`x' & layer==`y'
			
			
			// right y values
			summ stack_end if id==`x' & layer2==`x0' & layer==`y', meanonly
			local y2min = cond(r(N) > 0, r(min), 0)
			
			summ stack_end if id==`x' & layer2==`x1' & layer==`y', meanonly
			local y2max = cond(r(N) > 0, r(max), 0)	
			
			replace arclo = (`y2max' - `y2min') * (`ytemp' - `ymin') / (`ymax' - `ymin') + `y2min' if id==`x' & layer==`y'
			
		}
	}

	gen arcx = `xtemp' + layer

	
	**** fine tune
	if "`align'" != "" & "`fill'" == "" drop if _empty==1
	

	***** mid points for wedges
	egen tag_spike = tag(layer2 var tag)
	gen double ymid = (y1 + y2) / 2 if tag_spike==1
	
	
	***** mid points for sankey labels
	egen tag_id = tag(id marker)
	gen double arcmid = (stack_end + stack_start) / 2 if tag_id==1
	
	egen layer_id = group(layer2) // layer id for coloring

	
	// define all the locals before drawing
	
	if "`lcolor'"       == "" local lcolor black
	if "`labcolor'"     == "" local labcolor black
	if "`lwidth'"       == "" local lwidth 0.02	
	if "`colorvarmiss'" == "" local colorvarmiss gs12
	if "`labangle'" 	== "" local labangle 90
	if "`labsize'"  	== "" local labsize 2	
	
	if "`labgap'" 		== "" local labgap 0
	if "`valsize'"  	== "" local valsize 1.5
	if "`valgap'" 	 	== "" local valgap 2
	if "`boxwidth'"    	== "" local boxwidth 3.2
	if "`colorboxmiss'" == "" local colorboxmiss gs10
	
	if "`format'" 		== "" {
		if "`percent'" != "" {
			local format "%5.2f"
		}
		else {
			local format "%12.0f"
		}
	}
	
	if "`labposition'"  == "" local labposition 0	
	
	if "`labposition'" != "" {
		local lplen : word count `labposition'
		di "positions = `lplen'"
	}

		
	
	
	format val `format'	
	
	
	if "`colorby'" == "layer" | "`colorby'" == "level" {
		local switch 1
	}
	if "`colorby'"  == "" local switch 0		
	if "`colorvar'" != "" local switch 2	
	
	if "`palette'" == "" {
		local palette tableau
	}
	else {
		tokenize "`palette'", p(",")
		local palette  `1'
		local poptions `3'
	}	
	
	
	
	// draw bars
	
	local bars
	
	if `switch'==0 {
		levelsof var, local(lvls)
		local items = r(r)
		
		colorpalette `palette' , n(`items') nograph `poptions'
		foreach x of local lvls {			
			local bars `bars' (rspike y2 y1 layer2 if var==`x' & tag==1 & tag_spike==1, lw(`boxwidth')  lc("`r(p`x')'")) 
		}	
	}
	
	if `switch'==1 {
		levelsof layer_id, local(lvls)
		local items = r(r)
		
		colorpalette `palette' , n(`items') nograph `poptions'
		foreach x of local lvls {	
			local bars `bars' (rspike y2 y1 layer2 if layer_id==`x' & tag==1 & tag_spike==1, lw(`boxwidth')  lc("`r(p`x')'")) 
		}
	}
	
	if `switch'==2 {

		levelsof clrlvl
		local items = r(r)
		
		levelsof bar_order, local(lvls)
		foreach x of local lvls {			
			
			summ clrlvl if bar_order==`x' , meanonly
			
			if r(max) > 0 {
				local clr = r(max)
				colorpalette `palette' , n(`items') nograph `poptions'
				local myclr  `r(p`clr')'
			}
			else {
				local myclr  `colorboxmiss'
			}
			
			local bars `bars' (rspike y2 y1 layer2 if bar_order==`x' & tag==1 & tag_spike==1, lw(`boxwidth')  lc("`myclr'")) 
		}			
			
	}

	
	// draw arcs
	
	local shapes
	
	levelsof id if markme!=1, local(lvls)

	foreach x of local lvls {
		
		if `switch'==0 {
			summ var if id==`x' & marker==1, meanonly
		}
		if `switch'==1 {
			summ layer_id if id==`x' & marker==1, meanonly
		}
		if `switch'==2 {		 	// by layer
			sum clrlvl if id==`x' & tag_id==1, meanonly
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
		
		
			local shapes `shapes' (rarea archi arclo arcx if id==`x', lc(`lcolor') lw(`lwidth') fi(100) fcolor("`myclr'%`alpha'") ) 
		}
	}
	
		
	
	**** box labels
	
	if "`nolabels'" == "" {
		if "`showtotal'" != "" {
			gen lab2 = name + " (" + string(height, "`format'") + ")" if tag_spike==1
		}
		else {
			gen lab2 = name if tag_spike==1
		}
		
	
		if "`wrap'" != "" {
			ren lab2 lab2_temp
			labsplit lab2_temp, wrap(`wrap') gen(lab2)
			drop lab2_temp
		}			
		
		if "`labprop'" != "" {
			summ height if tag_spike==1, meanonly
			gen labwgt = `labsize' * (height / r(max))^`labscale' if tag_spike==1
			
			
			tempvar _lablyr
			egen `_lablyr' = group(id layer2) if tag_spike==1  // to prevent duplicates names
			
			
			levelsof `_lablyr', local(lvls)
			
			foreach x of local lvls {
				summ labwgt if `_lablyr'==`x' & tag_spike==1 & ymid!=., meanonly
				local labw = r(max)
			
				
				if `lplen' == 1 {
					local boxlabel `boxlabel' (scatter ymid layer2 if tag_spike==1 & `_lablyr'==`x' & height > `valcondition',  msymbol(none) mlabel(lab2) mlabsize(`labw') mlabpos(`labposition') mlabgap(`labgap') mlabangle(`labangle') mlabcolor(`labcolor')) 
				}
				else {
					levelsof layer2 if tag_spike==1, local(pos)
					foreach y of local pos {
						local _labpos : word `=`y'+1' of `labposition'
						local boxlabel `boxlabel' (scatter ymid layer2 if tag_spike==1  & height > `valcondition' & layer2==`y' & `_lablyr'==`x',  msymbol(none) mlabel(lab2) mlabsize(`labw') mlabpos(`_labpos') mlabgap(`labgap') mlabangle(`labangle') mlabcolor(`labcolor')) 
					}
				}
			}
		}
		else {  // no labprop
			if `lplen' == 1 {
				local boxlabel (scatter ymid layer2 if tag_spike==1  & height > `valcondition',  msymbol(none) mlabel(lab2) mlabsize(`labsize') mlabpos(`labposition') mlabgap(`labgap') mlabangle(`labangle') mlabcolor(`labcolor')) 
			}
			else {
				levelsof layer2 if tag_spike==1, local(lvls)
				foreach x of local lvls {
						
						local _labpos : word `=`x'+1' of `labposition'
						local boxlabel `boxlabel' (scatter ymid layer2 if tag_spike==1  & height > `valcondition' & layer2==`x',  msymbol(none) mlabel(lab2) mlabsize(`labsize') mlabpos(`_labpos') mlabgap(`labgap') mlabangle(`labangle') mlabcolor(`labcolor')) 
				}
			}
		}	
	}	

	
	local flowval val
	
	if "`percent'" != "" {
		gen valper = string(val, "`format'") + "%" if (marker==1 | marker==2)
		local flowval valper
	}
	

	**** arc labels
	
	if "`valprop'" != "" {
		summ val if tag==1, meanonly
		gen valwgt = `valsize' * (val / r(max))^`valscale' if tag_id==1
	}
	else {
		gen valwgt = 1 if tag_id==1
	}	
	
	if "`novalues'" == "" {
		if "`valprop'" == "" {
			
			if  "`novalleft'" == "" {
				local values `values' (scatter arcmid layer2  if val >= `valcondition' & marker==1, msymbol(none) mlabel(`flowval') mlabsize(`valsize') mlabpos(3) mlabgap(`valgap') mlabcolor(`labcolor')) 
			}
			
			if  "`novalright'" == "" {
				local values `values' (scatter arcmid layer2  if val >= `valcondition' & marker==2, msymbol(none) mlabel(`flowval') mlabsize(`valsize') mlabpos(9) mlabgap(`valgap') mlabcolor(`labcolor')) 
			}
		}
		else {
			
			levelsof id, local(lvls)
			
			foreach x of local lvls {
				summ valwgt if id==`x', meanonly
				local valw = r(mean)
			
				if  "`novalleft'" == "" {
					local values `values' (scatter arcmid layer2 if val >= `valcondition' & id==`x' & marker==1, msymbol(none) mlabel(val) mlabsize(`valw') mlabpos(3) mlabgap(`valgap') mlabcolor(`labcolor')) 
				}
			
				if  "`novalright'" == "" {
					local values `values' (scatter arcmid layer2 if val >= `valcondition' & id==`x' & marker==2, msymbol(none) mlabel(val) mlabsize(`valw') mlabpos(9) mlabgap(`valgap') mlabcolor(`labcolor')) 
				}
			}
		}		
	}
	
	
	**** fix the title lists
	
	if `"`ctitles'"' != "" {
		
		if "`ctpos'" == "bot" | "`ctpos'" == "" {
			summ y2, meanonly
			local cty = -1 * (`r(max)' * (`ctgap' / 100))
		}
		
		if "`ctpos'" == "top" {
			summ y2, meanonly
			local cty = `r(max)' * (`ctgap' / 100)
		}
		
		local clabs `"`ctitles'"'
		local len : word count `clabs'

		gen title_x 	= .
		gen title_y 	= `cty' in 1/`len'
		gen title_name 	= ""


		forval i = 1/`len' {
			replace title_x = `i' - 1 in `i' 
			
			local aa : word `i' of `clabs'
			replace title_name =  `"`:word `i' of `clabs''"' in `i'
		}
		
		
		if "`ctwrap'" != "" {
			ren title_name title_name_temp
			labsplit title_name_temp, wrap(`ctwrap') gen(title_name)
			drop title_name_temp
		}	
		
	}	
	
	**** column labels 
	
	if "`ctsize'"  == ""  local ctsize  2.5
	if "`ctcolor'" == ""  local ctcolor black
	
	if `"`ctitles'"' != "" {
		local lvllab (scatter title_y title_x, msymbol(none) mlabel(title_name) mlabcolor(`ctcolor') mlabpos(0) mlabsize(`ctsize')) ///
		
	}

	
	// offset	
	
	summ layer2, meanonly
	local xrmin = r(min)
	local xrmax = r(max) + ((r(max) - r(min)) * `offset' / 100)

	**** PLOT EVERYTHING ***
	
	
	twoway 			///
		`shapes' 	///
		`bars' 		///
		`boxlabel' 	///
		`values'  	///
		`lvllab'   	///
			, 		///
				legend(off) 										 ///
					xlabel(minmax, nogrid) ylabel(0 `yrange' , nogrid)     ///
					xscale(off range(`xrmin' `xrmax')) yscale(off)	 ///
					`options'
		
*/

restore
}
		
end




*********************************
******** END OF PROGRAM *********
*********************************


