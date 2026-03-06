# Repository overview:

This repository contains the literature review search results, code for analysis, and analysis outputs associated with Hasan et al. Systematic Review of Metrics Linking Benthic Marine Imagery with Essential Biodiversity Variables and Essential Ocean Variables. By following the R scripts in this repository, the analysis can be reproduced based on the literature search results produced for the research article. The goals of this analysis are to:  
   <a name="anchor-goal-1"></a> **(1)** to identify which Essential ocean Variables and Essential Biodiversity Variables have been assessed using benthic imagery; and  
   <a name="anchor-goal-2"></a>  **(2)** to identify associations between metrics and modes of data collection, and to detect best use cases and gaps in benthic imagery data regarding EOVs and EBVs.

# Structure of the EV_Benthic_Imagery_Literature_Review repository:

- EV_lit_review_part1.R is the R script to conduct analysis associated with goal [1]("anchor-goal-1") of the literature review. This script will reference the appropriate literature search results housed in Inputs/Literature_search_results_part1.  
- EV_lit_review_part2.R is the R script to conduct analysis associated with goal (2) of the literature review. This script will reference the appropriate literature search results housed in Inputs/Literature_search_results_part2.  
- EV_Benthic_Imagery_Review.Rproj is the R project wrapper containing the contents of the repository.  
- Inputs/ contains the literature review search results that will be used in the R scripts for analyses. The literature search results are separated into two folders (Literature_search_results_part1 and Literature_search_results_part2) based on literature searches conducted for goal (1) and goal (2) of the article. The subfolders contain multiple .csv files with the full corpus of literature from Scopus or Web of Science addressing specific questions. Please see Hasan et al. for further details on the literature search terms and questions. The Manual_screen subfolder contains the .csv file of literature related to fish that were manually screened for relevance to the article. It also contains a .csv file of the articles that were excluded through the manual screening process.  
- Outputs/ contains output .csv and .txt files produced during analysis. These include tables of intermediate results and cleaned literature search results after further filtering and screening.  
- Figures/ contains the figures that are produced by the R scripts that are used in the Hasan et al. article.  

# Processing steps:

1. Run EV_lit_review_part1.R script
2. Run* EV_lit_review_part2.R script  
**If using this repository as a vignette, manual screening of literature is required during EV_lit_review_part2.R script at the line that states "MANUAL CLEANING AT THIS POINT." The file that is imported after this line is your manually screened corpus of literature.*

# Input file field definitions:

The input files in the folders Literature_search_results_part1 and Literature_search_results_part2 contain the standard export files from Web of Science and Scopus literature searches. The input files in the folder Manual_screening contain: 
- The Input/Literature_search_results_part1 folder contains the standard export files from Web of Science and Scopus literature searches. The fields selected during export contain bibliographic information only.
- The Input/Literature_search_results_part2 folder contains the standard export files from Web of Science and Scopus literature searches. The fields selected during export contain bibliographic information, abstract, and keywords.
- The Input/Manual_screen folder contains the files for goal (2) related to fish after manual screening of literature for inclusion or exclusion in analyses. Further description of methods can be found in the manuscript (Hasan et al.) associated with this repository. The specific ext-matching terms can be found within the script EV_lit_review_part2.R.
  - scopus_wos_fish_manually_cleaned.csv
    - Authors: authors of article  
    - Title: title of article  
    - Source.title: journal of article publication  
    - Abstract: abstract of article  
    - Year: year of publication  
    - DOI: article DOI  
    - DOI_long: article DOI with https:// prefix  
    - Keywords: keywords of article  
    - title_abstract_keywords: merge of title, abstract, and keywords columns for text matching  
    - filter_criteria_match: terms contained in article that match criteria used for automatically filtering articles to exclude (should be NULL, as these articles were retained after filtering)  
    - criteria_match: the ecological target and metric terms found by text matching in the title, abstract, and keywords  
    - criteria1_match: the ecological target terms found by text matching in the title, abstract, and keywords  
    - criteria2_match: the metric terms found by text matching in the title, abstract, and keywords  
    - image_platform: the imagery platform used in the article (lander, remotely operated vehicle (ROV), autonomous underwater vehicle (AUV), animal, diver, submersible, observatory, drop camera, towed vehicle, and trawl)   
    - depth_zone: the depth zone of study in the article (shallow, continental shelf, mesophotic zone, rariphotic zone, continental slope, and abyssal zone)  
    - platform_criteria: terms related to platform found by text matching to aid in manual assignment of imagery platform  
   
  - fish_literature_excluded_manual.csv
    - doi: article DOI  
    - justification: justification for exclusion of article from literature corpus for analysis  
    - ecological_target: ecological target filtered for subset of articles (fish, in this case)  
    - DOI: article DOI with https:// prefix  

