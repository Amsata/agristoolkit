global data "C:\Users\USER\Documents\GitHub\agrisvyst"
// importation des bases vers stata
// Obtenir la liste des fichiers d'extension *sav* dans le dossier



// local name_files : dir "$data" files "*.sav"
//
// foreach fichier of local name_files {
// dis "`fichier'"
// local name_data = ustrregexrf("`fichier'", ".sav", "")
// dis "`name_data'"
// import spss using "$data/`fichier'", clear
// save "$data/`name_data'", replace
// }

*Traitement de la base ménage.
use "$data/sect1_infosmembres_extraction", clear
*contrôle des identifiants de collecte
 isid interview__id Sect1_InfosMembres__id //RAS
 *contrôle des Identifiants du pays
 duplicates tag Region Prefecture SousPrefect ZD NumMenage Sect1_InfosMembres__id, gen(doublon)
 tab doublon // il ressort 29 doublons dans la base
*Identification des dimensions
tab Region, mi
*Sexe du mémbre 
tab Sect1_C4, mi
*L'age du membre  et tranche d'age
tab1 Tranche_age Sect1_C5
tab Sect1_C5 if Tranche_age==1 // la variable tranche d'age est mal construite car la tranche [15-35] contient en même temps les moins 15 ans
*Correction
replace Tranche_age=0 if Sect1_C5<15
lab def Tranche_age 0"[0-15[" 1"[15-35[" 2"[35-55[" 3"[55-65[" 4"[65 et +[", modify
lab val Tranche_age Tranche_age
tab Tranche_age
// Computation des indicateurs
// Effectif des membres de ménages agricoles Effectif_mbr
gen Effectif_mbr=1
tabstat Effectif_mbr [fw=round(Ponderation_Men)], stat(sum)
total Effectif_mbr [pw=Ponderation_Men]
// Proportion moyenne d'actifs agricoles par ménage
tab Sect1_C7, mi 
tab Sect1_C5 if Sect1_C7 ==.
gen prop_actif=(Sect1_C7==1)*100 if !missing(Sect1_C7)
table Region Sect1_C4, stat(mean prop_actif)
// Proportion des membres responsables de parcelles
tab Sect1_C8, mi
tab Sect1_C5 if Sect1_C8 ==. //Pour être responsable de parcelle il faut avoir au moins 12 ans
gen prop_resp_parcel=(Sect1_C8==1)*100 if !missing(Sect1_C8)
table Region Sect1_C4, stat(mean prop_resp_parcel)
// Proportion des membres propriétaires d'animaux 
tab Sect1_C9, mi
tab Sect1_C5 if Sect1_C9 ==. // Pour être responsable de parcelle il faut avoir au moins 12 ans
gen prop_prop_anim=(Sect1_C9==1)*100 if !missing(Sect1_C9)
table Region Sect1_C4, stat(mean prop_prop_anim)
// Proportion des membres alphabétisés
tab Sect1_C10, mi
tab Sect1_C5 if Sect1_C10 ==. // pour les 5 ans et plus
gen prop_alphab=inrange(Sect1_C10,3,8)*100 if !missing(Sect1_C10)
table Region Sect1_C4, stat(mean prop_alphab)
// Proportion des membres qui ont le niveau primaire
gen prop_primair=(Sect1_C10==4)*100 if !missing(Sect1_C10)
table Region Sect1_C4, stat(mean prop_primair)
// Proportion des membres qui ont le niveau secondaire et supérieur
gen prop_second_sup=inrange(Sect1_C10,5,8)*100 if !missing(Sect1_C10)
table Region Sect1_C4, stat(mean prop_second_sup)
// Proportion de membres ayant adhéré à une organisation de producteurs (OP)
gen prop_adh_OP=(Sect1_C11==1)*100 if !missing(Sect1_C11)
table Region Sect1_C4, stat(mean prop_adh_OP)
// Proportion des membres qui ont reçu un encadrement
gen prop_encadr=(Sect1_C12==1)*100 if !missing(Sect1_C12) // qu'est ce qui justifie le nombre de missing important de cette variable.
table Region Sect1_C4, stat(mean prop_encadr)
tab Sect1_C12, mi

// Proportion des membres qui ont reçu un encadrement d'une structure de l'Etat
// Proportion des membres qui ont reçu un encadrement d'un Projet
// Proportion des membres qui ont reçu un encadrement d'une ONG
// Proportion des membres ayant reçu un encadrement de type Fiche technique
// Proportion des membres ayant reçu un encadrement de type Support audiovisuel
// Proportion des membres ayant reçu un encadrement de type TIC
// Proportion des membres ayant reçu un encadrement de type Visite commentée
// Proportion des membres ayant reçu un encadrement de type Voyage d'études
// Proportion des membres ayant reçu un encadrement de type Exposition/Foire
// Proportion des membres ayant reçu un encadrement de type Conseil

