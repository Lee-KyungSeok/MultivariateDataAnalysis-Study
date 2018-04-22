# Package for cluster validity
install.packages("clValid")
install.packages("plotrix")

library(clValid)
library(plotrix)

# Load the Wine dataset
wine <- read.csv("wine.csv") # class �� ������ ǰ��

# Remove the class label # ���ο� ���� ������ �� ���̹Ƿ� class ����
wine_class <- wine[,1] 
wine_x <- wine[,-1]

# data scaling # distance�� ����� ���� ����ȭ(scaling) �۾��� �Ͽ� ����� 0����, ǥ�������� 1�� �ؾ� �� ������ �����ϰ� ����� �� �ְ� �ȴ�.
wine_x_scaled <- scale(wine_x, center = TRUE, scale = TRUE)

# Evaluating the cluster validity measures # � ������ ����ϴ� ���� ������ �Ǵ����ش�. 
wine_clValid <- clValid(wine_x_scaled, 2:10, clMethods = "kmeans",
                           validation = c("internal", "stability"))
summary(wine_clValid)

# Perform K-Means Clustering with the best K determined by Silhouette
wine_kmc <- kmeans(wine_x_scaled,3) # ���� kmeans �� ���ڰ� 3�� ��

str(wine_kmc)
wine_kmc$centers
wine_kmc$size
wine_kmc$cluster

# Compare the cluster info. and class labels (����������, ����ȭ ������ ���غ���.)
real_class <- wine_class
kmc_cluster <- wine_kmc$cluster
table(real_class, kmc_cluster)

# Compare each cluster for KMC
cluster_kmc <- data.frame(wine_x_scaled, clusterID = as.factor(wine_kmc$cluster))
kmc_summary <- data.frame() # �����ͼ� �ʱ�ȣ

## 1�� �������� 13�������� ���� �߿��� row�� ���ε��Ͽ� (���Ʒ��� ����ȭ�ڴ�) Ŭ�����ͺ��� ����ڴ�.
for (i in 1:(ncol(cluster_kmc)-1)){
  kmc_summary = rbind(kmc_summary, 
                     tapply(cluster_kmc[,i], cluster_kmc$clusterID, mean))
}

colnames(kmc_summary) <- paste("cluster", c(1:3))
rownames(kmc_summary) <- colnames(wine_x)
kmc_summary

# Radar chart
for (i in 1:3){
  plot_title <- paste("Radar Chart for Cluster", i, sep=" ") # �̸��� ����
  radial.plot(kmc_summary[,i], labels = rownames(kmc_summary), # ������, ���� ����
              radial.lim=c(-2,2), rp.type = "p", main = plot_title, #����, Ÿ��, Ÿ��Ʋ
              line.col = "red", lwd = 3, show.grid.labels=1) #��, �β�, ���̺�1 ��
}
dev.off()

# Compare the first and the second cluster
kmc_cluster1 <- wine_x[wine_kmc$cluster == 1,]
kmc_cluster2 <- wine_x[wine_kmc$cluster == 2,]

# t_test_result
kmc_t_result <- data.frame()

for (i in 1:13){
  
  kmc_t_result[i,1] <- t.test(kmc_cluster1[,i], kmc_cluster2[,i], 
                              alternative = "two.sided")$p.value  # �������� pvalue
  
  kmc_t_result[i,2] <- t.test(kmc_cluster1[,i], kmc_cluster2[,i], 
                              alternative = "greater")$p.value  # 1���� �� ũ�ٴ� �Ϳ� ���� pvalue
  
  kmc_t_result[i,3] <- t.test(kmc_cluster1[,i], kmc_cluster2[,i], 
                              alternative = "less")$p.value   # 1���� �� �۴ٴ� �Ϳ� ���� pvalue
}

kmc_t_result