
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

Some functions require survey_definition_id, species_code, area_id,
start_year, and end_year as parameters.  
In order to correctly define these parameters, first download several
lookup tables.

``` r
# download species_code
taxa<- get_gap_taxonomic_classification()
#> Time Elapsed: 1.34 secs

# find species codes for shortraker rockfish
 taxa %>% filter(grepl("shortraker", tolower(common_name)))
#>        species_name         common_name species_code id_rank database_id
#> 1 Sebastes borealis shortraker rockfish        30576 species      274777
#>   database genus_taxon subfamily_taxon family_taxon superfamily_taxon
#> 1    WORMS    Sebastes      Sebastinae   Sebastidae              <NA>
#>   suborder_taxon order_taxon superorder_taxon subclass_taxon class_taxon
#> 1  Scorpaenoidei Perciformes             <NA>           <NA>   Teleostei
#>   superclass_taxon subphylum_taxon phylum_taxon kingdom_taxon
#> 1      Actinopteri      Vertebrata     Chordata      Animalia
#>        akfin_load_date
#> 1 2024-02-16T00:46:14Z
```

``` r
# download survey, area, and stratum group tables
survey<-get_gap_survey_design()
#> Time Elapsed: 0.07 secs
area<-get_gap_area()
#> Time Elapsed: 0.19 secs
stratum<-get_gap_stratum_groups()
#> Time Elapsed: 0.13 secs

#combine spatial lookup tables
stratum<-stratum %>%
  left_join(survey %>%
              # remove year specific information from survey, we only need the region codes
              group_by(survey) %>%
              summarize(survey_definition_id=max(survey_definition_id)), 
            by="survey_definition_id") %>%
  left_join(area,  by=c("area_id"="area_id", "survey_definition_id"="survey_definition_id", "design_year"="design_year"))
#> Warning in left_join(., area, by = c(area_id = "area_id", survey_definition_id = "survey_definition_id", : Detected an unexpected many-to-many relationship between `x` and `y`.
#> ℹ Row 115 of `x` matches multiple rows in `y`.
#> ℹ Row 144 of `y` matches multiple rows in `x`.
#> ℹ If a many-to-many relationship is expected, set `relationship =
#>   "many-to-many"` to silence this warning.
              # I get a many to one here that gives me two extra rows

# look for the western Gulf
# 805
stratum %>%
  filter(survey=="GOA",
         area_type=="REGULATORY AREA",
         grepl("western", tolower(area_name))
         )
