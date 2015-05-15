# http://patilv.com/USOpenCountries/
# https://github.com/patilv/USOpengreatcircles

library(ggplot2)
library(ggmap)
library(geosphere)
library(plyr)

mensbracket=read.csv("mensbracket.csv") 
ladiesbracket=read.csv("ladiesbracket.csv")
usopenbracket=rbind(mensbracket,ladiesbracket) # combining the two genders
usopencountry=as.data.frame(table(usopenbracket$country)) # number of players from different countries
colnames(usopencountry)=c("Country","Players") # modifying column names
# kable(head(usopencountry))
usopencountry=cbind(usopencountry,geocode(as.character(usopencountry$Country)))
# kable(head(usopencountry))

usopencountry[5,]$lon=18.383925 # Bosnia
usopencountry[5,]$lat=43.851882 # Bosnia
usopencountry[11,]$lon=33.3974183 # Cyprus
usopencountry[11,]$lat=35.1919937 # Cyprus
usopencountry[45,]$lon=174.885971 # New Zealand
usopencountry[45,]$lat=-40.900557 # New Zealand
nygeocode=geocode(as.character("New York City")) # This was fine

# Calculating routes 
routes = gcIntermediate(nygeocode, usopencountry[,c('lon', 'lat')], 200, breakAtDateLine=FALSE, addStartEnd=TRUE, sp=TRUE)

# fortifying the routes information to create a dataframe; function from ggplot's github site ... thanks to the comments section in AnthroSpace's post

fortify.SpatialLinesDataFrame = function(model, data, ...) {
  ldply(model@lines, fortify)
}

fortifiedroutes = fortify.SpatialLinesDataFrame(routes) 

# An id for each country
usopencountry$id=as.character(c(1:nrow(usopencountry))) 

# Merge fortified routes with usopencountry information
greatcircles = merge(fortifiedroutes, usopencountry, all.x=T, by="id") 

### Recentering the world map ####

center = 290 # takes positive values - US centered view is 260. This took a bit to figure out to avoid splitting of arcs in the final map.

# shifting coordinates to recenter great circles
greatcircles$long.recenter =  ifelse(greatcircles$long  < center - 180 , greatcircles$long + 360, greatcircles$long) 

# shifting coordinates to recenter worldmap
worldmap = map_data ("world")
worldmap$long.recenter =  ifelse(worldmap$long  < center - 180 , worldmap$long + 360, worldmap$long)

### Function to regroup split lines and polygons
# takes dataframe, column with long and unique group variable, returns df with added column named group.regroup
RegroupElements = function(df, longcol, idcol){  
  g = rep(1, length(df[,longcol]))
  if (diff(range(df[,longcol])) > 300) {          # check if longitude within group differs more than 300 deg, ie if element was split
    d = df[,longcol] > mean(range(df[,longcol])) # we use the mean to help us separate the extreme values
    g[!d] = 1     # some marker for parts that stay in place (we cheat here a little, as we do not take into account concave polygons)
    g[d] = 2      # parts that are moved
  }
  g =  paste(df[, idcol], g, sep=".") # attach to id to create unique group variable for the dataset
  df$group.regroup = g
  df
}

### Function to close regrouped polygons
# takes dataframe, checks if 1st and last longitude value are the same, if not, inserts first as last and reassigns order variable
ClosePolygons = function(df, longcol, ordercol){
  if (df[1,longcol] != df[nrow(df),longcol]) {
    tmp = df[1,]
    df = rbind(df,tmp)
  }
  o = c(1: nrow(df))  # rassign the order variable
  df[,ordercol] = o
  df
}

# regrouping
regroupedgreatcircles = ddply(greatcircles, .(id), RegroupElements, "long.recenter", "id")
regroupedworldmap = ddply(worldmap, .(group), RegroupElements, "long.recenter", "group")

# close polygons
worldmap.closedpolygons = ddply(regroupedworldmap, .(group.regroup), ClosePolygons, "long.recenter", "order")

ggplot() +
  geom_polygon(aes(long.recenter,lat,group=group.regroup), size = 0.1, fill="black", colour = "#4D4D4D", data=worldmap.closedpolygons) +
  geom_line(aes(long.recenter,lat.x,group=group.regroup, color=Country, alpha=Players), size=1,data= regroupedgreatcircles)+ 
  theme(panel.grid.minor = element_blank(), panel.grid.major = element_blank(),  axis.ticks = element_blank(), axis.title= element_blank(), 
         axis.text = element_blank(),legend.position = "none")+
  ylim(-60, 90) +theme(panel.background = element_rect(fill = 'black'))+
  coord_equal()+annotate("text",x=max(worldmap.closedpolygons$long.recenter),y=-60,hjust=.9,size=3,
label=paste("Arrival/Departures of US Open Players","your name",sep="\n"),color="white")