# Literature search queries:  
These literature search queries can be entered into Scopus and Web of Science, respectively, to reproduce the literature searches described in Hasan et al. Systematic Review of Metrics Linking Benthic Marine Imagery with Essential Biodiversity Variables and Essential Ocean Variables.
## Part 1:
### Search 1.1:
**Scopus**:  ( TITLE-ABS-KEY ( "marine" OR "ocean" OR "sea" OR "coast*" ) AND TITLE-ABS-KEY ( "seabed" OR "benthic" OR "demersal" ) AND TITLE-ABS-KEY ( "imag*" OR "video*" OR "photo*" OR "footage*" ) ) AND ( LIMIT-TO ( DOCTYPE , "ar" ) )  
**Web of Science**:  ((((AB=( "marine" OR "ocean" OR "sea" OR "coast*") OR TI=( "marine" OR "ocean" OR "sea" OR "coast*") OR KP=( "marine" OR "ocean" OR "sea" OR "coast*"))) AND (AB=("seabed" OR "benthic" OR "demersal") OR TI=("seabed" OR "benthic" OR "demersal") OR KP=("seabed" OR "benthic" OR "demersal"))) AND (AB=( "imag*" OR "video*" OR "photo*" OR "footage*" ) OR TI=( "imag*" OR "video*" OR "photo*" OR "footage*" ) OR KP=( "imag*" OR "video*" OR "photo*" OR "footage*" ))) AND DT=(Article) and Article (Document Types)  
### Search 1.2:
**Scopus**:  TITLE-ABS-KEY ( "essential ocean variable*" OR "essential biodiversity variable*" ) AND ( LIMIT-TO ( DOCTYPE , "ar" ) )  
**Web of Science**:  (AB=("essential ocean variable*" OR "essential biodiversity variable*") OR TI=( "essential ocean variable*" OR "essential biodiversity variable*") OR KP=( "essential ocean variable*" OR "essential biodiversity variable*")) AND DT=(Article) and Article (Document Types)  
### Search 1.3:
**Scopus**:  ( TITLE-ABS-KEY ( "marine" OR "ocean" OR "sea" OR "coast*" ) AND TITLE-ABS-KEY ( "seabed" OR "benthic" OR "demersal" ) AND TITLE-ABS-KEY ( "imag*" OR "video*" OR "photo*" OR "footage*" ) AND TITLE-ABS-KEY ( "essential ocean variable*" OR "essential biodiversity variable*" ) ) AND ( LIMIT-TO ( DOCTYPE , "ar" ) )  
**Web of Science**:  ((((AB=( "marine" OR "ocean" OR "sea" OR "coast*") OR TI=( "marine" OR "ocean" OR "sea" OR "coast*") OR KP=( "marine" OR "ocean" OR "sea" OR "coast*"))) AND (AB=("seabed" OR "benthic" OR "demersal") OR TI=("seabed" OR "benthic" OR "demersal") OR KP=("seabed" OR "benthic" OR "demersal"))) AND (AB=( "imag*" OR "video*" OR "photo*" OR "footage*" ) OR TI=( "imag*" OR "video*" OR "photo*" OR "footage*" ) OR KP=( "imag*" OR "video*" OR "photo*" OR "footage*" ))) AND (AB=("essential ocean variable*" OR "essential biodiversity variable*") OR TI=( "essential ocean variable*" OR "essential biodiversity variable*") OR KP=( "essential ocean variable*" OR "essential biodiversity variable*")) AND DT=(Article) and Article (Document Types)  
      
