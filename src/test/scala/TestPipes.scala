import Chisel._
import rosetta._
import org.scalatest.junit.JUnitSuite
import org.junit.Test
import RosettaTest._

// A series of tests to test the performance of Queues, Pipes, and Accelerator wrappers.
class TestPipesSuite extends JUnitSuite {
  @Test def QueueTest {

    // Tester-derived class to give stimulus and observe the outputs for the
    // Module to be tested
    class QueueTest(c: Queue[UInt]) extends Tester(c) {
      val inputSeries = Array[Int](0 until seriesLength)
      val outputSeries = Array[Int].fill(seriesLength){ 0 }
      for(i <- 0 until seriesLength) {
        // use peek() to read I/O output signal values
        peek(c.io.signature)
        // use poke() to set I/O input signal values
        poke(c.io.op(0), 10)
        poke(c.io.op(1), 20)
        // use step() to advance the clock cycle
        step(1)
        // use expect() to read and check I/O output signal values
        expect(c.io.sum, 10+20)
      }
    }

    val queueLength = 8
    val wordlength = 32
    val seriesLength = 10
  }
}

