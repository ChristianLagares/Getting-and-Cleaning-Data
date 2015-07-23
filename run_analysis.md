# run_analysis
Christian Lagares  
July 23, 2015  
## Preparing the material   

### Lightweight Preparation:
* Library Mounting
* URL Text Saved to variable `url`
* File Name is set to `Instance.zip`


```r
library(httr) 
library(plyr)
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
file <- "Instance.zip"
```

### Download Data
#### Data Source
The data can be accessed directly at the [Machine Learning Repository - Human Activity Recognition Using Smartphones Data Set](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones). 

##### Citation
Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. A Public Domain Dataset for Human Activity Recognition Using Smartphones. 21th European Symposium on Artificial Neural Networks, Computational Intelligence and Machine Learning, ESANN 2013. Bruges, Belgium 24-26 April 2013.

#### Data Set Information
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING UPSTAIRS, WALKING DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

#### Code for downloading the data for Coursera's Project

```r
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
file <- "Instance.zip"
if(!file.exists(file)){
        print("Downloading...")
        download.file(url, file, method="curl")
        print("Downloading Done!")
}
```

### Unzip and Create Folders

The downloaded files are decompressed and if the needed directories are not available, those are created as well.


```r
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
```

##Reading and Database Development
### Read text file and covnert to data.frame

The downloaded data is made available in a *.txt* format and we are generating a **data.frame** which is a data structure commonly used within the **R Language**. 


```r
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
```

###Run/Check `gettables`


```r
features <- gettables("features.txt")
```

```
## [1] "Getting table: features.txt"
```

###Read Data and Build database


```r
getdata <- function(type, features){
        print(paste("Getting data", type))
        subject_data <- gettables(paste(type,"/","subject_",type,".txt",sep=""),"id")
        y_data <- gettables(paste(type,"/","y_",type,".txt",sep=""),"activity")
        x_data <- gettables(paste(type,"/","X_",type,".txt",sep=""),features$V2)
        return (cbind(subject_data,y_data,x_data))
}
```

###Run and Check *getdata*


```r
test <- getdata("test", features)
```

```
## [1] "Getting data test"
## [1] "Getting table: test/subject_test.txt"
## [1] "Getting table: test/y_test.txt"
## [1] "Getting table: test/X_test.txt"
```

```r
train <- getdata("train", features)
```

```
## [1] "Getting data train"
## [1] "Getting table: train/subject_train.txt"
## [1] "Getting table: train/y_train.txt"
## [1] "Getting table: train/X_train.txt"
```

###Save the resulting data in the indicated folder
We are now generating a function to save the files in a *.csv* format.


```r
saveresults <- function (data,name){
        print(paste("Saving results...", name))
        file <- paste(resultsfolder, "/", name,".csv" ,sep="")
        write.csv(data,file)
}
```

## Tidy Data Set
### Required activities
The main section of the project required the generation of a tidy data set for analysis. The following code chuncks complete this task on 5 steps.

####1) Merge the training and the test sets to create one data set.

```r
data <- rbind(train, test)
data <- arrange(data, id)
```

####2) Extract only the measurements on the mean and standard deviation for each measurement. 

```r
mean_and_std <- data[,c(1,2,grep("std", colnames(data)), grep("mean", colnames(data)))]
saveresults(mean_and_std,"mean_and_std")
```

```
## [1] "Saving results... mean_and_std"
```

####3) Use descriptive activity names to name the activities in the data set

```r
activity_labels <- gettables("activity_labels.txt")
```

```
## [1] "Getting table: activity_labels.txt"
```

####4) Appropriately label the data set with descriptive variable names. 

```r
data$activity <- factor(data$activity, levels=activity_labels$V1, labels=activity_labels$V2)
```

####5) Create a second, independent tidy data set with the average of each variable for each activity and each subject. 

```r
tidy_dataset <- ddply(mean_and_std, .(id, activity), .fun=function(x){ colMeans(x[,-c(1:2)]) })
colnames(tidy_dataset)[-c(1:2)] <- paste(colnames(tidy_dataset)[-c(1:2)], "_mean", sep="")
saveresults(tidy_dataset,"tidy_dataset")
```

```
## [1] "Saving results... tidy_dataset"
```
### Resulting files
The code generates a file named `results` on your current working directory which contains the tidy dataset with the average of each measured variable for each activity and each subject, and a file with the mean and standard deviation for each measurement. Both resulting files are in a *Comma Separated Variable* format (*.csv*).

### Analysis
The dataset generated can be used to perform several analysis, but non was required for this specific Course Project. Rerunning this document as a *.Rmd* file or rerunning the individual code chuncks as regular *.R* scripts should generate the results described.
