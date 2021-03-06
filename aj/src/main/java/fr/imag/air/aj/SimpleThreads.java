// From https://docs.oracle.com/javase/tutorial/essential/concurrency/simple.html
package fr.imag.air.aj;

import java.util.concurrent.ConcurrentHashMap;

public class SimpleThreads {

    // Display a message, preceded by
    // the name of the current thread
    static void threadMessage(String message) {
        String threadName = Thread.currentThread().getName();
        System.out.format("%s: %s%n",
                threadName,
                message);
    }

    private static class MessageLoop implements Runnable {
        public void run() {
            String importantInfo[] = {
                    "Mares eat oats",
                    "Does eat oats",
                    "Little lambs eat ivy",
                    "A kid will eat ivy too"
            };
            try {
                for (int i = 0;
                     i < importantInfo.length;
                     i++) {

                    // Pause for a random number between 10 and 500 ms
                    long time = (long)(Math.random() * (500-10)) + 10;
                    Thread.sleep(time);

                    // Pause for 4 seconds
                    //Thread.sleep(4000);

                    // Print a message
                    threadMessage(importantInfo[i]);
                }
            } catch (InterruptedException e) {
                threadMessage("I wasn't done!");
            }
        }
    }

    public static void main(String args[]) throws InterruptedException {

        // get number of running threads
        int NUM_THREADS = Integer.parseInt(System.getProperty("numthreads", "5"));

        // Delay, in milliseconds before
        // we interrupt MessageLoop
        // thread (default one hour).
        long patience = 1000 * 60 * 60;

        // If command line argument
        // present, gives patience
        // in seconds.
        if (args.length > 0) {
            try {
                patience = Long.parseLong(args[0]) * 1000;
            } catch (NumberFormatException e) {
                System.err.println("Argument must be an integer.");
                System.exit(1);
            }
        }

        final long startTime = System.currentTimeMillis();

        // create a thread array
        Thread tArray[] = new Thread[NUM_THREADS];
        for(int i=0; i<NUM_THREADS; i++) {
            final long finalPatience = patience;

            // Run and join each MessageLoop threads in parallel
            // thanks to a new Thread implementing the run method of runnable
            tArray[i] = new Thread(new Runnable() {
                @Override
                public void run() {
                    Thread t = new Thread(new MessageLoop());
                    threadMessage("Starting MessageLoop thread");
                    t.start();

                    threadMessage("Waiting for MessageLoop thread to finish");
                    // loop until MessageLoop
                    // thread exits
                    while (t.isAlive()) {
                        threadMessage("Still waiting...");
                        // Wait maximum of 1 second
                        // for MessageLoop thread
                        // to finish.
                        try {
                            if (((System.currentTimeMillis() - startTime) > finalPatience)
                                    && t.isAlive()) {
                                threadMessage("Tired of waiting!");
                                t.interrupt();
                                // Shouldn't be long now
                                // -- wait indefinitely

                                    t.join();

                            }
                            else{
                                t.join(1000);
                            }
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                    }
                    threadMessage("Finally!");
                }
            });
            tArray[i].start();

            // Sleep 1 second in order to shift the start of each thread
            // this may be useful when you want to see how works
            // the code for Exercise 2
            Thread.currentThread().sleep(1000);
        }

        for(Thread t : tArray){
            t.join();
        }
    }
}