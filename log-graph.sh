#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

E1SERIE1=example1_pre_pipe1.log
E1SERIE2=example1_post_pipe1.log
E1SERIE3=example1_post_pipe2.log
E2SERIE1=example2_pipe1.log
E2SERIE2=example2_pipe2.log

function run_example1() {
  local metric="$1"

  touch "$E1SERIE1" "$E1SERIE2" "$E1SERIE3"
  
 
  stdbuf -o0 paste -d " " \
    <(tail -f $E1SERIE1 | sed -u -n -E "s/.*$metric=([0-9\.]+).*/\1/p") \
    <(tail -f $E1SERIE2 | sed -u -n -E "s/.*$metric=([0-9\.]+).*/\1/p") \
    <(tail -f $E1SERIE3 | sed -u -n -E "s/.*$metric=([0-9\.]+).*/\1/p") \
    | (
    while read -r s1 s2 s3; do
      clear
      echo "Last values for metric: $metric"
      echo "- pre pipe1: $s1"
      echo "- post pipe1: $s2"
      echo "- post pipe2: $s3"
    done
  )
}

function run_example2() {
  local metric="$1"

  touch "$E2SERIE1" "$E2SERIE2"

  stdbuf -o0 paste -d " " \
    <(tail -f $E2SERIE1 | sed -u -n -E "s/.*$metric=([0-9\.]+).*/\1/p") \
    <(tail -f $E2SERIE2 | sed -u -n -E "s/.*$metric=([0-9\.]+).*/\1/p") \
    | (
    while read -r s1 s2; do
      clear
      echo "Last values for metric: $metric"
      echo "- pipe1: $s1"
      echo "- pipe2: $s2"
    done
  )

}

cd "$SCRIPT_DIR/examples" || exit 1
run=""
case $1 in
  example1)
    run=run_example1
    ;;
  example2)
    run=run_example2
    ;;
  *)
    echo >&2 "Usage: $0 (example1|example2) {backpressure|starvation|ratio}"
    exit 2
    ;;
esac

shift
case $1 in
  backpressure)
    $run backpressure
    ;;
  starvation)
    $run starvation 
    ;;
  ratio)
    $run ratio 
    ;;
  *)
    echo >&2 "Usage: $0 (example1|example2) {backpressure|starvation|ratio}"
    exit 2
    ;;
esac

