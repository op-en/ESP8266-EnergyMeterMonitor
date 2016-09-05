print("Starting pulse detector script")


--Globals
count = 0
prev_sec = 0
prev_usec = 0
connected = false
sec = 0
usec = 0
energy = 0
valid = false
pin = 4
tsyncing = false
synced = false

 

--Just to get pulse lenght to work
rtctime.set(1468431267)
 

function synctime()
    if (tsyncing == false) then
        tsyncing = true
        sntp.sync('ntp1.sptime.se',
          function(sec,usec,server)
            tsyncing = false
            print('Time synced: ' .. sec .. "." .. usec)
            synced = true
            --resync time every hour.
            tmr.alarm(0, 3600000, tmr.ALARM_AUTO, synctime)
          end, 
          function()
           tsyncing = false
           print('Time sync failed!')
           synced = false
            --retry time every 30sec.
            synctime()
            --tmr.alarm(0, 10000, tmr.ALARM_AUTO, synctime)
          end
        )
    end
end


print("Opening pin " .. pin .. " for pulse detection")

gpio.mode(pin, gpio.INPUT,gpio.PULLUP)
gpio.trig(pin, "both", function(level)

 if (level == gpio.LOW) then

    count = count + 1

    sec, usec = rtctime.get()

    while (gpio.read(4) == gpio.LOW) do

    end 

    hsec, husec = rtctime.get()

    pulselength =  husec-usec + (hsec - sec) * 1000000

    delta = (sec-prev_sec) * 1000 + (usec - prev_usec)/1000


    if (pulselength > 400) and (pulselength < 5000) and (delta > 180) then
        energy = energy + 1
        valid = true
    else
        valid = false
    end


    --print(sec,prev_sec,usec,prev_usec)

    --Create message.
    msg = "{"

    --If we have a time sync add current time.
    if (synced) then
        msg = msg ..  "time:".. sec .. "." .. usec/1000 .. ","
    end
    msg = msg .. "count:" .. count

    --If we have a previous pulse att period.
    if (prev_sec > 0) then
       msg = msg .. ", period:".. delta
    end

    if (sec > 0) then
       msg = msg .. ", pulse:".. pulselength
    end

    msg = msg .."}"


    --Create message 2.
    msg2 = "{"

    if (synced) then
        msg2 = msg2 ..  "time:".. sec .. "." .. usec/1000 .. ","
    end
    msg2 = msg2 .. "energy:" .. energy


    --If we have a previous pulse att period.
    if (delta > 0) then
       msg2 = msg2 .. ",power:".. 3600000/delta
    end
    msg2 = msg2 .."}"

    
    if (connected) then
        m:publish("mainmeter/ioevent",msg,0,0)

        if (valid) then
            m:publish("mainmeter/meterevent",msg2,0,0)
        end
    end

    print("     " .. msg)

    if (valid) then
        print(msg2)
    end

    prev_sec = sec
    prev_usec = usec

 end

  end)





m = mqtt.Client("pulse_detector", 30)


m:on("connect", function(con)
    print ("MQTT connected")
    connected = true

end)
m:on("offline", function(con)

    print ("MQTT disconnected")
    connected = false
    MQTTConnect()
end)

-- on receive message
m:on("message", function(conn, topic, data)
  print(topic .. ":" )
  if data ~= nil then
    print(data)
  end
end)
 
cmd_ch = "esp/" .. wifi.sta.getmac() .. ""
m:lwt(cmd_ch, "MCU offline", 0, 1)
 
 
function MQTTConnect()
   
    --m:close()

    if connected == true then
        return
    end 
    
    m:connect("192.168.1.100", 1883, 0, function(conn)
      print("MQTT connected")
      connected = true
      -- subscribe topic with qos = 0
      m:subscribe(cmd_ch .. "/cmd",0, function(conn)
        -- publish a message with data = my_message, QoS = 0, retain = 0
        m:publish(cmd_ch,"MCU online",0,1, function(conn)
          --print("sent")
        end)
      end)
     end)
 end

 wifi.sta.eventMonReg(wifi.STA_GOTIP, function() 
 
    print("STATION_GOT_IP") 
    MQTTConnect()
 end)
 


print("Syncing time")
synctime()
print("Connecting to MQTT")
MQTTConnect()

--MQTTConnect()

