# http://robinlovelace.net/2014/06/22/great-circles-in-rworldmap-ggplot2.html
# https://gist.github.com/Robinlovelace/838178ef83561a6eb713
# https://gist.github.com/Robinlovelace/379e0a3db23b53965c73
# http://gis.stackexchange.com/questions/122494/how-to-prevent-cross-world-lines-in-ggplot-world-map

x <- c("ggmap", "geosphere", "sp")
lapply(x, library, character.only = TRUE)

download.file("https://dl.dropboxusercontent.com/u/15008199/tmp/origins.csv", "origins.csv", method = "wget")

origins <- read.csv("origins.csv")
os <- SpatialPoints(coords = origins,
proj4string = CRS("+init=epsg:4326"))
dest <- geocode("Leura")
destp <- SpatialPoints(coords = matrix(c(dest$lon, dest$lat), nrow = 1),
proj4string = CRS("+init=epsg:4326"))

path <- NULL
# for(i in 1:2){ # for testing
for(i in 1:nrow(coordinates(os))){
pathl <- gcIntermediate(coordinates(os[i, ])[2:3], p2 = dest, breakAtDateLine = T)
cl <- class(pathl)
path_tmp <- matrix(unlist(pathl, use.names = T ), ncol = 2)
path_tmp <- data.frame(path_tmp)
path_tmp$person <- i
# ifelse(cl == "matrix", path_tmp$person <- i , no = path_tmp$person <- paste(i, c(rep(1, nrow(pathl[[1]])), rep(2, nrow(pathl[[2]]))), sep = "."))
path <- rbind(path, path_tmp)
}

wrld <- borders("world", colour="gray50", fill="gray50")

# plot the result
ggplot() + wrld +
geom_point(data = origins, aes(lon, lat)) +
geom_path(data = path, aes(X1, X2, group = person)) +
coord_fixed(ratio = 1)