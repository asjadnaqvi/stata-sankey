{smcl}
{* 07May2026}{...}
{hi:help sankey}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-sankey":sankey v1.91 (GitHub)}}

{hline}

{title:sankey}: A Stata package for Sankey diagrams.

{marker syntax}{title:Syntax}

{p 8 15 2}

{cmd:sankey} {it:value} {ifin} {weight}, {cmd:from}({it:var}) {cmd:to}({it:var}) 
		{cmd:[} {cmd:by}({it:var}) {cmd:palette}({it:str}) {cmd:colorby}({it:layer}|{it:level}) {cmd:colorvar}({it:var}) {cmd:stock} {cmd:stock2} 
		  {cmd:colorvarmiss}({it:str}) {cmd:colorboxmiss}({it:str}) {cmd:smooth}({it:1-8}) {cmd:gap}({it:num}) {cmd:recenter}({it:mid}|{it:bot}|{it:top}) 
		  {cmd:range}({it:num}) {cmd:format}({it:str}) {cmd:sort1}({it:value}|{it:name}[{it:, reverse}]) {cmd:sort2}({it:value}|{it:order}[{it:, reverse}]) 
		  {cmd:alpha}({it:num}) {cmd:lwidth}({it:str}) {cmd:lcolor}({it:str}) {cmd:align} {cmd:fill} {cmd:offset}({it:num}) {cmd:percent}
		  {cmd:labsize}({it:str}) {cmd:labprop} {cmd:labscale}({it:num}) {cmd:labangle}({it:str}) {cmd:labposition}({it:str}) {cmd:labgap}({it:str}) 
		  {cmd:nolabels} {cmd:wrap}({it:num}) {cmd:showtotal} {cmd:boxwidth}({it:str}) {cmd:valsize}({it:str}) {cmd:valprop} {cmd:valscale}({it:num}) 
		  {cmd:novalues} {cmd:novalright} {cmd:novalleft} {cmd:valcondition}({it:num}) {cmd:ctitles}({it:list}) {cmd:ctsize}({it:num}) 
		  {cmd:ctgap}({it:num}) {cmd:ctcolor}({it:str}) {cmd:ctposition}({it:bot}|{it:top}) {cmd:ctwrap}({it:num}) {cmd:*} {cmd:]}

{marker options}{title:Options}

{synoptset 24 tabbed}{...}

{marker required}{dlgtab:Required}

{p2coldent : {opt from(var)}}Source variable; should be string or will be converted to string to ensure consistent mapping across {opt by()} levels.{p_end}

{p2coldent : {opt to(var)}}Destination variable; should be string or will be converted to string to ensure consistent mapping across {opt by()} levels.{p_end}

{marker display}{dlgtab:Display options}

{p2coldent : {opt by(var)}}The layers variable. Should be numeric, defined in increments of 1. If not specified, the command assumes one layer and displays a warning.{p_end}

{p2coldent : {opt sort1(name|value[, reverse])}}Sort boxes in each layer by {ul:name} (default, alphabetical) or {ul:value} (numerically).
Can combine with {opt reverse}, e.g., {opt sort1(value, reverse)}. Custom sorts can be applied using value labels.{p_end}

{p2coldent : {opt sort2(order|value[, reverse])}}Sort links between boxes by {ul:order} (default, as they originate) or {ul:value} (numerically).
The order option aesthetically avoids unnecessary link crossings. Can combine with {opt reverse}.{p_end}

{p2coldent : {opt align}}If there are single parent-child relationships, this option aligns flows to the parent's horizontal orientation rather than compact centering.{p_end}

{p2coldent : {opt fill}}If a node ends in the middle layers, generate missing values to complete the layers.{p_end}

{p2coldent : {opt stock}}Own flows (source = destination) are shown as stocks on the left (outgoing layer) and links are removed.{p_end}

{p2coldent : {opt stock2}}Own flows (source = destination) are shown as stocks on the right (incoming layer) and links are removed.{p_end}

{p2coldent : {opt offset(num)}}Extend the x-axis on the right-hand side, in percentage of x-axis width. Default is {opt offset(0)}.
Useful when labels are rotated with custom positions.{p_end}

