
library(Seurat)
library(dplyr)
library(ggplot2)
library(patchwork)
#readin
d<-read.csv("S:/Users/LXL/wk_figure4/FISH_analysis/Figure0926_update/data/FISH_FST_NormFlt_141_250926.csv")

e<-d[, 1:30]
expr_data <- e[, !(colnames(e) %in% "Eef2")]
expr_data <- t(expr_data) 
colnames(expr_data) <- d$CID

seurat_obj <- CreateSeuratObject(counts = expr_data)
seurat_obj$ST<-d$StrucType
seurat_obj$FT<-d$FuncType

seurat_obj <- NormalizeData(seurat_obj)
seurat_obj <- FindVariableFeatures(seurat_obj)
seurat_obj <- ScaleData(seurat_obj)
seurat_obj <- RunPCA(seurat_obj)
seurat_obj <- FindNeighbors(seurat_obj, dims = 1:6,k.param = 18)
seurat_obj <- FindClusters(seurat_obj, resolution = 0.31,algorithm = 1)
seurat_obj <- RunUMAP(seurat_obj, dims = 1:6,n.neighbors =20)
cell_colors <- c("0" = "#f8766d",   
                 "1" = "#619cff" )
DimPlot(seurat_obj, reduction = "umap", label = TRUE,pt.size=2,cols=cell_colors)

#cross table
cluster_celltype <- table(seurat_obj$seurat_clusters, seurat_obj$ST)
library(pheatmap)
pheatmap(cluster_celltype,
         cluster_rows = TRUE,    # 行聚类
         cluster_cols = FALSE,   # 列按顺序显示
         display_numbers = TRUE, # 显示比例
         color = colorRampPalette(c("white", "red"))(50))

## markers
Idents(seurat_obj)<-'seurat_clusters'
markers <- FindAllMarkers(seurat_obj)
library(dplyr)


#save seurat clusters
t<-as.data.frame(seurat_obj@meta.data)
write.csv(t,"S:/Users/LXL/wk_figure4/FISH_analysis/Analysis_basedata/20250718/seuratclusters_250718.csv")

## heatmap plot
gene_order3=c("Fezf2","Bcl11b","Bcl6","Sulf2","Etv1","Tac1","Penk","Syt6","Rbp4","Tshz2",
              "Satb2","Cux2","Rorb","Cck","Rasgrf2","Tbr1","Slc30a3","Rprm","Vglut1", "Otof",
              "C1ql3","Col6a1","Vip","Rspo1","Dkk3","Cdh9", "Lmo4", "Pvalb","Gad1")
library(ComplexHeatmap)
mat<-GetAssayData(seurat_obj,slot='scale.data')
cluster_info<-sort(seurat_obj$seurat_clusters)
mat<-as.matrix(mat[gene_order3,names(cluster_info)])

library(circlize)
col=colorRamp2(c(-2,0,2),c("blue","white","red"))
pdf("S:/Users/LXL/wk_figure4/FISH_analysis/Figure1001_update/heatmap1001.pdf",
    width = 6, height = 9)
Heatmap(mat,cluster_rows = FALSE,cluster_columns = FALSE,show_column_names = FALSE,column_split = cluster_info,col=col)
dev.off()

write.csv(t(mat), file = "S:/Users/LXL/wk_figure4/wk_website/prepare/Molecular/gene_mat.csv", row.names = TRUE) 
