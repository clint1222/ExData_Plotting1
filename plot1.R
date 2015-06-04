########################################################################
## plot1.R requires the lubridate library for date/time processing and
## calls out to the system grep program to filter the data into a 
## temporary file. Temp file is removed as the last statement.
## plot1.R creates a plot1.png file
########################################################################

library(lubridate)

## Create temp filename
tempFilename <- "feb1-2data.txt"

## Use the grep system command to filter out the two required
## dates outputting to a new temp file.
system(paste("grep -e \"^2/2/2007\\|^1/2/2007\" household_power_consumption.txt >", tempFilename))

## Read in the data from the temp file
## 1 obs per min * 60 min/hr * 24 hrs/day * 2 days = 2880 obs for a total 
## of 9 variables
pwrConsump <- as.data.frame(matrix(scan(tempFilename, what="", 
					n = (2880 * 9), sep=";"),
                                   2880, 9, byrow=TRUE), 
			    stringsAsFactors=FALSE)

## Read in the variable names from the first line of text
colnames(pwrConsump) <- strsplit(scan("household_power_consumption.txt", 
				      what="", nlines=1), ";")[[1]]

## Combine Date and Time fields into one and convert to datetime
pwrConsump$Date <- parse_date_time(paste(pwrConsump$Date, pwrConsump$Time),
				   "d/m/Y H:M:S")

# No need for the time column anymore
pwrConsump <- pwrConsump[,-2]

# convert the non-date data to numeric type
for (x in 2:8){
  pwrConsump[,x] <- as.numeric(pwrConsump[,x])
}

## Plot 1
png(filename="plot1.png")
hist(pwrConsump$Global_active_power, 
     main="Global Active Power", 
     xlab="Global Active Power (kilowatts)", 
     col="red")
dev.off()

## Remove temp file
system(paste("rm", tempFilename))
