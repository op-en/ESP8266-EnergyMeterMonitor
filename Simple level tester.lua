gpio.mode(5, gpio.INPUT,gpio.PULLUP)
count = 0

gpio.trig(5, "both", function(level)
 
 if level == gpio.LOW then 
    count = count + 1   
    print(count)
 end
 
  end)

  
