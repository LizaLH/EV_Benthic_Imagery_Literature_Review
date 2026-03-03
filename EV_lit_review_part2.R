# Analysis for Part 2 of the EV Literature Review

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
library(tibble)
library(knitr)
library(gt)

# Get the path to the R Project's root directory
project_dir <- rprojroot::find_rstudio_root_file()

# Set working directory to the project root
setwd(project_dir)

# ################## Import literature search results ##################
scopus_V26 <- read.csv("Inputs/Literature_search_results_part2/scopus_export_Nov 13-2025_V26.csv") #2713
wos_V26 <- read.csv("Inputs/Literature_search_results_part2/web_of_science_Nov 13-2025_V26.csv") #2665

# number of duplicates per database
scopus_dup <- scopus_V26[duplicated(scopus_V26$DOI),] #111 rows removed
wos_dup <- wos_V26[duplicated(wos_V26$DOI),] #100 rows removed
dup_int <- wos_dup[(wos_dup$DOI %in% scopus_dup$DOI), ] 

#remove duplicates
scopus_V26 <- scopus_V26[!duplicated(scopus_V26$DOI),] #111 rows removed
wos_V26 <- wos_V26[!duplicated(wos_V26$DOI),] #100 rows removed

# check how many scopus papers are included in openalex
papers_intersect1 <- scopus_V26[(scopus_V26$DOI %in% wos_V26$DOI), ] #1731 papers
papers_excluded1 <- scopus_V26[(!scopus_V26$DOI %in% wos_V26$DOI), ] #871 papers

papers_intersect2 <- wos_V26[(wos_V26$DOI %in% scopus_V26$DOI), ] #1731 papers
papers_excluded2 <- wos_V26[(!wos_V26$DOI %in% scopus_V26$DOI), ] #834 papers

#rename columns to match- keep authors, title, abstract, DOI, year, source
wos_additional <- papers_excluded2 %>%
  dplyr::select(Authors,Article.Title,Source.Title,Abstract,Publication.Year,DOI,Keywords.Plus)
wos_additional <- rename(wos_additional, Title = Article.Title)
wos_additional <- rename(wos_additional, Year = Publication.Year)
wos_additional <- rename(wos_additional, Source.title = Source.Title)
wos_additional <- rename(wos_additional, Keywords = Keywords.Plus)

scopus_select <- scopus_V26 %>%
  dplyr::select(Authors,Title,Source.title,Abstract,Year,DOI,Author.Keywords,Index.Keywords)
scopus_select$Keywords <- paste(scopus_select$Author.Keywords, scopus_select$Index.Keywords, sep=" ")
scopus_select <- scopus_select %>%
  dplyr::select(Authors,Title,Source.title,Abstract,Year,DOI,Keywords)

# combine datasets
lit_all <- rbind(scopus_select,wos_additional)

# Combine title, abstract, and keywords into one column for text matching
lit_all$title_abstract_keywords <- paste(lit_all$Title, lit_all$Abstract, lit_all$Keywords, sep=" ")

#change encoding of text
lit_all$title_abstract_keywords <- iconv(lit_all$title_abstract_keywords, from = "", to = "UTF-8", sub = " ")

# Function to check which terms are found in the paper
check_criteria <- function(paper_text, criteria) {
  lapply(criteria, function(terms) {
    matched_terms <- terms[sapply(terms, function(term) {
      # define special handling for 'area'
      if (tolower(term) == "area") {
        # exclude "marine protected area"
        pattern <- "(?<!marine protected )\\barea\\b"
      } else {
        # default: allow suffixes like 'fishes', 'rays'
        pattern <- paste0("\\b", term, "\\w*\\b")
      }
      
      grepl(pattern, paper_text, ignore.case = TRUE, perl = TRUE)
    })]
    if (length(matched_terms) > 0) matched_terms else NULL
  })
}

# Screen full set of candidate literature by omission of papers by specific words contained
# make copy of original dataset
lit_all_og <- lit_all

filter_criteria <- list(c("microscope", "aerial", "freshwater", "DIDSON", "hyperspectral", "microscopy", "spectroscopy", "photosynthesis", "photosynthetic", "photoautotroph", "phototroph", "photophore", "photoreceptor", "phototaxis", "photodegradation", "photo-degradation", "photoperiod", "photochemical", "paleo", "x-ray", "satellite imaging", "satellite imagery", "acoustic imaging", "acoustic imagery"))

lit_all$filter_criteria_match <- lapply(lit_all$title_abstract_keywords, check_criteria, criteria = filter_criteria)

# keep only rows where condition is TRUE
lit_all_filter_removed <- lit_all %>%
  filter(!grepl("NULL", filter_criteria_match, ignore.case = TRUE))

# turn list columns into strings
lit_all_filter_removed[] <- lapply(
  lit_all_filter_removed,
  function(x) if (is.list(x)) sapply(x, toString) else x
)

# export list of DOIs for papers removed by text-match filtering
write.csv(lit_all_filter_removed, file = "Outputs/lit_all_filter_removed.csv")

