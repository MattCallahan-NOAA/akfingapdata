
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
string in a .txt file, which will be in the format of 1234r..:abcd2..
The create_token function encrypts this secret string to authenticate
access to these data. The create_token function accepts a defined
variable as the secret string, the filepath to the textfile, or a
keyring package service input. This token is valid for about ten
minutes. If it expires you will get an error asking you to provide a
valid token. You must define the function output as token as in the
example below.

``` r
library(akfingapdata)
library(tidyverse)
library(keyring)
library(kableExtra)

token<-create_token("akfin_secret") # keyring input
# token<-create_token("Callahan_token.txt") file version
```

## Metadata

A good first step is to download the column descriptions for these data.
The authors of these tables mercifully named columns in such a way that
no column has different definitions in different tables, so one metadata
table will suffice for all tables.

``` r
metadata<-get_gap_metadata_column()
head(metadata %>% dplyr::select(metadata_colname,metadata_colname_long, metadata_units)) %>%kable()
```

| metadata_colname | metadata_colname_long               | metadata_units |
|:-----------------|:------------------------------------|:---------------|
| CATCHJOIN        | Catch observation ID                | ID key code    |
| CLASS_TAXON      | Class phylogenetic rank             | category       |
| CLASSIFICATION   | Taxonomic classification rank group | category       |
| COLLECTED_BY     | Person who collected specimen       | text           |
| COMMENTS         | Comments                            | text           |
| COMMON_NAME      | Taxon common name                   | text           |

## Lookup tables

Some functions require survey_definition_id, species_code, area_id,
start_year, and end_year as parameters.  
In order to correctly define these parameters, first download the
species lookup table.

``` r
# download species_code
# The akfin_taxonomic_groups table supersedes the akfin_taxonomic_classification table, these tables have the same structure, except the groups table has a group column designating which group code a species corresponds to for species that have comps calculated at the group level rather than individually. 
taxa<- get_gap_taxonomic_groups()
#> Time Elapsed: 4.97 secs
```

``` r

# find species codes for shortraker rockfish
 taxa %>% filter(grepl("shortraker", tolower(common_name))) %>%
   dplyr::select(group_code, species_code, species_name, common_name) %>% kable()
```

| group_code | species_code | species_name      | common_name         |
|-----------:|-------------:|:------------------|:--------------------|
|      30576 |        30576 | Sebastes borealis | shortraker rockfish |

The GAP_PRODUCTS data structure uses the survey_definition_id column to
specify which survey (region) data belong to.

``` r
# The survey name can be found in the cruise table.
cruise <- get_gap_cruise()
#> Time Elapsed: 0.19 secs
```

``` r

cruise %>%
  group_by(survey_definition_id) %>% 
  summarize(survey_name = unique(survey_name)) %>% kable()
```

| survey_definition_id | survey_name |
|---:|:---|
| 47 | Gulf of Alaska Bottom Trawl Survey |
| 52 | Aleutian Islands Bottom Trawl Survey |
| 78 | Eastern Bering Sea Slope Bottom Trawl Survey |
| 98 | Eastern Bering Sea Crab/Groundfish Bottom Trawl Survey |
| 143 | Northern Bering Sea Crab/Groundfish Survey - Eastern Bering Sea Shelf Survey Extension |

The design_year field notes the year of survey design. Biomass, agecomp,
and sizecomp estimates are provided for one design year only. As of
summer 2025, for all surveys except the GOA, indices use the most recent
survey design year. The GOA survey design changed in 2025 and old
estimates were not recalculated with the new design, therefore in the
GOA 1990-2023 use the 2024 design year and 2025 onward use the 2025
design year.

``` r
# download survey design
survey_design<-get_gap_survey_design()
#> Time Elapsed: 0.07 secs
```

``` r

survey_design %>% 
  group_by(survey_definition_id) %>%
  reframe(design_year = unique(design_year)) %>% kable()
```

| survey_definition_id | design_year |
|---------------------:|------------:|
|                   47 |        2024 |
|                   47 |        2025 |
|                   52 |        1991 |
|                   78 |        2023 |
|                   98 |        2022 |
|                  143 |        2022 |

The get_gap_area() function provides the akfin_area table, which
contains area_id descriptions. Biomass, sizecomp, and agecomp estimates
are provided at the area_id level. Determining the correct area_id is
one crux to replicate results from pre-gap_products tables. Area_ids are
grouped by area types e.g “REGION”, “REGULATORY AREA”, “STRATUM”. The
akfin_area table has records for each design_year, so if joining the
area descriptions to biomass estimates, design_year needs to be
specified to avoid duplicates.

