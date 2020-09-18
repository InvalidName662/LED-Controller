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
effectBuffer = ws2812.newBuffer(config.led.ledNum, config.led.byteCount)
ws2812_effects.init(effectBuffer)

--Global Functions
applyConfig = function(input)
  ledconfig = input
  uart.write(0, "Applying config...\n")
  if (ledconfig.power) then
    gpio.write(config.led.powerPin, gpio.HIGH)
  else
    ws2812_effects.stop()
    gpio.write(config.led.powerPin, gpio.LOW)
  end

  if (ledconfig.mode.mode == "static") then
    ws2812_effects.stop()
    if (config.led.byteCount == 3) then
      effectBuffer:fill(ledconfig.color.g, ledconfig.color.r, ledconfig.color.b)
    else
      effectBuffer:fill(ledconfig.color.g, ledconfig.color.r, ledconfig.color.b, ledconfig.color.w)
    end
    ws2812.write(effectBuffer)
  else
    ws2812_effects.set_speed(ledconfig.speed)
    if (ledconfig.mode.pars == "321!none!123") then
      ws2812_effects.set_mode(ledconfig.mode.mode)
    else
      code = "ws2812_effects.set_mode(ledconfig.mode.mode"
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
  uart.write(0, "Done.\n")
  ledconfig = nil
end

writeTable = function(name, table, file)
  uart.write(0, "Writing Table to file("..name..")...\n")
  file:writeline(name.."={};")
  for k, v in pairs(table) do
    if (type(v) == "table") then
      writeTable(name.."."..k, v, file)
    elseif (type(v) == "string") then
      file:writeline(name.."."..k.."=\""..v.."\";")
    else
      file:writeline(name.."."..k.."="..tostring(v)..";")
    end
  end
  uart.write(0, "Done("..name..")\n")
end

printTable = function(table, intendation)
  intendation = intendation or ""
  for k, v in pairs(table) do
    if (type(v) == "table") then
      print(intendation..k.."->")
      printTable(v, intendation.."  ")
      print(intendation.."End of "..k)
    else
      uart.write(0,intendation..k..": "..tostring(v).."\n")
    end
  end
end

--Load in the ledconfig to print and apply in case of power loss
local ledconfig = dofile("ledconfig.lua")

--print the config for debugging purpose
printTable(ledconfig)

--Applying
applyConfig(ledconfig)
ledconfig = nil
collectgarbage("collect")

--Now we set up UDP Callbacks so we can receive Messages, process them and change our behaviour
local udpSocket = net.createUDPSocket()
udpSocket:listen(config.net.port)
udpSocket:on("receive", function(s, data, port, ip)
  dofile("processCommand.lc")(data)
end)