// NB: clarifier d'abord le contenu de ces indicateurs ci-dessus avant de produire les indicateurs

// Proportion des membres pratiquant la culture pluviale
gen prop_cult_pluv=(Sect1_C24_C34__17==1)*100 if !missing(Sect1_C24_C34__17)
table Region Sect1_C4, stat(mean prop_cult_pluv) // la majeure partie des personnes éligibles à la question n'ont pas répondu. Pourquoi?
tab Sect1_C5 if Sect1_C24_C34__17==.
tab Sect1_C5 if Sect1_C24_C34__17!=.
// Proportion des membres pratiquant les cultures irriguées
gen prop_cult_irri=(Sect1_C24_C34__18==1)*100 if !missing(Sect1_C24_C34__18)
table Region Sect1_C4, stat(mean prop_cult_irri) // la majeure partie des personnes éligibles à la question n'ont pas répondu. Pourquoi?
// Proportion des membres pratiquant les cultures arboricoles 
gen prop_cult_arbori=(Sect1_C24_C34__27==1)*100 if !missing(Sect1_C24_C34__27)
table Region Sect1_C4, stat(mean prop_cult_arbori) // la majeure partie des personnes éligibles à la question n'ont pas répondu. Pourquoi?
// Proportion des membres pratiquant l'élevage
gen prop_cult_elev=(Sect1_C24_C34__19==1)*100 if !missing(Sect1_C24_C34__19)
table Region Sect1_C4, stat(mean prop_cult_elev) // la majeure partie des personnes éligibles à la question n'ont pas répondu. Pourquoi?
// Proportion des membres pratiquant l'apiculture
gen prop_cult_apicult=(Sect1_C24_C34__20==1)*100 if !missing(Sect1_C24_C34__20)
table Region Sect1_C4, stat(mean prop_cult_apicult) // la majeure partie des personnes éligibles à la question n'ont pas répondu. Pourquoi?
// Proportion des membres pratiquant la pêche
gen prop_cult_pech=(Sect1_C24_C34__21==1)*100 if !missing(Sect1_C24_C34__21)
table Region Sect1_C4, stat(mean prop_cult_pech) // la majeure partie des personnes éligibles à la question n'ont pas répondu. Pourquoi?

// Proportion des membres pratiquant la pisciculture
gen prop_cult_piss=(Sect1_C24_C34__28==1)*100 if !missing(Sect1_C24_C34__28)
table Region Sect1_C4, stat(mean prop_cult_piss) // la majeure partie des personnes éligibles à la question n'ont pas répondu. Pourquoi?

// Proportion des membres pratiquant l'aquaculture 
gen prop_cult_aquacult=(Sect1_C24_C34__23==1)*100 if !missing(Sect1_C24_C34__23)
table Region Sect1_C4, stat(mean prop_cult_aquacult) // la majeure partie des personnes éligibles à la question n'ont pas répondu. Pourquoi?

// Proportion des membres pratiquant la sylviculture
gen prop_cult_sylvi=(Sect1_C24_C34__24==1)*100 if !missing(Sect1_C24_C34__24)
table Region Sect1_C4, stat(mean prop_cult_sylvi) // la majeure partie des personnes éligibles à la question n'ont pas répondu. Pourquoi?

// Proportion des membres pratiquant la cueillette
gen prop_cult_cueil=(Sect1_C24_C34__25==1)*100 if !missing(Sect1_C24_C34__25)
table Region Sect1_C4, stat(mean prop_cult_cueil) // la majeure partie des personnes éligibles à la question n'ont pas répondu. Pourquoi?

// Proportion des membres pratiquant la chasse
gen prop_cult_chasse=(Sect1_C24_C34__26==1)*100 if !missing(Sect1_C24_C34__26)
table Region Sect1_C4, stat(mean prop_cult_chasse) // la majeure partie des personnes éligibles à la question n'ont pas répondu. Pourquoi?

