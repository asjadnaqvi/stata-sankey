

![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-sankey) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-sankey) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-sankey) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-sankey) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-sankey)

[Installation](#Installation) | [Syntax](#Syntax) | [Citation guidelines](#Citation-guidelines) | [Examples](#Examples) | [Feedback](#Feedback) | [Change log](#Change-log)

---


![sankey-1](https://github.com/asjadnaqvi/stata-sankey/assets/38498046/b019b070-64c5-4d92-abdd-7774e1cefea6)


---

# sankey v1.81
(22 Sep 2024)

This package allows users to draw Sankey plots in Stata. It is based on the [Sankey Guide](https://medium.com/the-stata-guide/stata-graphs-sankey-diagram-ecddd112aca1) published on [the Stata Guide](https://medium.com/the-stata-guide) on Medium on October 2021.


## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

SSC (**v1.74**):

```
ssc install sankey, replace
```

GitHub (**v1.81**):

```
net install sankey, from("https://raw.githubusercontent.com/asjadnaqvi/stata-sankey/main/installation/") replace
```



The `palettes` package is required to run this command:

```
ssc install palettes, replace
ssc install colrspace, replace
ssc install graphfunctions, replace
```

Even if you have these packages installed, please check for updates: `ado update, update`.

If you want to make a clean figure, then it is advisable to load a clean scheme. These are several available and I personally use the following:

```
ssc install schemepack, replace
set scheme white_tableau  
```

You can also push the scheme directly into the graph using the `scheme(schemename)` option. See the help file for details or the example below.

I also prefer narrow fonts in figures with long labels. You can change this as follows:

```
graph set window fontface "Arial Narrow"
```


## Syntax

The syntax for the latest version is as follows:

```stata
sankey value [if] [in] [weight], from(var) to(var) 
            [ by(var) palette(str) colorby(layer|level) colorvar(var) stock stock2 colorvarmiss(str) colorboxmiss(str)
              smooth(1-8) gap(num) recenter(mid|bot|top) ctitles(list) ctgap(num) ctsize(num) ctposition(bot|top) 
              ctcolor(str) labangle(str) labsize(str) labposition(str) labgap(str) showtotal labprop labscale(num) 
              valsize(str) valcondition(num) format(str) valgap(str) novalues valprop valscale(num)
              novalright novalleft nolabels sort1(value|name[, reverse]) sort2(value|order[, reverse]) align fill 
              lwidth(str) lcolor(str) alpha(num) offset(num) boxwidth(str) percent wrap(num) * ]

```

See the help file `help sankey` for details.

The most basic use is as follows:

```
sankey value, from(var1) to(var2) [by(level)]
```

where `var1` and `var2` are source and destination variables respectively against which the `value` variable is plotted. The `by()` variable defines the levels and is optional since v1.72.


## Citation guidelines
Software packages take countless hours of programming, testing, and bug fixing. If you use this package, then a citation would be highly appreciated. Suggested citations:


*in BibTeX*

```
@software{sankey,
   author = {Naqvi, Asjad},
   title = {Stata package ``sankey''},
   url = {https://github.com/asjadnaqvi/stata-sankey},
   version = {1.81},
   date = {2024-10-16}
}
```

*or simple text*

```
Naqvi, A. (2024). Stata package "sankey" version 1.81. Release date 16 October 2024. https://github.com/asjadnaqvi/stata-sankey.
```


*or see [SSC citation](https://ideas.repec.org/c/boc/bocode/s459154.html) (updated once a new version is submitted)*


## Examples

Get the example data from GitHub:

```stata
import excel using "https://github.com/asjadnaqvi/stata-sankey/blob/main/data/sankey_example2.xlsx?raw=true", clear first
```

Let's test the `sankey` command:


```stata
sankey value, from(source) to(destination) by(layer)
```

<img src="/figures/sankey1.png" width="100%">


### Smooth 

```
sankey value, from(source) to(destination) by(layer) smooth(2)
```

<img src="/figures/sankey2_1.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) smooth(8)
```

<img src="/figures/sankey2_2.png" width="100%">


### Re-center

```
sankey value, from(source) to(destination) by(layer) recenter(bot)
```

<img src="/figures/sankey3_1.png" width="100%">


```
sankey value, from(source) to(destination) by(layer) recenter(top)
```

<img src="/figures/sankey3_2.png" width="100%">

### Gaps

```
sankey value, from(source) to(destination) by(layer) gap(0)
```

<img src="/figures/sankey4_1.png" width="100%">


```
sankey value, from(source) to(destination) by(layer) gap(20)
```

<img src="/figures/sankey4_2.png" width="100%">

### Values

```
sankey value, from(source) to(destination) by(layer) noval showtot
```

<img src="/figures/sankey5.png" width="100%">


### Sort (v1.6)

```
sankey value, from(source) to(destination) by(layer) sort1(name)
```

<img src="/figures/sankey5_1.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) sort1(value)
```

<img src="/figures/sankey5_2.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) sort1(value) sort2(value)
```

<img src="/figures/sankey5_2_1.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) sort1(name, reverse) sort2(value)
```

<img src="/figures/sankey5_2_2.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) sort1(name, reverse) sort2(value, reverse) 
```

<img src="/figures/sankey5_2_3.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) sort1(name, reverse) sort2(order) 
```

<img src="/figures/sankey5_2_4.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) sort1(name, reverse) sort2(order, reverse) 
```

<img src="/figures/sankey5_2_5.png" width="100%">


Custom sorting on a value:

```stata
gen source2 = .
gen destination2 = .

foreach x in source destination {
	replace `x'2 = 1 if `x'=="Blog"
	replace `x'2 = 2 if `x'=="LinkedIn"
	replace `x'2 = 3 if `x'=="Twitter"
	replace `x'2 = 4 if `x'=="Direct"
	replace `x'2 = 5 if `x'=="App"
	replace `x'2 = 6 if `x'=="Medium"	
	replace `x'2 = 7 if `x'=="Website"
	replace `x'2 = 8 if `x'=="Homepage"
	replace `x'2 = 9 if `x'=="Total"
	replace `x'2 = 10 if `x'=="Google"
	replace `x'2 = 11 if `x'=="Facebook"
}


lab de labels 1 "Blog" 2 "LinkedIn" 3 "Twitter" 4 "Direct" 5 "App" 6 "Medium" 7 "Website" 8 "Homepage" 9 "Total" 10 "Google" 11 "Facebook", replace

lab val source2 labels
lab val destination2 labels



sankey value, from(source2) to(destination2) by(layer) 
```

<img src="/figures/sankey5_2_6.png" width="100%">


### boxwidth

```
sankey value, from(source) to(destination) by(layer) boxwid(5)
```

<img src="/figures/sankey5_3.png" width="100%">


### valcond

```
sankey value, from(source) to(destination) by(layer) valcond(200)
```

<img src="/figures/sankey5_4.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) valcond(300)
```

<img src="/figures/sankey5_5.png" width="100%">


### Palettes

```
sankey value, from(source) to(destination) by(layer) palette(CET C6)
```

<img src="/figures/sankey6.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) colorby(level)
```

<img src="/figures/sankey6_1.png" width="100%">


### color by variable (v1.4)

```
gen trace1 = 1 if source=="App"

sankey value, from(source) to(destination) by(layer) colorvar(trace1)
```

<img src="/figures/sankey6_2.png" width="100%">

```
cap drop trace2
gen trace2 = .
replace trace2 = 1 if  source=="App" & destination=="App" & layer==0
replace trace2 = 2 if  source=="App" & destination=="App" & layer==1
replace trace2 = 3 if  source=="App" & destination=="App" & layer==2
replace trace2 = 4 if  source=="App" & destination=="Total" & layer==3

sankey value, from(source) to(destination) by(layer) colorvar(trace2)
```

<img src="/figures/sankey6_3.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) colorvar(trace2) palette(Oranges)
```

<img src="/figures/sankey6_4.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) colorvar(trace2) palette(Blues) ///
 colorvarmiss(gs13) colorboxmiss(gs13)
```

<img src="/figures/sankey6_5.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) colorvar(trace2) ///
palette(blue*0.1 blue*0.3 blue*0.5 blue*0.7) colorvarmiss(gs13) colorboxmiss(gs13)
```

<img src="/figures/sankey6_6.png" width="100%">

### column titles (v1.4)

```
sankey value, from(source) to(destination) by(layer) ctitles(Cat1 Cat2 Cat3 Cat4 Cat5)
```

<img src="/figures/sankey6_7.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) ctitles(Cat1 Cat2 Cat3 Cat4 Cat5) ctg(-100)
```

<img src="/figures/sankey6_8.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) ctitles("Cat 1" "Cat 2" "Cat 3" "Cat 4" "Cat 5") ctg(-100)
```

<img src="/figures/sankey6_9.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) ctitles("Cat 1" "Cat 2" "Cat 3" "Cat 4" "Cat 5") ctpos(top) ctg(100) recenter(top)
```

<img src="/figures/sankey6_9_1.png" width="100%">


### label rotation and offset

```
sankey value, from(source) to(destination) by(layer) noval showtot palette(CET C6) ///
	laba(0) labpos(3) labg(-1) offset(10)
```

<img src="/figures/sankey6_10.png" width="100%">


### hide values and labels (v1.5)

```
sankey value, from(source) to(destination) by(layer) novalleft
```

<img src="/figures/sankey8_1.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) novalright
```

<img src="/figures/sankey8_2.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) noval
```

<img src="/figures/sankey8_3.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) nolabels
```

<img src="/figures/sankey8_4.png" width="100%">


### proportional values and labels (v1.5)


```
sankey value, from(source) to(destination) by(layer) valprop vals(2) 
```

<img src="/figures/sankey9_1.png" width="100%">

```
sankey value, from(source) to(destination) by(layer) labprop labs(2)
```

<img src="/figures/sankey9_2.png" width="100%">


<img src="/figures/sankey10.png" width="100%">


### All together

```
sankey value, from(source) to(destination) by(layer) palette(CET C6) alpha(60) ///
	labs(2.5) laba(0) labpos(3) labg(-1) offset(5)  noval showtot ///
	ctitles("Cat 1" "Cat 2" "Cat 3" "Cat 4" "Cat 5") ctg(-100) cts(3) ///
	title("My sankey plot", size(6)) note("Made with the #sankey package.", size(2.2)) ///
	xsize(2) ysize(1)
```

<img src="/figures/sankey7.png" width="100%">


### stocks (v1.6+)

```stata
import excel using "https://github.com/asjadnaqvi/stata-sankey/blob/main/data/sankey_stocks.xlsx?raw=true", clear first
```

```
sankey value, from(source) to(destination) by(layer) xsize(2) ysize(1)
sankey value, from(source) to(destination) by(layer) xsize(2) ysize(1) stock
sankey value, from(source) to(destination) by(layer) xsize(2) ysize(1) stock2
```
<img src="/figures/sankey_stock1.png" width="100%">
<img src="/figures/sankey_stock2.png" width="100%">
<img src="/figures/sankey_stock3.png" width="100%">



## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-sankey/issues) to report errors, feature enhancements, and/or other requests.


## Change log

**v1.81 (16 Oct 2024)**
- Weights are now allowed. It is still advisable to prepare the data beforehand.
- `wrap()` now requires [graphfunctions](https://github.com/asjadnaqvi/stata-graphfunctions) for label wrapping the respects word boundaries.
- Option `stock2` added that collapses stocks on the right (incoming) and removes own flows. In contrast, `stock` collapses stocks on the left (out-going).
- Various code fixes should remove additional small bugs.

**v1.8 (22 Sep 2024)**
- Added option `align` to align flows. Works only if there is just one parent (still beta).
- Added option `fill` to extrapolate missing flows. Works only if there is just one parent (still beta).
- Added option `n()` to allow users to increase the number of points for generating the arcs. Default is 30.
- Quite a large code clean up so the command should run a bit faster.

**v1.74 (11 Jun 2024)**
- Added `wrap()` option for wrapping labels.
- Minor code cleanups.

**v1.73 (16 Mar 2024)**
- If the `from()` and `to()` variables have value labels, then the order of the value labels is respected. This allows the users to have full control of the order of the drawing of the layers through value labels (requested by Katie Naylor + others).
- The command now throws an error if `from()` and `to()` have different format types. Both have to be either string or numeric variables. This was necessary to implement in order to implement the above change.
- Minor code cleanups.

**v1.72 (12 Feb 2024)**
- Fixed `labprop` from wrong calculation the label sizes.
- `valcond()` now passes on to box labels. Was removed but has been put back in.
- `by()` changed to optional. Assumes one layer if not specified. This is mostly a quality of life improvement. A warning message is displayed to ensure that `by()` is not left out by mistake.
- `ctsize()` converted to string allow size names.
- `ctcolor()` added.
- Help file improved.
- Minor code cleanups

**v1.71 (15 Jan 2024)**
- Fixed a bug where numerical `from()` and `to()` variables with value labels were messing up the labels in the final figure (reported by Ian White).

**v1.7 (06 Nov 2023)**
- Fixed `valcond()` dropping bar values.
- Fixed `ctitles()` getting random colors. It now defaults to black.
- Added `ctpos()` option to change column title position.
- Added `percent` option which is still beta. Convert flows to percent values.

**v1.61 (22 Jul 2023)**
- `saving()` option added (requested by Anirban Basu).
- Minor fixes.

**v1.6 (11 Jun 2023)**
- Complete rewrite of the base routines. The code is 30% smaller but several times faster.
- The option `sortby()` split into `sort1()` and `sort2()` for clarity.
- Added support for numerical variables with value labels.
- Option `stock` added to collapse own flows (source = destination) to box heights (requested by Oras Alabas).
- Several code optimizations and minor bug fixes.

**v1.51 (25 May 2023)**
- Added background checks for `from()` and `to()` variable. This ensures that the code runs regardless of the variable types. Ideally both should be strings.

**v1.5 (30 Apr 2023)**
- Added `laprop`, `titleprop`, and `labscale()` for scaling values and labels.
- Added `novalright`, `novalleft`, `nolabels` options.
- Added `sortby(., reverse)` option.
- Help file improved in its layout.

**v1.4 (23 Apr 2023)**
- Fixed major bugs with unbalanced panels.
- Added column title options.
- Added option to draw colors by variables.
- Several bug fixes and improvements to the code.

**v1.31 (04 Apr 2023)**
- Fixed the color of categories. Previous version was resulting in wrong color assignments.

**v1.3 (26 Feb 2023)**
- Node bundling added which align nodes in front of each other. This looks better especially if flows are passing through certain nodes.
- Option `sortby()` added that allows alphabetical sorting (`sortby(name)`) or numerical sorting `sortby(value)` (Thanks to Fabian Unterlass for detailed feedback).
- Option `boxwdith()` added to allow adjusting the width of node boxes.

**v1.21 (15 Feb 2023)**
- `valcond()` fixed.
- Error in gaps fixed.

**v1.2 (02 Feb 2023)**
- Unbalanced Sankey's are now allowed. This means that incoming and outgoing layers do not necessarily have to be equal. Outgoing can be larger than incoming.
- A category can now also start in the middle.
- Various bug fixes.

**v1.1 (13 Dec 2022)**
- Option `valformat()` renamed to just `format`. This aligns it with standard Stata usages.
- A new option `offset()` added to displace x-axis on the right-hand side. Offset is given in percentage share of x-axis range. This allows rotated labels to be displaced properly.
- Checks for missing bilateral flow combinations. Hitting a non-flow combo was causing the code to crash.

**v1.0 (08 Dec 2022)**
- Public release.







