--On Power Up we reboot, because otherwise UDP ports arent free
--I dont know why but it works :)
_, bootreason = node.bootreason()
if (bootreason == 0) then
  node.restart()
end
bootreason = nil
collectgarbage()

--Load in the config
config = dofile("config.lc")

--Setting up wifi and connecting to Accesspoint
wifi.setmode(wifi.STATION)
wifi.sta.config(config.wifi)

wifi.sta.setip(config.net.ipconfig)

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
    uart.write(0, "Succesfully connected to Access point "..T.SSID.." on Channel "..T.channel.."\n")
  end
)

--Misc
gpio.mode(5, gpio.OUTPUT)
ws2812.init()

--Applying the existing config in case of power loss
ledconfig = dofile("ledconfig.lua")
dofile("applyConfig.lc")(ledconfig)
ledconfig = nil
collectgarbage()

--Now we set up UDP Callbacks so we can receive Messages, process them and change our behaviour
udpSocket = net.createUDPSocket()
udpSocket:listen(config.net.port)
udpSocket:on("receive", function(s, data, port, ip)
  dofile("processCommand.lc")(data)
end)
