# chronotest
A basic testing framework designed to be run concurrently, with parallel capabilities.
(read [this Q/A](https://softwareengineering.stackexchange.com/questions/190719/the-difference-between-concurrent-and-parallel-execution) for the distinction between the two.)

All tests are as thread-safe as possible, assuming the code being testing is 
non-parallel, and barring the tested code using class or global variables. 
There's nothing I can do about that, so that burden of safety is on the tester.

The beauty of a testing framework is that it's self-descriptive. You can use 
the framework to test itself, assuming the tests passed some other framework 
once upon a time. That's exactly what's done here.
