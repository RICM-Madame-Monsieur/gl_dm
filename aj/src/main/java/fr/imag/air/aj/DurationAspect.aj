package fr.imag.air.aj;

import java.util.concurrent.ConcurrentHashMap;

/**
 * Created by matthieu on 26/03/16.
 */
public aspect DurationAspect {

    private ConcurrentHashMap<Long, Long> startTime = new ConcurrentHashMap<>();
    private ConcurrentHashMap<Long, Long> count = new ConcurrentHashMap<>();
    private static long globalDuration = 0;
    private static long globalCount = 0;

    before() : execution(public void *.run()){
        startTime.put(Thread.currentThread().getId(), System.nanoTime());
        if(!count.containsKey(Thread.currentThread().getId())){
            count.put(Thread.currentThread().getId(), 0L);
        }
        count.put(Thread.currentThread().getId(), count.get(Thread.currentThread().getId()) + 1L);
        globalCount++;
    }

    after() : execution(public void *.run()){
        long endTime=System.nanoTime();
        long delta = endTime-startTime.get(Thread.currentThread().getId());
        globalDuration += delta;
        System.out.println("Call #" + count.get(Thread.currentThread().getId()) + ": Duration=" + delta/1000000);
    }

    before() : execution(public void SimpleThreads.main(..)){
        System.out.println("START STATISTICS ");
    }

    after() : execution(public void SimpleThreads.main(..)){
        System.out.println("END STATISTICS ");
        System.out.println("CallNumber: " + globalCount + " : AvgDuration=" + (globalDuration/(globalCount*1000000)));
    }

}
