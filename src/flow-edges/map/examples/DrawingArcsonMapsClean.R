# http://dsgeek.com/2013/06/08/DrawingArcsonMaps.html\

library(ggplot2)
library(maptools)
library(geosphere)

draw.map <- function(ylim=c(0,85)) {
  ggplot(cntry.polys, aes(x=long, y=lat, group=group)) +
    geom_polygon(fill="#CCCCCC") +
    geom_path(size=0.1,color="white") +
    coord_map("mercator", ylim=ylim, xlim=c(-180,180)) +
    theme(
      line = element_blank(),
      text = element_blank(),
      line = element_blank(),
      title = element_blank(),
      rect = element_blank()
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


cntry.info <- data.frame(
  Country=c("United States", "Russia"),
  ISO3=c("USA","RUS"),
  latitude=c(38,60),
  longitude=c(-97,100),
  stringsAsFactors=FALSE
)

data(wrld_simpl)

ws <- fortify(wrld_simpl)

cntry.idxs  <- which(ws$id %in% cntry.info$ISO3)
cntry.polys <- ws[cntry.idxs,]

p1 <- c(cntry.info$longitude[1], cntry.info$latitude[1])
p2 <- c(cntry.info$longitude[2], cntry.info$latitude[2])
arc <- bezier.uv.merc.arc(p1, p2)

draw.map()#+
  # geom_path(data=as.data.frame(arc), aes(x=lon, y=lat, group=NULL))
