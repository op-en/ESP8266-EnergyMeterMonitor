--Network preferences

-- The name of your network
SSID = "OpenEnergy"
-- Your network passwird
PASSWORD = "enhemligkod"

--Electric meter monitor settings

-- How much is one pulse form the electric meter in Wh (watt hours i.e. watt x duration in hours). 
-- 1000 imp/kwh for example means 1000 pulses per 1000Wh which is 1 pulse per Wh.
-- Hence we write 1.
EMM_pulse_unit = 1

-- If we get noice form other electrical devices we can set these to have the unit ignore long or short pulses detected on the photodiod.
EMM_min_pulselenght = 1
EMM_max_pulselenght = 90


--General

-- The server from we which we get the current time.
timeserver = 'ntp1.sptime.se'
-- The name of the application
ApplicationName="EMM"

-- Will write debug messages to test/EMM/[MAC of module]/debug
-- Use log("my message") to write debug messages
debug=false

