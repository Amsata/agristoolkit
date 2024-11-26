{smcl}
{* *! version 1.0 26 Nov 2024}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "generateODTParByGeo##syntax"}{...}
{viewerjumpto "Description" "generateODTParByGeo##description"}{...}
{viewerjumpto "Options" "generateODTParByGeo##options"}{...}
{viewerjumpto "Remarks" "generateODTParByGeo##remarks"}{...}
{viewerjumpto "Examples" "generateODTParByGeo##examples"}{...}
{title:Title}
{phang}
{bf:generateODTParByGeo} {hline 2} a command to setup working directory and necessary files and folder for anonymization

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:generateODTParByGeo}
varlist
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Required }

{synopt:{opt marginlabels(string asis)}}  specify the labels of margins of variables in varlist. {p_end}

{synopt:{opt param:eter(string asis)}}  parameter to be estimated in the domains (total, mean or ratio). {p_end}

{synopt:{opt var:iable(string asis)}}  variable the value of which will be used to generate the specified parameter in 'parameter'. {p_end}

{syntab:Optional}
{synopt:{opt hiergeovars(string asis)}}  

{synopt:{opt geovarmarginlab(string asis)}}  

{synopt:{opt conditionals(string asis)}} eliminate tuples (of dimensions in varlist) according to specified conditions.

{synopt:{opt :svySE(string)}}  

{synopt:{opt subpop(string asis)}} {cmd:(}[{varname}

{synopt:{opt unit:s(string asis)}} units of the parameter generated with variable in 'variable'.

{synopt:{opt indicator:name(string asis)}} a comprehensive and informative label of the indicator generated with variables specified in 'variable'.

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
 {cmd:generateODT} generate multi-dimentional statisticial tables destined to open Data Africa plateform
 or for other potential use.

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt marginlabels(string asis)} specify the labels of margins of variables in varlist.

{phang}
{opt param:eter(string asis)} parameter to be estimated in the domains (total, mean or ratio).

{phang}
{opt var:iable(string asis)} variable the value of which will be used to generate the specified parameter in 'parameter'.

{phang}
{opt hiergeovars(string asis)}  

{phang}
{opt geovarmarginlab(string asis)}  

{phang}
{opt conditionals(string asis)} eliminate tuples (of dimensions in varlist) according to specified conditions.

{phang}
{opt :svySE(string)}  

{phang}
{opt subpop(string asis)} {cmd:(}[{varname}

{phang}
{opt unit:s(string asis)} units of the parameter generated with variable in 'variable'.

{phang}
{opt indicator:name(string asis)} a comprehensive and informative label of the indicator generated with variables specified in 'variable'.



{marker examples}{...}
{title:Examples}

 {stata generateODT Region sex ,marginlabels("All households" "Wakanda") param("ratio") var((I3_n/I3_d)) ///
	indicatorname("Women entrepreneurship index") ///
	units("")}
	
	 {stata generateODT Region sex ,marginlabels("All households" "Wakanda") param("mean") var(hh_member) ///
	indicatorname("Average households size") ///
	units("people")}
	
		 {stata generateODT Region sex ,marginlabels("All households" "Wakanda") param("total") var(production) ///
	indicatorname("Crop production") ///
	units("MT")}


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