// Proportion des membres pratiquant une activité non agricole
gen prop_act_Nagri=(Sect1_C35__0==0)*100 if !missing(Sect1_C35__0)
table Region Sect1_C4, stat(mean prop_act_Nagri)
// Proportion des membres pratiquant l'activité non agricole de commerce
gen prop_act_commer=(Sect1_C35__1==1)*100 if !missing(Sect1_C35__1)
table Region Sect1_C4, stat(mean prop_act_commer)
// Proportion des membres pratiquant l'activité non agricole d'artisanat
gen prop_act_artisa=(Sect1_C35__2==1)*100 if !missing(Sect1_C35__2)
table Region Sect1_C4, stat(mean prop_act_artisa)
// Proportion des membres pratiquant l'activité non agricole de transport
gen prop_act_transport=(Sect1_C35__4==1)*100 if !missing(Sect1_C35__4)
table Region Sect1_C4, stat(mean prop_act_transport)
// Proportion des membres pratiquant l'activité non agricole d'orpaillage
gen prop_act_orpaill=(Sect1_C35__3==1)*100 if !missing(Sect1_C35__3)
table Region Sect1_C4, stat(mean prop_act_orpaill)
// Proportion des membres pratiquant d'autres activités non agricoles
gen prop_act_Nagri_autr=(Sect1_C35__5==1)*100 if !missing(Sect1_C35__5)
table Region Sect1_C4, stat(mean prop_act_Nagri_autr)
// Revenu moyen non agricole des membres ayant effectué ces activités au cours de la campagne agricole précédente
gen revenu_moy_Nagri=Sect1_C36 // les revenus semblent être très élevés: revoir les valeurs.
sum revenu_moy_Nagri, detail 
mean revenu_moy_Nagri
// Proportion des membres ayant effectué une demande de crédits agricoles
gen prop_DemanCredit=(Sect1_C37==1)*100 if !missing(Sect1_C37)
table Region Sect1_C4, stat(mean prop_DemanCredit)
// Proportion des membres ayant accès au crédit agricole
gen prop_AccessCredit=(Sect1_C38__0==0)*100 if !missing(prop_DemanCredit)
table Region Sect1_C4, stat(mean prop_AccessCredit)
// Proportion des mémbres ayant utilisé le crédit pour les intrants agricoles
gen prop_intrant_util=(Sect1_C38__1==1)*100 if !missing(Sect1_C38__1)
table Region Sect1_C4, stat(mean prop_intrant_util)
// Proportion des mémbres ayant utilisé le crédit pour les équipements agricoles
gen prop_equip_util=(Sect1_C38__2==1)*100 if !missing(Sect1_C38__2)
table Region Sect1_C4, stat(mean prop_equip_util)
// Proportion des mémbres ayant utilisé le crédit pour les autres activités agricoles
gen prop_autr_util=(Sect1_C38__3==1)*100 if !missing(Sect1_C38__3)
table Region Sect1_C4, stat(mean prop_autr_util)
// Proportion des membres ayant reçu du crédit accordé par les banques et IMF
gen prop_sour_Bank_IMF=inlist( Sect1_C39,1,2)*100 if !missing( Sect1_C39)
table Region Sect1_C4, stat(mean prop_sour_Bank_IMF)
// Proportion des membres ayant reçu du crédit accordé par l'Etat
gen prop_sour_Etat=(Sect1_C39==3)*100 if !missing( Sect1_C39)
table Region Sect1_C4, stat(mean prop_sour_Etat)
// Proportion des membres ayant reçu du crédit accordé par les ONG et Projets
gen prop_sour_ONG=inlist(Sect1_C39,4,5)*100 if !missing( Sect1_C39)
table Region Sect1_C4, stat(mean prop_sour_ONG)
// Proportion des membres ayant reçu du crédit accordé par les commerçants et OPA
gen prop_sour_Comm_OP=inlist(Sect1_C39,6,8)*100 if !missing( Sect1_C39)
table Region Sect1_C4, stat(mean prop_sour_Comm_OP)
// Proportion des membres ayant reçu du crédit accordé par les particuliers
gen prop_sour_particulier=inlist(Sect1_C39,7)*100 if !missing( Sect1_C39)
table Region Sect1_C4, stat(mean prop_sour_particulier)
// Proportion des membres ayant accès aux services financiers
gen prop_AcesSfinance=(Sect1_C40_C42__1==1 | Sect1_C40_C42__2==1 | Sect1_C40_C42__3==1)*100 if !missing( Sect1_C40_C42__1)
table Region Sect1_C4, stat(mean prop_AcesSfinance)

