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
                    // Pause for 4 seconds
                    Thread.sleep(4000);
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

        long startTime = System.currentTimeMillis();

        // create a thread array
        Thread tArray[] = new Thread[NUM_THREADS];
        for(int i=0; i<NUM_THREADS; i++) {
            tArray[i] = new Thread(new MessageLoop());
            threadMessage("Starting MessageLoop thread");
            tArray[i].start();
        }

        for(Thread t : tArray){
            threadMessage("Waiting for MessageLoop thread to finish");
            // loop until MessageLoop
            // thread exits
            while (t.isAlive()) {
                threadMessage("Still waiting...");
                // Wait maximum of 1 second
                // for MessageLoop thread
                // to finish.
                try {
                    t.join(1000);
                    if (((System.currentTimeMillis() - startTime) > patience)
                            && t.isAlive()) {
                        threadMessage("Tired of waiting!");
                        t.interrupt();
                        // Shouldn't be long now
                        // -- wait indefinitely
                        t.join();
                    }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
            threadMessage("Finally!");
        }
    }
}