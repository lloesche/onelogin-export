module Enumerable
  def each_in_parallel(n)
    todo = Queue.new
    ts = (1..n).map do
      Thread.new do
        while x = todo.deq
          yield(x[0])
        end
      end
    end
    each{ |x| todo << [x] }
    n.times{ todo << nil }
    ts.each{ |t| t.join }
  end
end
