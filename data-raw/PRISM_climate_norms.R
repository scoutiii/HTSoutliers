## code to prepare `PRISM_climate_norms` dataset goes here

# This is dowloaded from https://prism.oregonstate.edu/normals/
tfiles <- list.files("D:/Data/PRISM/PRISM_ppt_30yr_normal_800mM2_all_asc/",
                     pattern = "[[:digit:]]+_asc.asc$",
                     full.names = TRUE)
# Complies the precipitation rasters
ppt <- vector("list", length = length(tfiles))
for(i in 1:length(ppt)) {
    ppt[[i]] <- raster::raster(tfiles[i])
}


# Compiles the max temperature
tfiles <- list.files("D:/Data/PRISM/PRISM_tmax_30yr_normal_800mM2_all_asc/",
                     pattern = "[[:digit:]]+_asc.asc$",
                     full.names = TRUE)
tmax <- vector("list", length = length(tfiles))
for(i in 1:length(tmax)) {
    tmax[[i]] <- raster::raster(tfiles[i])
}

# Compiles the min temperature
tfiles <- list.files("D:/Data/PRISM/PRISM_tmin_30yr_normal_800mM2_all_asc/",
                     pattern = "[[:digit:]]+_asc.asc$",
                     full.names = TRUE)
tmin <- vector("list", length = length(tfiles))
for(i in 1:length(tmin)) {
    tmin[[i]] <- raster::raster(tfiles[i])
}



PRISM_climate_norms <- raster::brick(ppt[[1]], ppt[[2]], ppt[[3]], ppt[[4]], ppt[[5]], ppt[[6]],
                                     ppt[[7]], ppt[[8]], ppt[[9]],ppt[[10]],ppt[[11]],ppt[[12]],
                                     tmin[[1]], tmin[[2]], tmin[[3]], tmin[[4]], tmin[[5]], tmin[[6]],
                                     tmin[[7]], tmin[[8]], tmin[[9]],tmin[[10]],tmin[[11]],tmin[[12]],
                                     tmax[[1]], tmax[[2]], tmax[[3]], tmax[[4]], tmax[[5]], tmax[[6]],
                                     tmax[[7]], tmax[[8]], tmax[[9]],tmax[[10]],tmax[[11]],tmax[[12]]
                                     )

# finds the raster values for each ghcnd station, stations are on the y-axis
temp <- snowload2::ghcnd_stations
sp::coordinates(temp) <- c("LONGITUDE", "LATITUDE")
sp::proj4string(temp) <- sp::proj4string(PRISM_climate_norms)
# Create the matrix of PRISM climate values (n (of GHCND_STATIONS) x 36)
tvalues <- raster::extract(PRISM_climate_norms, temp, method = "bilinear")
ttvalue <- as.data.frame(tvalues)
ttvalue[["ID"]] <- temp$ID
PRISM_climate_norms <- ttvalue

usethis::use_data(PRISM_climate_norms, overwrite = TRUE)
