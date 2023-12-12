
## akfingapdata

<!-- badges: start -->
<!-- badges: end -->

This pacakge provides functions to download
[gap_product](https://afsc-gap-products.github.io/gap_products/) tables
from the AKFIN database using web services.

## Installation

``` r
# devtools::install_github("MattCallahan-NOAA/akfingapdata")
```

## Authentication

In order to use this package you must be authorized to view these data.
Please contact <matt.callahan@noaa.gov> for assistance setting up web
service credentials. Authorized users will be issued a secret text
string in a .txt file, which is encrypted using the create_token()
function. This token is valid for about ten minutes. If it expires you
will get the following error:

Error: lexical error: invalid char in json text. \<!DOCTYPE html\>
<html>

\<style t (right here) ——^

This is a generic web service error, rerun create_token() to continue
querying.

``` r
library(akfingapdata)
library(tidyverse)
library(httr)
library(jsonlite)

token<-create_token("Callahan_token.txt")
```

## Metadata

A good first step is to download the column descriptions for these data.
The authors of these tables mercifully named columns in such a way that
no column has different definitions in different tables, so one metadata
table will suffice for all tables.

``` r
metadata<-get_gap_metadata_column()
```

## Lookup tables

Most functions require survey_definition_id, area_id, species_code,
start_year, and end_year as parameters. In order to correctly define
these parameters, first download several lookup tables.

``` r
# download species_code
taxa<- get_gap_taxonomics()

# find species codes for shortraker rockfish
 taxa %>% filter(grepl("shortraker", tolower(common_name)))
#> # A tibble: 1 × 22
#>   survey_name       accepted_name     common_name  species_code id_rank database
#>   <chr>             <chr>             <chr>               <int> <chr>   <chr>   
#> 1 Sebastes borealis Sebastes borealis shortraker …        30576 species WORMS   
#> # ℹ 16 more variables: database_id <int>, family <chr>, superfamily <chr>,
#> #   suborder <chr>, order <chr>, superorder <chr>, subclass <chr>, class <chr>,
#> #   subphylum <chr>, phylum <chr>, kingdom <chr>, akfin_load_date <chr>,
#> #   genus <chr>, superclass <chr>, reason <chr>, subfamily <chr>
```

``` r
# download survey, area, and strata tables
survey<-get_gap_survey_design()
area<-get_gap_area()
stratum<-get_gap_stratum_groups()

#combine spatial lookup tables
stratum<-stratum %>%
  left_join(survey %>%
              # remove year specific information from survey, we only need the region codes
              group_by(survey) %>%
              summarize(survey_definition_id=max(survey_definition_id)), 
            by="survey_definition_id") %>%
  left_join(area,  by=c("area_id"="area_id", "survey_definition_id"="survey_definition_id", "design_year"="design_year"))
#> Warning in left_join(., area, by = c(area_id = "area_id", survey_definition_id = "survey_definition_id", : Detected an unexpected many-to-many relationship between `x` and `y`.
#> ℹ Row 49 of `x` matches multiple rows in `y`.
#> ℹ Row 382 of `y` matches multiple rows in `x`.
#> ℹ If a many-to-many relationship is expected, set `relationship =
#>   "many-to-many"` to silence this warning.
              # I get a many to one here that gives me two extra rows

# look for the western Gulf
# 805
stratum %>%
  filter(survey=="GOA",
         type=="REGULATORY AREA",
         grepl("western", tolower(area_name))
         )
#> # A tibble: 16 × 13
#>    area_id survey_definition_id design_year stratum akfin_load_date.x    survey
#>      <int>                <int>       <int>   <int> <chr>                <chr> 
#>  1     805                   47        1984      10 2023-06-23T07:00:00Z GOA   
#>  2     805                   47        1984      11 2023-06-23T07:00:00Z GOA   
#>  3     805                   47        1984      12 2023-06-23T07:00:00Z GOA   
#>  4     805                   47        1984      13 2023-06-23T07:00:00Z GOA   
#>  5     805                   47        1984     110 2023-06-23T07:00:00Z GOA   
#>  6     805                   47        1984     111 2023-06-23T07:00:00Z GOA   
#>  7     805                   47        1984     112 2023-06-23T07:00:00Z GOA   
#>  8     805                   47        1984     210 2023-06-23T07:00:00Z GOA   
#>  9     805                   47        1984     310 2023-06-23T07:00:00Z GOA   
#> 10     805                   47        1984     410 2023-06-23T07:00:00Z GOA   
#> 11     805                   47        1984     510 2023-06-23T07:00:00Z GOA   
#> 12     806                   47        2025      14 2023-06-23T07:00:00Z GOA   
#> 13     806                   47        2025     113 2023-06-23T07:00:00Z GOA   
#> 14     806                   47        2025     211 2023-06-23T07:00:00Z GOA   
#> 15     806                   47        2025     411 2023-06-23T07:00:00Z GOA   
#> 16     806                   47        2025     511 2023-06-23T07:00:00Z GOA   
#> # ℹ 7 more variables: type <chr>, area_name <chr>, description <chr>,
#> #   area_km2 <dbl>, depth_min_m <int>, depth_max_m <int>,
#> #   akfin_load_date.y <chr>
```

## Data tables

Each table has a separate function to pull data from it. Agecomp,
Biomass, Catch, CPUE, Length, Sizecomp, and Specimen tables have
hundreds of thousands to over 100 million rows. Parameters are built
into the web services and functions to prevent enormous downloads.
Default parameters are as follows: survey_definition_id= 98 (Bering
Sea), area_id = 1 (EBS Subarea 1), species_code=21740 (Pollock),
start_year = 1990, and end_year = 3000 (will need to get updated in 976
years). Agecomp, biomass, and sizecomp are calculated at the area_id
level and survey_definition_id and area_id are built into those tables.

``` r
# Get Western GOA shortraker, agecomp, biomass from 2010 onward

# No agecomp data for this area/species
goasr_ages<-get_gap_agecomp(survey_definition_id = 47,
                area_id = 805,
                species_code = 30576,
                start_year=1990,
                end_year=2023)

goasr_biomass<-get_gap_biomass(survey_definition_id = 47,
                area_id = 805,
                species_code = 30576,
                start_year=1990,
                end_year=2023)

goasr_sizecomp<-get_gap_sizecomp(survey_definition_id = 47,
                area_id = 805,
                species_code = 30576,
                start_year=1990,
                end_year=2023)

head(goasr_sizecomp)
#> # A tibble: 6 × 8
#>   survey_definition_id  year area_id species_code length_mm   sex
#>                  <int> <int>   <int>        <int>     <int> <int>
#> 1                   47  1993     805        30576       570     2
#> 2                   47  1993     805        30576       580     2
#> 3                   47  1993     805        30576       590     2
#> 4                   47  1993     805        30576       600     2
#> 5                   47  1993     805        30576       610     2
#> 6                   47  1993     805        30576       620     2
#> # ℹ 2 more variables: population_count <int>, akfin_load_date <chr>
```

``` r
# No agecomp for shortraker at that area, run gulfwide instead.
head(get_gap_agecomp(survey_definition_id = 47,
                area_id = 99903,
                species_code = 30576,
                start_year=1990,
                end_year=2023))
#> # A tibble: 6 × 10
#>   survey_definition_id area_id  year species_code   sex   age population_count
#>                  <int>   <int> <int>        <int> <int> <int>            <int>
#> 1                   47   99903  2005        30576     1    37           183298
#> 2                   47   99903  2005        30576     1    38           306222
#> 3                   47   99903  2005        30576     1    39           239802
#> 4                   47   99903  2005        30576     1    40            28292
#> 5                   47   99903  2005        30576     1    41           424516
#> 6                   47   99903  2005        30576     1    42           333900
#> # ℹ 3 more variables: length_mm_mean <dbl>, length_mm_sd <dbl>,
#> #   akfin_load_date <chr>
```

Catch, CPUE, Lengh, and Specimen tables contain haul level data. The web
service joins the haul, cruises, and stratum groups tables to allow
querying by area_id.

``` r
# Get catch, cpue, length frequency, and specimens at a haul level for Western GOA shortraker

# The catch table only includes records where the species were caught
goasr_catch<-get_gap_catch(survey_definition_id = 47,
                area_id = 805,
                species_code = 30576,
                start_year=1990,
                end_year=2023)

# The CPUE table includes zeros and thus has many more records
goasr_cpue<-get_gap_cpue(survey_definition_id = 47,
                area_id = 805,
                species_code = 30576,
                start_year=1990,
                end_year=2023)

# The length table has ~150 million rows as of 2023. 
# Even with filters it may load a large amount of data
# For WGOA shortraker below it pulled 40367 records. 
# Add timing to track how long this takes
start<-Sys.time()
goasr_lengths<-get_gap_lengths(survey_definition_id = 47,
                area_id = 805,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
end<-Sys.time()
end-start
#> Time difference of 14.49828 secs

# The specimen table contains length, sex, weight, and age data for individual fish.
goasr_specimen<-get_gap_specimen(survey_definition_id = 47,
                area_id = 805,
                species_code = 30576,
                start_year=1990,
                end_year=2023)

head(goasr_specimen)
#> # A tibble: 6 × 18
#>   cruisejoin hauljoin region vessel_id specimen_id stratum species_code
#>        <int>    <int> <chr>      <int>       <int>   <int>        <int>
#> 1       -608   -12889 GOA          143           1     111        30576
#> 2       -608   -12896 GOA          143           2     210        30576
#> 3       -608   -12915 GOA          143          27     210        30576
#> 4       -608   -12915 GOA          143          26     210        30576
#> 5       -608   -12914 GOA          143           3     310        30576
#> 6       -608   -12914 GOA          143           4     310        30576
#> # ℹ 11 more variables: length_mm <int>, sex <int>, weight_g <int>, age <int>,
#> #   specimen_subsample_method <int>, specimen_sample_type <int>,
#> #   age_determination_method <int>, akfin_load_date <chr>,
#> #   survey_definition_id <int>, year <int>, area_id <int>
```

I set up the get_gap_biomass() function to also accept vectors as inputs
allowing users to query more than one species at a time. I could set up
the rest of them to do the same thing if useful.

``` r
# Get rougheye and shortraker biomass for the WGOA
taxa %>% filter(grepl("rougheye", common_name))
#> # A tibble: 2 × 22
#>   survey_name         accepted_name    common_name species_code id_rank database
#>   <chr>               <chr>            <chr>              <int> <chr>   <chr>   
#> 1 Sebastes aleutianus Sebastes aleuti… rougheye r…        30051 species WORMS   
#> 2 <NA>                <NA>             rougheye a…        30050 <NA>    <NA>    
#> # ℹ 16 more variables: database_id <int>, family <chr>, superfamily <chr>,
#> #   suborder <chr>, order <chr>, superorder <chr>, subclass <chr>, class <chr>,
#> #   subphylum <chr>, phylum <chr>, kingdom <chr>, akfin_load_date <chr>,
#> #   genus <chr>, superclass <chr>, reason <chr>, subfamily <chr>

goa_resr_biomass<-get_gap_biomass(survey_definition_id = 47,
                area_id = 805,
                species_code = c(30576, 30051),
                start_year=1990,
                end_year=2023)


head(goa_resr_biomass)
#> # A tibble: 6 × 17
#>   survey_definition_id area_id species_code  year n_haul n_weight n_count
#>                  <int>   <int>        <int> <int>  <dbl>    <dbl>   <dbl>
#> 1                   47     805        30051  1990    135        0       0
#> 2                   47     805        30576  1990    135        3       3
#> 3                   47     805        30051  1993    170        0       0
#> 4                   47     805        30576  1993    170        7       7
#> 5                   47     805        30051  1996    200        0       0
#> 6                   47     805        30576  1996    200       17      17
#> # ℹ 10 more variables: n_length <dbl>, cpue_kgkm2_mean <dbl>,
#> #   cpue_kgkm2_var <dbl>, cpue_nokm2_mean <dbl>, cpue_nokm2_var <dbl>,
#> #   biomass_mt <dbl>, biomass_var <dbl>, population_count <dbl>,
#> #   population_var <dbl>, akfin_load_date <chr>

# trying the same thing with the other functions produces the same generic error as when the token is expired.
```

## Cruise and haul tables

Haul and cruise level details are available for download as well.
Download these tables in full and manipulate in R.

``` r
gap_haul<-get_gap_haul()

gap_cruise<-get_gap_cruises()

head(gap_haul)
#> # A tibble: 6 × 28
#>   cruisejoin hauljoin  haul haul_type vessel_id performance date_time_start     
#>        <int>    <int> <int>     <int>     <int>       <dbl> <chr>               
#> 1       -608   -12880     1         3       143        0    2005-05-21T22:34:16Z
#> 2       -608   -12881     2         3       143        1.11 2005-05-22T01:51:09Z
#> 3       -608   -12882     3         3       143        0    2005-05-22T20:19:04Z
#> 4       -608   -12883     4         3       143        0    2005-05-23T14:48:46Z
#> 5       -608   -12884     5         3       143        0    2005-05-23T16:34:40Z
#> 6       -608   -12885     6         3       143        0    2005-05-23T19:06:03Z
#> # ℹ 21 more variables: duration_km <dbl>, distance_fished_km <dbl>,
#> #   net_width_m <dbl>, net_measured <chr>, net_height_m <dbl>, stratum <int>,
#> #   latitude_dd_start <dbl>, latitude_dd_end <dbl>, longitude_dd_start <dbl>,
#> #   longitude_dd_end <dbl>, station <chr>, depth_m_gear <int>, depth_m <int>,
#> #   surface_temperature_c <dbl>, wire_length <int>, gear <chr>,
#> #   accessories <chr>, abundance_haul <chr>, akfin_load_date <chr>,
#> #   bottom_type <chr>, bottom_temperature_c <dbl>
```

## Split Fractions

This table shows what proportion of fish are in the eastern or western
GOA. It is downloaded in its entirety.

``` r
split_fractions<-get_gap_split_fractions()
```