#remove papers from full list of literature
lit_all <- lit_all[!(lit_all$DOI %in% lit_all_filter_removed$DOI), ] #1322 papers removed

# List of search criteria (one list per line)
criteria <- list(c("Fish", "Shark", "Ray", "Sea turtle", "Marine mammal", "Coral", "Seagrass", "Kelp", "Seaweed", "Macroalgae", "Mangrove", "Invertebrate"), 
                 c("Cover", "Area", "Density", "Distance", "Residence time", "Spatial distribution", "Extent", "Abundance", "Presence/absence", "Count", "Biomass", "Occurrence",
                   "Frequency", "Presence", "Absence", "Number of", "Length", "Weight", "Size", "Sex", "Phenology",  "Behavior", "Behaviour", "Maturity", "Diversity",  "Biodiversity",
                   "Distinctiveness",  "Originality", "Species richness",  "Composition", "Structure", "Condition", "Age", "Primary production", "Canopy", "Resilience", 
                   "Essential habitat", "Disturbance"))

# Check Which Terms Are Satisfied

# Apply to each paper 
lit_all$criteria_match <- lapply(lit_all$title_abstract_keywords, check_criteria, criteria = criteria)
lit_all$criteria1_match <- lapply(lit_all$title_abstract_keywords, check_criteria, criteria = criteria[1])
lit_all$criteria2_match <- lapply(lit_all$title_abstract_keywords, check_criteria, criteria = criteria[2])

# Summarize Results

summary_df <- do.call(rbind, lapply(seq_along(lit_all$title_abstract_keywords), function(i) {
  data.frame(
    paper_id = lit_all$DOI[i],
    matched_terms = sapply(lit_all$criteria_match[[i]], function(x) if (is.null(x)) NA else paste(x, collapse = ", ")),
    stringsAsFactors = FALSE
  )
}))

# Count Papers for Each Term:

all_matches <- unlist(lit_all$criteria_match)
criteria1_matches <- unlist(lit_all$criteria1_match)
criteria2_matches <- unlist(lit_all$criteria2_match)
term_counts <- table(all_matches)
term_counts1 <- table(criteria1_matches)
term_counts2 <- table(criteria2_matches)
print(term_counts)
write.table(term_counts, file = "Outputs/raw_term_counts_scopus_wos.txt", sep = "\t", row.names = FALSE, col.names = TRUE)

#Word cloud based on term frequency
set.seed(123)
wordcloud <- wordcloud(names(term_counts), term_counts, max.words = 100, colors = brewer.pal(8, "Dark2"))

#bar chart based on target species/ecosystem frequency
term_counts1_df <- as.data.frame(term_counts1)
term_counts2_df <- as.data.frame(term_counts2)

#combine similar terms to display their cumulative frequency
behavior_row <- data.frame(criteria2_matches = "Behavior", Freq = (term_counts2_df[5,2]+term_counts2_df[6,2]))
occurrence_row <- data.frame(criteria2_matches = "Occurrence", Freq = (term_counts2_df[1,2]+term_counts2_df[25,2]+term_counts2_df[28,2]+term_counts2_df[29,2]))
abundance_row <- data.frame(criteria2_matches = "Abundance", Freq = (term_counts2_df[2,2]+term_counts2_df[12,2]+term_counts2_df[21,2]+term_counts2_df[24,2]))
diversity_row <- data.frame(criteria2_matches = "Diversity", Freq = (term_counts2_df[7,2]+term_counts2_df[16,2]+term_counts2_df[18,2]+term_counts2_df[26,2]+term_counts2_df[36,2]))
area_row <- data.frame(criteria2_matches = "Area", Freq = (term_counts2_df[4,2]+term_counts2_df[20,2]))
composition_row <- data.frame(criteria2_matches = "Composition", Freq = (term_counts2_df[10,2]+term_counts2_df[37,2]))
biomass_row <- data.frame(criteria2_matches = "Biomass", Freq = (term_counts2_df[8,2]+term_counts2_df[38,2]))
length_row <- data.frame(criteria2_matches = "Length", Freq = (term_counts2_df[22,2]+term_counts2_df[34,2]))

#add rows to dataframe
term_counts2_df <- rbind(term_counts2_df, behavior_row)
term_counts2_df <- rbind(term_counts2_df, occurrence_row)
term_counts2_df <- rbind(term_counts2_df, abundance_row)
term_counts2_df <- rbind(term_counts2_df, diversity_row)
term_counts2_df <- rbind(term_counts2_df, area_row)
term_counts2_df <- rbind(term_counts2_df, composition_row)
term_counts2_df <- rbind(term_counts2_df, biomass_row)
term_counts2_df <- rbind(term_counts2_df, length_row)

#remove rows that were combined
term_counts2_df <- term_counts2_df[-c(5,6,1,25,28,29,2,12,21,24,7,16,18,26,36,4,20,10,37,8,38,22,34),]

criteria1_bar <- ggplot(term_counts1_df, aes(x= reorder(criteria1_matches, Freq), y= Freq)) +
  geom_bar(stat = "identity") +
  labs(x = "Ecological target", y = "Frequency") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, size = 10), 
    axis.text.y = element_text(size = 10), 
    axis.title.x = element_text(size = 15),
    axis.title.y = element_text(size = 15),
  )