``` r
area <- get_gap_area()
#> Time Elapsed: 0.31 secs
```

``` r

unique(area$area_type)
#> [1] "SUBAREA"                  "STRATUM"                 
#> [3] "DEPTH"                    "REGION"                  
#> [5] "REGULATORY AREA"          "INPFC BY DEPTH"          
#> [7] "INPFC"                    "NMFS STATISTICAL AREA"   
#> [9] "REGULATORY AREA BY DEPTH"
```

The get_gap_stratum_groups() function shows which strata are in each
AREA_ID (for non “STRATUM” area_ids).

``` r
stratum_groups <- get_gap_stratum_groups()
#> Time Elapsed: 0.38 secs
```

``` r

# which stata are in the Western GOA?
area %>%
  filter(design_year ==2025,
         survey_definition_id==47,
         area_type=="REGULATORY AREA",
         area_name == "Western GOA"
         ) %>%
  dplyr::select(area_id)
#>   area_id
#> 1     805
```

``` r

stratum_groups %>%
  filter(design_year == 2025,,
         survey_definition_id==47,
         area_id == 805) %>% kable()
```

| area_id | survey_definition_id | design_year | stratum | akfin_load_date      |
|--------:|---------------------:|------------:|--------:|:---------------------|
|     805 |                   47 |        2025 |      14 | 2025-05-22T00:00:00Z |
|     805 |                   47 |        2025 |      15 | 2025-05-22T00:00:00Z |
|     805 |                   47 |        2025 |     113 | 2025-05-22T00:00:00Z |
|     805 |                   47 |        2025 |     211 | 2025-05-22T00:00:00Z |
|     805 |                   47 |        2025 |     511 | 2025-05-22T00:00:00Z |

## Data tables

Each table has a separate function to pull data from it. Agecomp,
Biomass, Catch, CPUE, Length, Sizecomp, and Specimen tables have
hundreds of thousands to over 100 million rows. Parameters are built
into the web services and functions to prevent enormous downloads.
Default parameters are as follows: survey_definition_id= 98 (Bering
Sea), area_id = 1 (EBS Subarea 1), species_code=21740 (Pollock),
start_year = 1990, and end_year = 3000. Agecomp, biomass, and sizecomp
are calculated at the area_id level and survey_definition_id and area_id
are built into those tables.

``` r
# Get GOA shortraker, agecomp, biomass, and sizecomp data 
goasr_biomass<-get_gap_biomass(survey_definition_id = 47,
                area_id = 99903,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 0.12 secs
```

``` r

goasr_sizecomp<-get_gap_sizecomp(survey_definition_id = 47,
                area_id = 99903,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 1.57 secs
```

``` r


head(get_gap_agecomp(survey_definition_id = 47,
                area_id = 99903,
                species_code = 30576,
                start_year=1990,
                end_year=2023))%>% kable()
#> Time Elapsed: 0.46 secs
```

| survey_definition_id | area_id | year | species_code | sex | age | population_count | length_mm_mean | length_mm_sd | area_id_footprint | akfin_load_date |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|:---|:---|
| 47 | 99903 | 1990 | 30576 | 1 | -9 | 1419310 | 610.95 | 93.96 | GOA | 2025-05-22T00:00:00Z |
| 47 | 99903 | 1990 | 30576 | 2 | -9 | 1510395 | 611.68 | 110.53 | GOA | 2025-05-22T00:00:00Z |
| 47 | 99903 | 1990 | 30576 | 3 | -99 | 201929 | NA | NA | GOA | 2025-05-22T00:00:00Z |
| 47 | 99903 | 1993 | 30576 | 1 | -9 | 2367880 | 598.67 | 115.11 | GOA | 2025-05-22T00:00:00Z |
| 47 | 99903 | 1993 | 30576 | 2 | -9 | 2663239 | 599.72 | 118.42 | GOA | 2025-05-22T00:00:00Z |
| 47 | 99903 | 1996 | 30576 | 1 | -9 | 29630 | 404.16 | 306.53 | GOA | 2025-05-22T00:00:00Z |

Note that Eastern Bering Sea stratum level age compositions are
calculated using “EBS STANDARD” and “EBS STANDARD PLUS NW” girds. The
get_gap_agecomp() function has an optional area_id_footprint argument
that specifies which footprint to use (default is “EBS STANDARD PLUS
NW”).

``` r
unique(get_gap_agecomp(
  survey_definition_id = 98, area_id = 50,species_code = 21370,start_year=1990,end_year=2023,area_id_footprint = "EBS STANDARD PLUS NW")$area_id_footprint)
#> Agecomps calculated using EBS STANDARD PLUS NW area_id_footprint
#> Time Elapsed: 0.2 secs
#> [1] "EBS STANDARD PLUS NW"
```

