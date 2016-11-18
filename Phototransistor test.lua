
count = 0  
changed = false

gpio.mode(4,gpio.OUTPUT) 
 

do
  -- use pin 1 as the input pulse width counter
  local pin, pulse_lenght, du, now, trig = 5, 0, 0, tmr.now, gpio.trig      
  local count,changed, ptime, delta, ts, tsu, lasttime = 0, false, 0,0,0,0,0  
  local t_lo,t_hi = 5000, 20000
  gpio.mode(pin,gpio.INT)
  local function pin1cb(level)
    -- The program enters here when the pulse starts

    -- Turn on blue LED
    gpio.write(4,0) 

    -- Save the time 
    ptime = now()
    
    -- Wait until pin goes low
    -- This is a fix since interupt on both 
    -- high and low tends to miss level changes.
    while gpio.read(pin) == 1 do
    end
 
    -- Now the pulse has finnished
    -- Calculate pulse length
    pulse_lenght = now() - ptime

    -- Increase counter
    if pulse_lenght > t_lo and pulse_lenght < t_hi then
        delta = ptime - lasttime
        lasttime = ptime
        count = count + 1
        ts,tsu = rtctime.get()
        changed = true    
        
    end

    -- Rearm interupt
    trig(pin, "high") 

    --Turn of led
    gpio.write(4,1)

    
    
  end
  
  trig(pin, "high", pin1cb)

  tmr.alarm(2,500,1,function()

     if changed then
        print(count.. "\t:" .. pulse_lenght .. "\t:" .. delta .. "\007 \n")
        changed = false
     end

   end)

end