criteria2_bar <- ggplot(term_counts2_df, aes(x= reorder(criteria2_matches, Freq), y= Freq)) +
  geom_bar(stat = "identity") +
  labs(x = "Metric", y = NULL) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, size = 10), 
    axis.text.y = element_text(size = 10), 
    axis.title.x = element_text(size = 15),
    axis.title.y = element_text(size = 15),
  )

# barplots together
criteria_barplots <- (criteria1_bar | criteria2_bar)

ggsave("Figures/criteria_barplots.png", plot = criteria_barplots, width = 8, height = 8, dpi = 300)

################################################################################

# ############### Part 2.2: FISH LITERATURE ###############

# ############### PREPARE DATA FOR MANUAL SCREENING ###############

# subset all papers that include fish, shark, or ray AND contain at least one metric
scopus_wos_fish_V26 <- lit_all %>%
  filter(grepl("fish|shark|ray", criteria_match, ignore.case = TRUE)) %>%
  filter(!grepl("NULL", criteria2_match, ignore.case = TRUE)) #1432 papers

# Assign depth zone to aid with manual assignment
detect_depth_zone <- function(text) {
  text <- tolower(text)
  
  if (grepl("\\b(abyssal plain|abyssal|abyss|hadal|trench|trough|>\\s*3000\\s*m)\\b", text)) return("abyssal")
  if (grepl("\\b(rariphotic|150\\s*-\\s*300\\s*m)\\b", text)) return("rariphotic")
  if (grepl("\\b(mesophotic|twilight zone|40\\s*-\\s*150\\s*m)\\b", text)) return("mesophotic")
  if (grepl("\\b(continental slope|bathyal|slope|300\\s*-\\s*3000\\s*m)\\b", text)) return("slope")
  if (grepl("\\b(continental shelf|shelf|40\\s*-\\s*300\\s*m)\\b", text)) return("shelf")
  if (grepl("\\b(shallow|nearshore|intertidal|altiphotic|0\\s*-\\s*40\\s*m)\\b", text)) return("shallow")
  
  # If specific depth mentioned
  matches <- regmatches(text, gregexpr("\\b\\d{1,4}\\s*(m|meters|metres)\\b", text))
  if (length(matches[[1]]) > 0) {
    depths <- as.numeric(gsub("[^0-9]", "", unlist(matches)))
    max_depth <- max(depths, na.rm = TRUE)
    if (max_depth <= 40) return("shallow")
    if (max_depth <= 150) return("mesophotic")
    if (max_depth <= 300) return("rariphotic")
    if (max_depth <= 3000) return("slope")
    return("abyssal")
  }
  
  return(NA)
}

# run function on dataframe
scopus_wos_fish_V26$depth_zone <- sapply(scopus_wos_fish_V26$title_abstract_keywords, detect_depth_zone) 

#summarize by depth zone and NAs
depth_counts <- scopus_wos_fish_V26 %>%
  group_by(depth_zone) %>%
  summarise(n = n(), .groups = "drop")

# extract platform to aid with manual assignment
platform_criteria <- list(c("ROV", "drop camera", "AUV", "STAVIRO", "BRUV", "towed vehicle", "TOWV", "DOV", 
                            "towed camera",  "photogrammetry", "marine imagery", "underwater image", 
                            "underwater video", "stereo video", "GoPro",  "glider", "UUV", "diver", 
                            "baited stereo-video", "baited underwater video", "time lapse camera", "baited camera" , 
                            "baited video", "stereo image", "remote video", "underwater stereo camera", "fixed camera" ,
                            "underwater stereo camera","underwater image", "seafloor camera", "diver", 
                            "diver-operated video" , "diver-operated stereo-video", "diver-operated video transect", 
                            "stereo-video", "diver-operated stereo video", "diver operated stereo video", 
                            "diver-operated video", "diver-operated video transect", "stereo-ROV", 
                            "semi-autonomous underwater vehicle", "remotely operated vehicle", "RUV", 
                            "remote underwater video", "baited lander" , "stereo-video lander", "photosampling", 
                            "video transect", "seal-mounted camera", "video sled" , "camera sled" , "structure from motion"))

scopus_wos_fish_V26$platform_criteria <- lapply(scopus_wos_fish_V26$title_abstract_keywords, check_criteria, criteria = platform_criteria)

#export document of papers to be cleaned for depth and manual assignment of iFDO platform
scopus_wos_fish_V26[] <- lapply(
  scopus_wos_fish_V26,
  function(x) if (is.list(x)) sapply(x, toString) else x
)

# export file for manual cleaning
write.csv(scopus_wos_fish_V26, "Outputs/scopus_wos_fish_manual_cleaning.csv")

################################################################################
# ************** MANUAL CLEANING AT THIS POINT ********************
################################################################################

# import the cleaned fish papers
fish_clean <- read.csv("Inputs/scopus_wos_fish_manually_cleaned.csv") 

#remove duplicates
fish_clean <- fish_clean[!duplicated(fish_clean$DOI),] #10 rows removed