#>    area_id survey_definition_id design_year stratum    akfin_load_date.x survey
#> 1      805                   47        1984      10 2024-02-16T00:46:14Z    GOA
#> 2      805                   47        1984      11 2024-02-16T00:46:14Z    GOA
#> 3      805                   47        1984      12 2024-02-16T00:46:14Z    GOA
#> 4      805                   47        1984      13 2024-02-16T00:46:14Z    GOA
#> 5      805                   47        1984     110 2024-02-16T00:46:14Z    GOA
#> 6      805                   47        1984     111 2024-02-16T00:46:14Z    GOA
#> 7      805                   47        1984     112 2024-02-16T00:46:14Z    GOA
#> 8      805                   47        1984     210 2024-02-16T00:46:14Z    GOA
#> 9      805                   47        1984     310 2024-02-16T00:46:14Z    GOA
#> 10     805                   47        1984     410 2024-02-16T00:46:14Z    GOA
#> 11     805                   47        1984     510 2024-02-16T00:46:14Z    GOA
#> 12     806                   47        2025      14 2024-02-16T00:46:14Z    GOA
#> 13     806                   47        2025     113 2024-02-16T00:46:14Z    GOA
#> 14     806                   47        2025     211 2024-02-16T00:46:14Z    GOA
#> 15     806                   47        2025     411 2024-02-16T00:46:14Z    GOA
#> 16     806                   47        2025     511 2024-02-16T00:46:14Z    GOA
#>          area_type   area_name         description area_km2 depth_min_m
#> 1  REGULATORY AREA Western GOA WESTERN GOA - INPFC       NA          NA
#> 2  REGULATORY AREA Western GOA WESTERN GOA - INPFC       NA          NA
#> 3  REGULATORY AREA Western GOA WESTERN GOA - INPFC       NA          NA
#> 4  REGULATORY AREA Western GOA WESTERN GOA - INPFC       NA          NA
#> 5  REGULATORY AREA Western GOA WESTERN GOA - INPFC       NA          NA
#> 6  REGULATORY AREA Western GOA WESTERN GOA - INPFC       NA          NA
#> 7  REGULATORY AREA Western GOA WESTERN GOA - INPFC       NA          NA
#> 8  REGULATORY AREA Western GOA WESTERN GOA - INPFC       NA          NA
#> 9  REGULATORY AREA Western GOA WESTERN GOA - INPFC       NA          NA
#> 10 REGULATORY AREA Western GOA WESTERN GOA - INPFC       NA          NA
#> 11 REGULATORY AREA Western GOA WESTERN GOA - INPFC       NA          NA
#> 12 REGULATORY AREA Western GOA  WESTERN GOA - NMFS       NA          NA
#> 13 REGULATORY AREA Western GOA  WESTERN GOA - NMFS       NA          NA
#> 14 REGULATORY AREA Western GOA  WESTERN GOA - NMFS       NA          NA
#> 15 REGULATORY AREA Western GOA  WESTERN GOA - NMFS       NA          NA
#> 16 REGULATORY AREA Western GOA  WESTERN GOA - NMFS       NA          NA
#>    depth_max_m crs    akfin_load_date.y
#> 1           NA  NA 2024-02-16T00:46:14Z
#> 2           NA  NA 2024-02-16T00:46:14Z
#> 3           NA  NA 2024-02-16T00:46:14Z
#> 4           NA  NA 2024-02-16T00:46:14Z
#> 5           NA  NA 2024-02-16T00:46:14Z
#> 6           NA  NA 2024-02-16T00:46:14Z
#> 7           NA  NA 2024-02-16T00:46:14Z
#> 8           NA  NA 2024-02-16T00:46:14Z
#> 9           NA  NA 2024-02-16T00:46:14Z
#> 10          NA  NA 2024-02-16T00:46:14Z
#> 11          NA  NA 2024-02-16T00:46:14Z
#> 12          NA  NA 2024-02-16T00:46:14Z
#> 13          NA  NA 2024-02-16T00:46:14Z
#> 14          NA  NA 2024-02-16T00:46:14Z
#> 15          NA  NA 2024-02-16T00:46:14Z
#> 16          NA  NA 2024-02-16T00:46:14Z
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
#> Time Elapsed: 0.1 secs

