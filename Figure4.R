# Plasma protein analyses MIS-C (Figure 4)

# Load olink NPX (normalized prot expr)
olink <- read.csv("https://ki.box.com/shared/static/bw23kqxcnnqp91r9qjqo8tga8zsh6pc3.csv", header = T, row.names = 1, check.names = FALSE) #184 proteins
# Ddetect number of samples with limit of detection (LOD)
num_LOD <- apply(olink, 2, function(x) length(which(x[1:90] == x[91])) )
olink <- rbind(olink, num_LOD)
rownames(olink)[92] <- "n_LOD"
olink <- olink[-91,]
# Remove proteins from analysis where more than 30% of samples have LOD (30% of 90 is 27)
olink <- olink[,-which(olink[91,] > 27)] # 123 proteins
olink <- olink[-91,] #remove lod_n info
#average out duplicated proteins
# IL6
olink$IL6x <- rowMeans(cbind(olink$IL6, olink$IL6.1), na.rm=TRUE)
# CCL11
olink$CCL11z <- rowMeans(cbind(olink$CCL11, olink$CCL11.1), na.rm=TRUE)
# Remove
olink$IL6 <- NULL
olink$IL6.1 <- NULL
olink$CCL11 <- NULL
olink$CCL11.1 <- NULL
# Rename
which(colnames(olink) == "IL6x")
colnames(olink)[120] <- "IL6"
which(colnames(olink) == "CCL11z")
colnames(olink)[121] <- "CCL11"
# Remove healthy adults from olink df
olink <- subset(olink, !(grepl("HC", rownames(olink) )) )


# PCA
library(ggplot2)
library(factoextra)
library(ggrepel)

pca <- prcomp(na.omit(olink), scale. = T)
pca_x <- as.data.frame(pca$x)

# Add grouping variables
IDs <- read.csv("https://ki.box.com/shared/static/iz1u31r2fv13xzcmg3f1xazyys1humgl.csv", row.names = 1, header = T, stringsAsFactors = FALSE)
pca_x <- merge(IDs, pca_x, by.x="ID", by.y="row.names", sort=FALSE)
pca_x$Group <- factor(pca_x$Group, levels = c("Healthy", "CoV2+", "MIS-C", "Kawasaki"))

#grouping variable for geom_repel
pca_x$ID2 <-pca_x$ID
pca_x$ID2 <- ifelse(
  str_detect(pca_x$ID, "CACTUS 023"),
  pca_x$ID2 <- pca_x$ID,
  ifelse(
    str_detect(pca_x$ID, "CACTUS 032"),
    pca_x$ID2 <- pca_x$ID,
    ifelse(
      str_detect(pca_x$ID, "CACTUS 004"),
      pca_x$ID2 <- pca_x$ID,
      pca_x$ID2 <- NA )))
#grouping variable for geom_line
pca_x$ID3 <- ifelse(
  str_detect(pca_x$ID, "CACTUS 023"),
  pca_x$ID3 <- "CACTUS 023",
  ifelse(
    str_detect(pca_x$ID, "CACTUS 032"),
    pca_x$ID3 <- "CACTUS 032",
    ifelse(
      str_detect(pca_x$ID, "CACTUS 004"),
      pca_x$ID3 <- "CACTUS 004",
      pca_x$ID3 <- pca_x$ID )))

# Screeplot
scree <- fviz_eig(pca)
screedata <- scree$data
sum(screedata$eig[1:5]) #Principal comp 1:5 explain 62.56293% of variation in data


#PCA pairs  PC1:PC5
PCA12 <- ggplot(pca_x, aes(x=PC1, y=PC2)) + geom_point(aes(color=Group)) + theme_bw() +
  theme(legend.title = element_blank()) + geom_line(aes(group=ID3)) +
  geom_text_repel(
    data = pca_x, 
    aes(label = ID2),
    size = 0.8,
    segment.size = 0.05,
    segment.colour = "black") +
  scale_color_manual(values=c("#2F8AC4", "#E48725", "#A5AA99", "#CD3A8E"))

