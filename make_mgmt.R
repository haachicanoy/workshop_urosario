library(sf)
library(tidyverse)
library(tmaptools)
library(foreach)
library(doSNOW)

path <- 'data/'

shape_colombia <- st_read(dsn = paste0(path, 'masks/shape_colombia/Municipios_SIGOT_geo.shp')) %>%
  select(NOM_MUNICI, NOMBRE_DPT)

load(paste0(path, 'management/_maize_crop_mgmt_secano.RDat'))
crop_mgmt <- as_data_frame(crop_mgmt) %>%
  filter(country == 'Colombia') %>%
  st_as_sf(coords = c("x", "y"))

st_crs(crop_mgmt) <- st_crs(shape_colombia)

mgmt_colombia <- shape_colombia %>%
  crop_shape(crop_mgmt, polygon = T) 

ggplot()+
  geom_sf(data = mgmt_colombia, colour = "black", fill = NA) +
  geom_sf(data = crop_mgmt, colour = "red") 

# intersectar en paralello?
mgmt_colombia <- st_intersection(crop_mgmt, mgmt_colombia)

           