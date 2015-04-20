remove_outliers <- function(x, na.rm = TRUE, ...) {
  qnt <- quantile(x, probs=c(.25, .75), na.rm = na.rm, ...)
  H <- 1.5 * IQR(x, na.rm = na.rm)
  y <- x
  y[x < (qnt[1] - H)] <- NA
  y[x > (qnt[2] + H)] <- NA
  y
}

file <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/interval/lattes-flow-interval.csv", sep=",",header=T, check.names = FALSE)

#### Histogram duration interval
hist(file$interval)
hist(file$interval, breaks = 20)
hist(file$interval, breaks = 20, col = "gray", labels = TRUE)
hist(file$interval[1:20000], breaks = 200, col = "gray")

#### Histogram duration interval
library(ggplot2) 
file$interval <- remove_outliers(file$interval)
ggplot(file, aes(x = interval, y = (..count..)/sum(..count..)))+ 
  geom_bar()+
  # xlab("duration interval") + ylab("count (%)")+ggtitle("Interval Frequency")+ 
  xlab("duration interval") + ylab("count (%)")+
  theme(
      title=element_text(size=14,face="bold"), 
      axis.text=element_text(size=14,face="bold"), 
      axis.title=element_text(size=14,face="bold"),
      axis.text.x=element_text(angle=-90)
  )+
  xlim(0, 50)


#### Boxplot duration by degree
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/interval/lattes-flow-interval2.csv")
ggplot(flow, aes(x=kind,y=years))+
  geom_boxplot(outlier.size=NA)+
  ylim(0, 15)+
  scale_x_discrete(limits=c("ensino-fundamental","ensino-medio","graduacao","especializacao", "mestrado", "doutorado","pos-doutorado"))

flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/interval/lattes-flow-interval3.csv")