{p2coldent : {opt percent}}{bf:Beta option:} Convert flow values to percentage share of category bars. Might give messy output if outflows exceed inflows.{p_end}

{marker colors}{dlgtab:Colors and visual properties}

{p2coldent : {opt palette(str)}}Color scheme. Any named scheme from the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt colorby(layer|level)}}Color diagram by {ul:layer} (each layer gets a unique color from the palette) or leave unspecified to color by unique names.
Alternatively, use {opt colorvar()} for finer control.{p_end}

{p2coldent : {opt colorvar(var)}}Color the diagram by a variable. The variable should contain integer values starting from 1. 
Categories not assigned a color are automatically grayed out; control their color with the options below.
Note: either {opt colorvar()} or {opt colorby()} can be specified, not both.{p_end}

{p2coldent : {opt colorvarmiss(str)}}Color of flows for categories not defined in {opt colorvar()}. Default is {opt colorvarmiss(gs12)}.{p_end}

{p2coldent : {opt colorboxmiss(str)}}Color of boxes for categories not defined in {opt colorvar()}. Default is {opt colorboxmiss(gs10)}.{p_end}

{p2coldent : {opt alpha(num)}}Transparency of area fills, ranging from 0-100. 0 = no fill, 100 = fully opaque. Default is {opt alpha(75)}.{p_end}

{p2coldent : {opt lwidth(str)}}Outline width of area fills. Default is {opt lwidth(none)} (off by default).{p_end}

{p2coldent : {opt lcolor(str)}}Outline color of area fills. Default is {opt lcolor(white)}.{p_end}

{marker flow}{dlgtab:Flow and layout}

{p2coldent : {opt smooth(num)}}Smooth out the link curves. Range 1-8: 1 = straight lines, 8 = steps, 3-6 = smooth S-shaped. Default is {opt smooth(4)}.{p_end}

{p2coldent : {opt gap(num)}}Gap between categories, as a percentage of maximum y-axis range. Default is {opt gap(2)}.{p_end}

{p2coldent : {opt recenter(mid|bot|top)}}Vertical alignment of content: {ul:mid} or {ul:m} = middle (default), {ul:bot} or {ul:b} = bottom, {ul:top} or {ul:t} = top.
Mostly aesthetic. Default is {opt recenter(mid)}.{p_end}

{p2coldent : {opt range(num)}}Fix the vertical scale to a specified value. Enables consistent height comparisons across subsets or panels.
Must be greater than or equal to the maximum observed height.{p_end}

{marker labels}{dlgtab:Labels and text}

{p2coldent : {opt labsize(str)}}Size of bar labels. Default is {opt labsize(2)}.{p_end}

{p2coldent : {opt labprop}}Scale bar labels proportionally to their relative stocks.{p_end}

{p2coldent : {opt labscale(num)}}Scaling factor for {opt labprop}. Default is {opt labscale(0.3333)}. 
Values closer to 0 give more exponential scaling; values closer to 1 give nearly linear scaling. Advanced option.{p_end}

{p2coldent : {opt labangle(str)}}Angle of bar labels in degrees. Default is {opt labangle(90)} for vertical labels.{p_end}

{p2coldent : {opt labposition(str)}}Position of bar labels. Default is {opt labposition(0)} for centered. 
Can also accept position lists for fine-tuning; e.g., {opt labposition(9 3)} for left and right labels.{p_end}

{p2coldent : {opt labgap(str)}}Gap of bars from the midpoint. Default is {opt labgap(0)}.
Useful when label angle or position is adjusted for fine-tuning placement.{p_end}

{p2coldent : {opt wrap(num)}}Wrap bar labels after this many characters. For example, {opt wrap(10)} breaks every 10 characters.{p_end}

{p2coldent : {opt nolabels}}Hide all bar labels.{p_end}

{p2coldent : {opt showtotal}}Display the category totals on the bars.{p_end}

{p2coldent : {opt boxwidth(str)}}Width of the bars. Default is {opt boxwidth(3.2)}.{p_end}

