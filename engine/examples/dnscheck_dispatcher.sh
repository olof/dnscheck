#!/bin/bash

DIR=/var/run/dnscheck
USER=dnscheck
DISPATCHER=/usr/local/bin/dnscheck-dispatcher
PIDFILE=dnscheck_dispatcher.pid

start () {
    echo Starting $DISPATCHER
    if [ \! -d $DIR];then
        (mkdir $DIR && chown $USER $LOGDIR) || exit(1)
    fi
    su $USER $DISPATCHER
}

stop () {
    echo Stopping $DISPATCHER
    pid=`cat $DIR/$PIDFILE`
    kill $pid
    sleep 1
    i=0
    while ( kill -0 $pid 2> /dev/null && [ $i < 12]); do
        echo 'Waiting for dispatcher to exit...'
        i=`expr $i + 1`
        sleep 5
    done
    if [ $i -eq 12 ]; then
        echo 'Timeout. Killing dispatcher harder.'
        kill -9 $pid
    fi
}

case $1 in
    'start' )
        start
        ;;
    'stop' )
        stop
        ;;
    'restart' )
        stop
        start
        ;;
esac