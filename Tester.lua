
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
    now = tmr.now()/1000

    delta = now - before
    ev_delta = now - ev_before
    ev_before = now

    if levelcount == 10 then
        mylevel = gpio.HIGH
    else
        mylevel = gpio.LOW
    end

    --if mylevel = level then
    --    print("Level error")
    --end
    idelta = math.floor(delta)

    if mylevel == lastlevel then
        msg = "Conflict: ML" .. mylevel .. " L" .. level .. " CL" .. checklevel(10) .. " LL" .. lastlevel

        log(msg)
        
        if mylevel ~= level then
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



    --if lastlevel == mylevel and lastlevel == level then
    --    print("I: " .. math.floor(ev_delta) .. " \tMy level:" .. mylevel .. " Level:" .. level .. "***")
    --    return
    --end

    before = now
    --print(delta)

     if mylevel == gpio.LOW then
        low = low + 1
        msg = "H: " .. idelta .. " \tMy level:" .. mylevel .. " Level:" .. level

        if delta > 520 or delta < 400 then
            
            msg = msg .. "   ******* miss *******" .. miss
            --m:publish("test/test",msg,0,0)
            --print("******* miss" .. miss)
            --print("H: " .. idelta .. " \tMy level:" .. mylevel .. " Level:" .. level)
            miss = miss+1

        end

     else
        high = high + 1
        --print("L: " .. idelta .. " \tMy level:" .. mylevel .. " Level:" .. level)
        msg = "L: " .. idelta .. " \tMy level:" .. mylevel .. " Level:" .. level

     end


     lastlevel = mylevel

     log(msg)
     
     --m:publish("test/test","hej",0,0)
     --m:publish("test/test","hej",0,0)
     --m:publish("test/test","hej",0,0)

  end)

  function log(msg) 
    if debug then
        m:publish(cmd_ch .. "/debug",msg,0,0)
    end
  end