# import the excluded papers
fish_excluded <- read.csv("Inputs/fish_literature_excluded_manual.csv")

# REMOVE THE HTTPS PREFIX FROM DOI
fish_excluded$DOI <- substring(fish_excluded$doi, 17)

length(unique(fish_clean$DOI))
length(unique(fish_excluded$DOI))

# transform data from long to wide
# create binary columns for the metrics
criteria2_words <- c("Cover", "Area", "Density", "Distance", "Residence.time", "Spatial.distribution",
                     "Abundance", "Biomass", "Occurrence", "Phenology",
                     "Length", "Sex", "Behavior", "Maturity", "Age",
                     "Diversity", "Composition", "Canopy",
                     "Resilience", "Primary.production", "Essential.habitat", "Disturbance", "Condition",
                     "Extent", "Presence/absence", "Count", "Frequency", "Presence", "Absence", "Number of",
                     "Weight", "Size", "Behaviour", "Biodiversity", "Distinctiveness",  "Originality", 
                     "Species richness", "Structure")


for (w in criteria2_words) {
  fish_clean[[w]] <- as.integer(str_detect(fish_clean$criteria2_match,
                                           regex(paste0("\\b", w, "\\b"))))
}

# combine columns with terms that group together and remove extra columns

fish_clean <- fish_clean %>%
  mutate(
    Area = as.integer(if_any(c(Area, Extent), ~ . == 1)),
    
    Abundance = as.integer(
      if_any(c(Abundance, Count, Frequency, `Number of`), ~ . == 1)
    ),
    
    Occurrence = as.integer(
      if_any(c(Occurrence, `Presence/absence`, Presence, Absence), ~ . == 1)
    ),
    
    Biomass = as.integer(if_any(c(Biomass, Weight), ~ . == 1)),
    
    Behavior = as.integer(if_any(c(Behavior, Behaviour), ~ . == 1)),
    
    Diversity = as.integer(
      if_any(c(
        Diversity, Biodiversity, Distinctiveness,
        Originality, `Species richness`
      ), ~ . == 1)
    ),
    
    Composition = as.integer(if_any(c(Composition, Structure), ~ . == 1)),
    Length = as.integer(if_any(c(Length, Size), ~ . == 1))
  ) %>%
  dplyr::select(
    -Extent,
    -Count, -Frequency, -`Number of`,
    -`Presence/absence`, -Presence, -Absence,
    -Weight,
    -Behaviour,
    -Biodiversity, -Distinctiveness, -Originality, -`Species richness`,
    -Structure, -Size
  )


write.csv(fish_clean, file = "Outputs/fish_clean_metrics.csv")

# ############### BORAL ANALYSIS ###############

y <- fish_clean[,c(18:40)]

y2 <- y[, -c(5,10,14)] # remove maturity, residence time, and phenology

n <- nrow(y2)
p <- ncol(y2)

set.seed(123)

boral_fit2 <- boral(y2, family = "binomial",
                    lv.control = list(num.lv = 2)) #latent variables are needed for ordination

boral_fit2$lv.coefs.median

write.csv(boral_fit2$lv.coefs.median, file = "Outputs/boral2_lvcoefsmedian.csv")

plot.boral(boral_fit2)
summary(boral_fit2)
lvsplot(boral_fit2)

# clustering on the latent variables
# Extract species loadings (lambda_j)
species_loadings <- boral_fit2$lv.median  # n_species x 2 matrix

dist_matrix <- dist(species_loadings, method = "euclidean")
hc <- hclust(dist_matrix, method = "ward.D2") #Ward’s method (ward.D2) is commonly used because it tends to produce compact, balanced clusters.
plot(hc, labels = rownames(species_loadings), main = "Hierarchical Clustering of Metrics in Articles")

clusters <- cutree(hc, k = 3)  # cut into 3 clusters
clusters

articles_df <- data.frame(
  LV1 = species_loadings[,1],
  LV2 = species_loadings[,2],
  Cluster = as.factor(clusters),
  Species = rownames(species_loadings)
)

cluster_ord_boral <- ggplot(articles_df, aes(x = LV1, y = LV2, color = Cluster, label = Species)) +
  geom_point(size = 3) +
  geom_text(vjust = -0.5, hjust = 0.5, size = 3) +
  theme_minimal() +
  labs(title = "Articles in Boral Latent Space") +
  theme(
    legend.position = "bottom", # Move legend to the bottom
    legend.justification = "center" # Center the legend
  )


# with custom colors for clusters
cluster_ord_boral <- ggplot(articles_df, aes(x = LV1, y = LV2, color = Cluster, label = Species)) +
  geom_point(size = 2) +
  theme_minimal() +
  scale_color_manual(values = c(
    "1" = "#0072B2",
    "2" = "#D55E00",
    "3" = "#009E73"
  )) +
  theme(
    legend.position = "bottom",
    legend.justification = "center"
  )

# Extract species LV loadings (drivers)
metrics_df <- as.data.frame(boral_fit2$lv.coefs.median)
metrics_df$Species <- rownames(metrics_df)

