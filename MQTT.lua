clientid = wifi.sta.getmac()
server = "op-en.se"
cmd_ch = "test/cape/" .. wifi.sta.getmac() .. ""

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
      print("MQTT connected")
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
 


print("Connecting to MQTT")

MQTTConnect()
