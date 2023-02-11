############################################################################################
####################### Data Science for Business Group Project  ###########################
################################ Section B Team 25 #########################################

library("dplyr") 
library("ggplot2")
library(pROC)
library(tree)
library(randomForest)
install.packages("corrplot")
library(corrplot)

data <- read.csv(file.choose()) # Trainingset_all.csv

################################## Data Cleaning ##########################################
# 
data$Y_skip1 <- NA
data$Y_skip2 <- NA
data$Y_skip3 <- NA

# the song is skipped very briefly
data[(data$skip_3=="True")&(data$skip_2=="True")&(data$skip_1=="True"), ]$Y_skip1 <- 1
data[is.na(data$Y_skip1), ]$Y_skip1 <- 0
# the song is skipped briefly
data[(data$skip_3=="True")&(data$skip_2=="True")&(data$skip_1=="False"), ]$Y_skip2 <- 1
data[is.na(data$Y_skip2), ]$Y_skip2 <- 0
# most of the song is played
data[(data$skip_3=="True")&(data$skip_2=="False")&(data$skip_1=="False"), ]$Y_skip3 <- 1
data[is.na(data$Y_skip3), ]$Y_skip3 <- 0
# the entire song is played
data$Y_noskip <- ifelse(data$not_skipped=="True", 1, 0)

# create dummies for categorical data
data$shuffle <- ifelse(data$hist_user_behavior_is_shuffle=="True", 1, 0)
data$premium <- ifelse(data$premium=="True", 1, 0)
table(data$context_type)
data$context_catalog <- ifelse(data$context_type=="catalog", 1, 0)
data$context_charts <- ifelse(data$context_type=="charts", 1, 0)
data$context_editorial <- ifelse(data$context_type=="editorial_playlist", 1, 0)
data$context_personalized <- ifelse(data$context_type=="personalized_playlist", 1, 0)
data$context_radio <- ifelse(data$context_type=="radio", 1, 0)
data$context_collection <- ifelse(data$context_type=="user_collection", 1, 0)
table(data$hist_user_behavior_reason_start)
data$reason_start_appload <- ifelse(data$hist_user_behavior_reason_start=="appload", 1, 0)
data$reason_start_backbtn <- ifelse(data$hist_user_behavior_reason_start=="backbtn", 1, 0)
data$reason_start_clickrow <- ifelse(data$hist_user_behavior_reason_start=="clickrow", 1, 0)
data$reason_start_endplay <- ifelse(data$hist_user_behavior_reason_start=="endplay", 1, 0)
data$reason_start_fwdbtn <- ifelse(data$hist_user_behavior_reason_start=="fwdbtn", 1, 0)
data$reason_start_playbtn <- ifelse(data$hist_user_behavior_reason_start=="playbtn", 1, 0)
data$reason_start_remote <- ifelse(data$hist_user_behavior_reason_start=="remote", 1, 0)
data$reason_start_trackdone <- ifelse(data$hist_user_behavior_reason_start=="trackdone", 1, 0)
data$reason_start_trackerror <- ifelse(data$hist_user_behavior_reason_start=="trackerror", 1, 0)
table(data$hist_user_behavior_reason_end)
data$reason_end_appload <- ifelse(data$hist_user_behavior_reason_end=="appload", 1, 0)
data$reason_end_backbtn <- ifelse(data$hist_user_behavior_reason_end=="backbtn", 1, 0)
data$reason_end_clickrow <- ifelse(data$hist_user_behavior_reason_end=="clickrow", 1, 0)
data$reason_end_endplay <- ifelse(data$hist_user_behavior_reason_end=="endplay", 1, 0)
data$reason_end_fwdbtn <- ifelse(data$hist_user_behavior_reason_end=="fwdbtn", 1, 0)
data$reason_end_logout <- ifelse(data$hist_user_behavior_reason_end=="logout", 1, 0)
data$reason_end_remote <- ifelse(data$hist_user_behavior_reason_end=="remote", 1, 0)
data$reason_end_trackdone <- ifelse(data$hist_user_behavior_reason_end=="trackdone", 1, 0)

