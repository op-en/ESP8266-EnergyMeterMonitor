clientid = wifi.sta.getmac()
server = "op-en.se"
cmd_ch = "test/".. ApplicationName .."/" .. wifi.sta.getmac() .. ""

if (m ~= nil) then
    m:close()
end

connected = false



m = mqtt.Client(clientid, 30)

function handle_disconnect(con)
    print ("MQTT disconnected")
    connected = false
    MQTTConnect()
end

m:on("offline", handle_disconnect)



-- on receive message
m:on("message", function(conn, topic, data)
  print(topic .. ":" )
  if data ~= nil then
    print(data)
  end
end)
 

m:lwt(cmd_ch, "MCU offline", 0, 1)
 
  
function MQTTConnect()
   
    --m:close()

    if connected == true then
        return
    end 
    
    m:connect(server, 1883, 0, function(conn)
      print("MQTT connected!")
      print("Publishing data to MQTT server: " .. server .. " on topic: " .. cmd_ch)
      if debug then
        print("Debug messages will be written to " .. cmd_ch .. "/debug")
      end
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

function log(msg) 
    if debug then
        m:publish(cmd_ch .. "/debug",msg,0,0)
    end
end
 


print("Connecting to MQTT")

MQTTConnect()
