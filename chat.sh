#!/bin/bash
trap "kill 0" EXIT

### You unlock this door with the key of imagination. Beyond it
### is another dimension - a dimension of sound, a dimension of sight,
### a dimension of mind. You're moving into a land of both shadow and
### substance, of things and ideas. You've just crossed over into ...
### 
### The Regex Zone.

if [ "$1" = "-h" ]; then
	echo "Usage: chat.sh [room] [color] [server-base, defaults to greywolf]"
	echo "Hangs up when end of file is reached. "
	exit
fi
 
ROOM=${1--}
COLOR=${2-BC1500}
SERVER=${3-http://greywolf.co.nz/testing/chat/}
BASEURL=$SERVER/r/$ROOM/

(
	SINCE=0
	while true; do
		while read -r message; do
			NEWSINCE=`echo $message | sed -e 's/^.*"id": \([0-9]\+\).*$/\1/' | grep "^[0-9]\+$"`
			if test ! -z $NEWSINCE; then
				SINCE=$NEWSINCE
			fi
			echo $message | sed -e 's|^.*"msg": "\(.*[^\\]\)".*"colour": "#\([0-9A-Fa-f]*\)".*$|\2: \1|'
		done < <(curl -s $BASEURL/room?since=$SINCE | grep -o '.{[^}]\+}')
	done
) &

while read -r line; do
	curl -s -b "Colour=#$COLOR" --data-urlencode "message=$line" $BASEURL/room > /dev/null
done

