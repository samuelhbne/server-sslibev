#!/bin/bash

DIR=`dirname $0`
DIR="$(cd $DIR; pwd)"
SVCID="sslibev"
CTNNAME="server-$SVCID"
IMGNAME="samuelhbne/server-sslibev"
ARCH=`uname -m`

case $ARCH in
	x86_64|i686|i386)
		TARGET=amd64
		;;
	aarch64)
		# Amazon A1 instance
		TARGET=arm64
		;;
	armv6l|armv7l)
		# Raspberry Pi
		TARGET=arm
		;;
	*)
		echo "Unsupported arch"
		exit 255
		;;
esac

while [[ $# > 0 ]]; do
	case $1 in
		--from-src)
			docker build -t $IMGNAME:$TARGET -f $DIR/Dockerfile.$TARGET $DIR
			break
			;;
		*)
			shift
			;;
	esac
done

. $DIR/$CTNNAME.env

echo "Starting $CTNNAME..."
docker run --name $CTNNAME -p $SSPORT:8388 -p $SSPORT:8388/udp -d $IMGNAME:$TARGET \
	-w $SSPASS -m $SSMTHD
echo

sleep 5

CNT=`docker ps|grep $IMGNAME:$TARGET|grep $CTNNAME -c`

if [ $CNT > 0 ]; then
	echo "$CTNNAME started."
	echo "Done"
	exit 0
else
	echo "Starting $CTNNAME failed. Check detail with \"docker logs $CTNNAME\""
	exit 252
fi
