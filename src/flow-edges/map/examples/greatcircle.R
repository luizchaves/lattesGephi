library(maps)
library(geosphere)
library(plyr)
library(ggplot2)
library(sp)
library(foreign)
library(grid)

# country=read.dbf('D:/Downloads/R/ne_10m_admin_0_countries.dbf')
load('world_light.RData')
airports <- read.csv("http://www.stanford.edu/~cengel/cgi-bin/anthrospace/wp-content/uploads/2012/03/airports.csv", as.is=TRUE, header=TRUE)
flights <- read.csv("http://www.stanford.edu/~cengel/cgi-bin/anthrospace/wp-content/uploads/2012/03/PEK-openflights-export-2012-03-19.csv", as.is=TRUE, header=TRUE)
flights_TPE=read.csv("openflights-export-2013-12-08.csv", as.is=TRUE, header=TRUE)
flights_TPE=flights_TPE[seq(1,dim(flights_TPE)[1],2),]


# temp_urban=read.dbf('D:/Downloads/R/ne_10m_populated_places_simple.dbf')
x=as.character(country$ADMIN[country$GDP_MD_EST>=median(country$GDP_MD_EST)])

urban=temp_urban[temp_urban$adm0name ==x[1],]
for (i in 2:length(x)){
  urban=rbind(urban,temp_urban[temp_urban$adm0name ==x[i],])
}
urban=urban[urban$pop_max>=25000,]
# aggregate nunber of flights
flights.ag <- ddply(flights, .(From, To), summarise, freq = length(To))
flights_TPE.ag <- ddply(flights_TPE, .(From, To), summarise, freq = length(To))
# add latlons
flights_PEK.ll <- merge(flights.ag, airports, all.x=TRUE, by.x="To", by.y="IATA")
flights_TPE.ll <- merge(flights_TPE.ag, airports, all.x=TRUE, by.x="To", by.y="IATA")

beijing.ll <- c(airports$longitude[airports["IATA"]=="PEK"],airports$latitude[airports["IATA"]=="PEK"])
taipei.ll <- c(airports$longitude[airports["IATA"]=="TPE"],airports$latitude[airports["IATA"]=="TPE"])


# calculate routes -- Dateline Break FALSE, otherwise we get a bump in the shifted ggplots
rts <- gcIntermediate(taipei.ll, flights_TPE.ll[,c('longitude', 'latitude')], 100, breakAtDateLine=FALSE, addStartEnd=TRUE, sp=TRUE)
rts.TPE <- ggplot2:::fortify.SpatialLinesDataFrame(rts) # convert into something ggplot can plot
rts <- gcIntermediate(beijing.ll, flights_PEK.ll[,c('longitude', 'latitude')], 100, breakAtDateLine=FALSE, addStartEnd=TRUE, sp=TRUE)
rts.PEK <- ggplot2:::fortify.SpatialLinesDataFrame(rts) # convert into something ggplot can plot

flights_TPE.ll$id <-as.character(c(1:nrow(flights_TPE.ll))) # that rts.ff$id is a char
gcircles_TPE <- merge(rts.TPE, flights_TPE.ll, all.x=TRUE, by="id") # join attributes, we keep them all, just in case

flights_PEK.ll$id <-as.character(c(1:nrow(flights_PEK.ll))) # that rts.ff$id is a char
gcircles_PEK <- merge(rts.PEK, flights_PEK.ll, all.x=TRUE, by="id") # join attributes, we keep them all, just in case

# gcircles=rbind(gcircles_TPE,gcircles_PEK)
### Recenter ####

center <- 150 # positive values only - US centered view is 260

# shift coordinates to recenter great circles
gcircles_PEK$long.recenter <- ifelse(gcircles_PEK$long < center - 180 , gcircles_PEK$long + 360, gcircles_PEK$long)
gcircles_TPE$long.recenter <- ifelse(gcircles_TPE$long < center - 180 , gcircles_TPE$long + 360, gcircles_TPE$long)

# shift coordinates to recenter worldmap
worldmap <- map_data ("world")
worldmap$long.recenter <- ifelse(worldmap$long < center - 180 , worldmap$long + 360, worldmap$long)

# shift coordinates to recenter urban

urban$longitude <- ifelse(urban$longitude < center - 180 , urban$longitude + 360, urban$longitude)
### Function to regroup split lines and polygons
# takes dataframe, column with long and unique group variable, returns df with added column named group.regroup
RegroupElements <- function(df, longcol, idcol){
  g <- rep(1, length(df[,longcol]))
  if (diff(range(df[,longcol])) > 300) { # check if longitude within group differs more than 300 deg, ie if element was split
    d <- df[,longcol] > mean(range(df[,longcol])) # we use the mean to help us separate the extreme values
    g[!d] <- 1 # some marker for parts that stay in place (we cheat here a little, as we do not take into account concave polygons)
    g[d] <- 2 # parts that are moved
  }
  g <- paste(df[, idcol], g, sep=".") # attach to id to create unique group variable for the dataset
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
  o <- c(1: nrow(df)) # rassign the order variable
  df[,ordercol] <- o
  df
}

# now regroup
gcircles_TPE.rg <- ddply(gcircles_TPE, .(id), RegroupElements, "long.recenter", "id")
gcircles_PEK.rg <- ddply(gcircles_PEK, .(id), RegroupElements, "long.recenter", "id")
worldmap.rg <- ddply(worldmap, .(group), RegroupElements, "long.recenter", "group")

# close polys
worldmap.cp <- ddply(worldmap.rg, .(group.regroup), ClosePolygons, "long.recenter", "order") # use the new grouping var


# plot

ggplot()+
  geom_polygon(aes(long.recenter,lat,group=group.regroup), size = 0.2, fill="#0a0b1f", colour = "#0a0b1f", data=worldmap.cp)+
  geom_point(aes(longitude,latitude), shape='.',size = 0.2,colour="#fbffee", data= urban) +
  geom_line(aes(long.recenter,lat,group=group.regroup, color=From, alpha=freq), size=1,data= gcircles_TPE.rg)+  # set transparency here
  geom_line(aes(long.recenter,lat,group=group.regroup, color=From, alpha=freq), size=1, data= gcircles_PEK.rg)+  # set transparency here
#   scale_colour_gradient(low="yellow", high="#EE0000")+  # set color gradient here
  theme(plot.margin=unit(c(0,-5,-3,-5),'lines'),panel.margin = unit(0, "lines"),panel.background = element_rect(fill = "#000115"), panel.grid.minor = element_blank(), panel.grid.major = element_blank(), axis.ticks = element_blank(), axis.title.x = element_blank(), axis.title.y = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank(), legend.position = "none") +
  ylim(-100, 90)+ 
  coord_equal()