``` r

unique(get_gap_agecomp(
  survey_definition_id = 98, area_id = 50,species_code = 21370,start_year=1990,end_year=2023,area_id_footprint = "EBS STANDARD")$area_id_footprint)
#> Agecomps calculated using EBS STANDARD area_id_footprint
#> Time Elapsed: 0.19 secs
#> [1] "EBS STANDARD"
```

Catch, CPUE, Length, and Specimen tables contain haul level data. The
web service joins the haul and cruises tables to allow querying by
survey.

``` r
# Get catch, cpue, length frequency, and specimens at a haul level for GOA shortraker

# The catch table only includes records where the species were caught
goasr_catch<-get_gap_catch(survey_definition_id = 47,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 0.68 secs
```

``` r

# The CPUE table includes zeros and thus has many more records
goasr_cpue<-get_gap_cpue(survey_definition_id = 47,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 6.85 secs
```

``` r

# The length table has ~4 million rows as of 2025 so loads may be slow. 
goasr_length<-get_gap_length(survey_definition_id = 47,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 6.68 secs
```

``` r


# The specimen table contains length, sex, weight, and age data for individual fish.
goasr_specimen<-get_gap_specimen(survey_definition_id = 47,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 7.02 secs
```

``` r

head(goasr_specimen)
#>   hauljoin specimen_id species_code length_mm sex weight_g age maturity gonad_g
#> 1   -12914           3        30576       410   2     1104  42       NA      NA
#> 2   -12914           4        30576       500   2     1836  28       NA      NA
#> 3   -12914           5        30576       460   2     1300  52       NA      NA
#> 4   -12914           6        30576       440   2     1430  38       NA      NA
#> 5   -12914           7        30576       480   2     1672  39       NA      NA
#> 6   -12914           8        30576       340   2      622  19       NA      NA
#>   specimen_subsample_method specimen_sample_type age_determination_method
#> 1                         5                    1                        5
#> 2                         5                    1                        5
#> 3                         5                    1                        5
#> 4                         5                    1                        5
#> 5                         5                    1                        5
#> 6                         5                    1                        5
#>        akfin_load_date stratum survey_definition_id year
#> 1 2025-05-22T00:00:00Z     310                   47 2005
#> 2 2025-05-22T00:00:00Z     310                   47 2005
#> 3 2025-05-22T00:00:00Z     310                   47 2005
#> 4 2025-05-22T00:00:00Z     310                   47 2005
#> 5 2025-05-22T00:00:00Z     310                   47 2005
#> 6 2025-05-22T00:00:00Z     310                   47 2005
```

To query more than one species (or area) at a time use the lapply
function or a for loop.

``` r
# Get rougheye and shortraker biomass for the WGOA
taxa %>% filter(grepl("rougheye", common_name))
#>   group_code species_code        species_name
#> 1      30050        30050                <NA>
#> 2      30051        30051 Sebastes aleutianus
#>                                common_name id_rank database database_id
#> 1 rougheye and blackspotted rockfish unid.    <NA>    WORMS        <NA>
#> 2                        rougheye rockfish species    WORMS      274771
#>   genus_taxon subfamily_taxon family_taxon superfamily_taxon infraorder_taxon
#> 1    Sebastes      Sebastinae   Sebastidae              <NA>             <NA>
#> 2    Sebastes      Sebastinae   Sebastidae              <NA>             <NA>
#>   suborder_taxon order_taxon superorder_taxon subclass_taxon class_taxon
#> 1  Scorpaenoidei Perciformes             <NA>           <NA>   Teleostei
#> 2  Scorpaenoidei Perciformes             <NA>           <NA>   Teleostei
#>   superclass_taxon subphylum_taxon phylum_taxon kingdom_taxon
#> 1      Actinopteri      Vertebrata     Chordata      Animalia
#> 2      Actinopteri      Vertebrata     Chordata      Animalia
#>        akfin_load_date infraclass_taxon
#> 1 2025-05-22T00:00:00Z             <NA>
#> 2 2025-05-22T00:00:00Z             <NA>
```

``` r

myspecies <- c(30050, 30051)

goa_resr_biomass<-lapply(myspecies, FUN = function(x) get_gap_biomass(
  survey_definition_id = 47,
  area_id = 805,
  species_code = x,
  start_year=2007,
  end_year=2023)) %>%
  bind_rows() %>%
  arrange(year)
#> Time Elapsed: 0.09 secs
#> Time Elapsed: 0.08 secs
```

