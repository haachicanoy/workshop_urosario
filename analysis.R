# Crop modeling application for Maize: DDSAT run
# J. Mesa, J. Ramirez & H. Achicanoy
# Workshop en Big data, U. del Rosario, 2017

# R options
options(warn = -1); options(scipen = 999); g <- gc(); rm(list = ls())

# Load packages
suppressMessages(library(tidyverse))
suppressMessages(library(stringr))
suppressMessages(library(magrittr))
suppressMessages(library(purrr))
suppressMessages(library(raster))
suppressMessages(library(sf))
suppressMessages(library(rvest))
suppressMessages(library(viridis))
suppressMessages(library(sp))
suppressMessages(library(maptools))
suppressMessages(library(rgdal))
suppressMessages(library(trend))

crop_mgmt_climate <- readRDS('data/results/Integrated_results.RDS')

runs <- magrittr::extract2(crop_mgmt_climate, 'dssat_runs')
runs <- lapply(1:length(runs), function(i){
  df <- runs[[i]]
  df$ID <- crop_mgmt_climate$ID[i]
  df$FPU <- crop_mgmt_climate$New_FPU[i]
  return(df)
})
runs <- do.call(rbind, runs)
runs$SDAT <- as.numeric(substr(runs$SDAT, 1, nchar(runs$SDAT)-3))

# =========================================================================================== #
# Time series per pixel
# =========================================================================================== #
runs %>% ggplot(aes(x = as.numeric(SDAT), y = HWAH, group = ID)) +
  geom_line(alpha = .2, size = 1.2) + theme_bw() + xlab('Year') + ylab("Yield (kg/ha)") +
  theme(axis.title.x = element_text(size = 20, face = 'bold'),
        axis.title.y = element_text(size = 20, face = 'bold'),
        axis.text = element_text(size = 20))

# =========================================================================================== #
# Time series per pixel and FPU
# =========================================================================================== #
runs %>% ggplot(aes(x = SDAT, y = HWAH, group = ID, colour = factor(FPU))) +
  geom_line(alpha = .2, size = 1.2) + theme_bw() + xlab('Year') + ylab("Yield (kg/ha)") +
  theme(axis.title.x = element_text(size = 20, face = 'bold'),
        axis.title.y = element_text(size = 20, face = 'bold'),
        axis.text.x = element_text(size = 20, angle = 90),
        axis.text.y = element_text(size = 20),
        legend.title = element_text(size = 15, face = 'bold'),
        legend.text = element_text(size = 15),
        strip.text.x = element_text(size = 15, face = 'bold')) +
  labs(colour = "Region") + 
  facet_wrap(~factor(FPU))

# =========================================================================================== #
# Average yield map
# =========================================================================================== #
crop_mgmt_climate$Rend <- magrittr::extract2(crop_mgmt_climate, 'dssat_runs') %>%
  map(., function(df) mean(df$HWAH)) %>% as.numeric()

load("C:/Users/haachicanoy/Documents/GitHub/workshop_urosario/data/management/_maize_crop_mgmt_secano.RDat")
crop_mgmt <- as.data.frame(crop_mgmt)
crop_mgmt <- crop_mgmt %>% filter(country == "Colombia") %>% dplyr::select(Coincidencias, x, y)

crop_mgmt_climate <- left_join(x = crop_mgmt_climate, y = crop_mgmt, by = c('ID' = 'Coincidencias')); rm(crop_mgmt)

col_shp <- readOGR(dsn = "D:/Harold/_maps/ShapeFiles/Capas_SIG/col_departamentos_IGAC", layer = "Col_dpto_igac_2011_84")

ggplot() +
  geom_polygon(data = col_shp, 
               aes(x = long, y = lat, group = group)) +
  coord_fixed() + geom_raster(data = crop_mgmt_climate, aes(x = x, y = y, fill = Rend)) + theme_bw() + scale_fill_distiller(palette = "Spectral") +
  xlab('Longitude') + ylab("Latitude") +
  theme(axis.title.x = element_text(size = 20, face = 'bold'),
        axis.title.y = element_text(size = 20, face = 'bold'),
        axis.text = element_text(size = 20),
        legend.title = element_text(size = 15, face = 'bold'),
        legend.text = element_text(size = 15)) +
  labs(fill = "Yield (kg/ha)")

# =========================================================================================== #
# Trend map
# =========================================================================================== #
slope_trend <- function(df){
  timeSer <- ts(df$HWAH, start=1971, end=1999, frequency=1)
  slope <- sens.slope(timeSer); slope <- slope$b.sen
  return(slope)
}

crop_mgmt_climate$Slope <- magrittr::extract2(crop_mgmt_climate, 'dssat_runs') %>%
  map(., slope_trend) %>% as.numeric()

ggplot() +
  geom_polygon(data = col_shp, 
               aes(x = long, y = lat, group = group)) +
  coord_fixed() + geom_raster(data = crop_mgmt_climate, aes(x = x, y = y, fill = Slope)) + theme_bw() + scale_fill_distiller(palette = "Spectral") +
  xlab('Longitude') + ylab("Latitude") +
  theme(axis.title.x = element_text(size = 20, face = 'bold'),
        axis.title.y = element_text(size = 20, face = 'bold'),
        axis.text = element_text(size = 20),
        legend.title = element_text(size = 15, face = 'bold'),
        legend.text = element_text(size = 15)) +
  labs(fill = "Yield trend")


View(crop_mgmt_climate$dssat_runs[[1]][,20:29])
xx <- crop_mgmt_climate$dssat_runs[[1]][,20:29]
library(corrplot)
corrplot(cor(xx), method = 'ellipse')
library(FactoMineR)
pca.res <- PCA(X = xx, scale.unit = T)
