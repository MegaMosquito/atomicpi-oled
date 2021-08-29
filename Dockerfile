FROM ubuntu:18.04

RUN apt update && apt install -y python3 python3-pip python3-pil libjpeg-dev zlib1g-dev libfreetype6-dev liblcms2-dev libopenjp2-7 libtiff5 -y

RUN pip3 install --upgrade setuptools
RUN pip3 install luma.oled

WORKDIR /
COPY oled.py /

CMD python3 /oled.py

