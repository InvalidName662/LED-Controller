uart.write(0, "Starting up...\n")
--We call main.lc cause its compressed and we dont like used RAM/flash
dofile("main.lc")
