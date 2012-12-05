#!/bin/sh
### BEGIN INIT INFO
# Provides:          dnscheck-dispatcher
# Required-Start:    $remote_fs $syslog $network mysql
# Required-Stop:     $remote_fs $syslog $network mysql
# Default-Start:
# Default-Stop:
# Short-Description: Start/stop the DNSCheck dispatcher
### END INIT INFO

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
