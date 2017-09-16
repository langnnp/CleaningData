# Purpose
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 
1. a tidy data set as described below 
2. a link to a Github repository with your script for performing the analysis, and 
3. a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

You should create one R script called run_analysis.R that does the following.

* Merges the training and the test sets to create one data set.
* Extracts only the measurements on the mean and standard deviation for each measurement.
* Uses descriptive activity names to name the activities in the data set
* Appropriately labels the data set with descriptive variable names.
* From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Assumption
Analysis file is stored in a directory which has the same directory structure as [UCI HAR Dataset](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) directory

# Code explanation

__construct__: Utility function to read data and construct a dataset for different datasets. It reads:

* An identifier of the subject who carried out the experiment.
* Activity labels. 
* A 561-feature vector with time and frequency domain variables for each subject. 

and combines all of them into single data frame with mean and deviation measurement
```R
construct <- function(type, features) {
  # Read data
  subject <- read.csv(paste0(type, "/subject_", type, ".txt"), header = FALSE, col.names = "SubjectID") #7351
  label <- read.csv(paste0(type, "/y_", type, ".txt"), header = FALSE) # 7351
  val <- read.csv(paste0(type, "/X_", type, ".txt"), header = FALSE, sep = "") #2946
  
  # Merge label and activities dataset to
  # extract descriptive activity name
  label <- merge(label, activities, by.x="V1", by.y = "V1")[2]
  
  # Name the activities in the dataset
  names(label) <- "ActivityID"
  names(val) <- features
  
  # Extracts only the measurements on the mean and standard deviation
  val <- val[grepl("std()|mean()", features)]
  df <- cbind(subject, label, val)
  df
}
```

__run_analysis__: main function to analyze data. Its read all data needed and call to utility function to get all types of dataset, binds 2 datasets together and calculate the average of each variable for each activity and each subject.
```R
  # Calll to construct function to create each dataset based on its data type
  trainDF <- construct("train", features)
  testDF <- construct("test", features)

  # Binding 2 datasets and calculate average of each variable 
  # for each activity and each subject.
  fullDF <- bind_rows(trainDF, testDF) %>%
    group_by(SubjectID, ActivityID) %>% summarize_all(funs(mean)) %>%
    arrange(SubjectID, ActivityID) # %>% spread(DataGroup, ActivityID)
```