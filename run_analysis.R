# Christian J. Lagares
# A fully formatted and commented version has been made available for study and distribution.

library(httr) 
library(plyr)
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
file <- "Instance.zip"

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
file <- "Instance.zip"
if(!file.exists(file)){
        print("Downloading...")
        download.file(url, file, method="curl")
        print("Downloading Done!")
}

datafolder <- "UCI HAR Dataset"
resultsfolder <- "results"
if(!file.exists(datafolder)){
        print("Unzip file...")
        unzip(file, list = FALSE, overwrite = TRUE)
        print("Unzipping done!")
} 
if(!file.exists(resultsfolder)){
        print("create results folder")
        dir.create(resultsfolder)
} 

gettables <- function (filename,cols = NULL){
        print(paste("Getting table:", filename))
        f <- paste(datafolder,filename,sep="/")
        data <- data.frame()
        if(is.null(cols)){
                data <- read.table(f,sep="",stringsAsFactors=F)
        } else {
                data <- read.table(f,sep="",stringsAsFactors=F, col.names= cols)
        }
        data
}

features <- gettables("features.txt")

getdata <- function(type, features){
        print(paste("Getting data", type))
        subject_data <- gettables(paste(type,"/","subject_",type,".txt",sep=""),"id")
        y_data <- gettables(paste(type,"/","y_",type,".txt",sep=""),"activity")
        x_data <- gettables(paste(type,"/","X_",type,".txt",sep=""),features$V2)
        return (cbind(subject_data,y_data,x_data))
}

test <- getdata("test", features)
train <- getdata("train", features)

saveresults <- function (data,name){
        print(paste("Saving results...", name))
        file <- paste(resultsfolder, "/", name,".csv" ,sep="")
        write.csv(data,file)
}

data <- rbind(train, test)
data <- arrange(data, id)

mean_and_std <- data[,c(1,2,grep("std", colnames(data)), grep("mean", colnames(data)))]
saveresults(mean_and_std,"mean_and_std")

activity_labels <- gettables("activity_labels.txt")

data$activity <- factor(data$activity, levels=activity_labels$V1, labels=activity_labels$V2)

tidy_dataset <- ddply(mean_and_std, .(id, activity), .fun=function(x){ colMeans(x[,-c(1:2)]) })
colnames(tidy_dataset)[-c(1:2)] <- paste(colnames(tidy_dataset)[-c(1:2)], "_mean", sep="")
saveresults(tidy_dataset,"tidy_dataset")