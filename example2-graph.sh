#!/bin/sh

PIPE1=example2_pipe1.log
PIPE2=example2_pipe2.log

function run() {
  local metric="$1"

  touch "$PIPE1" "$PIPE2"

  stdbuf -o0 paste -d, \
    <(tail -f $PIPE1 | sed -u -n -E "s/.*$metric=([0-9\.]+).*/\1/p") \
    <(tail -f $PIPE2 | sed -u -n -E "s/.*$metric=([0-9\.]+).*/\1/p") \
    | asciigraph -r -h 20 -w 100  -sn 2 -sc "blue,red" -sl "pipe1, pipe2" -c "$metric"
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

