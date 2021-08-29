
DOCKERHUB_ID:=ibmosquito
NAME:="atomicpi-oled"
VERSION:="1.0.0"

# Some bits from https://github.com/MegaMosquito/netstuff/blob/master/Makefile
LOCAL_DEFAULT_ROUTE     := $(shell sh -c "ip route | grep default")
LOCAL_ROUTER_ADDRESS    := $(word 3, $(LOCAL_DEFAULT_ROUTE))
LOCAL_DEFAULT_INTERFACE := $(word 5, $(LOCAL_DEFAULT_ROUTE))
LOCAL_IPV4_ADDRESS      := $(shell sh -c "ip addr | egrep -A 3 enp1s0 | grep '    inet ' | sed 's/^    inet //;s|/.*||' | tail -1")
LOCAL_MAC_ADDRESS       := $(shell sh -c "ip link show | sed 'N;s/\n/ /' | grep $(LOCAL_DEFAULT_INTERFACE) | sed 's/.*ether //;s/ .*//;'")
LOCAL_SUBNET_CIDR       := $(shell sh -c "echo $(wordlist 1, 3, $(subst ., ,$(LOCAL_IPV4_ADDRESS))) | sed 's/ /./g;s|.*|&.0/24|'")

default: build run

build:
	docker build -t $(DOCKERHUB_ID)/$(NAME):$(VERSION) .

dev: stop build
	docker run -it -v `pwd`:/outside \
	  -e WHEN="${WHEN}" \
	  --name ${NAME} \
	  --privileged \
	  -e LOCAL_ROUTER_ADDRESS=$(LOCAL_ROUTER_ADDRESS) \
	  -e LOCAL_IPV4_ADDRESS=$(LOCAL_IPV4_ADDRESS) \
	  -v /dev/i2c-100:/dev/i2c-100 \
	  $(DOCKERHUB_ID)/$(NAME):$(VERSION) /bin/sh

run: stop
	docker run -d \
	  -e WHEN="${WHEN}" \
	  --name ${NAME} \
	  --restart unless-stopped \
	  --privileged \
	  -e LOCAL_ROUTER_ADDRESS=$(LOCAL_ROUTER_ADDRESS) \
	  -e LOCAL_IPV4_ADDRESS=$(LOCAL_IPV4_ADDRESS) \
	  -v /dev/i2c-100:/dev/i2c-100 \
	  $(DOCKERHUB_ID)/$(NAME):$(VERSION)

test:
	echo 'Just use "make run" to test it.'

push:
	docker push $(DOCKERHUB_ID)/$(NAME):$(VERSION) 

stop:
	@docker rm -f ${NAME} >/dev/null 2>&1 || :

clean:
	@docker rmi -f $(DOCKERHUB_ID)/$(NAME):$(VERSION) >/dev/null 2>&1 || :

.PHONY: build dev run push test stop clean
