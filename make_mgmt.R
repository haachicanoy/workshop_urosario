# Workshop en Big Data - Universidad del Rosario
# H. Achicanoy, J. Mesa
# CIAT, 2017

library(sf)
library(tidyverse)
library(tmaptools)

path <- 'data/'


# to load Colombia's shapefile

shape_colombia <- st_read(dsn = paste0(path, 'masks/shape_colombia/Municipios_SIGOT_geo.shp')) %>%
  select(NOM_MUNICI, NOMBRE_DPT)

# to load crop management for maize

load(paste0(path, 'management/_maize_crop_mgmt_secano.RDat'))

crop_mgmt <- as_data_frame(crop_mgmt) %>%
  filter(country == 'Colombia') %>%
  st_as_sf(coords = c("x", "y"))

## add coordinate system
st_crs(crop_mgmt) <- st_crs(shape_colombia)

## Crop points only for Colombia

mgmt_colombia <- shape_colombia %>%
  crop_shape(crop_mgmt, polygon = T) 

# To draw the area that we have information

ggplot()+
  geom_sf(data = mgmt_colombia, colour = "black", fill = NA) +
  geom_sf(data = crop_mgmt, colour = "red") 

# intersect (it is a better object into R) 
mgmt_colombia <- st_intersection(crop_mgmt, mgmt_colombia)

mgmt_colombia_df <- as_data_frame(mgmt_colombia) %>%
  select(-geometry)

write.csv(mgmt_colombia_df, file = paste0(path, 'results/mgmt_colombia.csv'))


