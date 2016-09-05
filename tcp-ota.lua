print("TCP OTA Server starting...")

loggedin = false
lastcmd = ""
conn = nil

function s_output(str) 

    --REFORMAT str
    sub = string.sub(str,string.len(str)-1)
    sub2 = string.sub(str,string.len(str))
    
    if (sub2 == "\n") then
        str = str .. "> "
    elseif ( sub ~= "> ") then
        str = str .. "\r\n> "
    end

    
    if (loggedin==true) then
    
        --print("Called:" .. str)
    
        if (conn ~= nil) then
            conn:send(lastcmd .. str)
        end
        
    else
        if (conn ~= nil) then
            conn:send("Enter password:")
        end
    end

    if (connected == true) then 
            m:publish(cmd_ch .. "/log",lastcmd .. str,0,0)
    end
    
    lastcmd = ""
 
end

node.output(s_output,1)


function startServer()
   print("Wifi AP connected. IP:")
   print(wifi.sta.getip())
   sv=net.createServer(net.TCP, 180)
   sv:listen(8080,   function(connection)
      print("Wifi console connected.")
      conn = connection              
      --print(s_output)
      
      loggedin = false

      s_output("Enter password:")
      
      conn:on("receive", function(connection, pl)
         if (loggedin==false) then
            if (pl=="1234\r\n") then
                loggedin=true
                --node.output(s_output,1)
     
                print("Logged in!\r\n> ")

                
            else
                s_output("Enter password:\r\n")
            end

            return 
         end
         --s_output(pl .. "\r\n")

         if (conn == connection) then
             lastcmd = pl
             node.input(pl)
         end 
      end)
      
      conn:on("disconnection",function(connection)
         --node.output(nil,1)
         conn = nil
         loggedin = false
         
      end)
   end)  
   print("OTA Server running at :8080")
   print("Use: sudo socat pty,link=/dev/ttyS1,group=dialout,mode=777,raw tcp:" .. wifi.sta.getip() .. ":8080")
   print("To map to local comport for use of ESPlorer")
end

startServer()

--tmr.alarm(0, 1000, 1, function()
--   if wifi.sta.getip()=="0.0.0.0" then
--      print("Connect AP, Waiting...")
 --  else
 --     startServer()
  --    tmr.stop(0)
--   end
--end)
