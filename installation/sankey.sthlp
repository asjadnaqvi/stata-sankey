{smcl}
{* 13Dec2022}{...}
{hi:help sankey}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-sankey":sankey v1.1 (GitHub)}}

{hline}

{title:sankey}: A Stata package for Sankey diagrams.

{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:sankey} {it:value} {ifin}, {cmdab:f:rom}({it:var}) {cmdab:t:o}({it:var}) {cmd:by}({it:var}) 
                {cmd:[} 
                  {cmd:palette}({it:str}) {cmd:colorby}({it:layer}|{it:level}) {cmd:smooth}({it:1-8}) {cmd:gap}({it:num}) {cmdab:recen:ter}({it:mid}|{it:bot}|{it:top}) 
                  {cmdab:laba:ngle}({it:str}) {cmdab:labs:ize}({it:str}) {cmdab:labpos:ition}({it:str}) {cmdab:labg:ap}({it:str}) {cmdab:showtot:al}
                  {cmdab:vals:ize}({it:str}) {cmdab:valcond:ition}({it:str}) {cmd:format}({it:str}) {cmdab:valg:ap}({it:str}) {cmdab:noval:ues}
                  {cmdab:lw:idth}({it:str}) {cmdab:lc:olor}({it:str}) {cmd:alpha}({it:num} {cmd:offset}({it:num})
                  {cmd:title}({it:str}) {cmd:subtitle}({it:str}) {cmd:note}({it:str}) {cmd:scheme}({it:str}) {cmd:name}({it:str}) {cmd:xsize}({it:num}) {cmd:ysize}({it:num}) 
                {cmd:]}


{p 4 4 2}
Please note that {opt sankey} is still in beta and not all checks and balances have been added.
Please report errors/bugs/enhancement requests on {browse "https://github.com/asjadnaqvi/stata-alluvial/issues":GitHub}. 


{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt sankey} value, from() to() by()}The command requires a numeric variable that contains the values. Both {cmd:from()} and {cmd:to()} can contain numeric, labeled or string variables.
The {cmd:by()} variable contains a layer variable which ideally should be numeric. If strings are used, please make sure spellingd are consitent for categories across layers.{p_end}

{p2coldent : {opt palette(name)}}Color name is any named scheme defined in the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt colorby(option)}}Users can color the diagram by {ul:layer} or {ul:level}.
The {it:layer} option, determined by the {cmd:by()} variable, will give each layer a unique color.
The {it:level} option will give each category a unique color, even if they exist across multiple layers.
The default value is {cmd:colorby(level)}.{p_end}

{p2coldent : {opt smooth(num)}}This option allows users to smooth out the spider plots connections. It can take on values between [1,8], where 1 is for straight lines, and 8 is stepwise.
The middle range between 3-6 gives more curvy links. The default value is {cmd:smooth(4)}.{p_end}

{p2coldent : {opt gap(num)}}Gap between categories is defined as a percentage of the highest y-axis range across the layers. Default value is {cmd:gap(2)} for 2%.{p_end}

{p2coldent : {opt recen:ter(option)}}Users can recenter the graph {ul:middle} ({ul:mid} or {ul:m} also accepted), {ul:top} (or {ul:t}), or {ul:bottom} (or {ul:bot} or {ul:b}).
This is mostly an aesthetic choice. Default value is {cmd:recen(mid)}.{p_end}

{p2coldent : {opt alpha(num)}}The transparency control of the area fills. The value ranges from 0-100, where 0 is no fill and 100 is fully filled.
Default value is {cmd:alpha(75)} for 75% transparency.{p_end}

{p2coldent : {opt lw:idth(str)}}The outline width of the area fills. Default is {cmd:lw(none)}. This implies that they are turned off by default.{p_end}

{p2coldent : {opt lc:olor(str)}}The outline color of the area fills. Default is {cmd:lc(white)}.{p_end}

{p2coldent : {opt labs:ize(str)}}The size of the category labels. Default is {cmd:labs(2)}.{p_end}

{p2coldent : {opt laba:ngle(str)}}The angle of the category labels. Default is {cmd:laba(90)} for vertical labels.{p_end}

{p2coldent : {opt labpos:ition(str)}}The position of the category labels. Default is {cmd:labpos(0)} for centered.{p_end}

{p2coldent : {opt labg:ap(str)}}The gap of the category labels from the mid point of the wedges. Default is {cmd:labg(0)} for no gap.
If the label angle is change to horitzontal or the label position is changed from 0, then {cmd:labg()} can be used to fine-tune the placement.{p_end}

{p2coldent : {opt showtot:al}}Display the category totals.{p_end}

{p2coldent : {opt vals:ize(str)}}The size of the displayed values. Default is {cmd:vals(1.5)}.{p_end}

{p2coldent : {opt valcond:ition(str)}}The condition to display the values.
This option can be used to reduce the number of labels displayed especially if there are a lot of very small categories than can make the figure look messy.
The way to use this option is to define an if condition, e.g. {cmd:valcond(>=100)}, will only show values above 100.{p_end}

{p2coldent : {opt format(str)}}The format of the displayed values. Default is {cmd:format(%12.0f)}.{p_end}

{p2coldent : {opt noval:ues}}Hide the values.{p_end}

{p2coldent : {opt offset(num)}}The value, in percentage of x-axis width, to extend the x-axis on the right-hand side. Default is {cmd:offset(0)}.
This option is highly useful if labels are rotated and positioned, for example, at 3 o'clock.{p_end}

{p2coldent : {opt title()}, {opt subtitle()}, {opt note()}}These are standard twoway graph options.{p_end}

{p2coldent : {opt scheme()}, {opt name()}}These are standard twoway graph options.{p_end}

{p2coldent : {opt xsize()}, {opt ysize()}}These standard twoway options can be used to space out the layers.
This is particularly helpful if several layers are plotted.{p_end}

{synoptline}
{p2colreset}{...}


{title:Dependencies}

The {browse "http://repec.sowi.unibe.ch/stata/palettes/index.html":palette} package (Jann 2018) is required for {cmd:sankey}:

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}

Even if you have these installed, it is highly recommended to update the dependencies:
{stata ado update, update}

{title:Examples}

See {browse "https://github.com/asjadnaqvi/stata-sankey":GitHub} for examples.



{hline}

{title:Version history}

- {bf:1.1} : Enhancements. {opt valformat()} renamed to {opt format()}. {opt offset} added to displace x-axis range.
- {bf:1.0} : First version.


{title:Package details}

Version      : {bf:sankey} v1.1
This release : 13 Dec 2022
First release: 08 Dec 2022
Repository   : {browse "https://github.com/asjadnaqvi/stata-sankey":GitHub}
Keywords     : Stata, graph, sankey
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}


{title:Acknowledgements}



{title:Feedback}

Please submit bugs, errors, feature requests on {browse "https://github.com/asjadnaqvi/stata-alluvial/issues":GitHub} by opening a new issue.

{title:References}

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{title:Other visualization packages}

{psee}
    {helpb alluvial}, {helpb circlebar}, {helpb spider}, {helpb treemap}, {helpb circlepack}, {helpb arcplot},
	{helpb marimekko}, {helpb bimap}, {helpb joyplot}, {helpb streamplot}, {helpb delaunay}, {helpb clipgeo},  {helpb schemepack}