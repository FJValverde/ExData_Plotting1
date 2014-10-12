## Script to plot the THIRD figure in Project 1
#
# ALl of the scripts follow the same procedure:
# 1. Load in the needed data.
# 2. Massage the data to extract what is needed
# 3. Create the plot in the png device and close.
#
# In fact, so that running is a little bit smoother I have used a flag debug
# to distinguish between two phases:
# - debug == TRUE, marks the designing phase: we build on a screen device the plot
#                  to check that it complies with the visual specifications
# - debug == FALSE, marks the plotting phase: we print to the PNG device

library(data.table)
library(dplyr)
library(lubridate)

#debug = TRUE
debug = FALSE
plotFile = "plot3.png"
# This pattern of reading is from:
# http://stackoverflow.com/questions/3053833/using-r-to-download-zipped-data-file-extract-and-import-data
# 1) Define a tmp file in the present dir where you unzip with unz,
# 2) Read the data in this file.
# 3) Get rid of the temporary file with unlink
zipFile <- "./exdata-data-household_power_consumption.zip"
if (debug){
    cat("File exists? ", (file.exists(zipFile)))  # Check 
}
zipDir <- tempfile()  # To decompress the file in
if (!file.exists(zipDir)){dir.create(zipDir)}
unzip(zipFile,exdir=zipDir)
#The single file ends in txt
fileName <- file.path(zipDir, (list.files(zipDir))[1])

# The uncompressed data is in csv2 format (sep=";") with a header describing variable names.
# data <- read.csv2(fileName, 
#                  colClasses = c("Date", "POSIXct", "Numeric", "Numeric", 
#                                 "Numeric", "Numeric", "Numeric", "Numeric", "Numeric"), 
#                  na.strings="?")  # As per the project statement description.
data <- fread(fileName, 
              verbose=TRUE, ## Gives lots of information about loading process.
              sep=";",
              colClasses = c("character", "character", "numeric", "numeric", 
                             "numeric", "numeric", "numeric", "numeric", "numeric"), 
              na.strings=c("?"))
unlink(zipDir)  # Get rid of the temporary decompressed file: it's BIG!
if (debug) summary(data)

# 2 Massage data to focus on those of interest:
# Reads in date infor as requested, then subclassess, aka filters, then transmutes
# only requested data, since fread, in the presence of "?" bumps numerics to characters.
# NOTE: This is not about *tidying* the data and the variables are pretty descriptive.
fdata <- data %>%
    filter(Date=="1/2/2007" | Date=="2/2/2007") %>%
    transmute(time=dmy_hms(paste(Date,Time)),
              submetering1=as.numeric(Sub_metering_1),
              submetering2=as.numeric(Sub_metering_2),
              submetering3=as.numeric(Sub_metering_3))

# fdata <- data %>%
#     filter(Date=="1/2/2007" | Date=="2/2/2007") %>%
#     transmute(time=dmy_hms(paste(Date,Time)),
#               globalActivePower=as.numeric(Global_active_power))
# 
if (debug) summary(fdata)

# 3 Build the plot
# Plot 3: plot the individual metering powers vs. time instant for the two days 
# *in the same plot*, and add a legend.
if (debug){
    quartz()  # First on screen to check output     
}else{
    png(filename=plotFile)  # Rest of defaults seem adequate.
}
# Plot first meter,
plot(fdata$time, fdata$submetering1, type="l",  # line scatterplot
     xlab="", 
     ylab="Energy sub metering",
     )
# Overlay 2nd and 3rd meter in different color.
lines(fdata$time, fdata$submetering2, col="red")
lines(fdata$time, fdata$submetering3, col="blue")
legend("topright", 
       c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), 
       lty=c(1,1,1),  # Type of lines to draw
       col=c("black","red","blue"),
       )
if (!debug){
    dev.off()  # Really only need to close on file devices.
}