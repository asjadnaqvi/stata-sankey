{smcl}
{* 06Nov2023}{...}
{hi:help sankey}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-sankey":sankey v1.7 (GitHub)}}

{hline}

{title:sankey}: A Stata package for Sankey diagrams.

{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:sankey} {it:value} {ifin}, {cmdab:f:rom}({it:var}) {cmdab:t:o}({it:var}) {cmd:by}({it:var}) 
            {cmd:[} {cmd:palette}({it:str}) {cmd:colorby}({it:layer}|{it:level}) {cmd:colorvar}({it:var}) {cmd:stock} {cmd:colorvarmiss}({it:str}) {cmd:colorboxmiss}({it:str})
              {cmd:smooth}({it:1-8}) {cmd:gap}({it:num}) {cmdab:recen:ter}({it:mid}|{it:bot}|{it:top}) {cmdab:ctitle:s}({it:list}) {cmdab:ctg:ap}({it:num}) {cmdab:cts:ize}({it:num}) {cmdab:ctpos:ition}({it:bot}|{it:top})
              {cmdab:laba:ngle}({it:str}) {cmdab:labs:ize}({it:str}) {cmdab:labpos:ition}({it:str}) {cmdab:labg:ap}({it:str}) {cmdab:showtot:al} {cmd:labprop} {cmd:labscale}({it:num}) 
              {cmdab:vals:ize}({it:str}) {cmdab:valcond:ition}({it:num}) {cmd:format}({it:str}) {cmdab:valg:ap}({it:str}) {cmdab:noval:ues} {cmd:valprop} {cmd:valscale}({it:num})
              {cmdab:novalr:ight} {cmdab:novall:eft} {cmdab:nolab:els} {cmd:sort1}({it:value}|{it:name}[{it:, reverse}]) {cmd:sort2}({it:value}|{it:order}[{it:, reverse}])
              {cmdab:lw:idth}({it:str}) {cmdab:lc:olor}({it:str}) {cmd:alpha}({it:num}) {cmd:offset}({it:num}) {cmdab:boxw:idth}({it:str}) {cmd:percent}
              {cmd:title}({it:str}) {cmd:subtitle}({it:str}) {cmd:note}({it:str}) {cmd:scheme}({it:str}) {cmd:name}({it:str}) {cmd:xsize}({it:num}) {cmd:ysize}({it:num}) {cmd:saving}({it:str}) {cmd:]}

{p 4 4 2}
Please report errors/bugs/enhancement requests on {browse "https://github.com/asjadnaqvi/stata-sankey/issues":GitHub}. 


{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt sankey numvar, from() to() by()}}The command plots a numeric {it:numvar} variable that is defined by source {opt from()} and destination {opt to()}
across {opt by()} levels. Both {opt from()} and {opt to()} should be string variables. If they are not, then they are converted to strings. This is to ensure that 
mapping across {opt by()} levels remains consistent. The level {opt by()} should be a numeric variable defined in increments of 1.{p_end}

{p2coldent : {opt palette(name)}}Color name is any named scheme defined in the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt sort1(name|value[, reverse])}}Users can sort the boxes for each layer by using {ul:value} or {ul:name} (default).
The {opt sort1(value)} organizes the boxes based on their values, while {opt sort1(name)} arranges them alphabetically.
Both can be combined with reverse, e.g. {opt sort1(value, reverse)} or {opt sortby(name, reverse)}. Note that you can specify a custom sort by using value labels.{p_end}

{p2coldent : {opt sort2(order|vaue[, reverse])}}Users can sort the links between the boxes using {ul:value} or {ul:order} (default).
The {opt sort2(value)} arranges the links numerically, while {opt sort2(order)} arranges them in the order they originate. The latter is also aesthetically more pleasing
since it avoids links unnecessarily crossing each other.{p_end}

{p2coldent : {opt stock}}This is an advanced option that collapses own flows (source = destination) as stocks. Own flows are no longer shown as links but add to the stocks
that is reflected by the height of the boxes. This option can be useful if own flows are not be be considered as leakages from one layer to another.{p_end}

{p2coldent : {opt colorby(option)}}Users can color the diagram by {ul:layer} instead of the default where each unique name is taken as a unique color category.
The {it:layer} option is determined by the {opt by()} variable, and it will give each layer a unique color. Alternatively, use the {opt colorvar()} option below.{p_end}

