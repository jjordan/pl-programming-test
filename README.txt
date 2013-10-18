pl-programming-test
===================

https://github.com/jjordan/pl-programming-test

DESCRIPTION:
------------

* A little repo for a programming test I'm taking.  It's a program to find the pull requests for a given GitHub repository that match certain criteria, and are labeled as 'interesting' for a human to review them further.

FEATURES/PROBLEMS:
------------------
Features:
* Can have the criteria for interesting/not interesting modified easily in a YAML config file
* Displays what's interesting along with what match was made

Problems:
* Not enough error checking
* No fun command-line switches

SYNOPSIS:
---------
        git clone https://github.com/jjordan/pl-programming-test
        cd pl-programming-test
        ./bin/review account/repo [/path/to/config.yml]

        https://github.com/candycorn/thingy/pull/3550 - Not Interesting
        https://github.com/candycorn/thingy/pull/3548 - Interesting
	    no file names contained '(?-mix:\bspec\/)'
        https://github.com/candycorn/thingy/pull/3538 - Not Interesting
        https://github.com/candycorn/thingy/pull/3513 - Interesting
	    no file names contained '(?-mix:\bspec\/)'
        https://github.com/candycorn/thingy/pull/3499 - Interesting
	    no file names contained '(?-mix:\bspec\/)'
	    found '(?-mix:\.write\b)' in patch

REQUIREMENTS:
-------------
Ruby: 1.9.2 and 1.9.3, probably previous revs, depending on dependencies.

Rubygems:
* JSON 1.8
* HTTParty 0.11
* Rspec 2
* simplecov 0.7

INSTALL:
--------
        git clone https://github.com/jjordan/pl-programming-test
        cd pl-programming-test
        rake gem
        sudo gem install pkg/prereviewer-0.0.1.gem

DEVELOPERS:
-----------
Jeremiah Jordan <jjordan at perlreason dot com>

LICENSE:
--------
(The MIT License)

Copyright (c) 2013 Jeremiah Jordan

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
