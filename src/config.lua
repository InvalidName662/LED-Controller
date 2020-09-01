local config = {}

--search for Wifi Config. If nonexistent print an error
assert(file.exists("wifiConfig.lc"), "Couldnt load 'wifiConfig.lc'. Cannot connect to AP")
config.wifi = dofile("wifiConfig.lc")

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