# Text-only plot of drivers
# edit labels to substitute . or _ with a space
metrics_df$Species <- gsub("\\.", " ", metrics_df$Species)

drivers_text <- ggplot(metrics_df, aes(x = theta1, y = theta2, label = Species)) +
  geom_text(size = 3) +
  theme_minimal() +
  coord_equal() +
  labs(title = "Measurements Latent Space", x = "LV1", y = "LV2")

# Example with vector lines (arrows) and jittered text
drivers_text <- ggplot(metrics_df, aes(x = theta1, y = theta2, label = Species)) +
  # Add arrows (vectors) from origin (0,0) to points, assuming theta1/theta2 represent vector coords
  geom_segment(aes(x = 0, y = 0, xend = theta1, yend = theta2),
               #arrow = arrow(length = unit(0.2, "cm")),
               color = "black", alpha = 0.5) +
  # Add jittered text to avoid overlap
  geom_text(position = position_jitter(width = 0.1, height = 0.2), size = 4) +
  theme_minimal() +
  coord_equal() +
  xlim(-1.75, 1) +
  labs(x = "LV1", y = "LV2")

# Plot ordination points and text side by side
boral_ord_AB1 <- cluster_ord_boral / drivers_text
ggsave("Figures/boral_ord_AB1.png", plot = boral_ord_AB1, width = 8, height = 10, dpi = 300)

# summarize the most frequent metrics in each cluster
fish_clean_clusters <- cbind(fish_clean[,-c(22,27,31)], clusters)

# produce cluster-level latent scores as quantitative descriptors of metrics characterizing each cluster
cluster_lv <- aggregate(
  boral_fit2$lv.median,
  by = list(cluster = clusters),
  FUN = median
)

eta <- boral_fit2$lv.coefs.median[, "beta0"] +
  boral_fit2$lv.coefs.median[, c("theta1", "theta2")] %*%
  t(cluster_lv[, -1])

p <- plogis(eta) #transforms values back into probabilities with inverse-logit

# ############### METRIC FREQUENCY BY CLUSTER ###############
# Reshape to long format
fish_clean_clusters_long <- fish_clean_clusters %>%
  dplyr::select(c(18:37), cluster = 38) %>% 
  pivot_longer(cols = 1:20, 
               names_to = "variable", 
               values_to = "value")

#count the number of papers in each cluster
cluster_counts_boral <- fish_clean_clusters %>%
  group_by(clusters) %>%
  summarise(count = n())

# Summarize raw counts of 1s
metric_cluster_freq <- fish_clean_clusters_long %>%
  group_by(cluster, variable) %>%
  summarise(count_ones = sum(value == 1), .groups = "drop")

metric_cluster_freq_wide <- metric_cluster_freq %>%
  pivot_wider(
    names_from = cluster,
    values_from = count_ones,
    values_fill = 0   # fills missing cases with 0
  )

df_plot <- metric_cluster_freq_wide %>%
  pivot_longer(
    cols = -variable,
    names_to = "cluster",
    values_to = "count"
  )

# make clusters ordered nicely
df_plot$cluster <- factor(df_plot$cluster, levels = sort(unique(df_plot$cluster)))

# edit labels to substitute . or _ with a space
df_plot$variable <- gsub("\\.", " ", df_plot$variable) 

# plot as a "heatmap table" with text labels
# custom order
custom_order <- c("Cover", "Area", "Density", "Distance", "Spatial distribution",
                  "Abundance", "Biomass", "Occurrence",
                  "Length", "Sex", "Behavior", "Age",
                  "Diversity", "Composition", "Canopy",
                  "Resilience", "Primary production", "Essential habitat", "Disturbance", "Condition")
# assign metrics to groups
group_map <- data.frame(
  variable = custom_order,
  group = c("Spatial","Spatial","Spatial","Spatial","Spatial",
            "Numeration", "Numeration", "Numeration",
            "Biology", "Biology", "Biology", "Biology",
            "Composition", "Composition", "Composition",
            "System", "System", "System", "System", "System")
)

# Merge group info into df_plot and apply order
df_plot <- df_plot %>%
  left_join(group_map, by = "variable") %>%
  mutate(
    variable = factor(variable, levels = custom_order)
  )

# plot metric frequency heatmap
metric_cluster_freq_table_boral <- ggplot(df_plot, aes(x = cluster, y = variable)) +
  geom_tile(aes(fill = group, alpha = count), color = "white") +
  geom_text(aes(label = count), color = "black", size = 4) +
  scale_alpha(range = c(0.2, 1.5)) +
  scale_fill_brewer(palette = "Set1", name = "Metric group") +
  scale_y_discrete(limits = rev) +
  scale_x_discrete(
    labels = c(
      "1" = "1\nComposition\nand system",
      "2" = "2\nSpatial and\nnumeration",
      "3" = "3\nBiology"
    )
  ) +
  labs(
    x = "Cluster", 
    y = "Metric"
  ) +
  guides(alpha = "none") +
  theme_minimal(base_size = 15) +
  theme(
    axis.text.x = element_text(angle = 0, vjust = 0.5, hjust = 0.5),
    panel.grid = element_blank(),
    legend.position = "right"
  )