{p2coldent : {opt colorvar(var)}}Users can color the diagram by {ul:variable}. The variable should contain integer values starting from 1. Any categories that are not assigned
a color will be automatically grayed out. The color of these categories can be controlled using the option below. Note that either {opt colorvar()} or {opt colorby()}
can be specified.{p_end}

{p2coldent : {opt colorvarmiss(str)}}Define the colors of the flows of the missing categories not defined in {opt colorvar()}. Default is {opt colorvarmiss(gs12)}.{p_end}

{p2coldent : {opt colorboxmiss(str)}}Define the colors of the boxes of the missing categories not defined in {opt colorvar()}. Default is {opt colorboxmiss(gs10)}.{p_end}

{p2coldent : {opt smooth(num)}}This option allows users to smooth out the spider plots connections. It can take on values between 1 to 8, where 1 is for straight lines, while 
is 8 shows steps. The middle range between 3-6 gives more curvy links. The default value is {opt smooth(4)}.{p_end}

{p2coldent : {opt gap(num)}}Gap between categories is defined as a percentage of the highest y-axis range across the layers. Default value is {opt gap(2)} for 2%.{p_end}

{p2coldent : {opt recen:ter(option)}}Users can recenter the graph {ul:middle} ({ul:mid} or {ul:m} also accepted), {ul:top} (or {ul:t}), or {ul:bottom} (or {ul:bot} or {ul:b}).
This is mostly an aesthetic choice. Default value is {opt recen(mid)}.{p_end}

{p2coldent : {opt alpha(num)}}The transparency control of the area fills. The value ranges from 0-100, where 0 is no fill and 100 is fully filled.
Default value is {opt alpha(75)} for 75% transparency.{p_end}

{p2coldent : {opt lw:idth(str)}}The outline width of the area fills. Default is {opt lw(none)}. This implies that they are turned off by default.{p_end}

{p2coldent : {opt lc:olor(str)}}The outline color of the area fills. Default is {opt lc(white)}.{p_end}

{p2coldent : {opt percent}} {bf:Beta option:} Covert flow values into percentage share of category bars. Might give messy output if outflows are greater than inflows.
Use cautiously.{p_end}


{p 4 4 2}{ul:{it:Bars}}

{p2coldent : {opt labs:ize(str)}}The size of the bar labels. Default is {opt labs(2)}.{p_end}

{p2coldent : {opt labprop}}Scale the bar labels based on the relative stocks.{p_end}

{p2coldent : {opt labscale(num)}}Scale factor of {opt labprop}. Default value is {opt labscale(0.3333)}. Advance option, use carefully.{p_end}

{p2coldent : {opt laba:ngle(str)}}The angle of the bar labels. Default is {opt laba(90)} for vertical labels.{p_end}

{p2coldent : {opt labc:olor(str)}}The color of the bar labels. Default is {opt labc(black)}.{p_end}

{p2coldent : {opt nolab:els}}Hide the bar labels.{p_end}

{p2coldent : {opt labpos:ition(str)}}The position of the bar labels. Default is {opt labpos(0)} for centered.{p_end}

{p2coldent : {opt labg:ap(str)}}The gap of the bars from the mid point. Default is {opt labg(0)} for no gap.
If the label angle is change to horitzontal or the label position is changed from 0, then {opt labg()} can be used to fine-tune the placement.{p_end}

{p2coldent : {opt showtot:al}}Display the category totals on the bars.{p_end}

{p2coldent : {opt boxw:idth(str)}}Width of the bars. Default is {opt boxw(3.2)}.{p_end}

{p2coldent : {opt labscale(num)}}Scaling factor of the labels. Default is {opt labscale(0.3333)}. Changing the value will change the relative
weights of the smaller and higher values. This is an advanced option therefore use with caution.{p_end}


{p 4 4 2}{ul:{it:Link values}}

{p2coldent : {opt vals:ize(str)}}The size of the displayed values. Default is {opt vals(1.5)}.{p_end}

{p2coldent : {opt valprop}}Scale the values based on the relative flows.{p_end}

{p2coldent : {opt valscale(num)}}Scale factor of {opt valprop}. Default value is {opt valscale(0.3333)}. Advance option, use carefully.{p_end}

{p2coldent : {opt noval:ues}}Hide the values.{p_end}

{p2coldent : {opt novalr:ight}}Hide values on the right. Cannot be combined with {opt novall}.{p_end}

{p2coldent : {opt novall:eft}}Hide values on the left. Cannot be combined with {opt novalr}.{p_end}

