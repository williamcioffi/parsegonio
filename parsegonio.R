# parse the raw goniometer files

parsegonio <- function(gfile, pttkey_file, prv_output = TRUE) {
# constants for the fake prv file
# header
h1 <- "03126"
h2 <- ""	# this is the ptt
h3 <- " 75 31 A 2"
h4 <- ""	# this is the date
h5 <- ""    # this is the time
h6 <- " 34.716  283.328  0.000 401677432"

# footer
f1 <- "" 	# this is the number of messages
f2 <- "msgs 000>-120dB  Best:  -126  Freq:  677432.3  IQ : 66" # first line
f3 <- "Lat1: 34.716N  Lon1:  76.672W  Lat2: 34.716N  Lon2:  76.672W" # second line

# read in raw goniometer file and separate the favorited NPRF from the NPR.
g <- readLines(gfile)
g_nprf <- g[grep("NPRF", g)]
g_npr <- g[grep("NPR,", g)]

# make new files out of these greped vectors
if(length(g_nprf) == 0 & length(g_npr) == 0) stop("you didn't give me any goniometer messages!")

allg <- data.frame(
character(),
character(),
character(),
character(),
character(),
character(),
character(),
character(),
character(),
character(),
character(),
character(),
character(),
character(),
character(),
character(),
character(),
character(),
character(),
character()
)

names(allg) <- paste0("V", 1:20)

if(length(g_nprf) != 0) {
	nprf_file <- tempfile()
	writeLines(g_nprf, nprf_file)
	nprf <- read.table(nprf_file, header = FALSE, sep = ',', stringsAsFactors = FALSE)
	allg <- rbind(allg, nprf)
}

if(length(g_npr) != 0) {
	npr_file <- tempfile()
	writeLines(g_npr, npr_file)
	npr <- read.table(npr_file, header = FALSE, sep = ',', stringsAsFactors = FALSE)
	# add dummy columns for the saved average strength and average bearing columns for NPR (this only works on NPRF)
	npr_withcols <- data.frame(npr[, 1:12], rep(NA, nrow(npr)), npr[, 13], rep(NA, nrow(npr)), npr[, 14:ncol(npr)])
	names(npr_withcols) <- paste0("V", 1:20)
	allg <- rbind(allg, npr_withcols)
}

if(nrow(allg) == 0) stop("i don't think you have anything to work with there...")

# format date
rec_date_tmp <- paste(
	allg$V3, 				# this code might break in the year 3000?
	sprintf("%02d", allg$V4), 
	sprintf("%02d", allg$V5),
	sep = '-'
)

rec_date_tmp <- as.character(as.POSIXct(rec_date_tmp, format = "%y-%m-%d", tz = "UTC"))

rec_time_tmp <- paste(
	sprintf("%02d", allg$V6), 
	sprintf("%02d", allg$V7), 
	sprintf("%02d", allg$V8),
	sep = ":"
)

# final formatted date and time
rec_date_formatted <- paste(rec_date_tmp, rec_time_tmp)
allg$V1 <- rec_date_formatted

# save back into the dataframe
allg$V1 <- rec_date_formatted

# separate the byte after the asterix
msg <- as.character(allg$V20)
msg_split <- strsplit(msg, "\\*")
msg_formatted <- sapply(msg_split, '[[', 1)
msg_asterix <- sapply(msg_split, '[[', 2)

allg$V20 <- msg_formatted
allg[, 'asterix'] <- msg_asterix

# read in the pttkey
pttkey <- read.table(pttkey_file, header = TRUE, sep = ',', stringsAsFactors = FALSE)
desehex <- pttkey$HEX[which(pttkey$DEPLOYID != "")]

# look for just those hex codes
subg <- allg[which(allg$V9 %in% desehex), ]

if(prv_output) {
  # set up vectors to make dsa
  foundhexes <- unique(subg$V9)
  foundptts <- pttkey$PTT[match(foundhexes, pttkey$HEX)]
  output <- ""
  	
  # go through each found hex and bundle up all the messages
  pb <- txtProgressBar(style = 3)
  for(i in 1:length(foundhexes)) {
  setTxtProgressBar(pb, i/length(foundhexes))
  	dese <- which(subg$V9 == foundhexes[i])
  	header <- paste(h1, foundptts[i], h3, subg$V1[dese[1]], h6)
  	
  	date <- subg[dese, ]$V1
  	msgs <- subg[dese, ]$V20
  	msgs <- as.character(msgs)
  	msgs <- split(msgs, 1:length(msgs))
  	
  	# split up into bytes dropping first byte
  	msgs <- lapply(msgs, function(l) {
  		lprime <- substring(l, seq(1, nchar(l), by = 2), seq(2, nchar(l), by = 2))
  		lprime[-1]
  	})
  	
  	# convert from hex to decimal and add 1 leader zero
  	msgs <- lapply(msgs, as.hexmode)
  	msgs <- lapply(msgs, as.integer)
  	msgs <- lapply(msgs, function(l) {
  		dese <- which(nchar(l) == 1)
  		l[dese] <- paste0("0", l[dese])
  		l
  	})
  	
  	output <- paste0(output, header, "\n")
  
  	for(p in 1:length(dese)) {
  		output <- paste0(output, date[p], " 1")
  		curmsg <- msgs[[p]]
  		msgseq <- rep(1:ceiling(length(curmsg)/4), each = 4)
  		msgseq <- msgseq[1:length(curmsg)]
  		u_msgseq <- unique(msgseq)
  		
  		for(q in 1:length(u_msgseq)) {
  			dose <- which(msgseq == u_msgseq[q])
  			output <- paste0(output, "\t", paste(curmsg[dose], collapse = "\t"), "\n")
  		}
  		
  	}
  }
  close(pb)
} else {
  output <- allg
}

if(length(output) == 0) warning("i don't think you found any matching hex...")

output
}



