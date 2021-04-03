require "chronotest/testdata"
class Chronotest

  @@classes = {}
  def self.inherited(subclass)
    @@classes[subclass] = TestClass.new
  end

  # Sets some block to be run before the specified test(s). If no test name is 
  # specified, the block is run before every test, before "before" clauses for 
  # that specific test. This pattern can be described by the following list, in 
  # order, for a test named "test":
  # - before()
  # - before("test")
  # - "test"
  #
  # If you specify any additional "before"s for a name, it's added to the list of 
  # methods to run. The "before"s are run in the order added.
  #
  # You can use this method to create an initial state for your tests. Instance 
  # variables defined in before methods are shared with tests. Each test is run 
  # in an isolated environment, so instance data won't be carried over. Instance 
  # variables defined in previous "before"s are accessible in later "before"s.
  #
  # If you do need to share information between tests (which is an extremely 
  # discouraged practice), you can define a class variable. It's recommended 
  # you do this outside of any `before` as "before" methods are run individually 
  # for every single relevant test, with no guaranteed ordering.
  def self.before(*tests, &block)
    raise ArgumentError unless block_given?
    if tests.empty?
      this.before_all = block
    else
      tests.each do |name|
        this.before[name] << block
      end
    end
    self
  end
  
  # Sets some block to be run after the specified test(s). If no test name is 
  # specified, the block is run after every test, after "after" clauses for 
  # that specific test. This pattern can be described by the following list, in 
  # order, for a test named "test":
  # - after()
  # - after("test")
  # - "test"
  #
  # If you specify any additional "after"s for a name, it's added to the list of 
  # methods to run. The "after"s are run in the order added.
  #
  # Instance variables defined previously in tests or "before"s are available 
  # to all "after"s, unless previously deleted. This is useful for cleaning up 
  # any resources that aren't automatically handled.
  def self.after(*tests, &block)
    raise ArgumentError unless block_given?
    if tests.empty?
      this.after_all = block
    else
      tests.each do |name|
        this.after[name] << block
      end
    end
    self
  end

  # Defines a test with the given name. This name is used to match with "before" 
  # and "after" clauses. 
  #
  # Note that `name` can be any kind of value. As long as it can be a Hash key, 
  # and can be used in `Kernel.puts`, it's a valid "name". This can potentially 
  # be useful to run tests on specific instances of a class or to make naming .
  def self.try(name, &block)
    this.tests[name] = Test.new(name, &block) 
    self
  end

  # Calling this on a class will run all the tests for that class. If a `async`
  # is true, the tests are run in separate threads. The maximum thread amount is 
  # set by `thread_count`. If `async` is false, the tests are run sequentially, 
  # and `thread_count` is ignored. `async` defaults to true. 
  #
  # Tests are always run in a random order, but output will be printed in the 
  # order the tests are registered.
  #
  # If `thread_count` is 0, the thread_count is unlimited, and each thread will 
  # be launched in its own thread at the same time. If it's less than zero, an 
  # ArgumentError is raised. `thread_count` defaults to 64. A `thread_count` of 
  # 1 is functionally equivalent to specifying `async: false`.
  #
  # Returns a boolean indicating whether all the tests passed.
  def self.run(async: true, thread_count: 64)
    raise ArgumentError if thread_count < 0
    async ? async_run(thread_count) : sync_run

    this.tests.each {|_, data| puts data.results}
    this.tests.all? {|_, data| data.pass?}
  end

  private
  class TestClass
    attr_accessor :before, :after, :before_all, :after_all, :tests
    def initialize
      @tests = {}
      @before = Hash.new {|hash, key| hash[key] = Array.new}
      @after  = Hash.new {|hash, key| hash[key] = Array.new}
      @before_all = Proc.new{}
      @after_all  = Proc.new{}
    end
  end

  def self.async_run(thread_count)
    thread_count = Float::INFINITY if thread_count.zero?
    queue = []
    tests_queued = 0
    tests = this.tests.keys.shuffle
    test_count = this.tests.size
    loop do
      if queue.size < thread_count && tests_queued < test_count
        name = tests.shift
        queue.push(this.tests[name])
        tests_queued += 1
        
        Thread.new do
          test = this.tests[name]
          run_test(name, test)
        end  
      end

      f = queue.shift
      queue.push(f) unless f&.run?
      break if queue.empty?
    end
  end

  def self.sync_run
    this.tests.keys.shuffle.each do |name|
      run_test(name, this.tests[name])
    end
  end

  def self.run_test(name, test)
    test.instance_eval(&this.before_all)
    this.before[name].each {|block| test.instance_eval(&block)}
    test.run
    this.after[name].each {|block| test.instance_eval(&block)}
    test.instance_eval(&this.after_all) 
  end
  
  def self.this
    @@classes[self]
  end

  private_class_method :this, :async_run, :sync_run, :run_test

end
