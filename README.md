
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
function. The create_token function accepts a filepath to the textfile
or a keyring package service input. This token is valid for about ten
minutes. If it expires you will get an error asking you to provide a
valid token. You must define the function output as token as in the
example below.

``` r
library(akfingapdata)
library(tidyverse)
library(keyring)

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
```

## Lookup tables

Some functions require survey_definition_id, species_code, area_id,
start_year, and end_year as parameters.  
In order to correctly define these parameters, first download several
lookup tables.

``` r
# download species_code
# The akfin_taxonomic_groups table supersedes the akfin_taxonomic_classification table, these tables have the same structure, except the groups table has a group column designating which group code a species corresponds to for species that have comps calculated at the group level rather than individually. 
taxa<- get_gap_taxonomic_groups()
#> Time Elapsed: 2.13 secs

# find species codes for shortraker rockfish
 taxa %>% filter(grepl("shortraker", tolower(common_name)))
#>   group_code species_code      species_name         common_name id_rank
#> 1      30576        30576 Sebastes borealis shortraker rockfish species
#>   database database_id genus_taxon subfamily_taxon family_taxon
#> 1    WORMS      274777    Sebastes      Sebastinae   Sebastidae
#>   superfamily_taxon infraorder_taxon suborder_taxon order_taxon
#> 1              <NA>             <NA>  Scorpaenoidei Perciformes
#>   superorder_taxon subclass_taxon class_taxon superclass_taxon subphylum_taxon
#> 1             <NA>           <NA>   Teleostei      Actinopteri      Vertebrata
#>   phylum_taxon kingdom_taxon      akfin_load_date
#> 1     Chordata      Animalia 2024-05-20T23:06:20Z
```

``` r
# download survey, area, and stratum group tables
survey<-get_gap_survey_design()
#> Time Elapsed: 0.23 secs
area<-get_gap_area()
#> Time Elapsed: 0.4 secs
stratum<-get_gap_stratum_groups()
#> Time Elapsed: 0.3 secs

#combine spatial lookup tables
stratum<-stratum %>%
  left_join(survey %>%
              # remove year specific information from survey, we only need the region codes
              group_by(survey_definition_id) %>%
              summarize(survey_definition_id=max(survey_definition_id)), 
            by="survey_definition_id") %>%
  left_join(area,  by=c("area_id"="area_id", "survey_definition_id"="survey_definition_id", "design_year"="design_year"))
              # I get a many to one here that gives me two extra rows

# Look for the western Gulf
# 805
stratum %>%
  filter(survey_definition_id=="GOA",
         area_type=="REGULATORY AREA",
         grepl("western", tolower(area_name))
         )
#>  [1] area_id              survey_definition_id design_year         
#>  [4] stratum              akfin_load_date.x    area_type           
#>  [7] area_name            description          area_km2            
#> [10] depth_min_m          depth_max_m          akfin_load_date.y   
#> <0 rows> (or 0-length row.names)
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

goasr_biomass<-get_gap_biomass(survey_definition_id = 47,
                area_id = 805,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 0.35 secs

goasr_sizecomp<-get_gap_sizecomp(survey_definition_id = 47,
                area_id = 805,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 0.9 secs

head(goasr_sizecomp)
#>   survey_definition_id year area_id species_code length_mm sex population_count
#> 1                   47 1990     805        30576       400   2             9586
#> 2                   47 1990     805        30576       530   1            10467
#> 3                   47 1990     805        30576       540   2            10467
#> 4                   47 1990     805        30576       550   2             9586
#> 5                   47 1990     805        30576       580   1            10467
#> 6                   47 1990     805        30576       590   1            20934
#>        akfin_load_date
#> 1 2024-05-20T23:06:20Z
#> 2 2024-05-20T23:06:20Z
#> 3 2024-05-20T23:06:20Z
#> 4 2024-05-20T23:06:20Z
#> 5 2024-05-20T23:06:20Z
#> 6 2024-05-20T23:06:20Z

# Gap only provides agecomps at strata and regional, not subregional, levels so I will run this gulf-wide. 
head(get_gap_agecomp(survey_definition_id = 47,
                area_id = 99903,
                species_code = 30576,
                start_year=1990,
                end_year=2023))
#> Time Elapsed: 0.52 secs
#>   survey_definition_id area_id year species_code sex age population_count
#> 1                   47   99903 1996        30576   2  34           133444
#> 2                   47   99903 1996        30576   2  35            66491
#> 3                   47   99903 1996        30576   2  36           135661
#> 4                   47   99903 1996        30576   2  37            78304
#> 5                   47   99903 1996        30576   2  38            49501
#> 6                   47   99903 1996        30576   2  39            26505
#>   length_mm_mean length_mm_sd area_id_footprint      akfin_load_date
#> 1         610.97        79.10               GOA 2024-05-20T23:06:20Z
#> 2         641.61        63.87               GOA 2024-05-20T23:06:20Z
#> 3         611.88        90.94               GOA 2024-05-20T23:06:20Z
#> 4         597.19        98.82               GOA 2024-05-20T23:06:20Z
#> 5         570.66        60.01               GOA 2024-05-20T23:06:20Z
#> 6         669.14        98.00               GOA 2024-05-20T23:06:20Z
```

