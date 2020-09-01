return function(ledconfig)
  if (ledconfig.power) then
    gpio.write(5, gpio.HIGH)
  else
    gpio.write(5, gpio.LOW)
  end
  buffer = ws2812.newBuffer(config.led.ledNum, config.led.byteCount)
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
