#!/bin/sh

ZENEKINDARL_ROOT=$(cd "$(dirname $0)/.."; pwd)
BENCH_ROOT="${ZENEKINDARL_ROOT}/benchmark"
CURRENT_BRANCH="$(git branch --list --no-color | grep '^\*' | cut -d\  -f2)"
cd "${BENCH_ROOT}"

bench_all(){
    sbcl  --load bench.lisp --quit > "${CURRENT_BRANCH}_all.bench" 2>&1
}

bench_all
