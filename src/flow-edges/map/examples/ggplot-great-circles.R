# http://robinlovelace.net/2014/06/22/great-circles-in-rworldmap-ggplot2.html
# https://gist.github.com/Robinlovelace/838178ef83561a6eb713
# https://gist.github.com/Robinlovelace/379e0a3db23b53965c73
# http://gis.stackexchange.com/questions/122494/how-to-prevent-cross-world-lines-in-ggplot-world-map

library(ggmap) # load the ggmap package
library(geosphere)
 
download.file("https://dl.dropboxusercontent.com/u/15008199/tmp/origins.csv", "origins.csv", method = "wget")
 
origins <- read.csv("origins.csv")
os <- SpatialPoints(coords = origins,
  proj4string = CRS("+init=epsg:4326"))
dest <- geocode("Leura")
destp <-  SpatialPoints(coords = matrix(c(dest$lon, dest$lat), nrow = 1),
  proj4string = CRS("+init=epsg:4326"))
 
path <- NULL
for(i in 1:nrow(coordinates(os))){
  path_tmp <- gcIntermediate(coordinates(os[i, ])[2:3], p2 = dest)
  path_tmp <- data.frame(path_tmp)
  path_tmp$person <- i
  path <- rbind(path, path_tmp)
}
 
wrld <- borders("world", colour="gray50", fill="gray50")
 
# plot the result
ggplot() + wrld +
  geom_point(data = origins, aes(lon, lat)) +
  geom_path(data = path, aes(lon, lat, group = person)) +
  coord_fixed(ratio = 1)
 
origins$lon[ origins$lon < 0] <- origins$lon[ origins$lon < 0] + 360
path$lon[path$lon < 0] <- path$lon[path$lon < 0]  + 360
 
wrld <- borders("world2", colour="gray50", fill="gray50")
 
# plot the result
ggplot() + wrld +
  geom_point(data = origins, aes(lon, lat)) +
  geom_path(data = path, aes(lon, lat, group = person)) +
  coord_fixed(ratio = 1)