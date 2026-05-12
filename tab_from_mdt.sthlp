{smcl}
{* *! version 1.3.22  01apr2019}{...}

{p2colset 1 14 16 2}{...}
{p2col:{bf:[SVY] svy} {hline 2}}The survey prefix command
{p_end}
{p2col:}({mansection SVY svy:View complete PDF manual entry}){p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang2}
{cmd:tab_from_mdt} [{help tab_from_mdt##varlist:{it:varlist}}] [{cmd:,}
           {help tab_from_mdt##vars_options:{it: variables_options}}
		   {help tab_from_mdt##dimension_options:{it: dimension_options}}
		   {help tab_from_mdt##formating_options:{it: formating_options}}
		   {help tab_from_mdt##saving_options:{it: saving_options}}] {cmd::} {it:command}


{marker varlist}{...}
{synopthdr:varlist}
{synoptline}
{synopt :{opt varlist}{cmd:(}[{varlist}]{cmd:)}}dimension variable that will appear in the first column{p_end}

{marker vars_options}{...}
{synopthdr:vars_options}
{synoptline}

{synopt :indvar([{help varname}])}Name of the variable in the multidimensional table that contain the indicors' ID ("Variable in the default value"){p_end}
{synopt :indicator([{help namelist}])}Contains the list of indicator ID (values inside the variable specified in indvar which values will be displayed in the table){p_end}
{synopt :indicatorname([{help varname}])}Variable in the multidimensional table that contains the labels (or name) of indicators in the indvar variable("IndicatorName is the default value"){p_end}
{synopt :valvar([{help varname}])}Variable that contains the values of the different indicators in the multidimensional talbe ("Value" is the default value){p_end}


{marker dimension_options}{...}
{synopthdr:dimension_options}
{synoptline}

{synopt :{opt over}{cmd:(}[{varname}]{cmd:)}}Enable crosstabulation with the specified dimension variable.{p_end}

{marker formating_options}{...}
{synopthdr:formating_options}
{synoptline}
{synopt :{opt tabtitle}{cmd:(}[{varlist}]{cmd:)}}Title of the table that will be displayed in the excel output{p_end}
{synopt :{opt decimal}{cmd:(}[{varlist}]{cmd:)}}Decimal separator ("." is the default value){p_end}
{synopt :{opt rowtotal}{cmd:(}[{varlist}]{cmd:)}}Enable adding a total column in the table{p_end}
{synopt :{opt valid}{cmd:(}[{varlist}]{cmd:)}}Allow to diplay the number of weighted obserbations which is the reference population of the indicator{p_end}


{marker saving_options}{...}
{synopthdr:saving_options}
{synoptline}
{synopt :{opt outfile}{cmd:(}[{varlist}]{cmd:)}}Contain the path of the Excel file where the table will be exported{p_end}
{synopt :{opt replace}}If specified, will replace the output Excel file{p_end}

{synoptline}
{p 4 6 2}
{cmd:genmdt} requires that the survey design variables be identified using
{helpb svyset}.
{p_end}
{p 4 6 2}
{it:command} defines the estimation command to be executed.  The {helpb by}
prefix cannot be part of {it:command}.{p_end}
{p 4 6 2}
{cmd:mi estimate} may be used with {cmd:svy linearized} if the estimation 
command allows {cmd:mi estimate}; it may not be used with {cmd:svy bootstrap},
{cmd:svy brr},
{cmd:svy jackknife}, or {cmd:svy sdr}.{p_end}
{p 4 6 2}
{opt noheader}, {opt nolegend}, {opt noadjust}, {opt noisily}, 
{opt trace}, and {opt coeflegend} are not shown in the dialog boxes for
estimation commands.
{p_end}
{p 4 6 2}
Warning:  Using {cmd:if} or {cmd:in} restrictions will often not produce correct
variance estimates for subpopulations.  To compute estimates
for subpopulations, use the {cmd:subpop()} option.
{p_end}
{p 4 6 2}
See {helpb svy postestimation:[SVY] svy postestimation} for features available
after estimation.
{p_end}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:genmdt} uses the advantages of the command {helpb svy} to compile multidimensional statistical table containing indicator estimated by {helpb mean},  {helpb total}, or {helpb ratio} (see {manhelp svy_estimation SVY:svy estimation})  for complex survey data by adjusting the results of a command for survey settings identified by {helpb svyset}. Exeptionally, the {helpb median} is estimate using by {helpb collapse}.
{marker linksweb}{...}
{title:Links to external documentation}

        {browse "https://amsata.github.io/agristoolkit/":Quick start}

        {browse "https://amsata.github.io/agristoolkit/":Remarks and examples}

        {browse "https://amsata.github.io/agristoolkit/":Methods and formulas}

{pstd}
The above sections are not included in this help file.


{marker options}{...}
{title:Options}

{dlgtab:Disaggregation dimensions}

{phang}
{opt subpop}{cmd:(}{it:subpop}{cmd:)} specifies that
estimates be computed for the single subpopulation identified by
{it:subpop}, which is [{varname}] [{it:{help if}}]

{pmore}
Thus the subpopulation is defined by the observations for which
{it:varname}!=0 that also meet the {cmd:if} conditions.  Typically,
{it:varname}=1 defines the subpopulation, and {it:varname}=0 indicates
observations not belonging to the subpopulation.  For observations whose
subpopulation status is uncertain, {it:varname} should be set to a missing
value; such observations are dropped from the estimation sample.

{pmore}
See {manlink SVY Subpopulation estimation}.

{dlgtab:if/in}

{phang}
{opt subpop}{cmd:(}{it:subpop}{cmd:)} specifies that
estimates be computed for the single subpopulation identified by
{it:subpop}, which is

{pmore2}
[{varname}] [{it:{help if}}]

{pmore}
Thus the subpopulation is defined by the observations for which
{it:varname}!=0 that also meet the {cmd:if} conditions.  Typically,
{it:varname}=1 defines the subpopulation, and {it:varname}=0 indicates
observations not belonging to the subpopulation.  For observations whose
subpopulation status is uncertain, {it:varname} should be set to a missing
value; such observations are dropped from the estimation sample.

{pmore}
See {manlink SVY Subpopulation estimation}.


{dlgtab:Parameters}

{phang}
{opt dof(#)} specifies the design degrees of freedom, overriding the default
calculation, df = N_psu - N_strata.

{phang}
{it:bootstrap_options} are other options that are allowed with bootstrap
variance estimation specified by {cmd:svy} {cmd:bootstrap} or specified as
{cmd:svyset} using the {cmd:vce(bootstrap)} option;
see {manhelpi bootstrap_options SVY}.

{phang}
{it:brr_options} are other options that are allowed with BRR
variance estimation specified by {cmd:svy} {cmd:brr} or specified as
{cmd:svyset} using the {cmd:vce(brr)} option;
see {manhelpi brr_options SVY}.

{phang}
{it:jackknife_options} are other options that are allowed with
jackknife variance estimation specified by {cmd:svy} {cmd:jackknife} or 
specified as {cmd:svyset} using the {cmd:vce(jackknife)} option; see
{manhelpi jackknife_options SVY}.

{phang}
{it:sdr_options} are other options that are allowed with SDR
variance estimation specified by {cmd:svy} {cmd:sdr} or specified as
{cmd:svyset} using the {cmd:vce(sdr)} option;
see {manhelpi sdr_options SVY}.

{dlgtab:Reporting}

{phang}
{opt level(#)}
specifies the confidence level, as a percentage, for confidence intervals.
The default is {cmd:level(95)} or as set by {helpb set level}.

{phang}
{opt nocnsreport}; see
     {helpb estimation options##nocnsreport:[R] Estimation options}.

INCLUDE help displayopts_list

{dlgtab:Others options}

{phang}
{opt level(#)}
specifies the confidence level, as a percentage, for confidence intervals.
The default is {cmd:level(95)} or as set by {helpb set level}.

{phang}
{opt nocnsreport}; see
     {helpb estimation options##nocnsreport:[R] Estimation options}.

INCLUDE help displayopts_list


{marker examples}{...}
{title:Example 1}

In this exemple we are going to use the nhanes2f dataset and generate a multidimensional statistical tables containings the following indicators by region, sex and race:

	1. Average age of the reference population
	2. Number of people with high blood pressure
	3. Proportion of people with hight blood pressure

{phang}
{cmd:. webuse nhanes2f}
{p_end}
{phang}
{cmd:. svyset psuid [pweight=finalwgt], strata(stratid)}
{p_end}
{phang}
{cmd:. genmdt region, mean(age)}
{p_end}
{phang}
{cmd:. genmdt region, marginlabels("region@USA") mean(age) units("age@Years") indicator("age@average age of individuals")}
{p_end}

{title:Example 2}

In this exemple we are going to use the nhanes2f dataset and generate a multidimensional statistical tables containings the following indicators by region, sex and race:

	1. Average age of the reference population
	2. Number of people with high blood pressure
	3. Proportion of people with hight blood pressure

{phang}
{cmd:. webuse nhanes2f}
{p_end}
{phang}
{cmd:. svyset psuid [pweight=finalwgt], strata(stratid)}
{p_end}
{phang}
{cmd:. genmdt region, mean(age)}
{p_end}
{phang}
{cmd:. genmdt region, marginlabels("region@USA") mean(age) units("age@Years") indicator("age@average age of individuals")}
{p_end}


{title:Example 3}

In this exemple we are going to use the nhanes2f dataset and generate a multidimensional statistical tables containings the following indicators by region, sex and race:

	1. Average age of the reference population
	2. Number of people with high blood pressure
	3. Proportion of people with hight blood pressure

{phang}
{cmd:. webuse nhanes2f}
{p_end}
{phang}
{cmd:. svyset psuid [pweight=finalwgt], strata(stratid)}
{p_end}
{phang}
{cmd:. genmdt region, mean(age)}
{p_end}
{phang}
{cmd:. genmdt region, marginlabels("region@USA") mean(age) units("age@Years") indicator("age@average age of individuals")}
{p_end}


{title:Example 4}

In this exemple we are going to use the nhanes2f dataset and generate a multidimensional statistical tables containings the following indicators by region, sex and race:

	1. Average age of the reference population
	2. Number of people with high blood pressure
	3. Proportion of people with hight blood pressure

{phang}
{cmd:. webuse nhanes2f}
{p_end}
{phang}
{cmd:. svyset psuid [pweight=finalwgt], strata(stratid)}
{p_end}
{phang}
{cmd:. genmdt region, mean(age)}
{p_end}
{phang}
{cmd:. genmdt region, marginlabels("region@USA") mean(age) units("age@Years") indicator("age@average age of individuals")}
{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:svy} stores the following in {cmd:e()}:

{synoptset 22 tabbed}{...}
{p2col 5 22 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_sub)}}subpopulation observations{p_end}
{synopt:{cmd:e(N_strata)}}number of strata{p_end}
{synopt:{cmd:e(N_strata_omit)}}number of strata omitted{p_end}
{synopt:{cmd:e(singleton)}}{cmd:1} if singleton strata, {cmd:0} otherwise{p_end}
{synopt:{cmd:e(census)}}{cmd:1} if census data, {cmd:0} otherwise{p_end}
{synopt:{cmd:e(F)}}model F statistic{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(df_r)}}variance degrees of freedom{p_end}
{synopt:{cmd:e(N_pop)}}estimate of population size{p_end}
{synopt:{cmd:e(N_subpop)}}estimate of subpopulation size{p_end}
{synopt:{cmd:e(N_psu)}}number of sampled PSUs{p_end}
{synopt:{cmd:e(stages)}}number of sampling stages{p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(k_aux)}}number of ancillary parameters{p_end}
{synopt:{cmd:e(p)}}p-value{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}

{synoptset 22 tabbed}{...}
{p2col 5 22 24 2: Macros}{p_end}
{synopt:{cmd:e(prefix)}}{cmd:svy}{p_end}
{synopt:{cmd:e(cmdname)}}command name from {it:command}{p_end}
{synopt:{cmd:e(cmd)}}same as {cmd:e(cmdname)} or {cmd:e(vce)}{p_end}
{synopt:{cmd:e(command)}}{it:command}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(weight}{it:#}{cmd:)}}variable identifying weight for stage {it:#}{p_end}
{synopt:{cmd:e(wvar)}}weight variable name{p_end}
{synopt:{cmd:e(singleunit)}}{cmd:singleunit()} setting{p_end}
{synopt:{cmd:e(strata)}}{cmd:strata()} variable{p_end}
{synopt:{cmd:e(strata}{it:#}{cmd:)}}variable identifying strata for stage {it:#}{p_end}
{synopt:{cmd:e(psu)}}{cmd:psu()} variable{p_end}
{synopt:{cmd:e(su}{it:#}{cmd:)}}variable identifying sampling units for stage
                          {it:#}{p_end}
{synopt:{cmd:e(fpc)}}{cmd:fpc()} variable{p_end}
{synopt:{cmd:e(fpc}{it:#}{cmd:)}}FPC for stage {it:#}{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(poststrata)}}{cmd:poststrata()} variable{p_end}
{synopt:{cmd:e(postweight)}}{cmd:postweight()} variable{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(mse)}}{cmd:mse}, if specified{p_end}
{synopt:{cmd:e(subpop)}}{it:subpop} from {cmd:subpop()}{p_end}
{synopt:{cmd:e(adjust)}}{cmd:noadjust}, if specified{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(estat_cmd)}}program used to implement {cmd:estat}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(marginsnotok)}}predictions disallowed by {cmd:margins}{p_end}
{synopt:{cmd:e(marginswtype)}}weight type for {cmd:margins}{p_end}

{synoptset 22 tabbed}{...}
{p2col 5 22 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}estimates{p_end}
{synopt:{cmd:e(V)}}design-based variance{p_end}
{synopt:{cmd:e(V_srs)}}simple-random-sampling-without-replacement variance,
V_srswor hat{p_end}
{synopt:{cmd:e(V_srssub)}}subpopulation
simple-random-sampling-without-replacement variance, V_srswor hat (created only
when {cmd:subpop()} is specified){p_end}
{synopt:{cmd:e(V_srswr)}}simple-random-sampling-with-replacement variance,
V_srswr hat (created only when {cmd:fpc()} option is {cmd:svyset}){p_end}
{synopt:{cmd:e(V_srssubwr)}}subpopulation simple-random-sampling-with-replacement variance, V_srswr hat (created only when {cmd:subpop()} is specified){p_end}
{synopt:{cmd:e(V_modelbased)}}model-based variance{p_end}
{synopt:{cmd:e(V_msp)}}variance from misspecified model fit, V_msp hat{p_end}
{synopt:{cmd:e(_N_strata_single)}}number of strata with one sampling unit{p_end}
{synopt:{cmd:e(_N_strata_certain)}}number of certainty strata{p_end}
{synopt:{cmd:e(_N_strata)}}number of strata{p_end}
{synopt:{cmd:e(_N_subp)}}estimate of subpopulation sizes within {cmd:over()}
groups{p_end}

{synoptset 22 tabbed}{...}
{p2col 5 22 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{pstd}
{cmd:svy} also carries forward most of the results already in {cmd:e()} from
{it:command}.


{marker reference}{...}
{title:Reference}

{marker KG1990}{...}
{phang}
Korn, E. L., and B. I. Graubard.  1990.  Simultaneous testing of regression
coefficients with complex survey data: Use of Bonferroni t statistics.
{it:American Statistician} 44: 270-276.
{p_end}
