# give it a test

# if you are using the text log file type input:
gfile <- "gonio_ex_log.txt"
pttkey_file <- "pttkey.csv"

source("parsegonio.R")

# load in pttkey_file
pttkey <- read.table(pttkey_file, 
  header = TRUE,
  sep = ',', 
  stringsAsFactors = FALSE, 
  colClasses = "character" # make sure hex is interpreted as char
)

# filter out hexes which don't have a deployid
desehex <- pttkey$HEX[which(pttkey$DEPLOYID != "")]


output <- parsegonio(gfile, pttkey, version = 1)
cat(output, file = "gonio_output.prv")

# if you are using an exported xls messages from a favorite
# save first as a csv
# date format is expected to be %d-%m-%y %H:%M:%S
gfile <- "favorite_ptt_180754.csv"
ptt <- "180754"

source("parsegonio.r")
output <- parsegonio_favorite_messages(gfile, ptt)
cat(output, file = "gonio_favorite_output.prv")