PCA13 <- ggplot(pca_x, aes(x=PC1, y=PC3)) + geom_point(aes(color=Group)) + theme_bw() +
  theme(legend.title = element_blank()) + geom_line(aes(group=ID3)) +
  geom_text_repel(
    data = pca_x, 
    aes(label = ID2),
    size = 0.8,
    segment.size = 0.05,
    segment.colour = "black") +
  scale_color_manual(values=c("#2F8AC4", "#E48725", "#A5AA99", "#CD3A8E"))

PCA23 <- ggplot(pca_x, aes(x=PC2, y=PC3)) + geom_point(aes(color=Group)) + theme_bw() +
  theme(legend.title = element_blank()) + geom_line(aes(group=ID3)) +
  geom_text_repel(
    data = pca_x, 
    aes(label = ID2),
    size = 0.8,
    segment.size = 0.05,
    segment.colour = "black") +
  scale_color_manual(values=c("#2F8AC4", "#E48725", "#A5AA99", "#CD3A8E"))

PCA14 <- ggplot(pca_x, aes(x=PC1, y=PC4)) + geom_point(aes(color=Group)) + theme_bw() +
  theme(legend.title = element_blank()) + geom_line(aes(group=ID3)) +
  geom_text_repel(
    data = pca_x, 
    aes(label = ID2),
    size = 0.8,
    segment.size = 0.05,
    segment.colour = "black") +
  scale_color_manual(values=c("#2F8AC4", "#E48725", "#A5AA99", "#CD3A8E"))

PCA24 <- ggplot(pca_x, aes(x=PC2, y=PC4)) + geom_point(aes(color=Group)) + theme_bw() +
  theme(legend.title = element_blank()) + geom_line(aes(group=ID3)) +
  geom_text_repel(
    data = pca_x, 
    aes(label = ID2),
    size = 0.8,
    segment.size = 0.05,
    segment.colour = "black") +
  scale_color_manual(values=c("#2F8AC4", "#E48725", "#A5AA99", "#CD3A8E"))

PCA34 <- ggplot(pca_x, aes(x=PC3, y=PC4)) + geom_point(aes(color=Group)) + theme_bw() +
  theme(legend.title = element_blank()) + geom_line(aes(group=ID3)) +
  geom_text_repel(
    data = pca_x, 
    aes(label = ID2),
    size = 0.8,
    segment.size = 0.05,
    segment.colour = "black") +
  scale_color_manual(values=c("#2F8AC4", "#E48725", "#A5AA99", "#CD3A8E"))

PCA15 <- ggplot(pca_x, aes(x=PC1, y=PC5)) + geom_point(aes(color=Group)) + theme_bw() +
  theme(legend.title = element_blank()) + geom_line(aes(group=ID3)) +
  geom_text_repel(
    data = pca_x, 
    aes(label = ID2),
    size = 0.8,
    segment.size = 0.05,
    segment.colour = "black") +
  scale_color_manual(values=c("#2F8AC4", "#E48725", "#A5AA99", "#CD3A8E"))

PCA25 <- ggplot(pca_x, aes(x=PC2, y=PC5)) + geom_point(aes(color=Group)) + theme_bw() +
  theme(legend.title = element_blank()) + geom_line(aes(group=ID3)) +
  geom_text_repel(
    data = pca_x, 
    aes(label = ID2),
    size = 0.8,
    segment.size = 0.05,
    segment.colour = "black") +
  scale_color_manual(values=c("#2F8AC4", "#E48725", "#A5AA99", "#CD3A8E"))

PCA35 <- ggplot(pca_x, aes(x=PC3, y=PC5)) + geom_point(aes(color=Group)) + theme_bw() +
  theme(legend.title = element_blank()) + geom_line(aes(group=ID3)) +
  geom_text_repel(
    data = pca_x, 
    aes(label = ID2),
    size = 0.8,
    segment.size = 0.05,
    segment.colour = "black") +
  scale_color_manual(values=c("#2F8AC4", "#E48725", "#A5AA99", "#CD3A8E"))

