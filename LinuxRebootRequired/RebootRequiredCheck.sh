#!/bin/bash
##################################
# Zabbix monitoring script
#
# Checking urgency in changelog 
# for updates which require system restart
#
# https://gist.githubusercontent.com/fitz123/6e0e127a336d96ca4c42/raw/be5275f6fb3869c6cce9d3fbb9c2727cad3df63a/reboot_required_check.sh
#
##################################
# Contact:
#  anton.lugovoi@yandex.ru
##################################
# ChangeLog:
#  20151205    initial creation
#  20151208    check uniq packages only 
##################################

case "$1" in

status)
    if [ -f /var/run/reboot-required ]; then
      echo 1
    else
      echo 0
    fi 
    ;;

urgency)
    if [ -f /var/run/reboot-required.pkgs ]; then
      while read pkg; do
        tmp=`/usr/bin/apt-get changelog $pkg | \
             /bin/grep -m1 -ioP '(?<=[Uu]rgency[=:])(low|medium|high|emergency|critical)' | \
             tr '[:upper:]' '[:lower:]'`
        if [ -n $tmp ]; then
          if   [ "$tmp" == "low" ] && \
               [ "$urgency" != "medium" ] && \
               [ "$urgency" != "high" ] && \
               [ "$urgency" != "emergency" ] && \
               [ "$urgency" != "critical" ]; then 
            urgency=low
          elif [ "$tmp" == "medium" ] && \
               [ "$urgency" != "high" ] && \
               [ "$urgency" != "emergency" ] && \
               [ "$urgency" != "critical" ]; then 
            urgency=medium
          elif [ "$tmp" == "high" ] && \
               [ "$urgency" != "emergency" ] && \
               [ "$urgency" != "critical" ]; then 
            urgency=high
          elif [ "$tmp" == "emergency" ] && \
               [ "$urgency" != "critical" ]; then 
            urgency=emergency
          elif [ "$tmp" == "critical" ]; then 
            urgency=critical
            break
          fi
        fi 
      done < <(sort -u /run/reboot-required.pkgs)
    else
      urgency=none
    fi

    case "$urgency" in
        none)      urgency=0 ;;
        low)       urgency=1 ;;
        medium)    urgency=2 ;;
        high)      urgency=3 ;;
        emergency) urgency=4 ;;
        critical)  urgency=5 ;;
        *)         urgency=42 ;;
    esac

    echo $urgency
    ;;
esac
exit 0
