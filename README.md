# parsegonio
beta testing of parsing gonio data into a prv file readable by Argos Message Decoder / DAP Processor or WC portal.

__WARNING:__ __very__ beta! no error handling! further testing required! 
all goniometer messages are packaged into one message per deployid. I am not sure what all the header information means in the prv messages and so I use the same header for everything with clearly incorrect times. I am not sure what the consequences are.

__use with extreme caution!__

## quick start

take a look at testparsegonio.R which includes a full working example to output a .prv file.

