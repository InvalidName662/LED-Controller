return function(data)
  local processCommand = function(ledconfig, type, pars)
    --Set Command
    if type == "set" then
      local firstWhitespace = pars:find(" ");
      local property = pars:sub(1, firstWhitespace-1)
      local value = pars:sub(firstWhitespace+1, -1)
      print("Property: "..property)
      print("Value: "..value)

      --Change the property
      if (property == "color") then
        local numbers = value:gmatch("%d+")
        local index = 0
        for number in numbers do
          number = number:gsub("%s", "")
          if (index == 0) then
            ledconfig.color.r = tonumber(number)
          elif(index == 1) then
            ledconfig.color.g = tonumber(number)
          elif(index == 2) then
            ledconfig.color.b = tonumber(number)
          elif(index == 3 and config.led.byteCount == 4) then
            ledconfig.color.w = tonumber(number)
          end
          index = index + 1
        end
      elif (property == "mode") then
        ledconfig.mode = value:gsub("%s", "")
      elif(property == "power") then
        if (value == "on") then
          ledconfig.power = true
        else
          ledconfig.power = false
        end
      elif(property == "brightness") then
        ledconfig.brightness = tonumber(value:gsub("%s", ""))
      elif(property == "speed") then
        ledconfig.speed = tonumber(value:gsub("%s", ""))
      elif(property == "delay") then
        ledconfig.delay = tonumber(value:gsub("%s", ""))
      else
        uart.write(0, "None existent property: "..property)
      end
    end

    --Clean up and end
    firstWhitespace = nil
    property = nil
    value = nil
    collectgarbage()
    return ledconfig
  end

  --Process Command(s)
  --Find valid commands
  local commands = data:gmatch("%l+ [%w ]+")
  --Load in the config file
  local ledconfig = dofile("ledconfig.lua")
  --Iterate over every valid command, change the config and later write it back to its file
  for command in commands do
      local _, firstWhitespace = command:find(" ")
      local type = command:sub(1, firstWhitespace-1)
      local pars = command:sub(firstWhitespace+1, -1)
      ledconfig = processCommand(ledconfig, type, pars)
  end

  --Write to file

  --Remove old file
  file.remove("ledconfig.lua")
  --Create new file
  file.open("ledconfig.lua")
  file.writeline("conf={}")
  --Iterate over the new config and rewrite values to the new file
  for k,v in pairs(ledconfig) do
    if (k == "color") then
      --Color needs special treatment cause its a table itself. There might be a better solution here but in my opinion its not worth searching for it
      file.writeline("conf.color."..k.."='"..v.."'")
      file.writeline("conf.color"..k.."='"..v.."'")
      file.writeline("conf.color"..k.."='"..v.."'")
      file.writeline("conf.color"..k.."='"..v.."'")
    else
      --In case of a string we have a special case because it needs "" around it
      if (type == "string") then
        file.writeline("conf."..k.."='"..v.."'")
      else
        file.writeline("conf."..k.."="..tostring(v))
      end
    end
  end
  file.writeline("return conf")
  file.close()

  --Apply Config
  dofile("applyConfig.lc")(ledconfig)

  --Clean up
  ledconfig = nil;
  commands = nil
  collectgarbage()
end
