#' get_gap_biomass_by_stratum
#' @description This function pulls data from the akfin_biomass table in the gap_products schema on the AKFIN database and joins in desctiptions from lookup tables.
#' This table is a copy of the biomass table produced by the groundfish assessment program (GAP)
#' These data are docuented here: https://github.com/afsc-gap-products/gap_products
#' get_gap_species() and get_gap_area() are related functions to look up species codes and area ids if necessary.

#' @param survey_definition_id character that designates regional survey. EBS-98, NBS-143, EBS slope-78, GOA-47, AI-52. Default is 47.
#' @param species_code RACE species code for which biomass is calculated.
#' @param start_year first year in the time series, default 1990.
#' @param end_year last year in the time series, default to latest year,
#' @param taxa optional parameter to specify taxonomy table if you don't want to take the extra 2 seconds to download it. Useful for looping.



get_gap_biomass_by_stratum <- function(survey_definition_id=98,  species_code=21740, start_year=1990, end_year=3000, taxa = NA) {

  # load area
  area <-get_gap_area() |>
    dplyr::select(!akfin_load_date)

  # limit to most recent design year
  regional_max_design_years <- area |>
    dplyr::group_by(survey_definition_id) |>
    dplyr::summarize(design_year=max(design_year))

  area2 <- regional_max_design_years |>
    dplyr::left_join(area, by=c("survey_definition_id"="survey_definition_id",
                     "design_year"="design_year"))

  # limit to specified survey
  area2 <- area2 |>
    dplyr::filter(survey_definition_id==!!survey_definition_id)

  # define strata to run biomass function for
  my_strata <- (area2 |> dplyr::filter(area_type == "STRATUM"))$area_id

  # load stratum group definitions
  stratum_groups <- get_gap_stratum_groups()

  # limit to most recent design year & specified survey
  stratum_groups <- regional_max_design_years |>
    dplyr::left_join(stratum_groups, by=c("survey_definition_id"="survey_definition_id",
                                "design_year"="design_year"))

  stratum_groups <- stratum_groups |>
    dplyr::filter(survey_definition_id==!!survey_definition_id)

  # join in area ID info
  stratum_groups2 <- stratum_groups |>
    dplyr::inner_join(area2, by=c("survey_definition_id"="survey_definition_id",
                                  "design_year"="design_year",
                          "area_id"="area_id"))

  # pivot
  stratum_groups3 <- stratum_groups2 |>
    dplyr::select(survey_definition_id, stratum, area_type, area_name) |>
    tidyr::pivot_wider(id_cols = c(survey_definition_id,stratum), names_from = area_type, values_from = area_name)


  biomass <- lapply(my_strata, FUN=function(x) get_gap_biomass(survey_definition_id=survey_definition_id,
                             area_id=x,
                             species_code=species_code,
                             start_year=start_year,
                             end_year=end_year)) |>
    dplyr::bind_rows()





  if(missing(taxa)) {
  taxa <- get_gap_taxonomic_groups() |>
    dplyr::select(species_code, species_name, common_name)
  } else { taxa<-taxa }

  biomass <- biomass |>
    dplyr::left_join(taxa, by="species_code") |>
    dplyr::left_join(stratum_groups3, by=c("survey_definition_id"="survey_definition_id",
                                  "area_id"="stratum"))

  return(biomass)
}

