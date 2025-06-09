#' get_biomass_deluxe
#' @description This function pulls data from the akfin_biomass table in the gap_products schema on the AKFIN database and joins in desctiptions from lookup tables.
#' This table is a copy of the biomass table produced by the groundfish assessment program (GAP)
#' These data are docuented here: https://github.com/afsc-gap-products/gap_products
#' get_gap_species() and get_gap_area() are related functions to look up species codes and area ids if necessary.

#' @param survey_definition_id character that designates regional survey. EBS-98, NBS-143, EBS slope-78, GOA-47, AI-52. Default is 47.
#' @param area_id This is the level at which biomass is calculated. Biomass may not be comparable accross areas.
#' @param species_code RACE species code for which biomass is calculated.
#' @param start_year first year in the time series, default 1990.
#' @param end_year last year in the time series, default to latest year,


get_biomass_deluxe <- function(survey_definition_id=98, area_id=99900, species_code=21740, start_year=1990, end_year=3000) {

  biomass <- get_gap_biomass(survey_definition_id=survey_definition_id,
                             area_id=area_id,
                             species_code=species_code,
                             start_year=start_year,
                             end_year=end_year)

  taxa <- get_gap_taxonomic_groups() |>
    dplyr::select(species_code, species_name, common_name)

  area <-get_gap_area() |>
    dplyr::select(!akfin_load_date)

  design <- get_gap_survey_design() |>
    dplyr::select(!akfin_load_date)

  biomass <- biomass |>
    dplyr::left_join(design, by=c("survey_definition_id"="survey_definition_id",
                                  "year"="year")) |>
    dplyr::left_join(area, by=c("survey_definition_id"="survey_definition_id",
                                "area_id"="area_id",
                                "design_year"="design_year" )) |>
    dplyr::left_join(taxa, by="species_code")

  return(biomass)
}