Note that Eastern Bering Sea stratum level age compositions are
calculated using “EBS STANDARD” and “EBS STANDARD PLUS NW” girds. The
get_gap_agecomp() function has an optional area_id_footprint argument
that specifies which footprint to use (default is “EBS STANDARD PLUS
NW”).

``` r
unique(get_gap_agecomp(
  survey_definition_id = 98, area_id = 50,species_code = 21370,start_year=1990,end_year=2023,area_id_footprint = "EBS STANDARD PLUS NW")$area_id_footprint)
#> Agecomps calculated using EBS STANDARD PLUS NW area_id_footprint
#> Time Elapsed: 0.27 secs
#> [1] "EBS STANDARD PLUS NW"

unique(get_gap_agecomp(
  survey_definition_id = 98, area_id = 50,species_code = 21370,start_year=1990,end_year=2023,area_id_footprint = "EBS STANDARD")$area_id_footprint)
#> Agecomps calculated using EBS STANDARD area_id_footprint
#> Time Elapsed: 0.29 secs
#> [1] "EBS STANDARD"
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
#> Time Elapsed: 0.52 secs

# The CPUE table includes zeros and thus has many more records
goasr_cpue<-get_gap_cpue(survey_definition_id = 47,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 3.28 secs

# The length table has ~150 million rows as of 2023. 
# Even with filters it may load a large amount of data
# For WGOA shortraker below it pulled 40367 records. 
# Add timing to track how long this takes

goasr_length<-get_gap_length(survey_definition_id = 47,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 2.96 secs


# The specimen table contains length, sex, weight, and age data for individual fish.
goasr_specimen<-get_gap_specimen(survey_definition_id = 47,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 2.42 secs

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
#> 1 2024-05-20T23:06:20Z     310                   47 2005
#> 2 2024-05-20T23:06:20Z     310                   47 2005
#> 3 2024-05-20T23:06:20Z     310                   47 2005
#> 4 2024-05-20T23:06:20Z     310                   47 2005
#> 5 2024-05-20T23:06:20Z     310                   47 2005
#> 6 2024-05-20T23:06:20Z     310                   47 2005
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
#>        akfin_load_date
#> 1 2024-05-20T23:06:20Z
#> 2 2024-05-20T23:06:20Z

myspecies <- c(30050, 30051)

goa_resr_biomass<-lapply(myspecies, FUN = function(x) get_gap_biomass(
  survey_definition_id = 47,
  area_id = 805,
  species_code = x,
  start_year=2007,
  end_year=2023)) %>%
  bind_rows() %>%
  arrange(year)
#> Time Elapsed: 0.23 secs
#> Time Elapsed: 0.22 secs


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
#> 1     0.0000        0.00                0              0 2024-05-20T23:06:20Z
#> 2   596.5102    79692.12           623273    48139437143 2024-05-20T23:06:20Z
#> 3     0.0000        0.00                0              0 2024-05-20T23:06:20Z
#> 4   759.9175   163556.88           534491    49855965270 2024-05-20T23:06:20Z
#> 5     0.0000        0.00                0              0 2024-05-20T23:06:20Z
#> 6   334.7664    27550.86           199147     8494888884 2024-05-20T23:06:20Z

# trying the same thing with the other functions produces the same generic error as when the token is expired.
```

## Cruise and haul tables

Haul and cruise level details are available for download as well.
Download these tables in full and manipulate in R.

``` r
gap_haul<-get_gap_haul()
#> Time Elapsed: 22.99 secs

gap_cruise<-get_gap_cruise()
#> Time Elapsed: 0.98 secs

head(gap_haul)
#>   cruisejoin hauljoin haul haul_type performance      date_time_start
#> 1       -608   -13118  239         3           0 2005-07-14T23:12:29Z
#> 2       -608   -13119  240         3           0 2005-07-15T01:10:53Z
#> 3       -608   -13120  241         3           0 2005-07-19T15:23:00Z
#> 4       -608   -13121  242         3           0 2005-07-19T18:00:54Z
#> 5       -608   -13122  243         3           0 2005-07-19T22:12:18Z
#> 6       -608   -13123  244         3           0 2005-07-20T00:37:00Z
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
#> 1           366  172         129 2024-05-20T23:06:20Z
#> 2           229  172         129 2024-05-20T23:06:20Z
#> 3           503  172         129 2024-05-20T23:06:20Z
#> 4           366  172         129 2024-05-20T23:06:20Z
#> 5           320  172         129 2024-05-20T23:06:20Z
#> 6           457  172         129 2024-05-20T23:06:20Z
```

## Split Fractions

This table shows what proportion of fish are in the eastern or western
GOA. It is downloaded in its entirety.

``` r
split_fractions<-get_gap_split_fractions()
#> Time Elapsed: 0.32 secs
```
