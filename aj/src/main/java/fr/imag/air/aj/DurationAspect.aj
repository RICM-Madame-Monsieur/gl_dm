package fr.imag.air.aj;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Created by matthieu on 26/03/16.
 */
public aspect DurationAspect {

    private float QUOTA;
    private AtomicLong globalStartTime = new AtomicLong();
    private ConcurrentHashMap<Long, Long> startTime = new ConcurrentHashMap<>();
    private ConcurrentHashMap<Long, Long> count = new ConcurrentHashMap<>();
    private static AtomicLong globalDuration = new AtomicLong(0);
    private static AtomicLong globalCount = new AtomicLong(0);

    before() : execution(public void SimpleThreads.MessageLoop.run()){
        float currentTime = System.nanoTime();
        float currentDiffTime = (currentTime - globalStartTime.get());
        if(globalCount.get() != 0L) {
            long currentTimeMedian = globalDuration.get() / globalCount.get();
            System.out.println("\tCurrent diff: " + currentDiffTime + " median: " + currentTimeMedian + " QUOTA: " + QUOTA
                + " Current QUOTA: " + (currentTimeMedian/currentDiffTime));
            if (currentTimeMedian/currentDiffTime > QUOTA) {
                long timeToWait = (long) ((currentTimeMedian - .8*QUOTA * currentDiffTime) / (0.8*QUOTA)) / 1000000;
                try {
                    System.out.println("\tWait: " + timeToWait + "ms");
                    Thread.currentThread().sleep(timeToWait);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }

        startTime.put(Thread.currentThread().getId(), System.nanoTime());
        if(!count.containsKey(Thread.currentThread().getId())){
            count.put(Thread.currentThread().getId(), 0L);
        }
        count.put(Thread.currentThread().getId(), count.get(Thread.currentThread().getId()) + 1L);
    }

    after() : execution(public void SimpleThreads.MessageLoop.run()){
        long endTime=System.nanoTime();
        long delta = endTime-startTime.get(Thread.currentThread().getId());
        synchronized (this) {
            globalCount.incrementAndGet();
            globalDuration.set(globalDuration.get() + delta);
        }
        System.out.println("Call #" + count.get(Thread.currentThread().getId()) + ": Duration=" + delta/1000000);
    }

    before() : execution(public void SimpleThreads.main(..)){
        // get the quota
        QUOTA = Float.parseFloat(System.getProperty("quota", "0.25"));
        // get the current time
        globalStartTime.set(System.nanoTime());
        System.out.println("START STATISTICS ");
    }

    after() : execution(public void SimpleThreads.main(..)){
        System.out.println("END STATISTICS ");
        System.out.println("CallNumber: " + globalCount.get() + " : AvgDuration=" + (globalDuration.get()/(globalCount.get()*1000000))
            + " : Program duration: " + ((System.nanoTime() - globalStartTime.get())/1000000));
    }

}
