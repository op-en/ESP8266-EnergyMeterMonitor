temperature = {}

pin = 4
ow.setup(pin)

counter=0
lasttemp=-999

function bxor(a,b)
   local r = 0
   for i = 0, 31 do
      if ( a % 2 + b % 2 == 1 ) then
         r = r + 2^i
      end
      a = a / 2
      b = b / 2
   end
   return r
end

function ArrayToHex(arr)
    
    result = ""

    c = arr:gsub(".", function(c)  

    result = result .. string.format( "%02X",c:byte())
    
    end)
   

    return result 
end

--- Get temperature from DS18B20 
function getTemp()
      addr = ow.reset_search(pin)
      repeat
        tmr.wdclr()
      
      if (addr ~= nil) then
        crc = ow.crc8(string.sub(addr,1,7))
        if (crc == addr:byte(8)) then
          if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
                ow.reset(pin)
                ow.select(pin, addr)
                ow.write(pin, 0x44, 1)
                tmr.delay(1000000)
                present = ow.reset(pin)
                ow.select(pin, addr)
                ow.write(pin,0xBE, 1)
                data = nil
                data = string.char(ow.read(pin))
                for i = 1, 8 do
                  data = data .. string.char(ow.read(pin))
                end
                crc = ow.crc8(string.sub(data,1,8))
                if (crc == data:byte(9)) then
                   t = (data:byte(1) + data:byte(2) * 256)
         if (t > 32768) then
                    t = (bxor(t, 0xffff)) + 1
                    t = (-1) * t
                   end
         t = t * 625

         sec,usec=rtctime.get()
         temperature[ArrayToHex(addr)] = {}
         temperature[ArrayToHex(addr)].time = sec
         temperature[ArrayToHex(addr)].temperature = t/10000
         temperature[ArrayToHex(addr)].sent = false
    
         --print("adress: " .. ArrayToHex(addr) .." temp:"  ..  t/10000)
                end                   
                tmr.wdclr()
          end
        end
      end
      addr = ow.search(pin)
      until(addr == nil)
end
