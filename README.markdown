[![Build Status](https://travis-ci.org/KeenS/arrows.svg?branch=master)](https://travis-ci.org/KeenS/arrows)
# Arrows
Template flies like an arrow

Expected to be a fast, flexible, extensible, low memory usage, async, concurrent template engine.

## Usage
Like this

```lisp
(render "Hello {{var name}}!!"
        :name "κeen")
```

.

Wait a while before full documentation is prefared.

## Instant Benchmark
Arrows perform **x16** as fast as a template engine in Python in the following instant benchmark.

![Benchmark](https://docs.google.com/spreadsheets/d/1M8x9dcK8ToL4-tfVUfGnCh_OOtttJpXxK905raA0eas/pubchart?oid=1882415724&format=image)

Template engines     | Time[sec]
---------------------|----------
Arrows, SBCL 1.1.8   | 1.365
Jinja2, Python 2.7.5 | 24.07

The benchmark code for Arrows:

    > (time
       (with-open-file (out #P"~/Desktop/out" :direction :output :if-exists :supersede)
         (let ((fun (arrows:compile-template-string :stream "Hello {{var name}}!!" nil)))
           (loop repeat 1000000
              do (funcall fun out :name "κeen")))))
    Evaluation took:
    1.625 seconds of real time
    1.364707 seconds of total run time (1.302198 user, 0.062509 system)
    [ Run times consist of 0.042 seconds GC time, and 1.323 seconds non-GC time. ]
    84.00% CPU
    1 form interpreted
    3 lambdas converted
    3,265,218,807 processor cycles
    528,706,464 bytes consed

The benchmark code for a template engine in Python:

    $ cat te.py
    from jinja2 import Template
    
    template = Template( u'Hello {{ name }}!!' )
    
    f = open( 'out', 'w' )
    for i in range( 1000000 ):
      f.write( template.render( name=u'κeen' ).encode( 'utf-8' ) )

    $ time python te.py
    real    0m25.612s
    user    0m24.069s
    sys	    0m0.190s

## Author

* κeen

## Copyright

Copyright (c) 2014 κeen
