# http://dsgeek.com/2013/06/08/DrawingArcsonMaps.html\

library(maps)
require(rgdal)
library(ggplot2)
library(maptools)
library(geosphere)
library(grid)

draw.map <- function(ylim=c(0,85)) {
  # https://wwwn.cdc.gov/epiinfo/html/shapefiles.htm
  state.map <- readShapeSpatial("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/BR/br.shp")
  state.map.df <- fortify(state.map, region = "ADMIN_NAME")
  ggplot(state.map.df, aes(x=long, y=lat, group=group)) +
  # ggplot(map_data("state"), aes(x=long, y=lat, group=group)) +
  # ggplot(map_data("world", "brazil"), aes(x=long, y=lat, group=group)) +
    # geom_polygon(size = 0.2, fill="#F9F9F9") +
    # geom_polygon(state.map.df, size = 0.2, fill="#191919") +
    geom_polygon(size = 0.2, fill="#191919") +
    # geom_polygon(fill="#FFFFFF") +
    # geom_polygon(fill="#CCCCCC") +
    geom_path(size=0.2, colour = "grey65") +
    # coord_map("mercator", ylim=ylim, xlim=c(-180,180)) +
    theme(
      # line = element_blank(),
      # text = element_blank(),
      # line = element_blank(),
      # title = element_blank(),
      # rect = element_blank()
      # panel.background = element_blank(), 
      panel.background = element_rect(fill = "#000000", colour = NA), 
      panel.grid.minor = element_blank(), 
      panel.grid.major = element_blank(),  
      axis.ticks = element_blank(), 
      axis.title.x = element_blank(), 
      axis.title.y = element_blank(), 
      axis.text.x = element_blank(), 
      axis.text.y = element_blank()
    )
 }

bezier.curve <- function(p1, p2, p3) {
  n <- seq(0,1,length.out=50)
  bx <- (1-n)^2 * p1[[1]] +
    (1-n) * n * 2 * p3[[1]] +
    n^2 * p2[[1]]
  by <- (1-n)^2 * p1[[2]] +
    (1-n) * n * 2 * p3[[2]] +
    n^2 * p2[[2]]
  data.frame(lon=bx, lat=by)
}

bezier.uv.arc <- function(p1, p2) {
  # Get unit vector from P1 to P2
  u <- p2 - p1
  u <- u / sqrt(sum(u*u))
  d <- sqrt(sum((p1-p2)^2))

  # Calculate third point for spline
  m <- d / 2
  h <- floor(d * .2)

  # Create new points in rotated space 
  pp1 <- c(0,0)
  pp2 <- c(d,0)
  pp3 <- c(m, h)

  mx <- as.matrix(bezier.curve(pp1, pp2, pp3))

  # Now translate back to original coordinate space
  theta <- acos(sum(u * c(1,0))) * sign(u[2])
  ct <- cos(theta)
  st <- sin(theta)
  tr <- matrix(c(ct,  -1 * st, st, ct),ncol=2)
  tt <- matrix(rep(p1,nrow(mx)),ncol=2,byrow=TRUE)
  points <- tt + (mx %*% tr)

  tmp.df <- data.frame(points)
  colnames(tmp.df) <- c("lon","lat")
  tmp.df
}

bezier.uv.merc.arc <- function(p1, p2) {
  # Do a mercator projection of the latitude
  # coordinates
  pp1 <- p1
  pp2 <- p2
  pp1[2] <- asinh(tan(p1[2]/180 * pi))/pi * 180
  pp2[2] <- asinh(tan(p2[2]/180 * pi))/pi * 180

  arc <- bezier.uv.arc(pp1,pp2)
  arc$lat <-  atan(sinh(arc$lat/180 * pi))/pi * 180
  arc
}


# for (year in 1950:1950) {
# for (year in 1950:1955) {
# for (year in 1960:1960) {
# for (year in 2013:2013) {
# for (year in 1950:2013) {
for (year in 1965:2013) {
  print(paste("year-", year, "!", sep=""))

  flows <- read.csv(paste("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-state/data-latlon/lattes-flows-state-", year,".csv", sep="")) 
  flows <- flows[which(flows$trips>0),]
  
  gg <- NULL
  name <- paste("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-state/img-map-normal/map-",year,".png", sep="")
  # png(filename = name, width = 1800, height = 1000, type = )
  gg <- draw.map()
  for (i in 1:length(flows$trips)) {  
    p1 <- c(flows[i,]$oY, flows[i,]$oX)
    p2 <- c(flows[i,]$dY, flows[i,]$dX)
    arc <- bezier.uv.merc.arc(p1, p2)
    size <- (flows[i,]$trips/200)+0.01
    # colour <- "green"
    # colour <- "#1292db"
    colour <- "#EE0000"
    # colour <- "#6a6262"
    # gg <- gg + geom_path(data=as.data.frame(arc), size=0.6, aes(x=lon, y=lat, group=NULL))
    gg <- gg + geom_path(data=as.data.frame(arc), size=size, colour=colour, aes(x=lon, y=lat, group=NULL))
    # gg <- gg + geom_line(data=as.data.frame(arc), size=size, colour=colour, aes(x=lon, y=lat, group=NULL), arrow = arrow(type = "closed", length = unit(0.06, "inches")))
  }
  ggsave(filename=name, plot=gg, width=3, height=3, dpi=300)
  # gg
  # dev.off()
}
print("END")