# extra variables
data$date_lag <- lag(data$date, 1)
data$date_switch <- NA
data[(data$session_position==1),]$date_switch <- 0
data[(data$session_position!=1)&(data$date!=data$date_lag),]$date_switch <- 1
data[(data$session_position!=1)&(data$date==data$date_lag),]$date_switch <- 0

drop <- c("session_id", "track_id_clean", "skip_1", "skip_2", "skip_3", "not_skipped", "date", "hist_user_behavior_is_shuffle", "context_type", 
          "hist_user_behavior_reason_start", "hist_user_behavior_reason_end", "date_lag")
# keep Y, Y_skip1, Y_skip2, Y_skip3, Y_noskip
data.clean <- data[, !(names(data) %in% drop)]

####################### Data Understanding & Preparation ###################################
# Visualizations

# 1.
# Top 5 tracks played
table_track <- data.frame(table(data$track_id_clean))
ggplot(head(table_track[order(table_track$Freq, decreasing=TRUE), ], n=5), 
       aes(c(1,2,3,4,5), Freq))+geom_bar(stat='identity', fill='grey')+
  geom_text(aes(label = signif(Freq)), nudge_y = 5) + 
  xlab('Track') + ylab('Number of times the track was played')+ggtitle('Top 5 Tracks Played')

# 2.
# Session length distribution
table_length <- aggregate(data=data, session_id~session_length, function(x) length(unique(x)))
table_length
ggplot(table_length, 
       aes(session_length, session_id))+geom_bar(stat='identity', fill='grey')+
  geom_text(aes(label = signif(session_id)), nudge_y = 5) +
  xlab('Length of Sessions') + ylab('Number of Sessions') + ggtitle('Distribution of Session Length')

# 3.
# Skip rates by different session length








# 4.
# Skip rates by different context type







# 5.
# Correlation Matrix

correlation.col <- c("session_position", "session_length", "context_switch", "reason_end_trackdone", "reason_end_backbtn",
                     "reason_start_fwdbtn", "reason_start_clickrow", "reason_start_appload", "reason_start_trackdone", 
                     "reason_start_backbtn", "Y_noskip", "Y_skip3")
data_corr <- data.clean[, correlation.col]
# Lets compute the correlation matrix (just need to call cor with the dataframe)
CorMatrix <- cor(data_corr)
# First Column of that matrix corresponds to weight vs. all variables:
CorMatrix[,1]
### Since we are talking about corelations we can visualize things a bit better. install and load package for displaying correlation matrix
corrplot(CorMatrix, method = "square")

#################################### K-means Clustering ####################################
xdata <- model.matrix(Y_skip1~.-Y_skip2-Y_skip3-Y_noskip-Y_skip1_fac, data=data.clean)[,-1]
xdata <- scale(xdata)
xdata <- as.data.frame(xdata)

# Set k = 6
# (Takes Over One Hour to Run)
SixCenters <- kmeans(xdata, 6 ,nstart=30)
SixCenters$size

# Variation explained with 6 clusters: 25%
1 - SixCenters$tot.withinss/ SixCenters$totss

# Centroids of the clusters
centers_6 <- data.frame(SixCenters$centers)

# Assign each row a cluster
data.clean$cluster <- factor(SixCenters$cluster)
cl1 = data.clean[data.clean$cluster=='1',]
cl2 = data.clean[data.clean$cluster=='2',]
cl3 = data.clean[data.clean$cluster=='3',]
cl4 = data.clean[data.clean$cluster=='4',]
cl5 = data.clean[data.clean$cluster=='5',]
cl6 = data.clean[data.clean$cluster=='6',]

# Calculate mean of each feature across every cluster
tc1 <- as.data.frame(summary(cl1))
tc1_mean <- tc1[c(seq(4, 208, length=35)), ]
tc2 <- as.data.frame(summary(cl2))
tc2_mean <- tc2[c(seq(4, 208, length=35)), ]
tc3 <- as.data.frame(summary(cl3))
tc3_mean <- tc3[c(seq(4, 208, length=35)), ]
tc4 <- as.data.frame(summary(cl4))
tc4_mean <- tc4[c(seq(4, 208, length=35)), ]
tc5 <- as.data.frame(summary(cl5))
tc5_mean <- tc5[c(seq(4, 208, length=35)), ]
tc6 <- as.data.frame(summary(cl6))
tc6_mean <- tc6[c(seq(4, 208, length=35)), ]
tc <- data.frame()
tc <- cbind(tc1_mean, tc2_mean$Freq, tc3_mean$Freq, tc4_mean$Freq, tc5_mean$Freq, tc6_mean$Freq)
View(tc)