{marker values}{dlgtab:Link values}

{p2coldent : {opt valsize(str)}}Size of displayed values on links. Default is {opt valsize(1.5)}.{p_end}

{p2coldent : {opt valprop}}Scale link values proportionally to their relative flows.{p_end}

{p2coldent : {opt valscale(num)}}Scaling factor for {opt valprop}. Default is {opt valscale(0.3333)}. Advanced option.{p_end}

{p2coldent : {opt novalues}}Hide all link values.{p_end}

{p2coldent : {opt novalright}}Hide values on the right. Cannot be combined with {opt novalleft}.{p_end}

{p2coldent : {opt novalleft}}Hide values on the left. Cannot be combined with {opt novalright}.{p_end}

{p2coldent : {opt valcondition(num)}}Only display values >= {it:num}. For example, {opt valcondition(100)} shows only values >= 100.
Useful to reduce clutter from very small categories.{p_end}

{p2coldent : {opt format(str)}}Format for displayed values. Default is {opt format(%12.0f)}.{p_end}

{marker titles}{dlgtab:Column titles}

{p2coldent : {opt ctitles(list)}}List of column/layer names. Can be specified as {opt ctitles("name1 name2 name3")} or with spaces as 
{opt ctitles("My name1" "My name2" "My name3")}. Ensure names are not too long and match the number of columns.{p_end}

{p2coldent : {opt ctsize(num)}}Size of column titles. Default is {opt ctsize(2.5)}.{p_end}

{p2coldent : {opt ctgap(num)}}Gap between column titles and bars, as percentage of total height. Default is {opt ctgap(0)}.{p_end}

{p2coldent : {opt ctcolor(str)}}Color of column titles. Default is {opt ctcolor(black)}.{p_end}

{p2coldent : {opt ctposition(bot|top)}}Position of column titles: {ul:bot} (bottom, default) or {ul:top}. May still need adjustment via {opt ctgap()}.{p_end}

{p2coldent : {opt ctwrap(num)}}Wrap column titles after this many characters. For example, {opt ctwrap(10)} breaks every 10 characters.{p_end}

{marker twoway}{dlgtab:Twoway options}

{p2coldent : {opt *}}All other standard twoway options not elsewhere specified and not blocked by the program.{p_end}

{synoptline}
{p2colreset}{...}

{title:Dependencies}

The {browse "http://repec.sowi.unibe.ch/stata/palettes/index.html":palettes} package (Jann 2018, 2022) and {browse "https://github.com/asjadnaqvi/stata-graphfunctions":graphfunctions} package are required:

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}
{stata ssc install graphfunctions, replace}


{title:Examples}

See {browse "https://github.com/asjadnaqvi/stata-sankey":GitHub} for examples.


{hline}

{title:Package details}

Version      : {bf:sankey} v1.91
This release : 07 May 2026
First release: 08 Dec 2022
Repository   : {browse "https://github.com/asjadnaqvi/stata-sankey":GitHub}
Keywords     : Stata, graph, sankey
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}


{title:Feedback}

Please submit bugs, errors, feature requests on {browse "https://github.com/asjadnaqvi/stata-sankey/issues":GitHub} by opening a new issue.


{title:Citation guidelines}

See {browse "https://ideas.repec.org/c/boc/bocode/s459154.html"} for the official SSC citation. 
Please note that the GitHub version might be newer than the SSC version.


{title:References}

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Jann, B. (2022). {browse "https://ideas.repec.org/p/bss/wpaper/43.html":Color palettes for Stata graphics: an update}. University of Bern Social Sciences Working Papers No. 43. 


{title:Other visualization packages}

{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb graphfunctions},
	{helpb geoboundary}, {helpb geoflow}, {helpb joyplot}, {helpb marimekko}, {helpb polarspike}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb splinefit}, {helpb streamplot}, 
	{helpb sunburst}, {helpb ternary}, {helpb tidytuesday}, {helpb treecluster}, {helpb treemap}, {helpb trimap}, {helpb waffle}

Visit {browse "https://github.com/asjadnaqvi":GitHub} for further information.	