``` r


head(goa_resr_biomass)
#>   survey_definition_id area_id species_code year n_haul n_weight n_count
#> 1                   47     805        30050 2007    204        0       0
#> 2                   47     805        30051 2007    204       15      15
#> 3                   47     805        30050 2009    194        0       0
#> 4                   47     805        30051 2009    194       15      15
#> 5                   47     805        30050 2011    161        0       0
#> 6                   47     805        30051 2011    161        5       5
#>   n_length cpue_kgkm2_mean cpue_kgkm2_var cpue_nokm2_mean cpue_nokm2_var
#> 1        0        0.000000        0.00000        0.000000       0.000000
#> 2       15        9.302360       19.36829        9.727109      11.764364
#> 3        0        0.000000        0.00000        0.000000       0.000000
#> 4       15       11.844262       39.75353        8.330015      12.116536
#> 5        0        0.000000        0.00000        0.000000       0.000000
#> 6        5        5.464892        7.46587        3.231812       2.242676
#>   biomass_mt biomass_var population_count population_var      akfin_load_date
#> 1     0.0000        0.00                0              0 2025-05-22T00:00:00Z
#> 2   596.6316    79674.17           623874    48394352408 2025-05-22T00:00:00Z
#> 3     0.0000        0.00                0              0 2025-05-22T00:00:00Z
#> 4   759.6633   163531.69           534268    49843060538 2025-05-22T00:00:00Z
#> 5     0.0000        0.00                0              0 2025-05-22T00:00:00Z
#> 6   339.9194    28884.78           201021     8676712314 2025-05-22T00:00:00Z
```

``` r

# trying the same thing with the other functions produces the same generic error as when the token is expired.
```

## Cruise and haul tables

Haul and cruise level details are available for download as well.
Download these tables in full and manipulate in R.

``` r
gap_haul<-get_gap_haul()
#> Time Elapsed: 58.59 secs
```

``` r

gap_cruise<-get_gap_cruise()
#> Time Elapsed: 0.23 secs
```

``` r

head(gap_haul)
#>   cruisejoin hauljoin haul haul_type performance      date_time_start
#> 1       -608   -13118  239         3           0 2005-07-14T00:00:00Z
#> 2       -608   -13119  240         3           0 2005-07-14T00:00:00Z
#> 3       -608   -13120  241         3           0 2005-07-19T00:00:00Z
#> 4       -608   -13121  242         3           0 2005-07-19T00:00:00Z
#> 5       -608   -13122  243         3           0 2005-07-19T00:00:00Z
#> 6       -608   -13123  244         3           0 2005-07-19T00:00:00Z
#>   duration_hr distance_fished_km net_width_m net_measured net_height_m stratum
#> 1       0.266              1.451      16.460            1        6.640     141
#> 2       0.262              1.463      15.342            1        7.263      40
#> 3       0.254              1.423      15.474            1        6.977     142
#> 4       0.254              1.410      15.428            1        6.967     143
#> 5       0.256              1.413      16.151            1        6.718      40
#> 6       0.252              1.416      16.301            1        6.414     143
#>   latitude_dd_start latitude_dd_end longitude_dd_start longitude_dd_end station
#> 1          59.57275        59.57293          -141.4842        -141.5094 345-166
#> 2          59.72135        59.73064          -141.4848        -141.5025 345-169
#> 3          58.88860        58.87645          -138.7889        -138.7949 378-151
#> 4          58.78326        58.78828          -138.5772        -138.5991 380-149
#> 5          58.73641        58.72393          -138.1552        -138.1575 385-148
#> 6          58.50039        58.51002          -137.8796        -137.8948 389-143
#>   depth_gear_m depth_m bottom_type surface_temperature_c gear_temperature_c
#> 1          118     125           1                  15.9                6.5
#> 2           51      58        <NA>                  14.2                6.9
#> 3          179     186           1                  15.1                6.5
#> 4          115     122           1                  15.4                6.7
#> 5           89      96           1                  15.3                6.5
#> 6          141     147           1                  15.6                6.5
#>   wire_length_m gear accessories      akfin_load_date
#> 1           366  172         129 2025-05-22T00:00:00Z
#> 2           229  172         129 2025-05-22T00:00:00Z
#> 3           503  172         129 2025-05-22T00:00:00Z
#> 4           366  172         129 2025-05-22T00:00:00Z
#> 5           320  172         129 2025-05-22T00:00:00Z
#> 6           457  172         129 2025-05-22T00:00:00Z
```

## Split Fractions

This table shows what proportion of fish are in the eastern or western
GOA. It is downloaded in its entirety.

``` r
split_fractions<-get_gap_split_fractions()
#> Time Elapsed: 0.19 secs
```
