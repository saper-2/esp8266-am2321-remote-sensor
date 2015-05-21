# ESP8266 NodeMCU and AM2321 Remote Sensor
ESP8266 with NodeMCU &amp; AM2321 Temperature &amp; Humidity sensor with web interface.
Basically this project allow you to show AM2321 readings in web browser in normal HTML format or XML format. You should treat this as example than fully working "remote sensor". I have still trouble with heap (that goes too low) because of my software i2c lib.

To communicate with AM2321 I had to create (copy my i2c library for AVRs) software I2C library because library builtin into NodeMcu didn't want to talk with AM2321 (I don't know why, and I didn't dug into).


# Getting things to work
I assume that you have working ESP8266 with flashed NodeMCU...
I'm using ESPloer for loading scripts. After loading script the ESPloere have "feature" (annoying one) that runs the script. So after loading each script you have to hard reset (by hardware - not by software because this does not release all heap).
After reset, you compile uploaded script. You only do not compile ```init.lua``` and this script should be the last one to be uploaded :smile: .
I have tested this "installation" of my scripts :smile: 

1. upload to ESP ```my-i2c.lua```
2. Hard-reset ESP and compile ```my-i2c.lua```
3. upload ```am2321.lua```
4. Hard-reset ESP and compile ```am2321.lua```
5. upload ```httpd-sensor.lua```
6. Hard-reset ESP and compile ```httpd-sensor.lua```
7. Upload ```configServer1.lua```
8. Hard-reset ESP and compile ```configServer1.lua```
9. upload ```init.lua``` and hard-reset

Now if you didn't connected your ESP to your WiFi. ESP should start config server by creating new WiFi network with "SvrSens-" prefix and 3 last bytes of MAC address.

Now connect to this network (I have used tablet) and open in web browser address ```192.168.4.1``` .

If you want to reconfigure ESP with this sensor-server, then the fastest way is to connect serial console and rename ```init.lua``` to anything else e.g.: ```=file.rename("init.lua","init0.lua")```, then hard-reset ESP and manually run ```dofile("configServer1.lc")```` . 
Or walking out of range your AP should should also load from init *configServer1* but I didn't tested it.

# Screenshots 
<img src="https://github.com/saper-2/esp8266-am2321-remote-sensor/blob/master/Screenshots/esp8266-remo-sensor-n7-httpd-sensor.jpg" title="Screenshot of www page" width="550px" /> <img src="https://github.com/saper-2/esp8266-am2321-remote-sensor/blob/master/Screenshots/esp8266-remo-sensor-n7-httpd-sensor-xml.jpg" title="Screenshot of www page in xml" width="550px"/>

