print("Starting pulse detector script")


--Globals
count = 0
prev_sec = 0
prev_usec = 0
sec = 0
usec = 0
energy = 0
valid = false
pin = 4
--tsyncing = false


 

--Just to get pulse lenght to work
--rtctime.set(1468431267)



print("Opening pin " .. pin .. " for pulse detection")

gpio.mode(pin, gpio.INPUT,gpio.PULLUP)
gpio.mode(3, gpio.OUTPUT)
gpio.write(3,0)
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
            msg = msg ..  "\"time\":".. sec .. "." .. math.floor(usec/1000) .. ","
        end
        msg = msg .. "\"count\":" .. count
    
        --If we have a previous pulse att period.
        if (prev_sec > 0) then
           msg = msg .. ", \"period\":".. delta
        end
    
        if (sec > 0) then
           msg = msg .. ", \"pulse\":".. pulselength
        end
    
        msg = msg .."}"
    
    
        --Create message 2.
        msg2 = "{"
    
        if (synced) then
            msg2 = msg2 ..  "\"time\":".. sec .. "." .. math.floor(usec/1000) .. ","
        end
        msg2 = msg2 .. "\"energy\":" .. energy
    
    
        --If we have a previous pulse att period.
        if (delta > 0) then
           msg2 = msg2 .. ",\"power\":".. 3600000/delta
        end
        msg2 = msg2 .."}"
    
        
        if (connected) then
            m:publish(cmd_ch .. "/ioevent",msg,0,0)
    
            if (valid) then
                m:publish(cmd_ch .. "/meterevent",msg2,0,0)
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






