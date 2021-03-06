#Created by Giuseppe Rubens Pascucci (pascucci.1479790@studenti.uniroma1.it)
####################################################################
library(ggplot2)
library(ggsignif)
library(Rtsne)
library(RColorBrewer) 
library(pheatmap)
library(corrplot)
library(ggbeeswarm)

mycols <- c(Healthy = '#3780b2', 'CoV2+' = '#d7802f', 'MIS-C' = '#9da290', Kawasaki = '#bd377f')


# ================================================== FREQUENCY DATABASE ==================================================

freq1 <- read.table("DataIN/CD57_Dataset.txt", sep = "\t", header = T, check.names=F, stringsAsFactors = F)
rownames(freq) <- freq[,1]
Group <- freq[,2]
Age <- freq[,3]
Sex <- freq[,4]
freq <- freq[,-c(1:4)]


# ================================================== D'AGOSTINO-PEARSON FUNCTION ==================================================
dagostino.pearson.test <- function(x) {
  # from Zar (1999), implemented by Doug Scofield, scofield at bio.indiana.edu
  DNAME <- deparse(substitute(x))
  n <- length(x)
  x2 <- x * x
  x3 <- x * x2
  x4 <- x * x3
  # compute Z_g1
  k3 <- ((n*sum(x3)) - (3*sum(x)*sum(x2)) + (2*(sum(x)^3)/n)) /((n-1)*(n-2))
  g1 <- k3 / sqrt(var(x)^3)
  sqrtb1 <- ((n - 2)*g1) / sqrt(n*(n - 1))
  A <- sqrtb1 * sqrt(((n + 1)*(n + 3)) / (6*(n - 2)))
  B <- (3*(n*n + 27*n - 70)*(n+1)*(n+3)) / ((n-2)*(n+5)*(n+7)*(n+9))
  C <- sqrt(2*(B - 1)) - 1
  D <- sqrt(C)
  E <- 1 / sqrt(log(D))
  F <- A / sqrt(2/(C - 1))
  Zg1 <- E * log(F + sqrt(F*F + 1))
  # compute Z_g2
  G <- (24*n*(n-2)*(n-3)) / (((n+1)^2)*(n+3)*(n+5))
  k4 <- (((n*n*n + n*n)*sum(x4)) - (4*(n*n + n)*sum(x3)*sum(x)) - (3*(n*n - n)*sum(x2)^2) + (12*n*sum(x2)*sum(x)^2) - (6*sum(x)^4)) /(n*(n-1)*(n-2)*(n-3))
  g2 <- k4 / var(x)^2
  H <- ((n-2)*(n-3)*abs(g2)) / ((n+1)*(n-1)*sqrt(G))
  J <- ((6*(n*n - 5*n + 2)) / ((n+7)*(n+9))) * sqrt((6*(n+3)*(n+5)) /(n*(n-2)*(n-3)))
  K <- 6 + (8/J)*(2/J + sqrt(1 + 4/(J*J)))
  L <- (1 - 2/K) / (1 + H*sqrt(2/(K-4)))
  Zg2 <- (1 - 2/(9*K) - (L^(1/3))) / (sqrt(2/(9*K)))
  K2 <- Zg1*Zg1 + Zg2*Zg2
  pk2 <- pchisq(K2, 2, lower.tail=FALSE)
  RVAL <- list(statistic = c(K2 = K2), p.value = pk2, method = "D'Agostino-Pearson normality test\n\nK2 is distributed as Chi-squared with df=2", alternative = "distribution is not normal", data.name = DNAME)
  class(RVAL) <- "htest"
  return(RVAL)
}








# =========================================================== Differential Analysis ===========================================================

Group1 <- c("Kawasaki", "MIS-C", "MIS-C","MIS-C", "CoV2+","CoV2+")
Group2 <- c("Healthy", "Healthy", "CoV2+","Kawasaki", "Healthy", "Kawasaki")

t <- data.frame()

for(j in 1:length(Group1))
{
  
  x <- freq[Group %in% Group1[j]]
  y <- freq[Group %in% Group2[j]]
  
  # Normality Test
  norX <- dagostino.pearson.test(x)$p.value
  norY <- dagostino.pearson.test(y)$p.value
  
  # Differential Test
  pv <- wilcox.test(x, y, paired = F, exact = F)$p.value
  
  # Fold Change
  fc <- mean(x) / mean(y)
  
  # Final Table
  m <- cbind(Label = "CD3+CD4+/CD57+ | Freq. of Parent", Group1 = Group1[j], Group2 = Group2[j], Comparison = paste0(Group1[j], " vs ", Group2[j]), pValue = pv, pAdj = pv, log2FoldChange = round(log2(fc + 0.01), 2))
  t <- rbind(t, m)
  
}

rm(x, y, j, norX, norY, pv, fc)

write.table(t[,-c(2,3)], "DATAOUT_CD57/TableDiff All.txt", sep="\t", row.names = F, col.names = T,  quote = F)
t$pValue <- as.numeric(as.character(t$pValue))
t <- t[t$pValue < 0.05,]
write.table(t[,-c(2,3)], "DATAOUT_CD57/TableDiff DE.txt", sep="\t", row.names = F, col.names = T,  quote = F)



# =========================================================== Violin Plot ===========================================================

Group <- factor(Group, levels = c("Healthy", "CoV2+","MIS-C","Kawasaki"))
t2 <- t[t$Group1 %in% "CoV2+" | t$Group2 %in% "CoV2+" | t$Group1 %in% "MIS-C" | t$Group2 %in% "MIS-C",]
lab <- as.character(unique(t2$Label))


m <- t
viol <- as.data.frame(cbind(freq, Group))
colnames(viol) <- c("V1", "V2")

p <- ggplot(viol, aes(x=Group, y=V1, col = Group , fill = Group)) + ggtitle("CD3+CD4+/CD57+ | Freq. of Parent") + 
  scale_fill_manual(values=mycols) + scale_color_manual(values=mycols) +
  geom_violin(key_glyph = "point", position="dodge") +
  geom_jitter(shape=16, position=position_jitter(0.2), size=1.5, colour="black") +
  theme_minimal(base_size = 23) + 
  ylab("%") +
  theme(legend.position = "none", 
        axis.title.x=element_blank(), 
        axis.text.x = element_text(colour = mycols, face = "bold"), 
        plot.title = element_text(size=21, family="sans", face = "bold"), 
        axis.text = element_text(colour = "black", family = "sans", size = 23)) 

for(x in 1:nrow(m)) p <- p + geom_signif(comparisons = list(c(as.character(m[x, colnames(m) %in% "Group1"]), as.character(m[x, colnames(m) %in% "Group2"]))), 
                                                         annotation = paste0 ("p = ", format(as.numeric(as.character(m[x, colnames(m) %in% "pValue"])), scientific = T, digits = 2)), tip_length = 0, size = 0.9, col = "black", 
                                                         margin_top = x*0.07, textsize = 5.5, vjust = - 0.03)
p
ggsave(paste0("DATAOUT_CD57/Violin - CD3+CD4+CD57+ Freq. of Parent.pdf"), width = 8, height = 6)



  

