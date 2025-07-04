#' get_stratum_area_assignments



get_stratum_area_assignments <- function() {

  # load area
  area <-get_gap_area() |>
    dplyr::select(!akfin_load_date)

  # load design
  sd <- get_gap_survey_design()|>
    dplyr::select(!akfin_load_date)

  sd_sum <- sd |>
    dplyr::group_by(survey_definition_id) |>
    dplyr::reframe(design_year=unique(design_year))




  # also filter to current design

area <- area |>
    dplyr::inner_join(sd_sum, by=c("survey_definition_id"="survey_definition_id",
                            "design_year"="design_year"))
# filter to stratum areas
 strata <- area |>
   dplyr::rename(stratum=area_id) |>
  dplyr::filter(area_type=="STRATUM")


  # load stratum groups
  # also filter to current design
  sg <- get_gap_stratum_groups() |>
    dplyr::select(!akfin_load_date) |>
    dplyr::inner_join(sd_sum, by=c("survey_definition_id"="survey_definition_id",
                                   "design_year"="design_year"))

  # join in stratum
  sa <- sg |>
    dplyr::inner_join(area, by=c("survey_definition_id"="survey_definition_id",
                          "design_year"="design_year",
                          "area_id"="area_id")) |>
    dplyr::filter(area_type!="STRATUM")

  saa <- sa |>
    dplyr::select(survey_definition_id, stratum, area_type, area_name,design_year) |>
    tidyr::pivot_wider(id_cols = c(survey_definition_id,stratum,design_year), names_from = area_type, values_from = area_name)
return(saa)
}


