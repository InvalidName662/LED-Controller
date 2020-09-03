This was my first time using Lua, NodeMCU and just any IoT device in general. I think I did a good job but that might not be the case.
If someone ever finds this, youre welcome to tell me what I did wrong
# LED-Controller
A NodeMCU Programm that can be used to control a Ws2812 LED-Strip via UDP.
It uses ws2812_effects which is deprecated, but ill update it once they replace it.

# Usage
Send a UDP Message to the IP and Port specified in your [config file](src/config.lua).
You'll obviously also need to change the password and ssid there so the NodeMCU can connect to your Network and you can reach it
You can then send commands which are written in this syntax:
```
  set property value
```
You can also chain them together like so:
```
  set property1 value1;set property2 value2
```
You can chain as many as you want as long as they are seperated by a Semicolon.\
\
Possible Properties are:
```
  -power on|off
    -Sets GPIO14/IO 5 to be set high/low So you might control a relais or something like that
  -color RGB(W)
    -change the color. W is only interpreted if in your [config file](src/config.lua) youve set the byteCount to be 4
  -mode mode
    -Change the mode. This is simply passed to ws2812_effects so everything valid there goes for this
  -brightness val
    -Change the brightness. 0 to 255 is valid
  -speed val
    -Change the speed of the animation. O to 255 is valid
  -delay val
    -Change delay between update cycles. 0 to 255 is valid
```
If you pass something that isnt valid there will be errors cause not much error catching is being done so watch out.

# Notes
You could actually easily rewrite this to be controlled by Serial or any other method for sending Text.
Just replace my udpsocket with your whatever. Then do something like this when receiving the Message
```lua
  dofile("processCommand.lc")(input)
```
Genererally you should have a good look at the [config file](src/config.lua) since everything i thaught you might need to change can be changed there\
The [upload script](upload.bat) only works with the [NodeMCU Tool](https://github.com/AndiDittrich/NodeMCU-Tool) by [Andi Dittrich](https://github.com/AndiDittrich)\
I heavily recommend it cause its easy to use, is well documented and looks nice. You'll also need to have a firmware with gpio, net, uart, file, wifi, ws2812, ws2812_effects and color_utils. I included a float build to this repo that works so you dont need to build yourself
