#' get_gap_cpue_wide
#' @description This function pulls data from the akfin_CPUE table in the gap_products schema on the AKFIN database and joins in desctiptions from lookup tables.
#' This table is a copy of the CPUE table produced by the groundfish assessment program (GAP)
#' These data are docuented here: https://github.com/afsc-gap-products/gap_products
#' get_gap_species() is a related functions to look up species codes if necessary.

#' @param survey_definition_id character that designates regional survey. EBS-98, NBS-143, EBS slope-78, GOA-47, AI-52. Default is 47.
#' @param species_code RACE species code for which biomass is calculated.
#' @param start_year first year in the time series, default 1990.
#' @param end_year last year in the time series, default to latest year,
#' @param taxa optional parameter to specify taxonomy table if you don't want to take the extra 2 seconds to download it. Useful for looping.
#' @param haul optional parameter to specify haul table if you don't want to take the extra 20 seconds to download it. Useful for looping.


get_gap_cpue_wide <- function(survey_definition_id=98, species_code=21740, start_year=1990, end_year=3000, taxa = NA, haul=NA) {

  cpue <- get_gap_cpue(survey_definition_id=survey_definition_id,
                             species_code=species_code,
                             start_year=start_year,
                             end_year=end_year)

  if(missing(taxa)) {
    taxa <- get_gap_taxonomic_groups() |>
      dplyr::select(species_code, species_name, common_name)
  } else { taxa <- taxa }

  if(missing(haul)) {
    haul <- get_gap_haul() |>
      dplyr::select(!c(akfin_load_date, stratum))
  } else { haul <- haul }

  cruise <- get_gap_cruise() |>
    dplyr::select(cruisejoin, survey_name)

  cpue <- cpue |>
    dplyr::left_join(haul, by="hauljoin") |>
    dplyr::left_join(cruise, by="cruisejoin") |>
    dplyr::left_join(taxa, by="species_code")

  return(cpue)
}

