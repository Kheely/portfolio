################################################################################
# EVR 628 Assignment 4
################################################################################
#
# Kimberly Heely
# kimberlyheely@gmail.com
# 18 November 2025
#
# Visualizing spatial data from my drone research project
#
################################################################################

# SET UP

## Load packages
library(tidyverse)
library(EVR628tools)
library(readr)
library(ggspatial)
library(rnaturalearth)
library(sf)
library(mapview)
library(janitor)
library(cowplot)

## Load data
  # Load FL sf
florida <- read_sf("data/raw/Florida_Shapefile/Detailed_Florida_State_Boundary.shp") |>
  st_transform(florida, crs = "EPSG:4326")
transects <- read_csv("data/raw/2025-Transect-Database  - Sheet9.csv")

# PROCESSING
  # Making tansect data into a sf
transects_sf <- st_as_sf(transects, coords = c("longitude","latitude"), crs = "EPSG:4326")
  # Visualizing the sf
plot(transects_sf)

  # Adding in a line to connect the start/end points of each transect
transect_lines <- transects_sf |>
  group_by(`site`,`transect_id`) |>
  summarize(do_union = FALSE,
            .groups = "drop") |>
  st_cast("LINESTRING")

  # Adding coordinates to crop the FL sf to just show around Miami (including study sites)
miami <- st_bbox(c(
  xmin = -80.40,  # west: covers Deering Estate area
  ymin = 25.50,   # south: slightly below Deering Estate
  xmax = -80.10,  # east: extends past Crandon Park
  ymax = 25.80    # north: covers downtown Miami area
), crs = st_crs(florida))


# VISUALIZE
# adding lines to connect the points of the transects
plot(transect_lines, reset = FALSE)
plot(transects_sf, add = TRUE)

# Build plot of FL peninsula
florida_plot <- ggplot() +
  geom_sf(data = florida) +
  geom_rect(aes(xmin = -80.40, xmax = -80.10, ymin = 25.50, ymax = 25.80),
            color = "red", fill = NA, linewidth = 1) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Florida, USA",
       x = "Longitude",
       y = "Latitude") +
  annotation_north_arrow(location = "tl",
                         which_north = "true") +
  annotation_scale(location = "bl")


 # Preparing to add boxes around study sites on zoomed in plot
    # Deering Estate bbox
deering_bbox <- st_as_sfc(st_bbox(c(
  xmin = -80.31, xmax = -80.285,
  ymin = 25.605, ymax = 25.625
), crs = st_crs(florida)))

    # Crandon Park bbox
crandon_bbox <- st_as_sfc(st_bbox(c(
  xmin = -80.175, xmax = -80.135,
  ymin = 25.695, ymax = 25.735
), crs = st_crs(florida)))


# Plot of FL zoomed into Miami area (including both study sites)
florida_crop <- st_crop(florida, miami)

fl_crop_plot <- ggplot() +
  geom_sf(data = florida_crop) +
  geom_sf(data = deering_bbox, color = "red", fill = NA, linewidth = 1) +
  geom_sf(data = crandon_bbox, color = "red", fill = NA, linewidth = 1) +
  annotate("text",
           x = -80.31 - 0.01,   # xmax + small offset
           y = (25.605 + 25.625)/2,    # ymax + small offset
           label = "C", color = "black", size = 4, fontface = "bold") +
  annotate("text",
           x = -80.175 - 0.01,   # xmax + small offset
           y = (25.695 + 25.735)/2,    # ymax + small offset
           label = "D", color = "black", size = 4) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Study Sites Locations",
       x = "Longitude",
       y = "Latitude") +
  annotation_scale(location = "bl")



# Plot for Deering transects
deering_transects <- ggplot() +
  geom_sf(data = florida_crop, fill = "lightgrey", color = NA) +
  geom_sf(data = transect_lines, color = "darkblue", size = 1) +
  geom_sf(data = transects_sf) +
  coord_sf(xlim = c(-80.31, -80.285), ylim = c(25.605, 25.620)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Deering Estate Transects",
       x = "Longitude",
       y = "Latitude") +
  annotation_scale(location = "bl")



# Plot for Crandon transects
crandon_transects <- ggplot() +
  geom_sf(data = florida_crop, fill = "lightgrey", color = NA) +
  geom_sf(data = transect_lines, color = "darkblue", size = 1) +
  geom_sf(data = transects_sf) +
   coord_sf(xlim = c(-80.160, -80.139), ylim = c(25.710, 25.721)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Crandon Park Transects",
       x = "Longitude",
       y = "Latitude",
       caption = "Data derived from my drone research project") +
  annotation_scale(location = "bl")


# Combining plots using cowplot

combined_plots <- plot_grid(florida_plot, fl_crop_plot,
                            deering_transects, crandon_transects,
          ncol = 2,
          rel_heights = 1,
          labels = c("A)", "B)", "C)", "D)"),
          label_x = 0.1)

# View final product of combined plots
combined_plots


# Exporting finalized map of my spatial data
ggsave(plot = combined_plots,
       filename = "results/img/drone_transects_map.png")
