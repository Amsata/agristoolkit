{smcl}
{* *! version 1.0 17 Oct 2024}{...}
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
{bf:genmdt} {hline 2} a command to setup working directory and necessary files and folder for anonymization

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:genmdt}
varlist
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Required }

{synopt:{opt dimcomb(string asis)}}  specify the labels of margins of variables in varlist. {p_end}

{synopt:{opt param:eter(string)}}  parameter to be estimated in the domains (total, mean or ratio). {p_end}

{synopt:{opt var:iable(string asis)}}  variable the value of which will be used to generate the specified parameter in 'parameter'. {p_end}

{synopt:{opt lab:ind(string asis)}}  a comprehensive and informative label of the indicator generated with variables specified in 'variable'. {p_end}

{synopt:{opt unit:s(string asis)}}  units of the parameter generated with variable in 'variable'. {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
 {cmd:setup_anonymization} generate folders, excel files for variables classification and dataset
 description, pre-populated scripts and sample reports for anonymization and information loss analysis.

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt dimcomb(string asis)}  specify the labels of margins of variables in varlist.

{phang}
{opt param:eter(string)}  parameter to be estimated in the domains (total, mean or ratio).

{phang}
{opt var:iable(string asis)}  variable the value of which will be used to generate the specified parameter in 'parameter'.

{phang}
{opt lab:ind(string asis)}  a comprehensive and informative label of the indicator generated with variables specified in 'variable'.

{phang}
{opt unit:s(string asis)}  units of the parameter generated with variable in 'variable'.



{marker examples}{...}
{title:Examples}

 {stata sgenODT Element Area ,dimcomb("All households" "Uganda") param("ratio") var((I3_n/I3_d)) ///
	labind("Pourcentage of households") ///
	units("%")}


{title:References}
{pstd}

{pstd}

{pstd}

{pstd}
This function is a wrap up of the function 'CreateAgrisvy' and 'setup_anonymization' (combined in one in Stata) from the R package 'agrisvyr'.


{title:Author}
{p}

Amsata Niang, Food and Agriculture Organization of the United Nations FAO.

Email {browse "mailto:amsata_niang@yahoo.fr":amsata_niang@yahoo.fr}



{title:See Also}
Related commands:



