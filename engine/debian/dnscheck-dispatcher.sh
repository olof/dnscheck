#!/bin/sh

start() {
    /usr/bin/dnscheck-dispatcher
}

stop() {
    /usr/bin/dnscheck-dispatcher --kill
}

case $1 in
    start )
        start
        ;;
    stop )
        stop
        ;;
    restart|force-reload )
        stop
        start
        ;;
esac