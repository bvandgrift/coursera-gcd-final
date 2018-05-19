# GCD : Final Assignment Code Book

## Data Sources

Source Data Description: [Human Activity Recognition Using Smartphones Data Set](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones )
Original Data Set: [link](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

The `run_analysis.R` script downloads this file when it is run.

# Tidying the Data

Three phases go into making this dataset nice and clean.

1. merging
1. cleaning
1. factoring

As a part of the exercise, we also summarize the data once it is tidy.

## Merging the Data

Combining the test and train data sets occurred in two phases:

1. compose test
2. compose train
3. bind the data rows

In both test and train, the `X_test.txt` files could were given named columns
using the features.txt file, and row numbers created. Columns were added for the activity and subject,
from `y_test.txt` and `subject.txt` respectively, after creating row numbers for
each table, then appending the properly columned rows.

## Cleaning the Data

The data at this point is labeled, but not tidy. Each row contains much
extraneous data. Step one is removing the extraneous data.

From the assignment:

  _Extracts only the measurements on the mean and standard deviation for each
measurement_

As described in `features_info.txt`, the measurements are the captured data from
the accelerometer and gyroscope, that is:

* tBodyAcc-XYZ
* tGravityAcc-XYZ
* tBodyAccJerk-XYZ
* tBodyGyro-XYZ
* tBodyGyroJerk-XYZ
* tBodyAccMag
* tGravityAccMag
* tBodyAccJerkMag
* tBodyGyroMag
* tBodyGyroJerkMag

The remainder of the measurements are the results of an FFT on these, or
derivative calculations. We are interested in the columns where the following
regex applies: `/^t(B|G).*(std|mean)/`

We must also keep our first three columns (row_number, subject, activity) by
setting the first three entries in the resulting logical vector to true.

## Factoring the Data

From the measurements, we want four variables: the source (body/gravity),
sensor (accelerometer/gyroscope), stat type (stdev/mean), and dimension. This
will produce a well-factored data set.

This is accomplished by melting the non-identity columns (row_number, subject,
activity), then using regular expressions to extract the appropriate variables
into newly created adjacent columns.

The original features follow the following pattern:

t(Body|Gravity)(Acc|AccJerk|Gyro|GyroJerk)(Mag)?-(std|mean)()(-(Z|Y|X))?

Each capture group reflects a factor:

1. body or gravity as source,
2. Acc, AccJerk, Gyro, or GyroJerk as sensor,
3. std or mean as stat method
4. Z, Y, X, or Mag (magnitude) as dimensions

These are extracted into the factors via a nasty regular expression.

## Variables and Summaries

### Tidy Data Set (`final.tbl`)

In the final data set, we find the following variables and factors:

* `subject` - the intger identifier of the subject under observation
* `activity` - one of the five provided activities observed
    * `walking`
    * `walking up stairs`
    * `walking down stairs`
    * `sitting`
    * `standing`
    * `laying`
* `source` - the source of acceleration for the measurement
    * `body` - movement of the body
    * `gravity` - acceleration due to gravity
* `sensor` - the sensor picking up the readings prior to normalization
    * `accelerometer`
    * `jerk-accelerometer`
    * `gyroscope`
    * `jerk-gyroscope`
* `stat` - the statistical method used for calculating the value
    * `mean` - mean
    * `std` - standard deviation
* `dimension` - the parts of the movement vector
    * `x` - movement in the x direction
    * `y` - movement in y
    * `z` - movement in z
    * `mag` - magnitude of the movement
* `value` - the measurement (floating point), after normalization

### Summary Data Set (`tidy_averages.tbl`)

In addition to the factors above, each row of this dataset contains
an `avg`, which is the average of the `value`s observed, grouped by
each set of distinct variable combinations.




