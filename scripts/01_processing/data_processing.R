################################################################################
# Assignment 2: Data Wrangling
################################################################################
#
# Kimberly Heely
# kimberlyheely@gmail.com
# 19 October 2025
#
# Using my data from drone surveys for data wrangling assignment
#
################################################################################


# SET UP

## Load packages
library(tidyverse)
library(EVR628tools)
library(readr)
library(janitor)

## Load data
  #Reading in csv files for species detections and environmental data
  #Also creating objects for each file

species_detections <- read.csv("data/raw/drone_species_detections.csv")
environmentals <- read.csv("data/raw/drone_environmental_data.csv")

 #viewing data and column names
view(species_detections)
view(environmentals)
colnames(species_detections)
colnames(environmentals)

# PROCESSING
  #using a left join to join the two csv files by date
combined_data <- species_detections |>
  left_join(environmentals, by = "DATE")

  #viewing combined data and seeing a summary
view(combined_data)
summary(combined_data)

  #viewing column names of new combined dataset
colnames(combined_data)

  #cleaning data
  #removing columns that are not needed for this analysis
cleaning <- combined_data |>
  select(-SCREENGRAB_LINK, -COMMENTS, -TIDE_SOURCE, -X._PEOPLE_CP,
         X._PEOPLE_PD, -X._PEOPLE_BB, -X._PEOPLE_DP, -CL_CON_SOURCE,
         -CL_CON_TIME,-O2_PPM_SOURCE, -O2_PPM_TIME, -O2._SOURCE,
         -O2._TIME, -SALINITY_SOURCE, -SALINITY_TIME, -WIND_SOURCE,
         -WIND_TIME, -SST_SOURCE, -SST_TIME, -SITE.y, -ADJUSTED_DETECTION_TIME,
         -DETECTION_TIME_STAMP, -ROAMING_SYSTEMATIC)

  #cleaning column names
clean_data <-cleaning |>
  clean_names()

 #viewing new clean version of data
view(clean_data)

 #viewing column names of clean data
colnames(clean_data)

# VISUALIZE
  #looking at how # of indivduals detected varies by SST
temp_plot <- ggplot(data = clean_data,
       mapping = aes(x = sst_c,
                     y = number_individuals,
                     color = species)) +
  geom_point() +
  labs(x = "Sea Surface Temperature (°C)",
       y = "Individuals Detected") +
  theme_minimal()

  #looking at how # of indivduals detected varies by salinity
salinity_plot <- ggplot(data = clean_data,
       mapping = aes(x = salinity_psu,
                     y = number_individuals,
                     color = species)) +
  geom_point() +
  labs(x = "Salinity (psu)",
       y = "Individuals Detected") +
  theme_minimal()

  #visualizing how detections and SST vary through time
sst_variation <- ggplot(data = clean_data,
       mapping = aes(x = date,
                     y = sst_c,
                     color = species)) +
  geom_line(aes(group = species)) +
  geom_point() +
  labs(x = "Date",
       y = "SST") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

  #visualizing # of detections by species with bar graph
detections_bar <- clean_data |>
  group_by(site_x, species) |>
  summarize(total_detected = sum(number_individuals, na.rm = TRUE)) |>
  ggplot(aes(x = site_x, y = total_detected, fill = species)) +
  geom_col(position = "dodge") +
  scale_fill_viridis_d(option = "mako") +
  theme_minimal() +
  labs(x = "Site",
       y = "Total Individuals Detected")


# EXPORT
  #saving cleaned & combined data set into the processed folder
saveRDS(clean_data, "data/processed/cleaned_combined_data.rds")

  #saving plots I made above to the results folder

ggsave(plot = detections_bar,
       filename = "results/img/species_detections_plot.png")

ggsave(plot = temp_plot,
       filename = "results/img/sst_species_detections.png")

ggsave(plot = salinity_plot,
       filename = "results/img/salinity_species_detections.png")

ggsave(plot = sst_variation,
       filename = "results/img/sst_detection_variation.png")


