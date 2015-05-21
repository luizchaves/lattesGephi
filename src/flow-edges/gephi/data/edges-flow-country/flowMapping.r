library(maps)
library(ggplot2)
library(maptools)
library(geosphere)
library(grid)

draw.map <- function(year, ylim=c(0,85)) {
  ggplot(map_data("world"), aes(x=long, y=lat, group=group)) +
    # geom_polygon(size = 0.2, fill="#191919") + # fill = #FFFFFF, #CCCCCC, #F9F9F9
    geom_polygon(size = 0.2, fill="#FFFFFF") +
    geom_path(size=0.2, colour = "grey65") +
    # coord_map("mercator", ylim=ylim, xlim=c(-180,180)) +
    theme(
      panel.background = element_blank(), 
      # panel.background = element_rect(fill = "#000000", colour = NA),
      panel.grid.minor = element_blank(), 
      panel.grid.major = element_blank(),  
      axis.ticks = element_blank(), 
      axis.title.x = element_blank(), 
      axis.title.y = element_blank(), 
      axis.text.x = element_blank(), 
      axis.text.y = element_blank(),
      plot.title = element_text(size = rel(3))
    )+
    ggtitle(paste("Flow",year, sep=""))
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
  # http://dsgeek.com/2013/06/08/DrawingArcsonMaps.html\
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


# for (year in 2013:2013) {
# for (year in 1960:1960) {
for (year in 1960:2013) {
  print(paste("year-", year, "!", sep=""))

  #white/black
  # theme <- "black" 
  theme <- "white" 

  path <- "~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-country/"
  file_map <- paste(path,"img-map-", theme, "-normal/map-",year,".png", sep="")
  file_data <- paste(path,"data-latlon/lattes-flows-country-", year,".csv", sep="")
  
  flows <- read.csv(file_data) 
  flows <- flows[which(flows$trips>0),]
  
  png(filename = file_map, width = 1400, height = 750)
  gg <- NULL
  gg <- draw.map(year, c(-90,90))
  for (i in 1:length(flows$trips)) {  
    arc <- bezier.uv.merc.arc(
      c(flows[i,]$oY, flows[i,]$oX), 
      c(flows[i,]$dY, flows[i,]$dX)
    )
    size <- (flows[i,]$trips/50)+0.1 #/100+0.01
    colour <- "#EE0000" # green, #1292db, #6a6262
    gg <- gg + geom_path(
      data=as.data.frame(arc), 
      size=size, 
      colour=colour, 
      aes(x=lon, y=lat, group=NULL)
    ) # size=0.6 / arrow = arrow(type = "closed", length = unit(0.06, "inches"))
  }
  print(gg)
  dev.off()
  # ggsave(filename=file_map, plot=gg, width=5, height=3, dpi=300)
}
print("END")