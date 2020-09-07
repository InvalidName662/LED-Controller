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
        for s in numbers do
          local number = s:gsub("%s", "")
          if (index == 0) then
            ledconfig.color.r = tonumber(number)
          elseif(index == 1) then
            ledconfig.color.g = tonumber(number)
          elseif(index == 2) then
            ledconfig.color.b = tonumber(number)
          elseif(index == 3 and config.led.byteCount == 4) then
            ledconfig.color.w = tonumber(number)
          end
          index = index + 1
        end
      elseif (property == "mode") then
        firstWhitespace = value:find(" ")
        if (firstWhitespace ~= nil) then
          local modeName = value:sub(1, firstWhitespace-1)
          ledconfig.mode.mode = modeName
          local args = value:sub(firstWhitespace+1, -1):gmatch("&d+")
          local flag = false
          local result = {}
          local index = 0
          for arg in args do
            flag = true
            loadstring("result."..tostring(index).."="..arg)()
            index = index + 1
          end

          if (flag) then
            ledconfig.mode.pars=result
          else
            ledconfig.mode.pars="321!none!123"
          end
        else
          ledconfig.mode.mode = value
          ledconfig.mode.pars = "321!none!123"
        end
      elseif(property == "power") then
        if (value == "on") then
          ledconfig.power = true
        else
          ledconfig.power = false
        end
      else
        local number = value:gsub("%s", "")
        if(property == "brightness") then
          ledconfig.brightness = tonumber(number)
        elseif(property == "speed") then
          ledconfig.speed = tonumber(number)
        elseif(property == "delay") then
          ledconfig.delay = tonumber(number)
        else
          uart.write(0, "None existent property: "..property)
        end
      end
    end

    return ledconfig
  end

  --Process Command(s)
  --Find valid commands
  local commands = data:gmatch("%l+ [%w ]+")
  --Load in the config file
  ledconfig = dofile("ledconfig.lua")

  --Iterate over every valid command, change the config and later write it back to its file
  --Queue this up so watchdog doesnt kick my ass into heaven
  local timer = tmr.create()
  timer:alarm(10, tmr.ALARM_AUTO, function()
    uart.write(0, "Processing next Command...\n")
    local command = commands()
    if command == nil then
      --No more Commands to process, so we write to the config file and finish off

      --Remove old file
      file.remove("ledconfig.lua")
      --Create new file
      local configfile = file.open("ledconfig.lua", "w")
      configfile:writeline("conf={}")
      configfile:writeline("conf.color={}")
      configfile:writeline("conf.mode={}")
      --Iterate over the new config and rewrite values to the new file
      for k,v in pairs(ledconfig) do
        if (k == "color") then
          --Color needs special treatment cause its a table itself
          for name, value in pairs(v) do
            configfile:writeline("conf.color."..name.."="..tostring(value))
          end
        else
          --In case of a string we have a special case because it needs "" around it
          if (type(v) == "string") then
            configfile:writeline("conf."..k.."=\""..v.."\"")
          else
            configfile:writeline("conf."..k.."="..tostring(v))
          end
        end
      end
      configfile:writeline("return conf")
      configfile:close()
      configfile = nil

      --Apply the config
      applyConfig(ledconfig)

      --Cleanup
      commands = nil
      ledconfig = nil
      timer:unregister()
      timer = nil
    else
      local _, firstWhitespace = command:find(" ")
      local type = command:sub(1, firstWhitespace-1)
      local pars = command:sub(firstWhitespace+1, -1)
      ledconfig = processCommand(ledconfig, type, pars)
    end
    collectgarbage("collect")
  end)
end
