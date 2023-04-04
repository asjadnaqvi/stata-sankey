![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-sankey) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-sankey) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-sankey) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-sankey) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-sankey)

---

[Installation](#Installation) | [Syntax](#Syntax) | [Examples](#Examples) | [Feedback](#Feedback) | [Change log](#Change-log)

---

# sankey v1.31

This package allows us to draw Sankey plots in Stata. It is based on the [Sankey Guide](https://medium.com/the-stata-guide/stata-graphs-sankey-diagram-ecddd112aca1) (October 2021).


## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

SSC (**v1.3**):

```
ssc install sankey, replace
```

GitHub (**v1.31**):

```
net install sankey, from("https://raw.githubusercontent.com/asjadnaqvi/stata-sankey/main/installation/") replace
```



The `palettes` package is required to run this command:

```
ssc install palettes, replace
ssc install colrspace, replace
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

The syntax for **v1.3** is as follows:

```applescript
sankey value [if] [in], from(var) to(var) by(var) 
                [ 
                  palette(str) colorby(layer|level) smooth(1-8) gap(num) recenter(mid|bot|top) 
                  labangle(str) labsize(str) labposition(str) labgap(str) showtotal
                  valsize(str) valcondition(str) format(str) valgap(str) novalues
                  lwidth(str) lcolor(str) alpha(num) offset(num) sortby(value|name) boxwidth(str)
                  title(str) subtitle(str) note(str) scheme(str) name(str) xsize(num) ysize(num) 
                ]
```

See the help file `help sankey` for details.

The most basic use is as follows:

```
sankey value, from(var1) to(var2) by(level variable)
```

where `var1` and `var2` are the string source and destination variables respectively against which the `value` variable is plotted. The `by()` variable defines the levels.



## Examples

Get the example data from GitHub:

```
use "https://github.com/asjadnaqvi/stata-sankey/blob/main/data/sankey2.dta?raw=true", clear
```

Let's test the `sankey` command:


```
sankey value, from(source) to(destination) by(layer)
```

<img src="/figures/sankey1.png" height="600">


### Smooth 

```
sankey value, from(source) to(destination) by(layer) smooth(2)
```

<img src="/figures/sankey2_1.png" height="600">

```
sankey value, from(source) to(destination) by(layer) smooth(8)
```

<img src="/figures/sankey2_2.png" height="600">


### Re-center

```
sankey value, from(source) to(destination) by(layer) recenter(bot)
```

<img src="/figures/sankey3_1.png" height="600">


```
sankey value, from(source) to(destination) by(layer) recenter(top)
```

<img src="/figures/sankey3_2.png" height="600">

### Gaps

```
sankey value, from(source) to(destination) by(layer) gap(0)
```

<img src="/figures/sankey4_1.png" height="600">


```
sankey value, from(source) to(destination) by(layer) gap(20)
```

<img src="/figures/sankey4_2.png" height="600">

### Values

```
sankey value, from(source) to(destination) by(layer) noval showtot
```

<img src="/figures/sankey5.png" height="600">


### Palettes

```
sankey value, from(source) to(destination) by(layer) palette(CET C7)
```

<img src="/figures/sankey6.png" height="600">

```
sankey value, from(source) to(destination) by(layer) colorby(level)
```

<img src="/figures/sankey6_1.png" height="600">

### Label rotations and offset (v1.1)

```
sankey value, from(source) to(destination) by(layer) noval showtot palette(CET C6) ///
	laba(0) labpos(3) labg(-1) offset(10)
```

<img src="/figures/sankey6_2.png" height="600">


### Unbalanced sankeys (v1.2)


```
import excel using "https://github.com/asjadnaqvi/stata-sankey/blob/main/data/sankey_simple.xlsx?raw=true", first clear

sankey value, from(source) to(destination) by(layer) showtot 
```

<img src="/figures/sankey_unbalanced.png" height="600">

### All together

```
sankey value, from(source) to(destination) by(layer) palette(CET C7) ///
	valcond(>100) valsize(1.6) showtotal ///
	xsize(2) ysize(1) lc(white) lw(0.1) 
```

<img src="/figures/sankey7.png" height="500">

## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-sankey/issues) to report errors, feature enhancements, and/or other requests.


## Change log

**v1.31 (04 Apr 2023)**
- Fix the color of categories. v1.3 was resulting in wrong color assignments.

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







