# parsegonio
beta testing of parsing gonio data into a DSA file readable by DAP Processor or WC portal.

WARNING: _very_ beta! no error handling! further testing required! all goniometer messages are packaged into one message per deployid. I'm not sure what all the header information means in the DSA messages and so I use the same header for everything with clearly incorrect times. I am not sure what the consequences are.

use with extreme caution.

#parsegonio.r

non-functionalized code to parse gonio log data. edit log filepath in line 4 to use.

#pttkey_file.csv

example pttkey file. fill in with the hex, ptt, and deployid of each animal you want to search for in the log. if none are present in the log file code will fail messy.