########################################## K-Fold CV (skip_1) ############################################
# data.clean <- read.csv(file.choose())
# data.clean <- data.clean[, !(names(data.clean) %in% c("X"))]
data.clean$Y_skip1_fac <- factor(data.clean$Y_skip1)

set.seed(1)

# Set k = 5
nfold <- 5
n <- nrow(data.clean)
# foldid_csv <- read.csv(file.choose())
# foldid <- foldid_csv$x
foldid <- rep(1:nfold, each=ceiling(n/nfold))[sample(1:n)]
OOS_accuracy <- data.frame(logistic.regression=rep(NA,nfold), tree=rep(NA,nfold), random.forest=rep(NA,nfold)) 

for(k in 1:nfold){
  train <- which(foldid!=k)
  # logistic regression
  cv.logistic <- glm(Y_skip1~.-Y_skip2-Y_skip3-Y_noskip-Y_skip1_fac, data=data.clean[train,], family='binomial')
  cv.logistic.pred <- predict(cv.logistic, newdata=data.clean[-train,])
  OOS_AUC$logistic.regression[k] <- auc((cv.logistic.pred >= 0.5) , data.clean[-train,]$Y_skip1)
  confusion <- table(data.clean[-train,]$Y_skip1, (cv.logistic.pred >= 0.5))
  OOS_accuracy$logistic.regression[k] <- (confusion[2, 2] + confusion[1, 1]) / sum(confusion)
  
  # tree
  cv.tree <- tree(Y_skip1_fac~.-Y_skip1-Y_skip2-Y_skip3-Y_noskip, data=data.clean[train,])
  cv.tree.pred <- predict(cv.tree, newdata=data.clean[-train,])
  OOS_AUC$tree[k] <- auc((cv.tree.pred[,2] >= 0.5) , data.clean[-train,]$Y_skip1)
  confusion <- table(data.clean[-train,]$Y_skip1, (cv.tree.pred[,2] >= 0.5))
  OOS_accuracy$tree[k] <- (confusion[2, 2] + confusion[1, 1]) / sum(confusion)
  
  # random forest
  maxNodes <- 300
  nodesize <- 800
  ntree <- 300
  mtry <- 6
  cv.rf <- randomForest(Y_skip1_fac~.-Y_skip1-Y_skip2-Y_skip3-Y_noskip, data=data.clean[train,], nodesize=nodesize, ntree = ntree, mtry = mtry)
  cv.rf.pred <- predict(cv.rf, newdata=data.clean[-train,])
  OOS_AUC$random.forest[k] <- auc(cv.rf.pred, data.clean[-train,]$Y_skip1)
  confusion <- table(data.clean[-train,]$Y_skip1, cv.rf.pred)
  confusion
  OOS_accuracy$random.forest[k] <- (confusion[2, 2] + confusion[1, 1]) / sum(confusion)
}

# Check and plot the OOS output
OOS_accuracy
colMeans(OOS_accuracy)
m.OOS_accuracy <- as.matrix(OOS_accuracy)
rownames(m.OOS_accuracy) <- c(1:nfold)
# par(mar = c(5, 4, 4, 8), )
barplot(t(OOS_accuracy), beside=TRUE,
        legend.text=TRUE, 
        args.legend=list(x="topright", cex=0.8, inset=c(0,0)),
        ylab= bquote( "Out of Sample Accuracy"), ylim=c(0.5, 1), xpd = FALSE, xlab="Fold", names.arg = c(1:5), 
        main='5-Fold CV Performance')

table(data.clean$Y_skip1)
1-861972/(1211497+861972) # 0.58 as a baseline