# use this one for a csv saved from the .xls output
# favorited messages
parsegonio_favorite_messages <- function(gfile, ptt) {
# constants for the fake prv file
# header
h1 <- "03126"
h2 <- ""	# this is the ptt
h3 <- " 75 31 A 2"
h4 <- ""	# this is the date
h5 <- ""    # this is the time
h6 <- " 34.716  283.328  0.000 401677432"

g <- read.table(gfile, sep = ',', header = TRUE, stringsAsFactors = FALSE)

# fix date format
dates <- as.POSIXct(g$Date, tz = 'utc', format = '%d-%m-%y %H:%M:%S')
dates <- paste(dates)

header <- paste(h1, ptt, h3, dates[length(dates)], h6)
msgs <- g$Data
msgs <- as.character(msgs)
msgs <- split(msgs, 1:length(msgs))

# split up into bytes dropping first byte
msgs <- lapply(msgs, function(l) {
  lprime <- substring(l, seq(1, nchar(l), by = 2), seq(2, nchar(l), by = 2))
  lprime[-1]
})

# convert from hex to decimal and add 1 leader zero
msgs <- lapply(msgs, as.hexmode)
msgs <- lapply(msgs, as.integer)
msgs <- lapply(msgs, function(x) {
  dese <- which(nchar(x) == 1)
  x[dese] <- paste0("0", x[dese])
  x
})

output <- paste0(header, "\n")

for(p in 1:length(dates)) {
  output <- paste0(output, dates[p], " 1")
  curmsg <- msgs[[p]]
  msgseq <- rep(1:ceiling(length(curmsg)/4), each = 4)
  msgseq <- msgseq[1:length(curmsg)]
  u_msgseq <- unique(msgseq)
    
  for(q in 1:length(u_msgseq)) {
    dose <- which(msgseq == u_msgseq[q])
    output <- paste0(output, "\t", paste(curmsg[dose], collapse = "\t"), "\n")
  }
}

output
}
