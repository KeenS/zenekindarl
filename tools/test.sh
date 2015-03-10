#!/bin/sh
ARROWS_ROOT=$(cd "$(dirname $0)/.."; pwd)
TEST_ROOT="${ARROWS_ROOT}/t"
CURRENT_BRANCH="$(git branch --list --no-color | grep '^\*' | cut -d\  -f2)"
cd "${TEST_ROOT}"

test_all(){
    sbcl --eval "(require 'asdf)"  --eval "(asdf:test-system 'arrows)" --quit 
}

test_all