# Save high-resolution image
ggsave(metric_cluster_freq_table_boral, file = "Figures/metric_cluster_freq_table_boral.png", width = 8, height = 10, dpi = 300)


# Plot metric frequency as barplot
metric_freq_cluster_barplot <- ggplot(metric_cluster_freq, aes(x = variable, y = count_ones)) +
  geom_col(fill = "steelblue") +
  facet_wrap(~ cluster) +
  coord_flip() +  # flip axes for readability
  labs(x = "Measurement", y = "Frequency",
       title = "Frequency of measurements by cluster") +
  theme_minimal()

# ############### METRIC FREQUENCY BY DEPTH AND PLATFORM ###############

# transform data for barplot
fish_clean_long <- fish_clean %>%
  dplyr::select(18:40, depth_zone = 16, image_platform = 15) %>% 
  pivot_longer(cols = 1:23, 
               names_to = "variable", 
               values_to = "value") %>%
  filter(value == 1)

metric_depth_counts <- fish_clean_long %>%
  group_by(depth_zone, variable) %>%
  summarise(Frequency = n(), .groups = "drop") %>%
  mutate(depth_zone = factor(depth_zone, levels = c("shallow", "shelf", "mesophotic", "rariphotic", "slope", "abyssal")))

metric_platform_counts <- fish_clean_long %>%
  group_by(image_platform, variable) %>%
  summarise(Frequency = n(), .groups = "drop")

# custom palette
palette24 <- createPalette(23, c("#1B9E77", "#D95F02", "#7570B3"))
swatch(palette24)  # visualize palette
names(palette24) <- levels(metric_depth_counts$variable)

# edit labels to substitute . or _ with a space
metric_depth_counts$variable <- gsub("\\.", " ", metric_depth_counts$variable)

stackbar_metric_depth <- ggplot(metric_depth_counts, aes(x = depth_zone, y = Frequency, fill = variable)) +
  geom_bar(stat = "identity") +
  labs(
    x = "Depth Zone",
    y = "Frequency",
    fill = "Metric"
  ) +
  theme_minimal(base_size = 14) +
  scale_fill_manual(values = palette24) +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 20), # larger x-axis labels
    axis.text.y = element_text(size = 20), 
    legend.text = element_text(size = 20),
    legend.title = element_text(size = 20),
    axis.title.x = element_text(size = 20),
    axis.title.y = element_text(size = 20),
  )

# edit labels to substitute . or _ with a space
metric_platform_counts$variable <- gsub("\\.", " ", metric_platform_counts$variable)
metric_platform_counts$image_platform <- gsub("\\_", " ", metric_platform_counts$image_platform)

stackbar_metric_platform <- ggplot(metric_platform_counts, aes(x = image_platform, y = Frequency, fill = variable)) +
  geom_bar(stat = "identity") +
  labs(
    x = "Platform",
    y = NULL,   # removes y-axis label
    fill = "Metric"
  ) +
  theme_minimal(base_size = 14) +
  scale_fill_manual(values = palette24) +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 20), 
    axis.text.y = element_text(size = 20), 
    legend.text = element_text(size = 20),
    legend.title = element_text(size = 20),
    axis.title.x = element_text(size = 20),
    axis.title.y = element_text(size = 20),
  )

stackbar_depth_platform <- (stackbar_metric_depth | stackbar_metric_platform) +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom") &
  guides(fill = guide_legend(nrow = 5))

subdued_bold_minblue_palette <- c(
  "#C44E52", # bold subdued red
  "#55A868", # green
  "#CCB974", # gold
  "#8172B3", # purple
  "#A1578C", # magenta
  "#937860", # brown
  "#8C8C8C", # grey
  "#4E9DA6", # teal (leans green, not blue-heavy)
  "#B07030", # copper
  "#7A9A3B"  # olive-green
)

# edit labels to substitute . or _ with a space
fish_clean_long$image_platform <- gsub("\\_", " ", fish_clean_long$image_platform)

depth_platform_barplot <- ggplot(
  fish_clean_long,
  aes(x = factor(depth_zone,
                 levels = c("shallow", "shelf", "mesophotic", "rariphotic", "slope", "abyssal")),
      fill = image_platform)
) +
  geom_bar(position = "stack") +
  scale_fill_manual(values = subdued_bold_minblue_palette) +
  labs(
    x = "Depth zone",
    y = "Frequency",
    fill = "Platform"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(size = 20),
    axis.text.y = element_text(size = 20),
    axis.title.x = element_text(size = 20),
    axis.title.y = element_text(size = 20),
    legend.text = element_text(size = 20),
    legend.title = element_text(size = 20)
  )

# ############### CHIQU TESTS OF PLATFORM AND DEPTH BETWEEN CLUSTERS ###############

# edit labels to replace _ with a space
fish_clean_clusters$image_platform <- gsub("\\_", " ", fish_clean_clusters$image_platform)

# depth zone by platform
tab_ip_dz <- table(fish_clean_clusters$image_platform, fish_clean_clusters$depth_zone)

