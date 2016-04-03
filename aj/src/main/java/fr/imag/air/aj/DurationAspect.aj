package fr.imag.air.aj;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Created by matthieu on 26/03/16.
 */
public aspect DurationAspect {

    private ConcurrentHashMap<Long, Long> startTime = new ConcurrentHashMap<>();
    private ConcurrentHashMap<Long, Long> count = new ConcurrentHashMap<>();
    private static AtomicLong globalDuration = new AtomicLong(0);
    private static AtomicLong globalCount = new AtomicLong(0);

    before() : execution(public void *.run()){
        startTime.put(Thread.currentThread().getId(), System.nanoTime());
        if(!count.containsKey(Thread.currentThread().getId())){
            count.put(Thread.currentThread().getId(), 0L);
        }
        count.put(Thread.currentThread().getId(), count.get(Thread.currentThread().getId()) + 1L);
    }

    after() : execution(public void *.run()){
        long endTime=System.nanoTime();
        long delta = endTime-startTime.get(Thread.currentThread().getId());
        synchronized (this) {
            globalCount.incrementAndGet();
            globalDuration.set(globalDuration.get() + delta);
        }
        System.out.println("Call #" + count.get(Thread.currentThread().getId()) + ": Duration=" + delta/1000000);
    }

    before() : execution(public void SimpleThreads.main(..)){
        System.out.println("START STATISTICS ");
    }

    after() : execution(public void SimpleThreads.main(..)){
        System.out.println("END STATISTICS ");
        System.out.println("CallNumber: " + globalCount.get() + " : AvgDuration=" + (globalDuration.get()/(globalCount.get()*1000000)));
    }

}
