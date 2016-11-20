intervall = 5000 -- in ms

function StartProgram(intervall)
    dofile('tcp-ota.lua')
    print("Starting EEM") 
    print(wifi.sta.getip())

    dofile('synctime.lua') 
    dofile('MQTT.lua')
    --dofile('Pulse detector.lua')
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


