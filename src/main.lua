--On Power Up we reboot, because otherwise UDP ports arent free
--I dont know why but it works :)
local _, bootreason = node.bootreason()
if (bootreason == 0) then
  node.restart()
end
bootreason = nil

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
gpio.mode(config.led.powerPin, gpio.OUTPUT)
ws2812.init()

--Apply Config Func
applyConfig = function(ledconfig)
  if (ledconfig.power) then
    gpio.write(config.led.powerPin, gpio.HIGH)
  else
    gpio.write(config.led.powerPin, gpio.LOW)
  end

  local buffer = ws2812.newBuffer(config.led.ledNum, config.led.byteCount)
  ws2812_effects.init(buffer)
  ws2812_effects.set_speed(ledconfig.speed)
  ws2812_effects.set_mode(ledconfig.mode)
  ws2812_effects.set_brightness(ledconfig.brightness)
  ws2812_effects.set_delay(ledconfig.delay)
  if (config.led.byteCount == 3) then
    ws2812_effects.set_color(ledconfig.color.g, ledconfig.color.r, ledconfig.color.b)
  else
    ws2812_effects.set_color(ledconfig.color.g, ledconfig.color.r, ledconfig.color.b, ledconfig.color.w)
  end
  ws2812_effects.start();
end

local ledconfig = dofile("ledconfig.lua")
--print the config for debugging purpose
for k,v in pairs(ledconfig) do
  if (type(v) == "table") then
    uart.write(0, k..": \n")
    for key, value in pairs(v) do
      uart.write(0, "   "..key..": "..tostring(value).."\n")
    end
  else
    uart.write(0,k..": "..tostring(v).."\n")
  end
end

--Applying the existing config in case of power loss
applyConfig(ledconfig)
ledconfig = nil
collectgarbage("collect")

--Now we set up UDP Callbacks so we can receive Messages, process them and change our behaviour
local udpSocket = net.createUDPSocket()
udpSocket:listen(config.net.port)
udpSocket:on("receive", function(s, data, port, ip)
  dofile("processCommand.lc")(data)
end)
