intervall = 5000 -- in ms

function StartCape(intervall)

    print("Starting CAPE") 
    print(wifi.sta.getip())

    dofile('synctime.lua') 
    dofile('MQTT.lua')
    dofile('owtemp.lua')
    --Add more stuff
    --dofile('MQTT.lua')
    
    tmr.alarm(2, 5000, tmr.ALARM_AUTO, function()

        
        getTemp()
        

        if connected == false then
            print("not connected")
            return
        end


        for key,value in pairs(temperature) do 
            print(key) 
            --print(value.time) 
            --print(value.temperature)

            if value.sent == false then
                topic = cmd_ch .. "/" .. key
                payload = "{\"time\":" .. value.time .. ",\"temperature\":" .. value.temperature .. "}"
                m:publish( topic , payload,0,0)
                value.sent = true

                print("Sending: " .. topic .. " " .. payload)
            end

        end
        
        
        --dofile('DHT11.lua')

        --if status == dht.OK then
        --    sec,usec=rtctime.get()
        --    if connected then
        --        m:publish(cmd_ch .. "/dht11","{\"time\":" .. sec .. ",\"temperature\":" .. temp .. ",\"humidity\":" .. humi .. "}",0,0)
        --    end
        --end
    end)
    
end




-- Start only if we have an IP or when we get one. 
if (wifi.sta.getip() ~= nil) then
    StartCape(intervall)
else
    wifi.sta.eventMonReg(wifi.STA_GOTIP, StartCape)
end


