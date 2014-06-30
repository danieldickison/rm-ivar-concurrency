class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    run_test
    true
  end

  THREADS = 10
  SET_PROB = 0.5
  NIL_PROB = 0.5

  def run_test
    puts "starting test"
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
    @ivar = rand < NIL_PROB ? nil : ["#{rand}"]
  end

  def do_get
    "@ivar: #{@ivar}"
  end
end
