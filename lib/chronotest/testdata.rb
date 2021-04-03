class Chronotest
  private
  class SkipError < StandardError
  end
  
  class PassError < StandardError
  end

  class FailError < StandardError
  end

  class AssertionError < FailError
    def initialize(msg = "Assertion failed", reason: "")
      msg += ": #{reason}" unless reason.empty?
      super(msg)
    end
  end

  class RaiseError < AssertionError
    def initialize(msg = "No exception raised", reason: "")
      super(msg, reason: reason)
    end
  end

  class Test
    def initialize(name, &block)
      @test_name = name
      @test_body = block
      @test_output = []
      @test_state = nil
    end

    def run
      begin 
        instance_eval(&@test_body)
      rescue SkipError => e
        @test_output << e.to_s unless e.to_s.empty?
        @test_state = :skip
      rescue PassError => e
        @test_output << e.to_s unless e.to_s.empty?
        @test_state = :pass
      rescue StandardError => e # including FailError
        @test_output << e.to_s unless e.to_s.empty?
        @test_state = :fail
      else
        @test_state = :pass
      end
    end

    def run?
      !@test_state.nil?
    end

    def pass?
      @test_state == :pass
    end

    def results
      (["#{@test_name.to_s}: " +
        case @test_state 
        when :skip then "skipped"
        when :pass then "pass"
        when :fail then "fail"
        else "not run"
        end] +
      @test_output).join("\n  ")
    end

    def skip(because: "")
      raise SkipError, because
    end

    def log(msg)
      @test_output << msg
    end

    # This is here because it is convenient for logging and ending the test early, 
    # if necessary. Prefer approaches that use `fail`, as those are generally safer.
    def pass(because: "")
      raise PassError, because
    end

    def fail(because: "")
      raise FailError, because
    end

    def assert(check, because: "")
      raise(AssertionError, because) unless check
    end
    
    def refute(check, because: "")
      raise(AssertionError, because) if check
    end

    def raises(error = StandardError, because: "", &block)
      raise ArgumentError unless block_given?
      raise ArgumentError unless error.kind_of?(Class)
      raised = begin
        block.call
        false
      rescue error
        true
      rescue StandardError
        raise RaiseError.new("Wrong error type raised", because)
      end
      raise RaiseError.new("No error raised", because) unless raised
    end

    def prints(expected, trim: :none, &block)
      old_stdout = $stdout
      result = ""
      begin
        reader, writer = IO.pipe
        $stdout = writer
        block.call
      ensure
        $stdout = old_stdout
        writer.close
        result = reader.read
        reader.close
      end

      case trim
      when :left then result.lstrip!
      when :right then result.rstrip!
      when :both then result.strip!
      end

      pass if expected === result
      raise AssertionError.new("Pattern not matched")
    end
  end
end
