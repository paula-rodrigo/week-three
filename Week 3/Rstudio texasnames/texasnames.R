# install igraph; this might take a long time
# you only run this line the first time you install igraph:
install.packages('igraph')
# now tell RStudio you want to use the igraph pacakge and its functions:
library('igraph')
# now let's load up the data by putting the csv files into nodes and links.
nodes <- read.csv("texasnodes.csv", header=T, as.is=T)
links <- read.csv("texaslinks.csv", header=T, as.is=T)
#examine data
head(nodes)
head(links)
# which gives the number of nodes in our data
nrow(nodes); length(unique(nodes$id))

nrow(links); nrow(unique(links[,c("source", "target")]))
# which gives the number of sources, and number of targets
# which means some people sent more than one letter, and some people received more than one letter
links <- aggregate(links[,3], links[,-3], sum)

links <- links[order(links$target, links$source),]

colnames(links)[3] <- "weight"

rownames(links) <- NULL

head(links)

# let's make a net
# notice that we are telling igraph that the network is directed, that the relationship Alice to Bob is different than Bob's to Alice (Alice is the _sender_, and Bob is the _receiver_)
# OR Newer version of igraph in desktop RStudio:
net <- graph_from_data_frame(d=links, vertices=nodes, directed=T)
# type 'net' again and run the line to see how the network is represented.
net
# let's visualizae it
plot(net, edge.arrow.size=.4,vertex.label=NA)
## the 'degree' of a node is the count of its connections. In this code chunk, we calculate degree, then make both a histogram of the counts and a plot of the network where we size the nodes proportionately to their degree. What do we learn from these two visualizations?
deg <- degree(net, mode="all")
hist(deg, breaks=1:vcount(net)-1, main="Histogram of node degree")
plot(net, vertex.size=deg*2, vertex.label = NA)
## write this info to file for safekeeping
write.csv(deg, 'degree.csv')
## now we look at closeness
closepeople <- closeness(net, mode="all", weights=NA)
sort(closepeople, decreasing = T) # so that we see who is most close first
write.csv(closepeople, 'closeness.csv') # so we have it on file.

hs <- hub_score(net, weights=NA)$vector
as <- authority_score(net, weights=NA)$vector

par(mfrow=c(1,2))

# vertex.label.cex sets the size of the label; play with the sizes until you see something appealing.
plot(net, vertex.size=hs*40, vertex.label.cex =.2, edge.arrow.size=.15, main="Hubs")
plot(net, vertex.size=as*20, vertex.label = NA, edge.arrow.size=.15, main="Authorities")
write.csv(hs, 'hub_score.csv') # so we have it on file.
write.csv(as, 'authority_score.csv') # so we have it on file.
# looking for modules
cfg <- cluster_fast_greedy(as.undirected(net))

lapply(cfg, function(x) write.table( data.frame(x), 'cfg.csv'  , append= T, sep=',' )

plot(cfg, net, vertex.size = 1, vertex.label.cex =.2, edge.arrow.size=.1, main="Communities")
# making it pretty
l1 <- layout_with_fr(net)

plot(cfg, net, layout=l1, vertex.size = 1, vertex.label.cex =.2, edge.arrow.size=.1, main="Communities")