## Part 2:
**Scopus**:  (TITLE-ABS-KEY("fish*" OR "sea turtle*" OR "marine mammal*" OR "coral*" OR "seagrass*" OR "macroalgae*" OR "kelp*" OR "seaweed*" OR "mangrove*" OR "invertebrate*" OR "shark*" OR "ray*") AND TITLE-ABS-KEY("Cover" OR "Area" OR "Density" OR "Distance" OR "Residence time" OR "Spatial distribution" OR "Extent" OR "Abundance" OR "Presence/absence" OR "Count" OR "Biomass" OR "Occurrence" OR "Frequency" OR "Presence" OR "absence" OR "Number of" OR "Length" OR "Weight" OR "Size" OR "Sex" OR "Phenology" OR "Behavior" OR "Behaviour" OR "Maturity" OR "Diversity" OR "Biodiversity" OR "Distinctiveness" OR "originality" OR "Species richness" OR "Composition" OR "Structure" OR "Condition" OR "Age" OR "Primary production" OR "Canopy" OR "Resilience" OR "Essential habitat" OR "Disturbance") AND TITLE-ABS-KEY("marine" OR "ocean" OR "sea" OR "coast*") AND TITLE-ABS-KEY("seabed" OR "benthic" OR "demersal") AND TITLE-ABS-KEY("imag*" OR "video*" OR "photo*" OR "footage*")) AND ( LIMIT-TO ( DOCTYPE,"ar" ) )  
   
**Web of Science**:  ((((((AB=("fish*" OR "sea turtle*" OR "marine mammal*" OR "coral*" OR "seagrass*" OR "macroalgae*" OR "kelp*" OR "seaweed*" OR "mangrove*" OR "invertebrate*" OR "shark*" OR "ray*") OR TI=("fish*" OR "sea turtle*" OR "marine mammal*" OR "coral*" OR "seagrass*" OR "macroalgae*" OR "kelp*" OR "seaweed*" OR "mangrove*" OR "invertebrate*" OR "shark*" OR "ray*") OR KP=("fish*" OR "sea turtle*" OR "marine mammal*" OR "coral*" OR "seagrass*" OR "macroalgae*" OR "kelp*" OR "seaweed*" OR "mangrove*" OR "invertebrate*" OR "shark*" OR "ray*"))) AND (AB=("cover" OR "area" OR "density" OR "distance" OR "residence time" OR "spatial distribution" OR "extent" OR "abundance" OR "presence/absence" OR "count" OR "biomass" OR "occurrence" OR "frequency" OR "presence" OR "absence" OR "number of" OR "length" OR "weight" OR "size" OR "sex" OR "phenology" OR "behavior" OR "behaviour" OR "maturity" OR "diversity" OR "biodiversity" OR "distinctiveness" OR "originality" OR "species richness" OR "composition" OR "structure" OR "condition" OR "age" OR "primary production" OR "canopy" OR "resilience" OR "essential habitat" OR "disturbance") OR TI=("cover" OR "area" OR "density" OR "distance" OR "residence time" OR "spatial distribution" OR "extent" OR "abundance" OR "presence/absence" OR "count" OR "biomass" OR "occurrence" OR "frequency" OR "presence" OR "absence" OR "number of" OR "length" OR "weight" OR "size" OR "sex" OR "phenology" OR "behavior" OR "behaviour" OR "maturity" OR "diversity" OR "biodiversity" OR "distinctiveness" OR "originality" OR "species richness" OR "composition" OR "structure" OR "condition" OR "age" OR "primary production" OR "canopy" OR "resilience" OR "essential habitat" OR "disturbance") OR KP=("cover" OR "area" OR "density" OR "distance" OR "residence time" OR "spatial distribution" OR "extent" OR "abundance" OR "presence/absence" OR "count" OR "biomass" OR "occurrence" OR "frequency" OR "presence" OR "absence" OR "number of" OR "length" OR "weight" OR "size" OR "sex" OR "phenology" OR "behavior" OR "behaviour" OR "maturity" OR "diversity" OR "biodiversity" OR "distinctiveness" OR "originality" OR "species richness" OR "composition" OR "structure" OR "condition" OR "age" OR "primary production" OR "canopy" OR "resilience" OR "essential habitat" OR "disturbance"))) AND (AB=( "marine" OR "ocean" OR "sea" OR "coast*") OR TI=( "marine" OR "ocean" OR "sea" OR "coast*") OR KP=( "marine" OR "ocean" OR "sea" OR "coast*"))) AND (AB=("seabed" OR "benthic" OR "demersal") OR TI=("seabed" OR "benthic" OR "demersal") OR KP=("seabed" OR "benthic" OR "demersal"))) AND (AB=( "imag*" OR "video*" OR "photo*" OR "footage*" ) OR TI=( "imag*" OR "video*" OR "photo*" OR "footage*" ) OR KP=( "imag*" OR "video*" OR "photo*" OR "footage*" ))) AND DT=(Article)

