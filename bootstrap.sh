#!/bin/bash

start_daemon(){
  /opt/logmein-hamachi/bin/hamachid -c /config
  while [ 1 ]; do
    out=$(hamachi)
    [[ $out =~ *version* ]] && sleep 1 || break
  done
}

check_login(){
  # IFS=$'\n';
  # regex_status="status: (.*?)"
  # regex_account="lmi account:(.*?)"
  # for line in $(hamachi); do
  #   if [[ $line =~ $regex_status ]]; then
  #     if [[ ${BASH_REMATCH[1]} == offline ]]; then
  #       while [ 1 ]; do
  #         echo "do login"
  #         out=$(hamachi login)
  #         [[ $out =~ ok ]] && break || sleep 1
  #       done
  #     fi
  #   fi
  # done

  while [ 1 ]; do
    out=$(hamachi)
    echo $out
    [[ $out =~ "Hamachi does not seem to be running" ]] && sleep 1
    [[ $out =~ "status" ]] && break
  done

  echo "start login"
  echo $(hamachi login)

  while [ 1 ]; do
    out=$(hamachi)
    echo $out
    [[ $out =~ "Logging in" ]] && sleep 1
    [[ $out =~ "logged in" ]] && break
  done
}

cd /logmein-hamachi-2.1.0.139-x64
./install.sh
start_daemon
check_login
hamachi join $HAMACHI_NET_ACC $HAMACHI_NET_PASS

set -e
# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- haproxy "$@"
fi

if [ "$1" = 'haproxy' ]; then
	# if the user wants "haproxy", let's use "haproxy-systemd-wrapper" instead so we can have proper reloadability implemented by upstream
	shift # "haproxy"
	set -- "$(which haproxy-systemd-wrapper)" -p /run/haproxy.pid "$@"
fi

exec "$@"

haproxy -f /usr/local/etc/haproxy/haproxy.cfg
