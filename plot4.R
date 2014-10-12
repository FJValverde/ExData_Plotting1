## Script to plot the FOURTH figure in Project 1
#
# All of the scripts follow the same procedure:
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

#debug <- TRUE
debug <- FALSE
plotFile <- "plot4.png"
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
data <- fread(fileName, 
              verbose=TRUE, ## Gives lots of information about loading process.
              sep=";",
              colClasses = c("character", "character", "numeric", "numeric", 
                             "numeric", "numeric", "numeric", "numeric", "numeric"), 
              na.strings=c("?"))
unlink(zipDir)  # Get rid of the temporary decompressed file: it's BIG!
if (debug) summary(data)

# 2 Massage data to focus on those of interest:
# Reads in date info as requested, then subclassess, aka filters, then transmutes
# only requested data, since fread, in the presence of "?" bumps numerics to characters.
# NOTE: This is not about *tidying* the data and the variables are pretty descriptive.
fdata <- data %>%
    filter(Date=="1/2/2007" | Date=="2/2/2007") %>%
    transmute(datetime=dmy_hms(paste(Date,Time)),
              globalActivePower=as.numeric(Global_active_power),
              globalReactivePower=as.numeric(Global_reactive_power),
              voltage=as.numeric(Voltage),
              submetering1=as.numeric(Sub_metering_1),
              submetering2=as.numeric(Sub_metering_2),
              submetering3=as.numeric(Sub_metering_3))
if (debug) summary(fdata)

# 3 Build the plot
# Plot 4: actually four plots in a  2x2 matrix
# plot (1,1): like plot 2, plot the global active power vs. time instant for the two days.
# plot (1,2): voltage vs. datetime (with xlabel)
# plot (2,1): like plot 3 plot the individual metering powers vs. time instant for the two days 
# *in the same plot*, and add a legend.
# plot (2,2): Reactive power vs. datetime (witn xlabel)
if (debug){
    quartz()  # First on screen to check output     
}else{
    png(filename=plotFile)  # Rest of defaults seem adequate.
}
# Define the plot matrix with 2x2 matrix
par(mfcol=c(2,2))
# Taken from class notes: use with(<dataframe>,{<joint plotting code>})
with(fdata,{
    # Plot (1,1)
    plot(datetime, globalActivePower, type="l",  # line scatterplot
         xlab="", 
         ylab="Global Active Power",
    )
    # Plot (2,1)
    plot(datetime, submetering1, type="l",  # line scatterplot
         xlab="", 
         ylab="Energy sub metering",
    )
    # Overlay 2nd and 3rd meter in different color.
    lines(datetime, submetering2, col="red")
    lines(datetime, submetering3, col="blue")
    legend("topright", 
           c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), 
           lty=c(1,1,1),  # Type of lines to draw
           col=c("black","red","blue"),
           bty="n"  # Box type: no box
    )
    # PLOT (1,2): Voltage vs. time
    plot(datetime, voltage, type="l",  # line scatterplot
         xlab="datetime", 
         ylab="Voltage",
    )
    # PLOT (2,2): Global reactive power vs. datetime
    plot(datetime, globalReactivePower, type="l",  #line scatterplot
         xlab="datetime",
         ylab="Global_reactive_power",
    )    
})
# CLOSE OFF
if (!debug){
    dev.off()  # Really only need to close on file devices.
}
cat("Done!")