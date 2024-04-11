
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
taxa<- get_gap_taxonomic_classification()
#> Time Elapsed: 2.96 secs

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
#> 1 2024-03-11T19:47:10Z
```

``` r
# download survey, area, and stratum group tables
survey<-get_gap_survey_design()
#> Time Elapsed: 0.15 secs
area<-get_gap_area()
#> Time Elapsed: 0.27 secs
stratum<-get_gap_stratum_groups()
#> Time Elapsed: 0.29 secs

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
#> [10] depth_min_m          depth_max_m          crs                 
#> [13] akfin_load_date.y   
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
#> Time Elapsed: 0.15 secs

goasr_sizecomp<-get_gap_sizecomp(survey_definition_id = 47,
                area_id = 805,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 0.41 secs

head(goasr_sizecomp)
#>   survey_definition_id year area_id species_code length_mm sex population_count
#> 1                   47 2011     805        30576       930   1            11289
#> 2                   47 2011     805        30576       340   2            18933
#> 3                   47 2011     805        30576       390   2            18933
#> 4                   47 2011     805        30576       420   2            33547
#> 5                   47 2011     805        30576       430   2            48949
#> 6                   47 2011     805        30576       440   2            14614
#>        akfin_load_date
#> 1 2024-03-11T19:47:10Z
#> 2 2024-03-11T19:47:10Z
#> 3 2024-03-11T19:47:10Z
#> 4 2024-03-11T19:47:10Z
#> 5 2024-03-11T19:47:10Z
#> 6 2024-03-11T19:47:10Z

# Gap only provides agecomps at strata and regional, not subregional, levels so I will run this gulf-wide. 
head(get_gap_agecomp(survey_definition_id = 47,
                area_id = 99903,
                species_code = 30576,
                start_year=1990,
                end_year=2023))
#> Time Elapsed: 0.32 secs
#>   survey_definition_id area_id year species_code sex age population_count
#> 1                   47   99903 1996        30576   2  22            37760
#> 2                   47   99903 1996        30576   2  23            60419
#> 3                   47   99903 1996        30576   2  24            79964
#> 4                   47   99903 1996        30576   2  25           111793
#> 5                   47   99903 1996        30576   2  26            84104
#> 6                   47   99903 1996        30576   2  27            90578
#>   length_mm_mean length_mm_sd area_id_footprint      akfin_load_date
#> 1         532.45        26.28               GOA 2024-03-11T19:47:10Z
#> 2         554.75        77.11               GOA 2024-03-11T19:47:10Z
#> 3         513.07        52.43               GOA 2024-03-11T19:47:10Z
#> 4         570.96        83.36               GOA 2024-03-11T19:47:10Z
#> 5         482.10        59.59               GOA 2024-03-11T19:47:10Z
#> 6         519.93        68.68               GOA 2024-03-11T19:47:10Z
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
#> Time Elapsed: 0.2 secs
#> [1] "EBS STANDARD PLUS NW"

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
# Get catch, cpue, length frequency, and specimens at a haul level for Western GOA shortraker

# The catch table only includes records where the species were caught
goasr_catch<-get_gap_catch(survey_definition_id = 47,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 0.54 secs

# The CPUE table includes zeros and thus has many more records
goasr_cpue<-get_gap_cpue(survey_definition_id = 47,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 5.06 secs

# The length table has ~150 million rows as of 2023. 
# Even with filters it may load a large amount of data
# For WGOA shortraker below it pulled 40367 records. 
# Add timing to track how long this takes

goasr_length<-get_gap_length(survey_definition_id = 47,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 3.84 secs


# The specimen table contains length, sex, weight, and age data for individual fish.
goasr_specimen<-get_gap_specimen(survey_definition_id = 47,
                species_code = 30576,
                start_year=1990,
                end_year=2023)
#> Time Elapsed: 3.94 secs

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
#> 1 2024-03-11T19:47:10Z     310                   47 1993
#> 2 2024-03-11T19:47:10Z     310                   47 1993
#> 3 2024-03-11T19:47:10Z     310                   47 1993
#> 4 2024-03-11T19:47:10Z     310                   47 1993
#> 5 2024-03-11T19:47:10Z     310                   47 1993
#> 6 2024-03-11T19:47:10Z     310                   47 1993
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
#> 1 2024-03-11T19:47:10Z
#> 2 2024-03-11T19:47:10Z

myspecies <- c(30050, 30051)

goa_resr_biomass<-lapply(myspecies, FUN = function(x) get_gap_biomass(
  survey_definition_id = 47,
  area_id = 805,
  species_code = x,
  start_year=2007,
  end_year=2023)) %>%
  bind_rows() %>%
  arrange(year)
#> Time Elapsed: 0.17 secs
#> Time Elapsed: 0.15 secs


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
#> 1     0.0000        0.00                0              0 2024-03-11T19:47:10Z
#> 2   596.5102    79692.12           623273    48139437143 2024-03-11T19:47:10Z
#> 3     0.0000        0.00                0              0 2024-03-11T19:47:10Z
#> 4   759.9175   163556.88           534491    49855965270 2024-03-11T19:47:10Z
#> 5     0.0000        0.00                0              0 2024-03-11T19:47:10Z
#> 6   334.7664    27550.86           199147     8494888884 2024-03-11T19:47:10Z

# trying the same thing with the other functions produces the same generic error as when the token is expired.
```

## Cruise and haul tables

Haul and cruise level details are available for download as well.
Download these tables in full and manipulate in R.

``` r
gap_haul<-get_gap_haul()
#> Time Elapsed: 42.44 secs

gap_cruise<-get_gap_cruise()
#> Time Elapsed: 0.85 secs

head(gap_haul)
#>   cruisejoin hauljoin haul haul_type performance      date_time_start
#> 1       -608   -12940   61         3           0 2005-06-05T19:50:18Z
#> 2       -608   -12942   63         3           0 2005-06-06T02:48:28Z
#> 3       -608   -12943   64         3           0 2005-06-06T14:08:09Z
#> 4       -608   -12944   65         3           0 2005-06-06T17:01:43Z
#> 5       -608   -12945   66         3           0 2005-06-06T21:01:37Z
#> 6       -608   -12946   67         3           0 2005-06-06T23:58:31Z
#>   duration_hr distance_fished_km net_width_m net_measured net_height_m stratum
#> 1       0.252              1.416      15.588            1        7.246      13
#> 2       0.253              1.405      15.741            1        7.214      13
#> 3       0.256              1.459      14.046            1        8.350      13
#> 4       0.253              1.419      15.077            1        7.531      13
#> 5       0.254              1.414      16.230            1        6.655     112
#> 6       0.254              1.448      15.517            1        7.044      12
#>   latitude_dd_start latitude_dd_end longitude_dd_start longitude_dd_end station
#> 1          54.90090        54.90018          -158.7672        -158.7455  136-63
#> 2          55.11358        55.11597          -159.4265        -159.4478  128-68
#> 3          54.84635        54.83851          -159.7782        -159.7959  124-61
#> 4          55.00704        55.01904          -159.9825        -159.9768  121-65
#> 5          55.45979        55.46384          -159.6435        -159.6644  125-76
#> 6          55.52143        55.53019          -160.2696        -160.2534  118-77
#>   depth_gear_m depth_m bottom_type surface_temperature_c gear_temperature_c
#> 1           80      87           6                   7.5                4.4
#> 2           77      84           3                   6.8                4.5
#> 3           30      38           4                   6.5                6.1
#> 4           33      41           6                   6.4                5.3
#> 5          148     155           1                   7.6                4.7
#> 6           65      72           6                   6.9                5.3
#>   wire_length_m gear accessories      akfin_load_date
#> 1           320  172         129 2024-03-11T19:47:10Z
#> 2           320  172         129 2024-03-11T19:47:10Z
#> 3           229  172         129 2024-03-11T19:47:10Z
#> 4           229  172         129 2024-03-11T19:47:10Z
#> 5           457  172         129 2024-03-11T19:47:10Z
#> 6           274  172         129 2024-03-11T19:47:10Z
```

## Split Fractions

This table shows what proportion of fish are in the eastern or western
GOA. It is downloaded in its entirety.

``` r
split_fractions<-get_gap_split_fractions()
#> Time Elapsed: 0.29 secs
```
