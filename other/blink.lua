function blink() 
    gpio.write(4,0)
    --gpio.write(4,0)
    --gpio.write(4,0)
    --gpio.write(4, 1)
    tmr.alarm(1, 20, 0, function () gpio.write(4, 1) end)
end

gpio.mode(4, gpio.OUTPUT)
tmr.alarm(0, 1000, 1, blink)
