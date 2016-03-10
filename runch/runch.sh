#!/usr/bin/env bash
function cmd_start 
{
	local bundle=$1
	if [ -z "$bundle" ]
	then
		echo "list: bundle cannot be empty" >&2
		exit
	fi

	if [ -f $bundle/config.json ]
	then
		true
	else
		echo "$bundle/config.json doesn't exist" >&2
		exit
	fi
	local uu=$(jshon -F $bundle/config.json -e root -e path -u -pp -e process -e args -au -pp -e user -e uid -u -p -e gid -u -pp -e cwd -u |
	(
	read root
	read args
	read uid
	read gid
	read cwd
	cd $bundle$cwd 
	echo $uid:$gid $bundle/$root $args
	)
	)

	echo arch-chroot --userspec $uu

	nohup ls &
	local pid=$!
	local id=$(basename bundle)
	local path=/run/opencontainer/chroots/$id
	mkdir -p $path
	cat >$path/state.json <<-END
	{ "config" : $(cat $bundle/config.json)
	, "init_process_pid" : $pid
	, "id" : "$id"
	, "created" : "$(date -Is)"
	}
	END
}

set -e
case $1 in
    start)
      cmd_$1 $2
      ;;
	"")
		echo "Empty command" >&2
		;;
	*)
      echo "Invalid command: $1" >&2
	  exit
      ;;
esac

