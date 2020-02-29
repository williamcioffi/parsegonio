# give it a test

# if you are using the text log file type input:
gfile <- "gonio_ex_log.txt"
pttkey_file <- "pttkey.csv"

source("parsegonio.R")
output <- parsegonio(gfile, pttkey_file)
cat(output, file = "gonio_output.prv")

# if you are using an exported xls messages from a favorite
# save first as a csv
# date format is expected to be %d-%m-%y %H:%M:%S
gfile <- "favorite_ptt_180754.csv"
ptt <- "180754"

source("parsegonio.r")
output <- parsegonio_favorite_messages(gfile, ptt)
cat(output, file = "gonio_favorite_output.prv")