{p2coldent : {opt valcond:ition(num)}}This option can be specified to only display values >={it:num}, e.g. {opt valcond(100)} implies >= 100. This option
can be used to reduce the number of labels displayed especially if there are several very small categories that might make the figure look messy.{p_end}

{p2coldent : {opt format(str)}}The format of the displayed values. Default is {opt format(%12.0f)}.{p_end}


{p 4 4 2}{ul:{it:Column titles}}

{p2coldent : {opt ctitle:s(list)}}Give a list of column names. Names can either be defined as {opt ctitle("name1 name2 name3 ...")} or if there are spaces in 
names as {opt ctitle("My name1" "My name2" "My name3" "...")}. Please make sure names are not very long and match the number of columns.{p_end}

{p2coldent : {opt cts:ize(num)}}The size of the column titles. Default is {opt cts(2.5)}.{p_end}

{p2coldent : {opt ctg:ap(num)}}The gap of the column titles. Default is {opt ctg(0)}.{p_end}

{p2coldent : {opt ctpos:ition(bot|top)}}The position of column titles. No option defaults to {opt ctpos(bot)}. Might still need adjustment via {opt ctgap()}.{p_end}


{p 4 4 2}{ul:{it:Miscellaneous}}

{p2coldent : {opt offset(num)}}The value, in percentage of x-axis width, to extend the x-axis on the right-hand side. Default is {opt offset(0)}.
This option is highly useful especially if labels are rotated with custom positions.{p_end}

{p2coldent : {opt title()}, {opt subtitle()}, {opt note()}}These are standard twoway graph options.{p_end}

{p2coldent : {opt scheme()}, {opt name()}, {opt saving()}}These are standard twoway graph options.{p_end}

{p2coldent : {opt xsize()}, {opt ysize()}}These standard twoway options can be used to space out the layers.
This is particularly helpful if several layers are plotted.{p_end}

{synoptline}
{p2colreset}{...}


{title:Dependencies}

The {browse "http://repec.sowi.unibe.ch/stata/palettes/index.html":palette} package (Jann 2018, 2022) is required for {opt sankey}:

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}

Even if you have these installed, it is highly recommended to regularly check for updates.


{title:Examples}

See {browse "https://github.com/asjadnaqvi/stata-sankey":GitHub} for examples.


{hline}

{title:Version history}

- {bf:1.7}  : Fixed {opt valcond()} dropping bar values, and fixed ctitles color to black. Added {opt percent} (beta), {opt ctpos()}.
- {bf:1.61} : Adding saving() option. 
- {bf:1.6}  : Rewrite of core routines. {opt sortby()} split into {opt sort1()} and {opt sort2()}. New option {opt stock} added.
- {bf:1.51} : Add a string check for {opt from()} and {opt by()} variables.
- {bf:1.5}  : Added {opt labprop}, {opt valprop}, {opt labscale()}, {opt valnoright}, {opt valnoleft}, {opt sortby(, reverse)}.
- {bf:1.4}  : Fixed the unbalanced panels. Fixed gaps between categories. Add column labels option. Added custom colors option.
- {bf:1.3}  : Node bundling added to align nodes across groups. Options {opt sortby()} and {opt boxwidth()} added.
- {bf:1.21} : Bug fixes for 1.2. {opt labcolor()} added.
- {bf:1.2}  : Unbalanced in-coming and out-going groups now properly displace. Groups ending and starting in the middle now allowed.
- {bf:1.1}  : Enhancements. {opt valformat()} renamed to {opt format()}. {opt offset} added to displace x-axis range.
- {bf:1.0}  : First version.


{title:Package details}

Version      : {bf:sankey} v1.7
This release : 06 Nov 2023
First release: 08 Dec 2022
Repository   : {browse "https://github.com/asjadnaqvi/stata-sankey":GitHub}
Keywords     : Stata, graph, sankey
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}



{title:Feedback}

Please submit bugs, errors, feature requests on {browse "https://github.com/asjadnaqvi/stata-alluvial/issues":GitHub} by opening a new issue.

{title:References}

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Jann, B. (2022). {browse "https://ideas.repec.org/p/bss/wpaper/43.html":Color palettes for Stata graphics: an update}. University of Bern Social Sciences Working Papers No. 43. 


{title:Other visualization packages}

{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb joyplot}, 
	{helpb marimekko}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb streamplot}, {helpb sunburst}, {helpb treecluster}, {helpb treemap}