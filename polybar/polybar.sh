#!/bin/bash

killall -9 polybar

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar ystepanoff &
  done
else
  polybar ystepanoff &
fi
