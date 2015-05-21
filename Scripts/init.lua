-- init.lua
print("-sys.up;");
-- IO2 as input with pull-up
wifi.setmode(wifi.STATION);
wifi.sta.autoconnect(1);
tmr.delay(5000000);
s = wifi.sta.status();
--s=0; --ENTER-CONFIG
if (s==0 or s==2 or s==3 or s==4) then
    print("-start.httpd.config;");
    s=nil;
    collectgarbage();
    tmr.delay(500000);
    dofile("configServer1.lc");
    --print(node.heap());
else -- s==1 or s==5
    print("-start.httpd.sensor;");
    s=nil;
    collectgarbage();
    tmr.delay(50000);
    dofile("httpd-sensor.lc");
    --print(node.heap());
end
