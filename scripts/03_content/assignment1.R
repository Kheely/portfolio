# Load packages
library(EVR628tools)
library(tidyverse)

# Load data
data(data_lionfish)

# Create a simple plot
p <- ggplot(data_lionfish,
            aes(x = total_length_mm, y = total_weight_gr)) +
  geom_point(colour = "pink") +
  facet_wrap(~site)

?geom_point

view(data_lionfish)

ggplot(data_lionfish,
       aes(x = size_class, y = depth_m)) +
  geom_point(colour = "blue")

ggplot(data_lionfish,
       aes(x = site, y = total_weight_gr)) +
  geom_point(colour = "red")
