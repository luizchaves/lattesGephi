# http://gis.stackexchange.com/questions/122494/how-to-prevent-cross-world-lines-in-ggplot-world-map

library(ggmap)
library(geosphere)

library(maps)
library(geosphere)
library(plyr) 
library(ggplot2)
library(sp)
library(grid)

### Function to regroup split lines and polygons
# takes dataframe, column with long and unique group variable, returns df with added column named group.regroup
RegroupElements <- function(df, longcol, idcol){  
  g <- rep(1, length(df[,longcol]))
  if (diff(range(df[,longcol])) > 300) {          # check if longitude within group differs more than 300 deg, ie if element was split
    d <- df[,longcol] > mean(range(df[,longcol])) # we use the mean to help us separate the extreme values
    g[!d] <- 1     # some marker for parts that stay in place (we cheat here a little, as we do not take into account concave polygons)
    g[d] <- 2      # parts that are moved
  }
  g <-  paste(df[, idcol], g, sep=".") # attach to id to create unique group variable for the dataset
  df$group.regroup <- g
  df
}
 
### Function to close regrouped polygons
# takes dataframe, checks if 1st and last longitude value are the same, if not, inserts first as last and reassigns order variable
ClosePolygons <- function(df, longcol, ordercol){
  if (df[1,longcol] != df[nrow(df),longcol]) {
    tmp <- df[1,]
    df <- rbind(df,tmp)
  }
  o <- c(1: nrow(df))  # rassign the order variable
  df[,ordercol] <- o
  df
}

### Function 
fortify.SpatialLinesDataFrame = function(model, data, ...) {
  ldply(model@lines, fortify)
}

# flows <- read.csv("lattes-flows-country-2013.csv") 
flows <- read.csv("lattes-flows-instituition-2013.csv") 
# flows <- read.csv("lattes-flows-instituition-2013-2.csv") 
# flows <- flows[which(flows$trips>0&flows$trips<100),]
flows <- flows[which(flows$trips>0),]
# flows <- flows[order(flows$trips),]

rts <- gcIntermediate(flows[c('oY','oX')], flows[c('dY','dX')], n=100, breakAtDateLine=FALSE, addStartEnd=TRUE, sp=TRUE)
rts.ff <- fortify.SpatialLinesDataFrame(rts)
gcircles <- merge(rts.ff, flows, all.x=T, by="id")

### Recenter ####
center <- 0 # positive values only - US centered view is 260
 
# shift coordinates to recenter great circles
gcircles$long.recenter <-  ifelse(gcircles$long  < center - 180 , gcircles$long + 360, gcircles$long) 
 
# shift coordinates to recenter worldmap
worldmap <- map_data ("world")
worldmap$long.recenter <-  ifelse(worldmap$long  < center - 180 , worldmap$long + 360, worldmap$long)

# now regroup
gcircles.rg <- ddply(gcircles, .(id), RegroupElements, "long.recenter", "id")
worldmap.rg <- ddply(worldmap, .(group), RegroupElements, "long.recenter", "group")
 
# close polys
worldmap.cp <- ddply(worldmap.rg, .(group.regroup), ClosePolygons, "long.recenter", "order")  # use the new grouping var


# png('ggplot-great-circles-lattes-2013-country-white.png', 1800, 1000)
png('ggplot-great-circles-lattes-instituition-2013-white.png', 1800, 1000)
# png('ggplot-great-circles-lattes-2013-country-black.png', 1800, 1000)
ggplot() + 
	# borders("world", colour="gray50", fill="gray50") +
  # geom_line(aes(long.recenter, lat, group=group), size=0.4, data= gcircles.rg)+
	geom_polygon(aes(long.recenter,lat,group=group.regroup), size = 0.2, fill="#f9f9f9", colour = "grey65", data=worldmap.cp) +
	# geom_polygon(aes(long.recenter,lat,group=group.regroup), size = 0.2, fill="#191919", colour = "grey65", data=worldmap.cp) +
  geom_line(aes(long.recenter,lat,group=group.regroup, color=trips, alpha=trips), size=0.6, data= gcircles.rg) +
  # geom_line(aes(long.recenter,lat,group=group.regroup, color=trips, alpha=trips), size=0.6, data= gcircles.rg, arrow = arrow(type = "closed")) +
  # geom_path(aes(long.recenter,lat,group=group.regroup, color=trips, alpha=trips), size=0.6, data= gcircles.rg) +
  # scale_colour_gradient(low="#fafafa", high="#EE0000") + 
  # scale_colour_gradient(low="#333333", high="#1292db") + 
  scale_colour_gradient(low="#6a6262", high="#1292db") + 
  scale_alpha_continuous(range = c(0.0003, 0.03))+
  theme(
  	panel.background = element_blank(), 
  	# panel.background = element_rect(fill = "#000000", colour = NA), 
  	panel.grid.minor = element_blank(), 
  	panel.grid.major = element_blank(),  
  	axis.ticks = element_blank(), 
  	axis.title.x = element_blank(), 
  	axis.title.y = element_blank(), 
  	axis.text.x = element_blank(), 
  	axis.text.y = element_blank()#, 
  	# legend.position = "none"
  ) +
  # ylim(-60, 90) +
  ylim(-70, 90) +
  coord_equal()
dev.off()
