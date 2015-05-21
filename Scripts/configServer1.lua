apName = "SvrSens-"..string.gsub(string.sub(wifi.ap.getmac(),10),"-","");
apNetConf = { ip="192.168.4.1", netmask="255.255.255.0", gateway="192.168.4.1"};

ap_config = {};
ap_config.ssid=apName;
ssid_is_set = "";

function get_sensor_name()
    local f = file.open("sensor_name.txt","r");
    if (f == nil) then
        file.close();
        return apName;
    end
    local sens_name = file.read();
    file.close();
    return sens_name;
end

function show_page(con)
    con:send("HTTP/1.1 200 OK\n\n");
    con:send('<!DOCTYPE HTML><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.3" />');
    con:send("<title>Dev Config - "..wifi.sta.getmac().."</title><style type='text/css'>");
    con:send("body{font-size:12pt;} tr.hdr td{font-weight:bold;text-align:center;} tr.vhdr td:first-child{font-weight:bold;} table{border-collapse:collapse;} ");
    con:send("table.net, table.net td{border:solid 1px #666666; padding: 1px 4px 1px 4px;} .mono{font-family:monospace;} .dev{font-size:16pt;font-family:sans-serif;font-weight:bold;color:#004080}");
    con:send("</style></head><body><span class='dev'>"..apName.."</span>");
    if (ssid_is_set ~= nil and ssid_is_set ~= "") then
        con:send("<br/><span style='font-size:14pt; color: #000080; text-align: center;'>Set SSID <span style='color: #008a00'>"..ssid_is_set.."</span> & password.</span>");
    end;
    con:send("<form action='/' METHOD='POST'><b>Enter SSID name &amp; password:</b><table>");
    con:send("<tr class='vhdr'><td>SSID:</td><td><input type='text' name='ssid' id='ssid' value='' size='16'/></td></tr>");
    con:send("<tr class='vhdr'><td>PASSWORD:</td><td><input type='text' name='passwd' value='' size='16'/></td></tr>");
    con:send("<tr class='vhdr'><td>Sensor name:</td><td><input type='text' name='sname' value='"..get_sensor_name().."' size='16'/></td></tr>");
    con:send("<tr><td colspan='2' style='text-align: center;'><input type='submit' value='Save'/>&nbsp;&nbsp;&nbsp;&nbsp;<input type='button' value='Refresh' onclick='window.location.href=\"/\";'/>");
    con:send("&nbsp;&nbsp;&nbsp;&nbsp;<input type='submit' name='reboot' value='Reboot'/></td></tr>");
    con:send("</table></form></body></html>");
    ssid_is_set="";
end;

function url_decode(str)
  local s = string.gsub (str, "+", " ")
  s = string.gsub(s, "%%(%x%x)",
      function(h) return string.char(tonumber(h,16)) end)
  s = string.gsub(s, "\r\n", "\n")
  return s
end

function onConnect(con, header)
    if (string.find(header, "GET /favicon.ico HTTP/1.1") ~= nil) then
        con:send("HTTP/1.1 404 Not Found"); -- bitch off browser :D
    elseif (string.find(header, "GET / HTTP/1.1") ~= nil) then
        print("-confsrv.show;");
        show_page(con);
    elseif (string.find(header, "POST / HTTP/1.1") ~= nil) then
        print("-confsrv.post;");
        local _, postStart = string.find(header, "\r\n\r\n");
        if (postStart == nil) then
            return;
        end;
        header = string.sub(header, postStart+1);
        local args = {};
        args.passwd = "";
        for k,v in string.gmatch(header,"([^=&]*)=([^&]*)") do
            args[k] = url_decode(v);
        end;

        file.open("sensor_name.txt","w+");
        if (args.sname ~= nil and args.sname ~= "") then
            file.write(args.sname);
            print("-confsrv.post.sname="..args.sname..";");
        else
            file.write(apName);
        end;
        file.close();
        
        if (args.ssid ~= nil and args.ssid ~= "") then
            print("-confsrv.post.ssid="..args.ssid..";");
            print("-confsrv.post.psw="..args.passwd..";");
            wifi.sta.config(args.ssid, args.passwd);
            ssid_is_set= args.ssid;
            show_page(con);
        end;
        
        if (args.reboot ~= nil) then
            print("-confsrv.reboot;");
            con:close();
            --wifi.setmode(wifi.STATION);
            --wifi.sta.connect();
            node.restart();
        end;
        --con:send('HTTP/1.1 303 See Other\n')
        --con:send('Location: /\n')
    end;
end;

wifi.sta.disconnect();
wifi.setmode(wifi.STATIONAP);
wifi.ap.config(ap_config);
wifi.ap.setip(apNetConf);

print("-confsrv.ap="..apName..";");
apNetConf=nil;

srv=net.createServer(net.TCP);
srv:listen(80, function(sock)
    sock:on("receive", onConnect)
    sock:on("sent", function(sock)
        sock:close()
    end)
end)
