#!/bin/bash

DIR=/var/run/dnscheck
USER=dnscheck
DISPATCHER=/usr/bin/dnscheck-dispatcher
PIDFILE=dnscheck_dispatcher.pid

check_running () {
	PID=`ps ax|grep dnscheck-disp|grep -v grep|awk '{print $1}'`
	if [ "X${PID}" == "X" ];then
		return 0	
	fi

	return 1
}

start () {
    check_running
    if [ $? -eq 1 ];then
	echo "Already running"
	exit
    fi
	
    echo Starting $DISPATCHER
    if [ \! -d $DIR ];then
        ( mkdir $DIR && chown $USER $DIR ) || exit 1
    fi

    su $USER $DISPATCHER
}

stop () {
    echo Stopping $DISPATCHER
    check_running
    if [ $? -eq 0 ]; then
	echo "Not running"
	exit
    fi
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
