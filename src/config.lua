local config = {}

--Wifi Config
--Change this to enable UDP control via your Wifi
config.wifi = {}
config.wifi.pwd = "Your Password"
config.wifi.ssid = "Your SSID (Networkname e.g. MyWifi123)"

--LED Config
config.led = {}
config.led.ledNum = 150
config.led.byteCount = 3

--net config
config.net = {}
config.net.ipconfig = {}
config.net.ipconfig.ip = "192.168.0.111"
config.net.ipconfig.netmask = "255.255.255.0"
config.net.ipconfig.gateway= "192.168.0.1"
config.net.port = 65000

return config;
