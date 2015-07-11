rank <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/rank/rank.csv")

# http://flowingdata.com/2010/02/11/an-easy-way-to-make-a-treemap/
# library(portfolio)
# map.market(id=rank$id,area=rank$grau,group=rank$group,color=rank$colour)

# https://github.com/mtennekes/treemap
# http://cran.r-project.org/web/packages/treemap/treemap.pdf
library(treemap)
df <- data.frame(index=rank$id,vSize=rank$grau,vColor=rank$grau)
treemap(df,
       index="index",
       vSize="vSize",
       vColor="vColor",
       type="value")