// * Boniface
// * Définition du plan de sondage
// svyset ZD [pw=Ponderation_Men], strata(Region)
// computeAcross Region Sect1_C4 Tranche_age, total(Effectif_mbr) mean (prop_actif prop_resp_parcel prop_prop_anim prop_alphab prop_primair prop_second_sup prop_adh_OP prop_encadr prop_cult_pluv prop_cult_irri prop_cult_arbori prop_cult_elev prop_cult_apicult prop_cult_pech prop_cult_piss prop_cult_aquacult prop_cult_sylvi prop_cult_cueil prop_cult_chasse prop_act_Nagri prop_act_commer prop_act_artisa prop_act_transport prop_act_orpaill prop_act_Nagri_autr prop_DemanCredit prop_AccessCredit prop_intrant_util prop_equip_util prop_autr_util prop_sour_Bank_IMF prop_sour_Etat prop_sour_ONG  prop_sour_Comm_OP prop_sour_particulier prop_AcesSfinance revenu_moy_Nagri) ///
// margincode(9 3 5) ///
// dimcomb(all)
// //1.les codes marginaux ne sont pas directement labélisables
// //2. Les indicateurs ne sont pas labelisés
// //3. Les unités ne sont pas précisées





// capture program drop generateODTbyGeo
// program  define generateODTbyGeo
//
//  syntax varlist ,dimcomb(string asis) hiergeovars(string asis) PARAMeter(string asis) VARiable(string asis) LABind(string asis) UNITs(string asis) 
//
//  local n_geovar: list sizeof hiergeovars
//
// if (`n_geovar'==0) {
// 	generateODT `varlist' ,dimcomb(`dimcomb') param(`parameter') var(`variable') lab(`labind') units(`units')
// }
// else {
// 
//	
// 	scalar init=0
// 	tempfile open_data_table
// 	foreach geovar of local hiergeovars {
//		
// 		local dim_to_exclude: list hiergeovars - geovar
//		
// 		di" dimension to exclude: `dim_to_exclude'"
// // Create a local macro to store the indices of elements to exclude
// local exclude_indices ""
//
// // Loop through each element in `lob`
// foreach element of local dim_to_exclude {
//     // Initialize position counter
//     local pos = 1
//     foreach loc_item of local varlist {
//         // Check if the current loc_item matches the element in lob
//         if "`element'" == "`loc_item'" {
//             // If it matches, store the position to exclude
//             local exclude_indices "`exclude_indices' `pos'"
//         }
//         local pos = `pos' + 1
//     }
// }
//
// // Display the indices to exclude
// di "Indices to exclude: `exclude_indices'"
//
// // Create a local macro for the new loc without the excluded elements
// local new_dimcomb ""
//
// // Initialize counter for the position
// local count = 1
// // Loop through loc to build the new macro excluding the specified indices
// foreach item of local dimcomb {
//     // Check if the current index is in the exclude list
//     if strpos("`exclude_indices'", "`count'") == 0 {
//         // If not excluded, add to the new local macro
// 		local item_bis `"`item'"'
// 		local new_dimcomb_bis `"`new_dimcomb'"'
//         local new_dimcomb: list new_dimcomb_bis  | item_bis
//     }
//     local count = `count' + 1
// }
//
// // Display the new loc
// di "New dimension without excluded elements: `new_dimcomb'"
//
// // Create a local macro for the new loc without the excluded elements
// local new_varlist ""
// // Initialize counter for the position
// local count = 1
// // Loop through loc to build the new macro excluding the specified indices
// foreach v of local varlist {
//     // Check if the current index is in the exclude list
//     if strpos("`exclude_indices'", "`count'") == 0 {
//         // If not excluded, add to the new local macro
//         local new_varlist "`new_varlist' `v'"
//     }
//     local count = `count' + 1
// }
// // Display the new loc
// di "New varlist without excluded elements: `new_varlist'"
//	
// 	di " premier element de new_dim: `:word 1 of `new_dimcomb''"
// ***generateODT for the new_varlist and n_w dim comb
//
// preserve
// 	quietly generateODT `new_varlist' ,dimcomb(`new_dimcomb') param(`parameter') var(`variable') lab(`labind') units(`units')
// 	rename `geovar' geo_var
// 	if(init==0) {
// 		save `open_data_table', replace
// 		init=1
// 	}
// 	append using `open_data_table'
// 	}
//	
// 	restore
//	
// 	use	`open_data_table'
// }
// end

*ren Effectif_mbr I1
svyset ZD [pw=Ponderation_Men], strata(Region)




set trace off

generateODT Region Prefecture Sect1_C4 Tranche_age,marginlab("National"  "prefect" "les deux sexes" "Toutes les classes dage") ///
param("total") var(Effectif_mbr) ///
conditionals(!(1&2)) ///
	indicator(  ///
	"Effectif des membres de ménages agricoles" ///
) ///
units("personnes")
	

// Note à Amsata
* Note : erreur1 : command elabel is unrecognized : solution : ssc install elabel
*gérer dans les apostrophes dans l'option dimcomb et labind
*Considérer freq comme temp var
*
