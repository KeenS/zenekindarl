#!/bin/sh
ZENEKINDARL_ROOT=$(cd "$(dirname $0)/.."; pwd)
TEST_ROOT="${ZENEKINDARL_ROOT}/t"
CURRENT_BRANCH="$(git branch --list --no-color | grep '^\*' | cut -d\  -f2)"
cd "${TEST_ROOT}"

test_all(){
    sbcl --eval "(require 'asdf)"  --eval "(asdf:test-system 'zenekindarl)" --quit 
}

test_all