#chi_squared test
chi_ip_dz <- chisq.test(tab_ip_dz, simulate.p.value = TRUE, B = 10000)

# cramer's v test for association between categories (0-1)
cramersv_ip_dz <- cramersv(chi_ip_dz)

# platform by cluster
tab_ip_clust <- table(fish_clean_clusters$image_platform, fish_clean_clusters$clusters)
chi_ip_clust <- chisq.test(tab_ip_clust, simulate.p.value = TRUE, B = 10000)
cramersv_ip_clust <- cramersv(chi_ip_clust)

# depth zone by cluster
tab_dz_clust <- table(fish_clean_clusters$depth_zone, fish_clean_clusters$clusters)
chi_dz_clust <- chisq.test(tab_dz_value, simulate.p.value = TRUE, B = 10000)
cramersv_ds_clust <- cramersv(chi_dz_clust)

# ############### HEATMAPS OF CHISQ RESULTS USING FREQUENCY ###############

# Function to compute cellwise significance and build heatmap
make_heatmap <- function(tab, chi_obj, title = "", 
                         xlab = "", ylab = "") {
  
  # Standardized residuals
  std_res <- chi_obj$stdres
  
  # Two-sided p-values
  raw_p <- 2 * pnorm(abs(std_res), lower.tail = FALSE)
  
  # Bonferroni-adjusted p-values
  adj_p <- p.adjust(as.vector(raw_p), method = "bonferroni")
  adj_p_mat <- matrix(adj_p, nrow = nrow(tab), ncol = ncol(tab),
                      dimnames = dimnames(tab))
  
  # Significance stars
  sig_stars <- ifelse(adj_p_mat < 0.001, "***",
                      ifelse(adj_p_mat < 0.01, "**",
                             ifelse(adj_p_mat < 0.05, "*", "")))
  
  # Prepare data for ggplot
  df <- melt(tab)
  colnames(df) <- c("Var1", "Var2", "Freq")
  df$Signif <- melt(sig_stars)$value
  
  # Heatmap with axis labels
  p <- ggplot(df, aes(x = Var1, y = Var2, fill = Freq)) +
    geom_tile(color = "white") +
    geom_text(aes(label = Signif), size = 6) +
    scale_fill_gradient(low = "#f0f0f0", high = "#08519c") +
    labs(title = title, 
         x = xlab, 
         y = ylab, 
         fill = "Freq") +
    theme_minimal(base_size = 14) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  return(p)
}

# Image Platform × Depth Zone
depth_order1 <- c("abyssal", "slope", "rariphotic",  "mesophotic", "shelf", "shallow")
tab_ip_dz <- tab_ip_dz[,depth_order1]


heatmap_ip_dz <- make_heatmap(tab_ip_dz, chi_ip_dz,
                              xlab = "Platform",
                              ylab = "Depth zone")

# Image Platform × Cluster
heatmap_ip_clust <- make_heatmap(tab_ip_clust, chi_ip_clust,
                                 xlab = "Platform",
                                 ylab = "Cluster")

# Depth Zone × Cluster
tab_dz_clust <- tab_dz_clust[desired_order,]
heatmap_dz_clust <- make_heatmap(tab_dz_clust, chi_dz_clust,
                                 xlab = "Depth zone",
                                 ylab = "Cluster")

heatmaps_vertical <- heatmap_ip_dz / heatmap_ip_clust / heatmap_dz_clust

# ############### HEATMAPS OF CHISQ RESULTS USING STANDARDIZED RESIDUALS ###############

make_residual_heatmap <- function(tab, chi_obj, title = "",
                                  xlab = "", ylab = "") {
  
  # 1. Extract standardized residuals
  std_res <- chi_obj$stdres
  
  # 2. Two-sided p-values
  raw_p <- 2 * pnorm(abs(std_res), lower.tail = FALSE)
  
  # 3. Bonferroni-adjust p-values (vector → matrix)
  adj_p <- p.adjust(as.vector(raw_p), method = "bonferroni")
  adj_p_mat <- matrix(adj_p, nrow = nrow(tab), ncol = ncol(tab),
                      dimnames = dimnames(tab))
  
  # 4. Significance stars
  sig_stars <- ifelse(adj_p_mat < 0.001, "***",
                      ifelse(adj_p_mat < 0.01, "**",
                             ifelse(adj_p_mat < 0.05, "*", "")))
  
  # 5. Convert residuals and stars to a DF
  df <- melt(std_res)
  colnames(df) <- c("Var1", "Var2", "StdResid")
  
  df$Signif <- melt(sig_stars)$value
  
  # 6. Residual heatmap
  p <- ggplot(df, aes(x = Var1, y = Var2, fill = StdResid)) +
    geom_tile(color = "white") +
    geom_text(aes(label = Signif), size = 6) +
    
    # Diverging color scale: underrepresentation → overrepresentation
    scale_fill_gradient2(
      low = "#2166ac",     # blue (underrepresented)
      mid = "white",       # expected
      high = "#b2182b",    # red (overrepresented)
      midpoint = 0,
      name = "Std. Residual"
    ) +
    
    labs(title = title, x = xlab, y = ylab) +
    
    theme_minimal(base_size = 14) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  return(p)
}

