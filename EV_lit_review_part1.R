# Analysis for Part 1 of the EV Literature Review

library(roadoi)
library(patchwork)
library(openalexR)
library(ggplot2)
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(sf)
library(raster)
library(ggmap)
library(ggplot2)
library(vegan)
library(FactoMineR)
library(factoextra)
library(Polychrome)
library(ggrepel)
library(ggforce)
library(wordcloud)
library(purrr)
library(countrycode)
library(vegan)
library(mvabund)
library(reshape2)
library(boral)
library(rjags)
library(parallel)
library(viridis)
library(scales)  
library(tibble)
library(forcats)
library(Polychrome)
library(confintr)

# Get the path to the R Project's root directory
project_dir <- rprojroot::find_rstudio_root_file()

# Set working directory to the project root
setwd(project_dir)

######################## part 1.1 ########################

# Import literature search results
scopus_1_1 <- read.csv("Inputs/Literature_search_results_part1/scopus_export_Dec 3-2025_CH1_Part1_1.csv")
wos_1_1 <- read.csv("Inputs/Literature_search_results_part1/CH1_Part1_1_WOS_03122025.csv")

#remove duplicates
scopus_1_1 <- scopus_1_1[!duplicated(scopus_1_1$DOI),] 
wos_1_1 <- wos_1_1[!duplicated(wos_1_1$DOI),] 

# check how many scopus papers are included in wos
intersect_1_1 <- wos_1_1[(wos_1_1$DOI %in% scopus_1_1$DOI), ] #1731 papers
excluded_1_1 <- wos_1_1[(!wos_1_1$DOI %in% scopus_1_1$DOI), ] #834 papers

#rename columns to match- keep authors, title, abstract, DOI, year, source
wos_additional <- excluded_1_1 %>%
  dplyr::select(Authors,Article.Title,Source.Title,Publication.Year,DOI)
wos_additional <- rename(wos_additional, Title = Article.Title)
wos_additional <- rename(wos_additional, Year = Publication.Year)
wos_additional <- rename(wos_additional, Source.title = Source.Title)

scopus_select <- scopus_1_1 %>%
  dplyr::select(Authors,Title,Source.title,Year,DOI)

# combine datasets
all_1_1 <- rbind(scopus_select,wos_additional)

######################## part 1.2 ########################

# Import literature search results
scopus_1_2 <- read.csv("Inputs/Literature_search_results_part1/scopus_export_Dec 3-2025_CH1_Part1_2.csv")
wos_1_2 <- read.csv("Inputs/Literature_search_results_part1/CH1_Part1_2_WOS_03122025.csv")

#remove duplicates
scopus_1_2 <- scopus_1_2[!duplicated(scopus_1_2$DOI),] 
wos_1_2 <- wos_1_2[!duplicated(wos_1_2$DOI),] 

# check how many scopus papers are included in wos
intersect_1_2 <- wos_1_2[(wos_1_2$DOI %in% scopus_1_2$DOI), ] #1731 papers
excluded_1_2 <- wos_1_2[(!wos_1_2$DOI %in% scopus_1_2$DOI), ] #834 papers

#rename columns to match- keep authors, title, abstract, DOI, year, source
wos_additional <- excluded_1_2 %>%
  dplyr::select(Authors,Article.Title,Source.Title,Publication.Year,DOI)
wos_additional <- rename(wos_additional, Title = Article.Title)
wos_additional <- rename(wos_additional, Year = Publication.Year)
wos_additional <- rename(wos_additional, Source.title = Source.Title)

scopus_select <- scopus_1_2 %>%
  dplyr::select(Authors,Title,Source.title,Year,DOI)

# combine datasets
all_1_2 <- rbind(scopus_select,wos_additional)

######################## part 1.3 ########################

# Import literature search results
scopus_1_3 <- read.csv("Inputs/Literature_search_results_part1/scopus_export_Dec 3-2025_CH1_Part1_3.csv")
wos_1_3 <- read.csv("Inputs/Literature_search_results_part1/CH1_Part1_3_WOS_03122025.csv")

#remove duplicates
scopus_1_3 <- scopus_1_3[!duplicated(scopus_1_3$DOI),] 
wos_1_3 <- wos_1_3[!duplicated(wos_1_3$DOI),] 

# check how many scopus papers are included in wos
intersect_1_3 <- wos_1_3[(wos_1_3$DOI %in% scopus_1_3$DOI), ] #1731 papers
excluded_1_3 <- wos_1_3[(!wos_1_3$DOI %in% scopus_1_3$DOI), ] #834 papers

#rename columns to match- keep authors, title, abstract, DOI, year, source
wos_additional <- excluded_1_3 %>%
  dplyr::select(Authors,Article.Title,Source.Title,Publication.Year,DOI)
wos_additional <- rename(wos_additional, Title = Article.Title)
wos_additional <- rename(wos_additional, Year = Publication.Year)
wos_additional <- rename(wos_additional, Source.title = Source.Title)

scopus_select <- scopus_1_3 %>%
  dplyr::select(Authors,Title,Source.title,Year,DOI)

# combine datasets
all_1_3 <- rbind(scopus_select,wos_additional)

######################## HISTORGRAM OF PUBLICATIONS BY YEAR ########################

all_1_1_counts <- all_1_1 %>%
  group_by(Year) %>%
  summarise(count = n()) %>%
  filter(Year >= 1950)

pubs_year_hist <- ggplot(all_1_1_counts, aes(x= Year, y= count)) +
  geom_bar(stat = "identity") +
  labs(x = "Publication year", y = "Number of publications") +
  theme_minimal() +
  scale_x_continuous(breaks = seq(1950, 2025, 10))

ggsave("Figures/part1_1_pubs_year.png", plot = pubs_year_hist, width = 8, height = 6, dpi = 300)


max_y <- max(all_1_1_counts$count)

pubs_year_hist <- ggplot(all_1_1_counts, aes(x = Year, y = count)) +
  geom_bar(stat = "identity") +
  labs(x = "Publication year", y = "Number of publications") +
  theme_minimal() +
  scale_x_continuous(breaks = seq(1950, 2025, 10)) +
  
  # draw partial vertical lines
  geom_segment(aes(x = 2013, xend = 2013, y = 0, yend = 500),
               linetype = "dashed", color = "blue") +
  geom_segment(aes(x = 2018, xend = 2018, y = 0, yend = 500),
               linetype = "dashed", color = "red") +
  
  # text labels above the lines
  annotate("text", x = 2013, y = 500 + 50, label = "EBV",
           color = "blue", size = 4, angle = 90) +
  annotate("text", x = 2018, y = 500 + 50, label = "EOV",
           color = "red", size = 4, angle = 90) +
  
  # expand y limits so labels fit
  expand_limits(y = 600) +
  theme(
    axis.text.x = element_text(size = 15),
    axis.text.y = element_text(size = 15),
    axis.title.x = element_text(size = 15),
    axis.title.y = element_text(size = 15),
  )

ggsave("Figures/part1_1_pubs_year.png", plot = pubs_year_hist, width = 8, height = 6, dpi = 300)
