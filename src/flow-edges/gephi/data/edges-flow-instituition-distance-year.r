library(ggplot2)
library(reshape2)

flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-instituition/edges-flow-instituition-distance-year-2010.csv", sep=",",header=T, check.names = FALSE)

# row.names(flow) <- flow[0,2:length(flow[0,])]
row.names(flow) <- flow$names
flow <- flow[,2:length(flow[0,])]
flow_matrix <- data.matrix(flow)
dat <- melt(flow_matrix, id.var = "X1")
# dat <- melt(log(flow_matrix), id.var = "X1")
# dat$value <- replace(dat$value, dat$value==-Inf, 0)

ggplot(dat, aes(as.factor(Var1), Var2, group=Var2)) +
  geom_tile(aes(fill = value)) + 
  # geom_text(aes(fill = dat$value, label = round(dat$value, 1)))+
  scale_fill_gradient(low = "white", high = "red")+
  theme(axis.text.x=element_text(angle=-90))

ggsave("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-instituition/edges-flow-instituition-distance-year-2010.png", width=12, height=10, dpi=300)