#!/bin/sh

ARROWS_ROOT=$(cd "$(dirname $0)/.."; pwd)
BENCH_ROOT="${ARROWS_ROOT}/benchmark"
CURRENT_BRANCH="$(git branch --list --no-color | grep '^\*' | cut -d\  -f2)"
cd $BENCH_ROOT

bench_all(){
    sbcl --eval "(require 'asdf)" --eval "(require 'arrows)" --load bench.lisp --quit >& ${CURRENT_BRANCH}_all.bench
}

bench_all
