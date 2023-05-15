############################################################################
# 
# Author: Daniel M. Griffith
# Date: 5/15/2023
# Description: The FIA and VegCAMP vegetation data used in this study were 
# obtained through inter-agency data sharing agreements. FIA data can be 
# obtained online (https://apps.fs.usda.gov/fia/datamart/datamart.html), with 
# exact coordinates fuzzed and swapped to protect landowner privacy per the Food
# Security Act. Details for VegCAMP are online 
# (https://wildlife.ca.gov/Data/VegCAMP). Vegbank data are openly available 
# online (http://vegbank.org/). Code for completing the core analyses is 
# available below and has been stripped of components that would reveal
# protected information. As a result, this document presents pseudocode.
#
############################################################################

# SET WD TO SCRIPT LOCATION
  setwd(".")

# LOAD LIBRARIES
  library(ape)
  library(picante)
  library(plantspec)
  library(indicspecies)
  library(labdsv)
  library(sf)
  library(terra)
  library(vegan)

  options(stringsAsFactors = FALSE)

# DATA
  # Clusters from Figure S2. NA = 0
    k15_cda <- rast("data/k15_cda.tif") 
  # Tree from Thornhill et al. 2017
    ca_tree <- read.nexus(file = "California_clades_fully_dated.nex")
  
  # extracting plots redacted
    
# Indicator Species Analysis  
  lft_indicators <- multipatt(x = redacted_veg, cluster = plot_clusters$k15_cda)
  summary(lft_indicators)
  
# MDS
  cluster_ord <- metaMDS(veg)

# FIND nodes for LFTs  
  ca_tree$node.label <- paste0("nd", seq_len(ca_tree$Nnode))
  nodelist <- ca_tree$node.label
  all_clade <- lapply(X = nodelist, FUN = function(x){extract.clade(phy = ca_tree, node = x, collapse.singles = FALSE)})
  all_clade.clusters <- lapply(X = all_clade, FUN = function(x){spp_clusters[x$tip.label]})
  names(all_clade.clusters) <- nodelist
  all_clade.counts <- unlist(lapply(X = all_clade.clusters, FUN = function(x){length(unique(x))}))    
  # The remaining code here combines clades but included calls to plot data. 
  
# SVM model   
  svm.model <- readRDS("svm_model.RData") # includes identifing information
  forsvm <- readRDS("dataforsvm.RData") # includes identifing information
  
  cda_all <- as.matrix(data.frame(cda_all)) # cda transformed data 
  colnames(cda_all) <- colnames(forsvm)
  
  lft_classification <- predict(svm.model, cda_all)    
    
    
    
  