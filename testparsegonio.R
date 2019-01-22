# give it a test
# this is the path to the raw goniometer file and ptt key file
gfile <- "gonio_ex_log.txt"
pttkey_file <- "pttkey.csv"

source("parsegonio.R")
output <- parsegonio(gfile, pttkey_file)
cat(output, file = "gonio_output.prv")
