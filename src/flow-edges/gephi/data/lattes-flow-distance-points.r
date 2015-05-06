
library(ggplot2) 
points <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-instituition-degree-distance-calc.csv")
df <- data.frame(x = points$node,y=points$distance)

ggplot(df, aes(factor(x), y))+ 
	geom_boxplot()

ggplot(df,aes(x=x,y=y))+ 
	geom_point(alpha = 0.3)

points <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-instituition-degree-distance-point.csv")
df <- data.frame(x = points$node,y=points$distance,z=points$size)
ggplot(df,aes(x=x,y=y))+ 
	geom_point(aes(size=z))+
	scale_size("cylinders")

# id,name,country,flow_weighted,flow,distance,avg,distances_weigthed,avg
points <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-instituition-degree-distance-calc.csv")
df <- data.frame(x = seq(1,length(points$flow_weighted)),flow_weighted=points$flow_weighted,flow=points$flow,distance=points$distance,distances_weigthed=points$distances_weigthed)

ggplot(df,aes(x=x,y=flow_weighted))+ 
ggplot(df,aes(x=x,y=flow))+ 
ggplot(df,aes(x=x,y=distance))+ 
ggplot(df,aes(x=x,y=distances_weigthed))+ 
	geom_point(aes(size=flow))+
	scale_size("cylinders")

df <- data.frame(rank=rank2$rank,degree=rank2$degree)
ggplot(df,aes(x=rank,y=degree))+ 
	geom_point()+
	geom_abline(intercept = 20)