package fr.imag.air.aj;

import java.util.concurrent.atomic.AtomicLong;

/**
 * Created by matthieu on 26/03/16.
 */
public aspect DurationAspect {

    private AtomicLong startTime = new AtomicLong();
    private AtomicLong count = new AtomicLong(0);
    private static AtomicLong globalDuration = new AtomicLong(0);
    private static AtomicLong globalCount = new AtomicLong(0);

    before() : execution(public void *.run()){
        startTime.set(System.nanoTime());
        count.incrementAndGet();
        globalCount.incrementAndGet();
    }

    after() : execution(public void *.run()){
        long endTime=System.nanoTime();
        long delta = endTime-startTime.get();
        globalDuration.set(delta + globalDuration.get());
        System.out.println("Call #" + count.get() + ": Duration=" + delta/1000000);
    }

    before() : execution(public void SimpleThreads.main(..)){
        System.out.println("START STATISTICS ");
    }

    after() : execution(public void SimpleThreads.main(..)){
        System.out.println("END STATISTICS ");
        System.out.println("CallNumber: " + globalCount.get() + " : AvgDuration=" + (globalDuration.get()/(globalCount.get()*1000000)));
    }

}
