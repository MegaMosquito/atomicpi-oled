# atomicpi-oled

This repo enables you to show status on an OLED display on an atomicpi. My atomicpi is running their ubuntu 18.04 image, and this code uses bitbanged I2C to drive a 0.96 inch OLED screen. It looks like this:

![atomicpi-oled-photo](https://raw.githubusercontent.com/MegaMosquito/atomicpi-oled/main/atomicpi-oled.jpg)

### Wiring

Connect the power (3.3V) and ground (GND) pins, and then:
* **SDA** connects to atomicpi GPIO#3
* **SCL** connects to atomicpi GPIO#4

### Custom I2C Bus

Then you need to create a custom I2C bus. You do that by (as `root`, e.g., using `sudo`) creating a file in `/etc/i2c-gpio-custom.d` directory. I called mine `oled`. It should contain 3 integers, separated by commas. Here's what mine looks like:

```
    $ cat /etc/i2c-gpio-custom.d/oled
    100,329,336
    $
```

The first number is the bus number you wish to use. I selected 100, which is the recommended lowest number to use. The other two numbers are the global pin numbers for GPIO#3 and GPIO#4, from the table in section 2.2 on page 4 of the manual:
    [https://www.digital-loggers.com/apug.pdf](https://www.digital-loggers.com/apug.pdf)

I.e., from that table:
```
    Schematic name   GPIO chip id   Chip pin number   Global pin number
    ISH_GPIO_3       gpiochip3      15                329
    ISH_GPIO_4.      gpiochip3      22                336
```

After creating the file, I suggest rebooting.

When the machine comes back up, **check** that your custom I2C bus was created **and** that your OLED was detected on this bus. Use `i2cdetect` (as `root`) for that, like this:

```
 $ sudo i2cdetect -y 100
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:          -- -- -- -- -- -- -- -- -- -- -- -- -- 
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
30: -- -- -- -- -- -- -- -- -- -- -- -- 3c -- -- -- 
40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
70: -- -- -- -- -- -- -- --                         
 $ 
```

The `100` is the I2C bus number to check. The `-y` says don't prompt me for Y/N answer (it does that because running this can destabilize any running I2C application on this bus number. Since you are checking this first before you are actually using it for stuff, this is fine. You can see that my OLED screen was detected at address `3C` (this is typical).

### OLED display library

To draw the text (or shapes, etc.) I used the `luma` OLED library. It is a nice little software I2C (i.e., "bitbanged" I2C) implementation. The documentation for it is here, in case you want to show something different on your screen:
    [https://ssd1306.readthedocs.io/en/latest/intro.html](https://ssd1306.readthedocs.io/en/latest/intro.html)

### How to use the container

1. Install `git`, `make`, `curl` and `docker`, if they are not alread installed. e.g.:

```
sudo apt update
sudo apt install -y git make curl
curl -sSL https://get.docker.com/ | sh
```

2. Give the `atomicpi` user the rights to use `docker` commands without `sudo` (optional, but convenient):

```
sudo usermod -aG docker atomicpi
```

Then exit your shell (e.g., close your `ssh` session) and open a new shell (e.g., reconnect with `ssh`). You need to do thsi because the existing shell has no way to pick up that changed group membership. Gorup membership is evaluated only at shell startup.

3. Clone this repo

```
git clone https://github.com/MegaMosquito/atomicpi-oled.git
```

4. Cd into the repo, and build the container:

```
cd atomicpi-oled
make build
```

5. Run the container (from the same directory)

```
make run
```

In the resulting `docker run` command, you should see these 2 environment variables being passed with reasonable values for your network:

```
  -e LOCAL_ROUTER_ADDRESS=192.168.123.1 \
  -e LOCAL_IPV4_ADDRESS=192.168.123.120 \
```

6. Observe the results on your little OLED screen!
