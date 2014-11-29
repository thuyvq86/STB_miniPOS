
/**
 *  Generic Queue
 */
@interface NSMutableArray (QueueAdditions)

// Grab the next item in the queue, if there is one
- (id)dequeue;

// Add to the tail of the queue
- (void)enqueue:(id)obj;

// Takes a look at an object at a given location
- (id)peek:(int)index;

// Let's take a look at the next item to be dequeued
- (id)peekHead;

// Let's take a look at the last item to have been added to the queue
- (id)peekTail;

// Checks if the queue is empty
- (BOOL)empty;

@end