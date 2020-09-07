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
    ws2812_effects.stop()
    gpio.write(config.led.powerPin, gpio.LOW)
  end

  local buffer = ws2812.newBuffer(config.led.ledNum, config.led.byteCount)

  if (ledconfig.mode.mode = "static") then
    ws2812_effects.stop()
    if (config.led.byteCount == 3) then
      buffer:fill(ledconfig.color.g, ledconfig.color.r, ledconfig.color.b)
    else
      buffer:fill(ledconfig.color.g, ledconfig.color.r, ledconfig.color.b, ledconfig.color.w)
    end
    ws2812.write(buffer)
  else
    ws2812_effects.init(buffer)
    ws2812_effects.set_speed(ledconfig.speed)
    if (ledconfig.mode.pars == "321!none!123") then
      ws2812_effects.set_mode(ledconfig.mode.mode)
    else
      code = "ws2812_effects.setmode(ledconfig.mode.mode"
      for key, value in pairs(ledconfig.mode.pars) do
        code = code..", "..value
      end
      code = code..")"
      loadstring(code)()
    end
    ws2812_effects.set_brightness(ledconfig.brightness)
    ws2812_effects.set_delay(ledconfig.delay)
    if (config.led.byteCount == 3) then
      ws2812_effects.set_color(ledconfig.color.g, ledconfig.color.r, ledconfig.color.b)
    else
      ws2812_effects.set_color(ledconfig.color.g, ledconfig.color.r, ledconfig.color.b, ledconfig.color.w)
    end
    ws2812_effects.start();
  end
end

local ledconfig = dofile("ledconfig.lua")
--print the config for debugging purpose
local printTable = function(table)
  for k, v in pairs(table) do
    if (type(v) == "table") then
      print(k.."->")
      printTable(v)
      print("End of "..k)
    else
      uart.write(0,k..": "..tostring(v).."\n")
    end
  end
end
printTable(ledconfig)

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
