# if not already installed, uncomment
# install.packages("dplyer", "reshape2")

# load libraries
library(dplyr)
library(reshape2)

# retrieve the data and unpack
if(!dir.exists('data')) dir.create('data')

dataUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(dataUrl, "data/data.zip")
unzip('data/data.zip', exdir="data/")

# fetch the feature names into a vector
feature_names.df <- read.table("data/UCI HAR Dataset/features.txt", header = FALSE)

# get the data from the data file
x_test_raw.df <- read.table("data/UCI HAR Dataset/test/X_test.txt", header = FALSE)

# make it a tibble with the right names
x_test_raw.tbl <- tbl_df(x_test_raw.df)
colnames(x_test_raw.tbl) <- feature_names.df[,2]

# give it a row number
x_test_numbered.tbl <- tibble::rowid_to_column(x_test_raw.tbl, "row_number")

# repeat with y and subject
y_test_raw.df <- read.table("data/UCI HAR Dataset/test/y_test.txt", header = FALSE)
y_test_raw.tbl <- tbl_df(y_test_raw.df)
colnames(y_test_raw.tbl) <- c('activity')
y_test_numbered.tbl <- tibble::rowid_to_column(y_test_raw.tbl, "row_number")
subject_test_raw.df <- read.table("data/UCI HAR Dataset/test/subject_test.txt", header = FALSE)
subject_test_raw.tbl <- tbl_df(subject_test_raw.df)
colnames(subject_test_raw.tbl) <- c('subject')
subject_test_numbered.tbl <- tibble::rowid_to_column(subject_test_raw.tbl, "row_number")

# join the rows together with row_number, then ditch it
yx_test.tbl <- merge(y_test_numbered.tbl, x_test_numbered.tbl, on="row_number")
syx_test.tbl <- merge(subject_test_numbered.tbl, yx_test.tbl, on="row_number")

# same thing again with train
# get the data from the data file
x_train_raw.df <- read.table("data/UCI HAR Dataset/train/X_train.txt", header = FALSE)
# make it a tibble with the right names
x_train_raw.tbl <- tbl_df(x_train_raw.df)
colnames(x_train_raw.tbl) <- feature_names.df[,2]
# give it a row number
x_train_numbered.tbl <- tibble::rowid_to_column(x_train_raw.tbl, "row_number")

# repeat with y and subject
y_train_raw.df <- read.table("data/UCI HAR Dataset/train/y_train.txt", header = FALSE)
y_train_raw.tbl <- tbl_df(y_train_raw.df)
colnames(y_train_raw.tbl) <- c('activity')
y_train_numbered.tbl <- tibble::rowid_to_column(y_train_raw.tbl, "row_number")
subject_train_raw.df <- read.table("data/UCI HAR Dataset/train/subject_train.txt", header = FALSE)
subject_train_raw.tbl <- tbl_df(subject_train_raw.df)
colnames(subject_train_raw.tbl) <- c('subject')
subject_train_numbered.tbl <- tibble::rowid_to_column(subject_train_raw.tbl, "row_number")

# join the rows together with row_number, then ditch it
yx_train.tbl <- merge(y_train_numbered.tbl, x_train_numbered.tbl, on="row_number")
syx_train.tbl <- merge(subject_train_numbered.tbl, yx_train.tbl, on="row_number")

merged.tbl <- rbind(syx_train.tbl, syx_test.tbl) 

# filter out the columns we don't want to operate on
kept_columns <- grepl("^t[BG].*(std()|mean())", names(merged.tbl))
kept_columns[1:3] = TRUE
stat_columns.tbl <- tbl_df(merged.tbl[,kept_columns])

# clean up the env for better performance
rm(list=ls(pattern="^x_"))
rm(list=ls(pattern="^y_"))
rm(list=ls(pattern="^subject_"))
rm(list=ls(pattern="^yx_"))
rm(list=ls(pattern="^syx_"))
rm(list=ls(pattern="^feature_names"))
rm("merged.tbl")

# remove the leading t and useless parens()
new_colnames = gsub("(^t|\\(\\))", "", names(stat_columns.tbl))
colnames(stat_columns.tbl) <- new_colnames

# melt on the column names
melted.tbl = melt(stat_columns.tbl, id=c("row_number", "subject", "activity"))

# columns to hold our factors, set them all to NA for later testing
add_cols <- c('source', 'sensor', 'stat', 'dimension')
melted.tbl[,add_cols] <- NA

# here we are extracting the factors from the data, marking up
# a factor for each section of the overcrowded variable space.

# yeah, it's hideous.
melted.tbl[with(melted.tbl, grepl('^Body', variable)),]$source <- "body"
melted.tbl[with(melted.tbl, grepl('^Grav', variable)),]$source <- "gravity"
melted.tbl[with(melted.tbl, grepl('-X$', variable)),]$dimension <- "x"
melted.tbl[with(melted.tbl, grepl('-Y$', variable)),]$dimension <- "y"
melted.tbl[with(melted.tbl, grepl('-Z$', variable)),]$dimension <- "z"
melted.tbl[with(melted.tbl, grepl('(-std$|-mean$)', variable)),]$dimension <- "mag"
melted.tbl[with(melted.tbl, grepl('Acc(Mag)?-', variable)),]$sensor <- "accelerometer"
melted.tbl[with(melted.tbl, grepl('AccJerk(Mag)?-', variable)),]$sensor <- "jerk-accelerometer"
melted.tbl[with(melted.tbl, grepl('Gyro(Mag)?-', variable)),]$sensor <- "gyroscope"
melted.tbl[with(melted.tbl, grepl('GyroJerk(Mag)?-', variable)),]$sensor <- "jerk-gyroscope"
melted.tbl[with(melted.tbl, grepl('mean', variable)),]$stat <- "mean"
melted.tbl[with(melted.tbl, grepl('std', variable)),]$stat <- "std"

# replace activity factor 1-6 with useful names
melted.tbl$activity=as.factor(melted.tbl$activity)
levels(melted.tbl$activity) <- c("walking", "walking up stairs", "walking down stairs", "sitting", "standing", "laying")

# clean up our variable column, since its usefulness has
# ended
final.tbl <- tbl_df(select(melted.tbl, -starts_with('variable'), -starts_with('row_number')))

# spit out the results to the screen
head(final.tbl, 20)

# spit out the results to a csv file
if (!dir.exists("results")) dir.create("results")
write.csv(final.tbl, "results/uci-har-test-train.csv", row.names=FALSE)

tidy_averages.tbl <- dplyr::summarize(group_by(final.tbl, subject, activity, source, sensor, stat, dimension), avg = mean(value))

write.csv(tidy_averages.tbl, "results/avg-by-factor.csv", row.names=FALSE)

