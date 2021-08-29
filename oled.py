#  oled.py  Display useful info on 0.96" OLED display
#  Written by mosquito@darlingevil.com, 2019-11-15

import os
import time
import subprocess
from datetime import datetime
from luma.core.interface.serial import i2c
from luma.oled.device import ssd1306
from luma.core.render import canvas

# The Makefile pulls these from the host when the container is run
LOCAL_ROUTER_ADDRESS   = os.environ['LOCAL_ROUTER_ADDRESS']
LOCAL_IPV4_ADDRESS = os.environ['LOCAL_IPV4_ADDRESS']

# Commands to check LAN, WAN, etc.
LAN_COMMAND = 'curl -sS https://' + LOCAL_ROUTER_ADDRESS + ' 2>/dev/null | wc -l'
WAN_COMMAND = 'curl -sS https://google.com 2>/dev/null | wc -l'
UPTIME_COMMAND = "uptime | awk '{printf \"up %s avg %.2f\", $3, $(NF-2)}'"

# Change these to the right size for your display!
WIDTH = 128
HEIGHT = 64
BORDER = 5

# Initialize the I2C device
serial = i2c(port=100, address=0x3C)
oled = ssd1306(serial)
draw = canvas(oled)

# Loop forever showing status info on the OLED screen
while (True):

  with canvas(oled) as draw:

    lan = '0' != str(subprocess.check_output(LAN_COMMAND, shell=True)).strip()
    wan = '0' != str(subprocess.check_output(WAN_COMMAND, shell=True)).strip()

    # Draw a black background
    draw.rectangle((0, 0, oled.width, oled.height), outline=0, fill=0)

    draw.text((0, 2), "IPv4: " + LOCAL_IPV4_ADDRESS, 255)
    if lan:
      draw.text((0, 14), "Gateway: (connected)", 255)
    else:
      draw.text((0, 14), "Gateway: UNREACHABLE!", 255)
    if wan:
      draw.text((0, 24), "Internet: (reachable)", 255)
    else:
      draw.text((0, 24), "Internet: UNREACHABLE!", 255)

    draw.text((0, 34), " ", 255)

    date = datetime.utcnow().strftime("UTC: %H:%M:%S")
    draw.text((0, 44), date, 255)
    uptime = subprocess.check_output(UPTIME_COMMAND, shell=True)
    uptime = uptime.decode("utf-8").strip()
    draw.text((0, 54), "" + uptime, 255)

  time.sleep(5)

