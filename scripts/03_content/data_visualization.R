################################################################################
# EVR 628 Assignment 3
################################################################################
#
# Kimberly Heely
# kimberlyheely@gmail.com
# 2 November 2025
#
# Description
# Data Visualization
################################################################################


# SET UP

## Load packages

library(tidyverse)
library(EVR628tools)
library(readr)
library(janitor)
library(patchwork)

## Load data
#Reading in csv files for species detections and environmental data
  #Also creating objects for each file

species_detections <- read.csv("data/raw/drone_species_detections.csv")
environmentals <- read.csv("data/raw/drone_environmental_data.csv")

# PROCESSING

  # Using a left join to join the two csv files by date
combined_data <- species_detections |>
  left_join(environmentals, by = "DATE")

  # Cleaning data
  # Removing columns that are not needed for this analysis
cleaning <- combined_data |>
  select(-SCREENGRAB_LINK, -COMMENTS, -TIDE_SOURCE, -X._PEOPLE_CP,
         X._PEOPLE_PD, -X._PEOPLE_BB, -X._PEOPLE_DP, -CL_CON_SOURCE,
         -CL_CON_TIME,-O2_PPM_SOURCE, -O2_PPM_TIME, -O2._SOURCE,
         -O2._TIME, -SALINITY_SOURCE, -SALINITY_TIME, -WIND_SOURCE,
         -WIND_TIME, -SST_SOURCE, -SST_TIME, -SITE.y, -ADJUSTED_DETECTION_TIME,
         -DETECTION_TIME_STAMP, -ROAMING_SYSTEMATIC)

  # Cleaning column names
clean_data <-cleaning |>
  clean_names()

# VISUALIZE

  # Looking at how # of individuals detected varies by SST
temp_plot <- ggplot(data = clean_data,
       mapping = aes(x = sst_c,
                     y = number_individuals,
                     color = species)) +
  geom_point() +
  labs(title = "Species detections based on SST",
       x = "Sea surface temperature (°C)",
       y = "Individuals detected",
       caption = "Data derived from my drone research project") +
  theme_minimal()

  # View plot
temp_plot


  # Looking at how # of indivduals detected varies by salinity
salinity_plot <- ggplot(data = clean_data,
       mapping = aes(x = salinity_psu,
                     y = number_individuals,
                     color = species)) +
  geom_point() +
  labs(title = "Species detections based on salinity",
       x = "Salinity (psu)",
       y = "Individuals detected",
       caption = "Data derived from my drone research project") +
  theme_minimal()

  # View plot
salinity_plot

  # Visualizing how detections and SST vary through time
sst_variation <- ggplot(data = clean_data,
       mapping = aes(x = date,
                     y = sst_c,
                     color = species)) +
  geom_line(aes(group = species)) +
  geom_point() +
  labs(title = "Species detections over time with SST",
       x = "Date",
       y = "Sea surface temperature (°C)",
       caption = "Data derived from my drone research project") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

  # View plot
sst_variation

  # Visualizing # of detections by species with bar graph
detections_bar <- clean_data |>
  group_by(site_x, species) |>
  summarize(total_detected = sum(number_individuals, na.rm = TRUE)) |>
  ggplot(aes(x = site_x,
             y = total_detected,
             fill = species)) +
  geom_col(position = "dodge") +
  scale_fill_viridis_d(option = "mako") +
  theme_minimal() +
  labs(title = "Total number of species detections", line = 2,
       x = "Site",
       y = "Total individuals detected",
       caption = "Data derived from my drone research project")

  # View plot
detections_bar


# Combining plots with patchwork
detections_bar + (temp_plot / salinity_plot)


# EXPORT
  # Saving plots made above to the results folder

ggsave(plot = detections_bar,
       filename = "results/img/species_detections_plot.png")

ggsave(plot = temp_plot,
       filename = "results/img/sst_species_detections.png")

ggsave(plot = salinity_plot,
       filename = "results/img/salinity_species_detections.png")

ggsave(plot = sst_variation,
       filename = "results/img/sst_detection_variation.png")
