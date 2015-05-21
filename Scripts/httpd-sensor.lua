require "am2321"

am2321_init();

--stop_server = 0;
function check_sensor_name_file()
    f = file.open("sensor_name.txt");
    file.close();
    if (f == nil) then
        ip, _, _ = wifi.sta.getip();
        file.open("sensor_name.txt","w+");
        file.write(ip);
        file.close();
    end
end

function get_sensor_name()
    local f = file.open("sensor_name.txt","r");
    if (f == nil) then
        file.close();
        return "-no-name-";
    end
    local sens_name = file.read();
    file.close();
    return sens_name;
end

check_sensor_name_file();

function sendPage(cli,req)
        local _, _, method, path, vars = string.find(req, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(req, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end

        cli:send('HTTP/1.1 200 OK\n\n');
        
        local sens_name = get_sensor_name();
        local x = am2321_read_raw();
        local am_res = x[0];
        local humi = x[1];
        local temp = x[2];        
        
        if (_GET.xml ~= nil) then
            cli:send("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            cli:send("<sensor>");
                cli:send("<name>"..sens_name.."</name>");
                cli:send("<status>"..tostring(am_res).."</status>");
                cli:send("<humi>"..tostring(humi).."</humi>");
                cli:send("<temp>"..tostring(temp).."</temp>");
            cli:send("</sensor>");
        else
            cli:send("<html><head><meta charset='UTF-8'>");
            cli:send("<title>ESP8266 AM2321 NodeMCU - Humidity &amp; Temperature remote mini sensor</title>");
            cli:send("</head><body>");
            cli:send("<H2>Sensor: "..sens_name.."</H2>");
            if (am_res == 0) then
                humi_dec = humi - ((humi/10)*10);
                temp_dec = temp - ((temp/10)*10);
                cli:send("<B>Humi: </B>"..(humi/10).."."..humi_dec.."%<br/>");
                cli:send("<B>Temp: </B>"..(temp/10).."."..temp_dec.."&deg;C<br/>");
            else
                cli:send("<B>Humi: </B>ERROR("..am_res..")<br/>");
                cli:send("<B>Temp: </B>ERROR("..am_res..")<br/>");
            end
            cli:send("</body></html>");
        end
        print("AM2321_RAW_READ RES="..am_res.." HUMI="..string.format("%04X",humi).."("..humi..") TEMP="..string.format("%04X",temp).." ("..temp..")");  
end;

-- http server
srv=net.createServer(net.TCP, 10);
srv:listen(80, function(con)
    con:on("receive", sendPage)
    con:on("sent", function(sock)
        sock:close()
    end)
end)
     
