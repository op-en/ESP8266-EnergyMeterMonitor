-- load credentials, 'SSID' and 'PASSWORD' declared and initialize in there
dofile("credentials.lua")
   
function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Running")
        file.close("init.lua")
        dofile("Startup.lua")


    end
end

print("Connecting to WiFi access point...")
wifi.setmode(wifi.STATION)
--wifi.sta.setip({ip="192.168.0.230",netmask="255.255.255.0",gateway="192.168.0.1"})

wifi.sta.eventMonReg(wifi.STA_IDLE, function() print("STATION_IDLE") end)
wifi.sta.eventMonReg(wifi.STA_CONNECTING, function() print("STATION_CONNECTING") end)
wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() print("STATION_WRONG_PASSWORD") end)
wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() print("STATION_NO_AP_FOUND") end)
wifi.sta.eventMonReg(wifi.STA_FAIL, function() print("STATION_CONNECT_FAIL") end)
wifi.sta.eventMonReg(wifi.STA_GOTIP, function() print("STATION_GOT_IP") end)
wifi.sta.eventMonStart()

wifi.sta.config(SSID, PASSWORD,1)

--wifi.sta.connect()
--tmr.alarm(1, 1000, 1, function()
--    if wifi.sta.getip()wifi.sta.getip()wifi.sta.getip()wifi.sta.getip() == nil then
--        print("Waiting for IP address...")
--    else
--        tmr.stop(1)
--        print("WiFi connection established, IP address: " .. wifi.sta.getip())
        print("You have 3 seconds to abort")
        print("Waiting...")
        tmr.alarm(0, 3000, 0, startup)
  --  end
--end)
