intervall = 5000 -- in ms

function StartProgram(intervall)
    -- This is for programming the module over wifi
    --dofile('tcp-ota.lua')
    print(" ")
    print("Starting application " .. ApplicationName) 
    print("Yor device IP is: " .. wifi.sta.getip())
    print(" ")
    print("Data from you device can be viewed on:")
    print("https://op-en.se/emm/?id=" .. wifi.sta.getmac())
    print(" ")
 
    dofile('synctime.lua') 
    dofile('MQTT.lua')
    dofile('PulseDetectorV2.lua')
    --dofile('owtemp.lua')
    --Add more stuff
    --dofile('MQTT.lua')
    
      
     
end




-- Start only if we have an IP or when we get one. 
if (wifi.sta.getip() ~= nil) then
    StartProgram(intervall)
else
    wifi.sta.eventMonReg(wifi.STA_GOTIP, StartProgram)
end


