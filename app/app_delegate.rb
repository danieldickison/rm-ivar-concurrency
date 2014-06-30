class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    run_test
    true
  end

  THREADS = 20
  SET_PROB = 0.5
  NIL_PROB = 0.5
  LOCK_GET = false
  LOCK_SET = false

  def run_test
    puts "starting test"
    @lock = Mutex.new
    THREADS.times do
      Dispatch::Queue.concurrent.async do
        loop do
          if rand < SET_PROB
            do_set
          else
            do_get
          end
        end
      end
    end
  end

  def do_set
    if LOCK_SET
      @lock.synchronize {@ivar = rand < NIL_PROB ? nil : ["#{rand}"]}
    else
      @ivar = rand < NIL_PROB ? nil : ["#{rand}"]
    end
  end

  def do_get
    if LOCK_GET
      @lock.synchronize {"@ivar: #{@ivar}"}
    else
      "@ivar: #{@ivar}"
    end
  end
end