PCA45 <- ggplot(pca_x, aes(x=PC4, y=PC5)) + geom_point(aes(color=Group)) + theme_bw() +
  theme(legend.title = element_blank()) + geom_line(aes(group=ID3)) +
  geom_text_repel(
    data = pca_x, 
    aes(label = ID2),
    size = 0.8,
    segment.size = 0.05,
    segment.colour = "black") +
  scale_color_manual(values=c("#2F8AC4", "#E48725", "#A5AA99", "#CD3A8E"))

# cowplot arrange plots
library(cowplot)
legend <- get_legend(PCA45 + theme(legend.box.margin = margin(0, 0, 0, 12)) ) # create some space to the left of the legend

#Figure 4A
plot_grid(PCA12 + theme(legend.position="none"), NULL, NULL, legend, 
          PCA13+ theme(legend.position="none"), PCA23+ theme(legend.position="none"), NULL, NULL, 
          PCA14+ theme(legend.position="none"), PCA24+ theme(legend.position="none"), PCA34+ theme(legend.position="none"), NULL, 
          PCA15+ theme(legend.position="none"), PCA25+ theme(legend.position="none"), PCA35+ theme(legend.position="none"), PCA45 + theme(legend.position="none"),
          ncol = 4)



#Figure 4B
#top 25 loadings in PC2
load_PC2 <- fviz_pca_var(pca,
                         axes = c(2,2),
                         col.var = "contrib", 
                         gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                         repel = TRUE,
                         labelsize=2,
                         select.var = list(contrib = 25) ) 

load_PC2data <- as.data.frame(load_PC2$data)
load_PC2data <- load_PC2data[order(load_PC2data$x, decreasing = T),]
load_PC2data$name <- factor(load_PC2data$name, levels = load_PC2data$name)
ggplot(load_PC2data, aes(x=name, y=x)) +
  geom_segment( aes(x=name, xend=name, y=0, yend=x), color="grey") +
  geom_point( color="#A5AA99", size=4) +
  theme_light() +
  theme(
    panel.grid.major.x = element_blank(),
    panel.border = element_blank(),
    axis.ticks.x = element_blank() ) +
  xlab("") +
  ylab("Contribution to PC2")


#Figure 4C
#merge olink with ID, melt df
olink1 <- merge(IDs, olink, by.x="ID", by.y="row.names", sort=FALSE)
melt_olink <- melt(olink1, id.vars = c("ID", "Group", "Group2"))
melt_olink <- melt_olink[!(melt_olink$Group2 %in% "MIS-C_treated"),] #remove MIS-C treated
melt_olink$Group <- factor(melt_olink$Group, levels = c("Healthy","CoV2+","MIS-C", "Kawasaki"))
Fig4CDE <- c("IL6", "IL-17A", "CXCL10", "NT-3", "TWEAK", "SCF", "DCBLD2", "MMP-10", "MCP-4")
melt_olink_top <- subset(melt_olink, variable %in% Fig4CDE)
melt_olink_top$variable <- factor(melt_olink_top$variable, levels = Fig4CDE)
#Violin plots
ggplot(melt_olink_top, aes(x=Group, y=value)) + theme_minimal() + 
  geom_violin(aes(fill=Group, colour=Group)) +
  facet_wrap(~ variable, scales = "free", ncol = 3) + 
  geom_jitter(shape=16, position=position_jitter(0.2), size=0.8, colour="black") +
  ggtitle("Plasma proteins") +
  scale_fill_manual(values=c("#2F8AC4", "#E48725", "#A5AA99", "#CD3A8E")) +
  scale_color_manual(values=c("#2F8AC4", "#E48725", "#A5AA99", "#CD3A8E")) +
  theme(axis.text.x = element_text(size = 5), legend.title = element_blank()) + labs(x=NULL, y="NPX") 


#Statistics for Figure 4C
MISC_Untreated <- c("CACTUS 023", "CACTUS 004", "CACTUS 032")
kawa <- rownames(subset(olink, grepl("Kawasaki", rownames(olink))))
kd_MISC <- c(MISC_Untreated, kawa)
olink_kd_MISC <- olink1[olink1$ID %in% kd_MISC, c(Fig4CDE, "ID", "Group", "Group2")]
lapply(olink_kd_MISC[,-(10:12)], function(i) t.test(i ~ olink_kd_MISC$Group)$p.value )