# image platform x depth zone
heatmap_stdres_iz_dp <- make_residual_heatmap(
  tab_ip_dz, chi_ip_dz,
  xlab = "Platform",
  ylab = "Depth zone"
)
heatmap_stdres_iz_dp

# Image Platform × Cluster
heatmap_stdres_iz_clust <- make_residual_heatmap(tab_ip_clust, chi_ip_clust,
                                                 xlab = "Platform",
                                                 ylab = "Cluster")
heatmap_stdres_iz_clust

# Depth Zone × Cluster
heatmap_stdres_dz_clust <- make_residual_heatmap(tab_dz_clust, chi_dz_clust,
                                                 xlab = "Depth zone",
                                                 ylab = "Cluster")
make_residual_heatmap

heatmaps_vertical_stdres <- heatmap_stdres_iz_dp / heatmap_stdres_iz_clust / heatmap_stdres_dz_clust
ggsave("Figures/heatmaps_vertical_stdres.png", plot = heatmaps_vertical_stdres, width = 9, height = 12, dpi = 300)

# ############### TABLES OF STANDARDIZED RESIDUALS ###############

# Function that returns a rowname-column data.frame and a matrix
make_residual_table <- function(tab, chi_obj, digits = 2, p_adj_method = "bonferroni") {
  # Ensure standardized residuals are a matrix with dimnames
  std_res <- as.matrix(chi_obj$stdres)
  if (is.null(dimnames(std_res))) {
    # try using dimnames from tab if missing
    dimnames(std_res) <- dimnames(as.matrix(tab))
  }
  
  # Two-sided p-values from standardized residuals
  raw_p <- 2 * pnorm(abs(std_res), lower.tail = FALSE)
  
  # Adjust p-values across all cells
  adj_p <- p.adjust(as.vector(raw_p), method = p_adj_method)
  adj_p_mat <- matrix(adj_p, nrow = nrow(std_res), ncol = ncol(std_res),
                      dimnames = dimnames(std_res))
  
  # Significance stars
  sig_stars <- matrix("", nrow = nrow(std_res), ncol = ncol(std_res),
                      dimnames = dimnames(std_res))
  sig_stars[adj_p_mat < 0.05]  <- "*"
  sig_stars[adj_p_mat < 0.01]  <- "**"
  sig_stars[adj_p_mat < 0.001] <- "***"
  
  # Format residuals (rounded) and append stars
  fmt_vals <- matrix(sprintf(paste0("%.", digits, "f"), std_res),
                     nrow = nrow(std_res), ncol = ncol(std_res),
                     dimnames = dimnames(std_res))
  result_mat <- matrix(paste0(fmt_vals, sig_stars),
                       nrow = nrow(std_res), ncol = ncol(std_res),
                       dimnames = dimnames(std_res))
  
  # Return both a matrix and a data.frame with rownames as a column
  result_df <- as.data.frame(result_mat, stringsAsFactors = FALSE)
  result_df <- rownames_to_column(result_df, var = "Row")
  
  return(list(
    matrix = result_mat,
    df = result_df,
    p_values = adj_p_mat,
    std_residuals = std_res
  ))
}

# Example usage for your three relationships:
res_ip_dz  <- make_residual_table(tab_ip_dz,  chi_ip_dz)
res_ip_cl  <- make_residual_table(tab_ip_clust, chi_ip_clust)
res_dz_cl  <- make_residual_table(tab_dz_clust, chi_dz_clust)

# Access the nicely shaped data.frame (row names are in column "Row")
resid_tab_ip_dz_df    <- res_ip_dz$df
resid_tab_ip_clust_df <- res_ip_cl$df
resid_tab_dz_clust_df <- res_dz_cl$df

# Access the plain matrix version if you prefer
resid_tab_ip_dz_mat    <- res_ip_dz$matrix
resid_tab_ip_clust_mat <- res_ip_cl$matrix
resid_tab_dz_clust_mat <- res_dz_cl$matrix

# Print a preview (knitr::kable)
knitr::kable(resid_tab_ip_dz_df, caption = "Std. residuals (Image Platform × Depth Zone)")

# # Save to CSV (row names preserved in the first column)
# write.csv(resid_tab_ip_dz_df,    "Outputs/resid_tab_ip_dz.csv",    row.names = FALSE)
# write.csv(resid_tab_ip_clust_df, "Outputs/resid_tab_ip_clust.csv", row.names = FALSE)
# write.csv(resid_tab_dz_clust_df, "Outputs/resid_tab_dz_clust.csv", row.names = FALSE)

# If you also want the numeric standardized residuals (without stars) for downstream use:
std_res_ip_dz    <- res_ip_dz$std_residuals
std_res_ip_clust <- res_ip_cl$std_residuals
std_res_dz_clust <- res_dz_cl$std_residuals

# And the adjusted p-values matrix if you want to inspect exact p-values:
adj_p_ip_dz    <- res_ip_dz$p_values
adj_p_ip_clust <- res_ip_cl$p_values
adj_p_dz_clust <- res_dz_cl$p_values