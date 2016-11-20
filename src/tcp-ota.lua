print("TCP OTA Server starting...")
tcp_ota = {}

tcp_ota.loggedin = false
tcp_ota.lastcmd = ""
tcp_ota.conn = nil
tcp_ota.sending = false
tcp_ota.response = {}

tcp_ota.sendcomplete = function(sk)
    --Send the rest if any. 
    if #tcp_ota.response > 0 then 
        msg = table.remove(tcp_ota.response, 1)
        if (msg ~= nil and tcp_ota.conn ~= nil) then 
            tcp_ota.conn:send(msg)
        end
        return
    end
    --Done 
    --print("Que complete")
    --uart.write(0, "Que complete!\n")
    --sending = false
    _G.tcp_ota.sending = false
end

tcp_ota.send = function(msg)
    tcp_ota.response[#tcp_ota.response + 1] = msg
    
    if _G.tcp_ota.sending then        
        return
    end

    _G.tcp_ota.sending = true
    tcp_ota.conn:on("sent", tcp_ota.sendcomplete)
    tcp_ota.sendcomplete()
    
end

tcp_ota.s_output = function(str) 

    --REFORMAT str
    --sub = string.sub(str,string.len(str)-1)
    --sub2 = string.sub(str,string.len(str))
    
    --if (sub2 == "\n") then
    --    str = str .. "> "
    --elseif ( sub ~= "> ") then
     --   str = str .. "\r\n> "
    --end

    
    if (tcp_ota.loggedin==true) then
    
        --print("Called:" .. str)
    
        if (tcp_ota.conn ~= nil) then
            --sending = true
            tcp_ota.send(tcp_ota.lastcmd .. str)
        end
        
    else 
        if (tcp_ota.conn ~= nil) then
            tcp_ota.send("Enter password:")
        end
    end

    if (mqtt_connection ~= nil) then
        if (mqtt_connection.connected == true) then 
                mqtt_connection.m:publish(mqtt_connection.cmd_ch .. "/log",tcp_ota.lastcmd .. str,0,0)
        end
    end
    
    tcp_ota.lastcmd = ""
 
end

node.output(tcp_ota.s_output,1)


tcp_ota.startServer= function()
   
   sv=net.createServer(net.TCP, 180)
   sv:listen(8080,   function(connection)
      print("Wifi console connected.")

     -- if (tcp_ota.conn ~= nil) then
     --       tcp_ota.conn:close()
     --       tcp_ota.conn = nil
     --       tcp_ota.sending = false
     -- end
     -- tcp_ota.conn = connection              
      --print(s_output)
      
      
      --tcp_ota.loggedin = false

      --tcp_ota.s_output("Enter password:")
      connection:send("Enter password:\r\n")
      
      connection:on("receive", function(connection, pl)
         if (connection ~= tcp_ota.conn or tcp_ota.loggedin==false) then
            if (pl=="nrj!!!\r\n") then
                tcp_ota.loggedin=true
                --node.output(s_output,1)
     
                connection:send("\r\nLogged in!\r\n> ")

                if (connection ~= tcp_ota.conn) then
                    old_conn = tcp_ota.conn
                    tcp_ota.conn = connection
                    if (old_conn~=nil) then
                        old_conn:close()
                    end
                end

                
            else
                connection:send("Enter password:\r\n")
            end

            return 
         end
         --s_output(pl .. "\r\n")

         if (tcp_ota.conn == connection) then
             tcp_ota.lastcmd = pl
             node.input(pl)
         end 
      end)
      
      connection:on("disconnection",function(connection)
         --node.output(nil,1)
         if (connection == tcp_ota.conn) then
             tcp_ota.conn = nil
             tcp_ota.loggedin = false
         end
         
      end)
   end)  
   print("OTA Server running at :8080")
   print("Use: sudo socat pty,link=/dev/ttyS1,group=dialout,mode=777,raw tcp:" .. wifi.sta.getip() .. ":8080")
   print("To map to local comport for use of ESPlorer")
end

if (wifi.sta.getip() ~= nil) then
    tcp_ota.startServer()
else
    wifi.sta.eventMonReg(wifi.STA_GOTIP, tcp_ota.startServer)
end




--tmr.alarm(0, 1000, 1, function()
--   if wifi.sta.getip()=="0.0.0.0" then
--      print("Connect AP, Waiting...")
 --  else
 --     startServer()
  --    tmr.stop(0)
--   end
--end)
