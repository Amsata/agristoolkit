{smcl}
{* *! version 1.0 15 Oct 2024}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "setup_anonymization##syntax"}{...}
{viewerjumpto "Description" "setup_anonymization##description"}{...}
{viewerjumpto "Options" "setup_anonymization##options"}{...}
{viewerjumpto "Remarks" "setup_anonymization##remarks"}{...}
{viewerjumpto "Examples" "setup_anonymization##examples"}{...}
{title:Title}
{phang}
{bf:setup_anonymization} {hline 2} a command to setup working directory and necessary files and folder for anonymization

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:setup_anonymization}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Optional}
{synopt:{opt svyname(string asis)}} name of the survey to be anonymization for dissemination.

{synopt:{opt author(string asis)}} institution in charge of the anonymization or microdata dissemination.

{synopt:{opt language(string asis)}} langage of the folders and reports 'en' for english 'fr' for franch and 'es' for spanish.

{synopt:{opt workingdir(string asis)}} path of the working directory where files will be created the path should be specifies as in R sorftware (with '/') .

{synopt:{opt datadir(string asis)}} folder where the microdata to be anonymized is located It accept nested folders.

{synopt:{opt type(string asis)}} data type.

{synopt:{opt overwrite(string asis)}} replace.

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
{opt svyname(string asis)}  name of the survey to be anonymization for dissemination.

{phang}
{opt author(string asis)}  institution in charge of the anonymization or microdata dissemination.

{phang}
{opt language(string asis)}  langage of the folders and reports 'en' for english 'fr' for franch and 'es' for spanish.

{phang}
{opt workingdir(string asis)}  path of the working directory where files will be created the path should be specifies as in R sorftware (with '/') .

{phang}
{opt datadir(string asis)}  folder where the microdata to be anonymized is located It accept nested folders.

{phang}
{opt type(string asis)}  data type.

{phang}
{opt overwrite(string asis)} specifies the probability used in the standard error formula.
and I wanted more than one line for the longer  descriptions of the
option overwrite() later in the help file



{marker examples}{...}
{title:Examples}

 {stata setup_anonymization, svyname("Enquete sur le maraichage") author("FAO") language("fr") workingdir("dir") datadir("Dir") type(".dta") overwrite("TRUE")}


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



