{smcl}
{* *! version 1.0 23 Feb 2026}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "genmdt##syntax"}{...}
{viewerjumpto "Description" "genmdt##description"}{...}
{viewerjumpto "Options" "genmdt##options"}{...}
{viewerjumpto "Remarks" "genmdt##remarks"}{...}
{viewerjumpto "Examples" "genmdt##examples"}{...}
{title:Title}
{phang}
{bf:genmdt} {hline 2} a command to generate multi-dimentional table from statistical survey

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:genmdt}
[varlist(default=none)]
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Optional}
{synopt:{opt margin:labels(string asis)}} specify the labels of margins of domains specified in  in varlist.

{synopt:{opt mean(string asis)}} used to spefify list of variables for which average will be estimated

{synopt:{opt total(string asis)}} used to spefify list of variables for which total will be estimated

{synopt:{opt ratio(string asis)}} used to spefify list of variables for which ratio will be estimated

{synopt:{opt hiergeo:vars(string asis)}} used to specify geographic variables that have hierachical link.

{synopt:{opt integer(string asis)}} used to spefify list of variables for which estimates will be display as integer (and not with decimal)

{synopt:{opt geomargin:label(string)}} used specify the label of the geographic variables in case hiergeovars is used

{synopt:{opt cond:itionals(string asis)}} eliminate tuples (of dimensions in varlist) according to specified conditions.

{synopt:{opt :svySE(string)}}  

{synopt:{opt subpop(string asis)}} {cmd:(}[{varname}

{synopt:{opt unit:s(string asis)}} used to spefify units of the variable that will be estimates with mean, total or ratio .

{synopt:{opt indicator:name(string asis)}} a comprehensive and informative label of the indicator generated with variables specified in 'variable'.

{synopt:{opt setcluster(#)}} used to spefify the number of cores in case one wants genrrate the multi-dimentional table with parallel computing.

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
 {cmd:genmdt} generate multi-dimentional statisticial tables from statistical survey.

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt margin:labels(string asis)} specify the labels of margins of domains specified in  in varlist.

{phang}
{opt mean(string asis)} used to spefify list of variables for which average will be estimated

{phang}
{opt total(string asis)} used to spefify list of variables for which total will be estimated

{phang}
{opt ratio(string asis)} used to spefify list of variables for which ratio will be estimated

{phang}
{opt hiergeo:vars(string asis)} used to specify geographic variables that have hierachical link.

{phang}
{opt integer(string asis)} used to spefify list of variables for which estimates will be display as integer (and not with decimal)

{phang}
{opt geomargin:label(string)} used specify the label of the geographic variables in case hiergeovars is used

{phang}
{opt cond:itionals(string asis)} eliminate tuples (of dimensions in varlist) according to specified conditions.

{phang}
{opt :svySE(string)}  

{phang}
{opt subpop(string asis)} {cmd:(}[{varname}

{phang}
{opt unit:s(string asis)} used to spefify units of the variable that will be estimates with mean, total or ratio .

{phang}
{opt indicator:name(string asis)} a comprehensive and informative label of the indicator generated with variables specified in 'variable'.

{phang}
{opt setcluster(#)} used to spefify the number of cores in case one wants genrrate the multi-dimentional table with parallel computing.



{marker examples}{...}
{title:Examples}

 {stata genmdt Region sex ,marginlabels("Region@Wakanda" "Sex@Both") 
 ratio ((WII=I3_n/I3_d)) mean(AGE) total(AG_PARCELLE) ///
	indicatorname("WII@Women entrepreneurship index" "AGE@Age of the households head" "AG_PARCELLE@Total number of agricultural parcels") ///
	units("WII%" "AGE@Years" "AG_PARCELLE@Parcel")}
	


{title:References}
{pstd}

{pstd}

{pstd}

{pstd}

{pstd}


{title:Author}
{p}

Amsata Niang, Food and Agriculture Organization of the United Nations FAO.

Email {browse "mailto:amsata_niang@yahoo.fr":amsata_niang@yahoo.fr}



{title:See Also}
Related commands:



