#!/bin/sh

SERIE1=example1_pre_pipe1.log
SERIE2=example1_post_pipe1.log
SERIE3=example1_post_pipe2.log

function run() {
  local metric="$1"

  touch "$SERIE1" "$SERIE2" "$SERIE3"
 
  stdbuf -o0 paste -d, \
    <(tail -f $SERIE1 | sed -u -n -E "s/.*$metric=([0-9\.]+).*/\1/p") \
    <(tail -f $SERIE2 | sed -u -n -E "s/.*$metric=([0-9\.]+).*/\1/p") \
    <(tail -f $SERIE3 | sed -u -n -E "s/.*$metric=([0-9\.]+).*/\1/p") \
    | asciigraph -r -h 20 -w 100  -sn 3 -sc "blue,red,green" -sl "pre pipe1, post pipe1, post pipe2" -c "$metric"
}

case $1 in
  backpressure)
    run backpressure
    ;;
  starvation)
    run starvation 
    ;;
  ratio)
    run ratio 
    ;;
  clean)
    rm -f "$PIPE1" "$PIPE2"
    ;;
  *)
    echo >&2 "Usage: $0 {backpressure|starvation|ratio|clean}"
    ;;
esac

