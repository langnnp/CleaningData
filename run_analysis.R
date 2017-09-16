library(dplyr)
library(tidyr)
library(stringr)


# Utility function 
# An identifier of the subject who carried out the experiment.
# Activity labels. 
# A 561-feature vector with time and frequency domain variables for each subject. 
# Args:
#   type: type of dataset
#   features: A 561-feature vector.
#   verbose: If TRUE, prints sample covariance; if not, not. Default is TRUE.
#
# Returns:
#   A dataset with measurements on the mean and standard deviation for specific type.
construct <- function(type, features) {
  # Read data
  subject <- read.csv(paste0(type, "/subject_", type, ".txt"), header = FALSE, col.names = "SubjectID") #7351
  label <- read.csv(paste0(type, "/y_", type, ".txt"), header = FALSE) # 7351
  val <- read.csv(paste0(type, "/X_", type, ".txt"), header = FALSE, sep = "") #2946
  
  # Merge label and activities dataset to
  # extract descriptive activity name
  label <- merge(label, activities, by.x="V1", by.y = "V1")[2]
  
  # Name the activities in the data set
  names(label) <- "ActivityID"
  names(val) <- features
  
  # Extracts only the measurements on the mean and standard deviation
  val <- val[grepl("std()|mean()", features)]
  df <- cbind(subject, label, val)
  df
}

run_analysis <- function() {
  # Read all activity labels to R
  activities <- read.csv("activity_labels.txt", header = FALSE, sep = " ") #6
  # Read all measurements labels that are used 
  features <- read.csv("features.txt", header = FALSE, sep = "", stringsAsFactors = FALSE)[,2] #561
  
  # Calll to construct function to create each dataset based on its data type
  trainDF <- construct("train", features)
  testDF <- construct("test", features)

  # Binding 2 datasets and calculate average of each variable 
  # for each activity and each subject.
  fullDF <- bind_rows(trainDF, testDF) %>%
    group_by(SubjectID, ActivityID) %>% summarize_all(funs(mean)) %>%
    arrange(SubjectID, ActivityID) # %>% spread(DataGroup, ActivityID)
  print(dim(fullDF))
  # Write the result to a file
  con<-file('tidydata.csv',encoding="UTF-8")
  write.table(fullDF, file = con, append = FALSE)
}
  