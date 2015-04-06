library(ggplot2) 
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/interval/lattes-flow-interval.csv")

hist(flow$interval)
hist(flow$interval, breaks = 20)
hist(flow$interval, breaks = 20, col = "gray", labels = TRUE)
hist(flow$interval[1:20000], breaks = 200, col = "gray")

ggplot(flow, aes(x = interval, y = (..count..)/sum(..count..)))+ 
  geom_bar()+ 
  xlim(0, 15)


flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/interval/lattes-flow-interval2.csv")
ggplot(flow, aes(x=kind,y=years))+
	geom_boxplot(outlier.size=NA)+
	ylim(0, 15)+
	scale_x_discrete(limits=c("ensino-fundamental","ensino-medio","graduacao","especializacao", "mestrado", "doutorado","pos-doutorado"))


flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/interval/lattes-flow-interval3.csv")
