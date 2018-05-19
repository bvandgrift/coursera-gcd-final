# Getting and Cleaning Data (GCD): Course Project

This repo contains the final project implementation for Coursera's
_Getting and Cleaning Data_ course.

## Assignment Specifics

The `run_analysis.R` file does the following:

1. Merges the training and the test sets to create one data set.
1. Extracts only the measurements on the mean and standard deviation for each measurement.
1. Uses descriptive activity names to name the activities in the data set
1. Appropriately labels the data set with descriptive variable names.
1. From the data set in step 4, creates a second, independent tidy data set 
   with the average of each variable for each activity and each subject.

### On Tidiness

To produce tidy data, I'm depending on Wickham's expression of Codd's 3rd Normal
Form, as follows:

1. Each variable forms a column.
2. Each observation forms a row.
3. Each type of observational unit forms a table.

In particular, I'm looking for the five most common problems:

1. Column headers are values, not variable names.
1. Multiple variables are stored in one column.
1. Variables are stored in both rows and columns.
1. Multiple types of observational units are stored in the same table. 
1. A single observational unit is stored in multiple tables.

In these data, there are two sets (test and train), which have been disassembled
into three `.txt` files each. In the `test` set, we have:

1. `subject_test.txt` - identifies the subject who performed the activity for 
   each window sample. Its range is from 1 to 30
1. `test_X.txt` - test set
1. `test_y.txt` - test labels

In the `train` set, we have:

1. `subject_train.txt` - identifies the subject who performed the activity for 
   each window sample. Its range is from 1 to 30
1. `train_X.txt` - training set
1. `train_y.txt` - training labels

### Code Book

The code book for this assignment can be found at the root of this repository,
as `CodeBook.md`. [link](./CodeBook.md)

## Acknowledgement

Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. 
_Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine_. 
International Workshop of Ambient Assisted Living (IWAAL 2012).
Vitoria-Gasteiz, Spain. Dec 2012
