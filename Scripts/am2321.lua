
require "my-i2c"

AM2321_I2C_ADDR = 0xB8;

function crc16_update(seed, byte)
    seed = bit.bxor(seed, byte);
    for i=1,8 do
        local j = bit.band(seed, 1);
        seed = bit.rshift(seed, 1);
        if j ~= 0 then
            seed = bit.bxor(seed, 0xA001);
        end
    end
    return seed;
end 

function am2321_init()
    i2c_init();
end

function am2321_wakeup()
    i2c_start();
    i2c_send(AM2321_I2C_ADDR);
    tmr.delay(3000);
    i2c_stop();
end

function am2321_read_raw()
    local crc=0xffff;
    local crc2=0xffff;
    res2 = {}
    am2321_wakeup();
    tmr.delay(3000);
    res2[0] = 2;
    i2c_start();
    i2c_send(AM2321_I2C_ADDR);
    i2c_send(0x03);
    i2c_send(0x00);
    i2c_send(0x04);
    i2c_stop();
    tmr.delay(6000);
    i2c_start();
    i2c_send(AM2321_I2C_ADDR+1);
    tmr.delay(200); -- wait at least 30us
        tmp = i2c_get(1);
        crc = crc16_update(crc,tmp);
        tmp = i2c_get(1);
        crc = crc16_update(crc,tmp);
        tmp = i2c_get(1);
        crc = crc16_update(crc,tmp);
        res2[1] = tmp;
        tmp = i2c_get(1);
        crc = crc16_update(crc,tmp);
        res2[1] = res2[1]*256 + tmp;
        tmp = i2c_get(1);
        crc = crc16_update(crc,tmp);
        res2[2] = tmp*256;
        tmp = i2c_get(1);
        crc = crc16_update(crc,tmp);
        res2[2] = res2[2] + tmp;
        tmp = i2c_get(1);
        crc2 = tmp;
        tmp = i2c_get(0);
        crc2 = crc2 + tmp*256;
    i2c_stop();
    if (crc == crc2) then res2[0]=0; else res2[0]=1; end
    return res2;
end
