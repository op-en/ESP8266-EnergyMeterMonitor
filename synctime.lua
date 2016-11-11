
tsyncing = false

function synctime()
    if (tsyncing == false) then
        tsyncing = true
        sntp.sync('ntp1.sptime.se',
          function(sec,usec,server)
            tsyncing = false
            print('Time synced: ' .. sec .. "." .. usec)
            synced = true
            --resync time every hour.
            tmr.alarm(0, 3600000, tmr.ALARM_AUTO, synctime)
          end, 
          function()
           tsyncing = false
           print('Time sync failed!')
           synced = false
            --retry time every 30sec.
            --synctime()
            tmr.alarm(0, 30000, tmr.ALARM_AUTO, synctime)
          end
        )
    end
end

print("Time sync in progress...")
synctime()