goasr_biomass<-get_gap_biomass(survey_definition_id = 47,
                area_id = 805,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 0.08 secs

goasr_sizecomp<-get_gap_sizecomp(survey_definition_id = 47,
                area_id = 805,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 0.34 secs

head(goasr_sizecomp)
#>   survey_definition_id year area_id species_code length_mm sex population_count
#> 1                   47 2001     805        30576       620   2            16861
#> 2                   47 2001     805        30576       640   2            17300
#> 3                   47 2003     805        30576       250   1            12038
#> 4                   47 2003     805        30576       260   1            12038
#> 5                   47 2003     805        30576       320   1            10946
#> 6                   47 2003     805        30576       340   1            10626
#>        akfin_load_date
#> 1 2024-02-16T00:46:14Z
#> 2 2024-02-16T00:46:14Z
#> 3 2024-02-16T00:46:14Z
#> 4 2024-02-16T00:46:14Z
#> 5 2024-02-16T00:46:14Z
#> 6 2024-02-16T00:46:14Z
```

``` r
# No agecomp for shortraker at that area, run gulfwide instead.
head(get_gap_agecomp(survey_definition_id = 47,
                area_id = 99903,
                species_code = 30576,
                start_year=1990,
                end_year=2023))
#> Time Elapsed: 0.19 secs
#>   survey_definition_id area_id year species_code sex age population_count
#> 1                   47   99903 2003        30576   2  16            46915
#> 2                   47   99903 2003        30576   2  17           182649
#> 3                   47   99903 2003        30576   2  18            47502
#> 4                   47   99903 2003        30576   2  19            14604
#> 5                   47   99903 2003        30576   2  20           254533
#> 6                   47   99903 2003        30576   2  21           156891
#>   length_mm_mean length_mm_sd      akfin_load_date
#> 1         403.77         9.26 2024-02-16T00:46:14Z
#> 2         408.45        44.66 2024-02-16T00:46:14Z
#> 3         365.40         4.98 2024-02-16T00:46:14Z
#> 4         390.00         0.00 2024-02-16T00:46:14Z
#> 5         434.59        30.73 2024-02-16T00:46:14Z
#> 6         501.29        67.40 2024-02-16T00:46:14Z
```

Catch, CPUE, Length, and Specimen tables contain haul level data. The
web service joins the haul and cruises tables to allow querying by
survey.

``` r
# Get catch, cpue, length frequency, and specimens at a haul level for Western GOA shortraker

# The catch table only includes records where the species were caught
goasr_catch<-get_gap_catch(survey_definition_id = 47,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 0.25 secs

# The CPUE table includes zeros and thus has many more records
goasr_cpue<-get_gap_cpue(survey_definition_id = 47,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 2.26 secs

# The length table has ~150 million rows as of 2023. 
# Even with filters it may load a large amount of data
# For WGOA shortraker below it pulled 40367 records. 
# Add timing to track how long this takes

goasr_length<-get_gap_length(survey_definition_id = 47,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 1.87 secs


# The specimen table contains length, sex, weight, and age data for individual fish.
goasr_specimen<-get_gap_specimen(survey_definition_id = 47,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 1.81 secs

head(goasr_specimen)
#>   hauljoin specimen_id species_code length_mm sex weight_g age maturity gonad_g
#> 1   784467          27        30576       610   2       NA  NA       NA      NA
#> 2   784467          28        30576       480   2       NA  NA       NA      NA
#> 3   784467          29        30576       450   2       NA  NA       NA      NA
#> 4   784467          30        30576       430   2       NA  NA       NA      NA
#> 5   784467          31        30576       450   2       NA  NA       NA      NA
#> 6   784524          32        30576       430   2     1379  NA       NA      NA
#>   specimen_subsample_method specimen_sample_type age_determination_method
#> 1                         5                    1                       NA
#> 2                         5                    1                       NA
#> 3                         5                    1                       NA
#> 4                         5                    1                       NA
#> 5                         5                    1                       NA
#> 6                         5                    1                       NA
#>        akfin_load_date stratum survey_definition_id year
#> 1 2024-02-16T00:46:14Z     310                   47 1993
#> 2 2024-02-16T00:46:14Z     310                   47 1993
#> 3 2024-02-16T00:46:14Z     310                   47 1993
#> 4 2024-02-16T00:46:14Z     310                   47 1993
#> 5 2024-02-16T00:46:14Z     310                   47 1993
#> 6 2024-02-16T00:46:14Z     310                   47 1993
```

To query more than one species (or area) at a time use the lapply
function or a for loop.

``` r
# Get rougheye and shortraker biomass for the WGOA
taxa %>% filter(grepl("rougheye", common_name))
#>          species_name                              common_name species_code
#> 1                <NA> rougheye and blackspotted rockfish unid.        30050
#> 2 Sebastes aleutianus                        rougheye rockfish        30051
#>   id_rank database_id database genus_taxon subfamily_taxon family_taxon
#> 1    <NA>          NA     <NA>        <NA>            <NA>         <NA>
#> 2 species      274771    WORMS    Sebastes      Sebastinae   Sebastidae
#>   superfamily_taxon suborder_taxon order_taxon superorder_taxon subclass_taxon
#> 1              <NA>           <NA>        <NA>             <NA>           <NA>
#> 2              <NA>  Scorpaenoidei Perciformes             <NA>           <NA>
#>   class_taxon superclass_taxon subphylum_taxon phylum_taxon kingdom_taxon
#> 1        <NA>             <NA>            <NA>         <NA>          <NA>
#> 2   Teleostei      Actinopteri      Vertebrata     Chordata      Animalia
#>        akfin_load_date
#> 1 2024-02-16T00:46:14Z
#> 2 2024-02-16T00:46:14Z

myspecies <- c(30050, 30051)

goa_resr_biomass<-lapply(myspecies, FUN = function(x) get_gap_biomass(
  survey_definition_id = 47,
  area_id = 805,
  species_code = x,
  start_year=2007,
  end_year=2023)) %>%
  bind_rows() %>%
  arrange(year)
#> Time Elapsed: 0.07 secs
#> Time Elapsed: 0.07 secs


head(goa_resr_biomass)
#>   survey_definition_id area_id species_code year n_haul n_weight n_count
#> 1                   47     805        30050 2007    205        0       0
#> 2                   47     805        30051 2007    205       15      15
#> 3                   47     805        30050 2009    196        0       0
#> 4                   47     805        30051 2009    196       15      15
#> 5                   47     805        30050 2011    163        0       0
#> 6                   47     805        30051 2011    163        5       5
#>   n_length cpue_kgkm2_mean cpue_kgkm2_var cpue_nokm2_mean cpue_nokm2_var
#> 1        0        0.000000       0.000000        0.000000       0.000000
#> 2       15        9.145039      18.730557        9.555335      11.314525
#> 3        0        0.000000       0.000000        0.000000       0.000000
#> 4       15       11.650219      38.441838        8.194234      11.717972
#> 5        0        0.000000       0.000000        0.000000       0.000000
#> 6        5        5.289361       6.877931        3.146554       2.120705
#>   biomass_mt biomass_var population_count population_var      akfin_load_date
#> 1     0.0000        0.00                0              0 2024-02-16T00:46:14Z
#> 2   596.5102    79692.12           623273    48139437143 2024-02-16T00:46:14Z
#> 3     0.0000        0.00                0              0 2024-02-16T00:46:14Z
#> 4   759.9175   163556.88           534491    49855965270 2024-02-16T00:46:14Z
#> 5     0.0000        0.00                0              0 2024-02-16T00:46:14Z
#> 6   334.7664    27550.86           199147     8494888884 2024-02-16T00:46:14Z

# trying the same thing with the other functions produces the same generic error as when the token is expired.
```

## Cruise and haul tables

Haul and cruise level details are available for download as well.
Download these tables in full and manipulate in R.

``` r
gap_haul<-get_gap_haul()
#> Time Elapsed: 18.45 secs

gap_cruise<-get_gap_cruise()
#> Time Elapsed: 0.18 secs

head(gap_haul)
#>   cruisejoin hauljoin haul haul_type performance      date_time_start
#> 1       -608   -13062  183         3        0.00 2005-07-02T17:03:26Z
#> 2       -608   -13063  184         3        0.00 2005-07-02T18:34:45Z
#> 3       -608   -13064  185         3        1.11 2005-07-02T20:12:55Z
#> 4       -608   -13065  186         3        0.00 2005-07-02T23:03:10Z
#> 5       -608   -13066  187         3        0.00 2005-07-03T14:15:20Z
#> 6       -608   -13067  188         3        0.00 2005-07-03T16:22:22Z
#>   duration_hr distance_fished_km net_width_m net_measured net_height_m stratum
#> 1       0.256              1.431      15.470            1        7.524      31
#> 2       0.266              1.495      15.668            1        7.417      31
#> 3       0.258              1.440      15.705            1        7.581      31
#> 4       0.262              1.477      15.127            1        7.225      31
#> 5       0.257              1.462      16.420            1        6.550     330
#> 6       0.262              1.478      15.949            1        6.668     330
#>   latitude_dd_start latitude_dd_end longitude_dd_start longitude_dd_end station
#> 1          57.46529        57.47803          -151.1313        -151.1304 228-121
#> 2          57.45372        57.45961          -151.2179        -151.2399 227-121
#> 3          57.61075        57.62205          -151.0859        -151.0754 229-124
#> 4          57.83390        57.82148          -150.5573        -150.5644 235-129
#> 5          57.53942        57.53059          -150.1437        -150.1611 240-122
#> 6          57.49053        57.48185          -150.1499        -150.1679 240-121
#>   depth_gear_m depth_m bottom_type surface_temperature_c gear_temperature_c
#> 1           79      87           4                  10.3                7.3
#> 2           83      90           4                  10.7                7.2
#> 3           71      79        <NA>                  10.6                7.7
#> 4           79      86        <NA>                  11.3                6.7
#> 5          326     333        <NA>                  12.6                4.5
#> 6          468     475        <NA>                  12.9                4.0
#>   wire_length_m gear accessories      akfin_load_date
#> 1           320  172         129 2024-02-16T00:46:14Z
#> 2           320  172         129 2024-02-16T00:46:14Z
#> 3           274  172         129 2024-02-16T00:46:14Z
#> 4           320  172         129 2024-02-16T00:46:14Z
#> 5           823  172         129 2024-02-16T00:46:14Z
#> 6          1097  172         129 2024-02-16T00:46:14Z
```

## Split Fractions

This table shows what proportion of fish are in the eastern or western
GOA. It is downloaded in its entirety.

``` r
split_fractions<-get_gap_split_fractions()
#> Time Elapsed: 0.15 secs
```
