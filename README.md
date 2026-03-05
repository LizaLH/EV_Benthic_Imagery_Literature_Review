-Repository overview:

This repository contains the literature review search results, code for analysis, and analysis outputs associated with Hasan et al. Systematic Review of Metrics Linking Benthic Marine Imagery with Essential Biodiversity Variables and Essential Ocean Variables. By following the R scripts in this repository, the analysis can be reproduced based on the literature search results produced for the research article. The goals of this analysis are to (1) to identify which Essential ocean Variables and Essential Biodiversity Variables have been assessed using benthic imagery; and (2) to identify associations between metrics and modes of data collection, and to detect best use cases and gaps in benthic imagery data regarding EOVs and EBVs.

-Structure of the EV_Benthic_Imagery_Literature_Review repository:

(.)EV_lit_review_part1.R is the R script to conduct analysis associated with goal (1) of the literature review. This script will reference the appropriate literature search results housed in Inputs/Literature_search_results_part1. 
(.)EV_lit_review_part2.R is the R script to conduct analysis associated with goal (2) of the literature review. This script will reference the appropriate literature search results housed in Inputs/Literature_search_results_part2.
(.)EV_Benthic_Imagery_Review.Rproj is the R project wrapper containing the contents of the repository.
(.)Inputs/ contains the literature review search results that will be used in the R scripts for analyses. The literature search results are separated into two folders based on literature searches conducted for goal (1) and goal (2) of the article. The subfolders contain multiple .csv files with the full corpus of literature from Scopus or Web of Science addressing specific questions. Please see Hasan et al. for further details on the literature search terms and questions. The Manual_screen subfolder contains the .csv file of literature related to fish that were manually screened for relevance to the article. It also contains a .csv file of the articles that were excluded through the manual screening process.
(.)Outputs/ contains output .csv and .txt files produced during analysis. These include tables of intermediate results and cleaned literature search results after further filtering and screening.
(.)Figures/ contains the figures that are produced by the R scripts that are used in the Hasan et al. article.

-Processing steps
1. Run EV_lit_review_part1.R script
2. Run* EV_lit_review_part2.R script
*If using this repository as a vignette, manual screening of literature is required during EV_lit_review_part2.R script at the line that states "MANUAL CLEANING AT THIS POINT." The file that is imported after this line is your manually screened corpus of literature. 
   
