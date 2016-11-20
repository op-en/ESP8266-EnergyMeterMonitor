
count = 0
low = 0
high = 0
last = 0
prev_sec = 0
prev_usec = 0
pin = 5
before = 0
miss = 0
levelcount = 0
mylevel = false
lastlevel = gpio.read(pin)
ev_before = 0
ev_delta=0
debug=true 

pulsestart = 0
pulseend = 0
pulselength = 0
oldpulsestart = 0
period = 0
count = 0
energy = 0
power = 0
last_power = 0
factor = 3600000 -- 1000 imp/kWh. 1W will give us a period of 1 pulse per hour. I.e. P = 360000 ms  
min_pulselenght = 1
max_pulselenght = 90
min_change = 0
heartbeat = 10
oldtime = 0
oldenergy = 0
time=0

gpio.mode(4, gpio.OUTPUT)

gpio.mode(pin, gpio.INPUT,gpio.PULLUP)

rtctime.set(1468431267)

function checklevel(n)

    c = 0
    for i=1,n do
            c = c + gpio.read(pin)
        end
    return c
end
 

gpio.trig(pin, "both", function(level)

    levelcount = checklevel(10)

    last = last + 1

    sec, usec = rtctime.get()
    time = sec + usec/1000000
    now = tmr.now()/1000
    
    delta = now - before
    ev_delta = now - ev_before
    ev_before = now

    if levelcount == 10 then
        mylevel = gpio.HIGH
        gpio.write(4,gpio.HIGH)
    else
        mylevel = gpio.LOW
        gpio.write(4,gpio.LOW)
    end 

    log("" .. now .. " : " .. mylevel .. " : " .. delta)

    --if mylevel = level then
    --    print("Level error")
    --end
    idelta = math.floor(delta)

    if mylevel == lastlevel then
        levelcheck2  = checklevel(10)
        
        msg = "Conflict: ML" .. mylevel .. " L" .. level .. " CL" .. levelcheck2 .. " LL" .. lastlevel

        log(msg)
        
        if (lastlevel == gpio.HIGH and mylevel == gpio.HIGH and levelcheck2 == 10) then
            log("Ignore")
            return
        end
        
        if mylevel ~= level or (levelcheck2 == 10 and lastlevel == gpio.LOW) then
            --print("Conflict: ML" .. mylevel .. " L" .. level .. " CL" .. checklevel(10) .. " LL" .. lastlevel )
            --print("Fixing!")
            log("Fix1")
            
            if lastlevel == gpio.HIGH then
                mylevel = gpio.LOW
            else
                mylevel = gpio.HIGH
            end
        end

       
        

    end

    before = now
    lastlevel = mylevel
 
    --******************************************** 
    -- Energy messages
     if (mylevel == gpio.HIGH) then
        pulseend = now
        pulselenght = pulseend - pulsestart

        --Handle wraps of timer
        if pulselenght < 0 then
            pulselenght = pulselength + 2147483.648
        end
        
        count = count + 1

        period = pulsestart - oldpulsestart

        --Handle wraps of timer
        if period < 0 then
            period = period + 2147483.648
        end

        oldpulsestart = pulsestart

        log(" ")
        ioevent()

        if pulselenght > min_pulselenght and pulselenght < max_pulselenght then
            energy = energy + 1
            power = factor/period
            
            if (math.abs(power-last_power) > min_change) then
                meterevent()
            end

        end
     else
        
        --period = now - pulsestart 
        pulsestart = now
       
     end
 

  end)

  function log(msg) 
    if debug then
        m:publish(cmd_ch .. "/debug",msg,0,0)
    end
  end
 
  function ioevent()

    msg = "{"
    
    --If we have a time sync add current time.
    if (synced) then
        msg = msg ..  "\"time\":".. sec .. "." .. math.floor(usec/1000) .. ","
    end
    msg = msg .. "\"count\":" .. count

    --If we have a previous pulse att period.
    
    msg = msg .. ", \"period\":".. period
    

    if (sec > 0) then
       msg = msg .. ", \"pulse\":".. pulselenght
    end

    msg = msg .."}"


    
    if connected then
        m:publish(cmd_ch .. "/ioevent",msg,0,0)
    end
  end

  function meterevent()  

    msg2 = "{"


    if (synced) then
        msg2 = msg2 ..  "\"time\":".. oldtime .. ","
    end
    msg2 = msg2 .. "\"energy\":" .. oldenergy


    --If we have a previous pulse att period.
    if (delta > 0) then
       msg2 = msg2 .. ",\"power\":".. power
    end
    msg2 = msg2 .."}"

    oldtime = time
    oldenergy = energy

    
    m:publish(cmd_ch .. "/meterevent",msg2,0,0)
  end

  
