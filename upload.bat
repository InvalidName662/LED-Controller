@echo off
call nodemcu-tool upload --compile src\main.lua src\wifiConfig.lua src\config.lua src\applyConfig.lua
call nodemcu-tool upload src\init.lua src\ledconfig.lua
call nodemcu-tool fsinfo
echo Process finished!
