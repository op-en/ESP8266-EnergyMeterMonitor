# ESP8266-EnergyMeterMonitor
This is a project to create an energy visualisation based on an ESP8266 that connects to the LED of a power meter with a phototransistor.

##How to use

###Software

1. Download or compile firmware to your NoceMCU chip with software from: http://nodemcu-build.com. Be sure to check MQTT, SNTP, File, Node, GPIO, RTC time, timer, UART and so on.

2. Flash your firmware with the float version of the firmware. Example: esptool.py -p /dev/cu.wchusbserial1410 write_flash -fm dio -fs 32m 0x00000 nodemcu-master-21-modules-2016-07-11-12-51-01-float.bin 

3. Change the settings file with you WIFI credentials and meter pulse unit. And upload it through the ESPlorer to the NodeMCU

4. Upload all files in the /src directory to the NodeMCU. Save the init file to last.

5. Reboot the NodeMCU. And write down the visualisation url.

###Hardware:

1. Connect a photodiod to the GND and PORT5  (situated next to each other) on the NodeMCU using a 2 x female to female dupont cable. Make sure its turned the right way the short leg with the broad stop piece should be connected to GPIO5 and the long leg to GND.
2. Insert a resistor with a value between 80k and 400k* in serial with the photodiod.  

*The smaller the resistande the more sensitive the photodiod will be. A to small value will make the blue led on the NodeMCU to be on all the time instead of just flashing when the electric meter does. A to big value or no resistor at all will make the unit stop detecting pulses when the suroundings are to dark. 

3. 3D print the stl file with the photodiod holder and push the photodiod into it. 
4. Cut out some double adhasive tape (the foam type works well) and place around the opening of the photodiod holder. 
5. Stick the photodiodholder to the led* on you electric meter and test. 

* Some diod are IR where you cant see the light. There are also different sorts of diods on some meters 2 pair for datacommunication with the meter and 1-2 for flashing the pulses. It usually says kwh or 1000 imp/kwh or something simular next to the correct one. 





