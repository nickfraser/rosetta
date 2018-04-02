import Chisel._
import rosetta._
import org.scalatest.junit.JUnitSuite
import org.junit.Test
import org.junit.Assert._
import RosettaTest._

// A series of tests to test the performance of Queues, Pipes, and Accelerator wrappers.
class TestPipesSuite extends JUnitSuite {
  @Test def QueueTest {
    // Tester-derived class to give stimulus and observe the outputs for the
    // Module to be tested
    class QueueTest(c: Queue[UInt], seriesLength: Int, isTrace: Boolean = true) extends Tester(c, isTrace) {
      val inputSeries = 0.until(seriesLength).toArray
      val outputSeries = Array.fill(seriesLength){ 0 }
      var readWords = 0
      var writtenWords = 0
      var writeClocks = 0
      var totalClocks = 0
      var writeWord: Boolean = false
      var readWord: Boolean = false
      while(readWords < seriesLength) {
        // Write words to the queue
        val ready_in = intToBoolean(peek(c.io.enq.ready))
        writeWord = writtenWords < seriesLength && ready_in
        if(writeWord) {
          poke(c.io.enq.valid, Bool(true).litValue())
          poke(c.io.enq.bits, UInt(inputSeries(writtenWords)).litValue())
          writtenWords += 1
        } else {
          poke(c.io.enq.valid, Bool(false).litValue())
          poke(c.io.enq.bits, UInt(0).litValue())
        }

        // Read words from the queue.
        val valid_out = intToBoolean(peek(c.io.deq.valid))
        readWord = valid_out
        poke(c.io.deq.ready, Bool(true).litValue())
        if(readWord) {
          outputSeries(readWords) = peek(c.io.deq.bits).toInt
          readWords += 1
        }

        // use step() to advance the clock cycle
        step(1)
        writeClocks += booleanToInt(writtenWords < seriesLength | writeWord)
        totalClocks += 1
      }
      for(i <- 0 until seriesLength) {
        assertEquals(inputSeries(i), outputSeries(i))
      }
      assertEquals(seriesLength, writeClocks)
      assertEquals(seriesLength+1, totalClocks)
    }

    def booleanToInt(b: Boolean) = if(b) 1 else 0
    def intToBoolean(i: BigInt) = if(i == 0) false else true

    val queueLength = 1
    val wordlength = 32
    val seriesLength = 10
    val packedWordSize = 16
    // actually run the test
    chiselMainTest(RosettaTest.stdArgs, () => Module(new Queue[UInt](UInt(width=wordlength), queueLength, pipe=true))){ c => new QueueTest(c, seriesLength, isTrace=false) }
  }

  @Test def UnpackTest {

    // A basic class to test the throughput of the Unpack & Repack hardware.
    class Unpack(w_in: Int, w_out: Int) extends Module {
      val io = new Bundle {
        val enq = Decoupled(UInt(width=w_in)).flip
        val deq = Decoupled(UInt(width=w_out))
      }

      val unpack = Module(new UnpackWords(w_in, w_out)).io
      unpack.in <> io.enq
      unpack.out <> io.deq
    }

    // Tester-derived class to give stimulus and observe the outputs for the
    // Module to be tested
    class UnpackTest(c: Unpack, seriesLength: Int, packFactor: Int, isTrace: Boolean = true) extends Tester(c, isTrace) {
      val inputSeries = 0.until(seriesLength).toArray
      val outputSeries = Array.fill(seriesLength*packFactor){ 0 }
      var readWords = 0
      var writtenWords = 0
      var writeClocks = 0
      var totalClocks = 0
      var writeWord: Boolean = false
      var readWord: Boolean = false
      while(readWords < seriesLength*packFactor) {
        // Write words to the queue
        val ready_in = intToBoolean(peek(c.io.enq.ready))
        writeWord = writtenWords < seriesLength && ready_in
        if(writeWord) {
          poke(c.io.enq.valid, Bool(true).litValue())
          poke(c.io.enq.bits, UInt(inputSeries(writtenWords)).litValue())
          writtenWords += 1
        } else {
          poke(c.io.enq.valid, Bool(false).litValue())
          poke(c.io.enq.bits, UInt(0).litValue())
        }

        // Read words from the queue.
        val valid_out = intToBoolean(peek(c.io.deq.valid))
        readWord = valid_out
        poke(c.io.deq.ready, Bool(true).litValue())
        if(readWord) {
          outputSeries(readWords) = peek(c.io.deq.bits).toInt
          readWords += 1
        }

        // use step() to advance the clock cycle
        step(1)
        writeClocks += booleanToInt(writtenWords < seriesLength | writeWord)
        totalClocks += 1
      }
      for(i <- 0 until seriesLength) {
        assertEquals(inputSeries(i), outputSeries(i*packFactor))
      }
      assertEquals(packFactor*seriesLength-1, writeClocks)
      assertEquals(packFactor*(seriesLength+1)-1, totalClocks)
    }

    def booleanToInt(b: Boolean) = if(b) 1 else 0
    def intToBoolean(i: BigInt) = if(i == 0) false else true

    val wordlength = 32
    val seriesLength = 10
    val packedWordSize = 16
    val packFactor = wordlength / packedWordSize
    // actually run the test
    chiselMainTest(RosettaTest.stdArgs, () => Module(new Unpack(wordlength, packedWordSize))){ c => new UnpackTest(c, seriesLength, packFactor, isTrace=false) }
  }

  @Test def UnpackRepackTest {

    // A basic class to test the throughput of the Unpack & Repack hardware.
    class UnpackRepack(w_io: Int, w_int: Int) extends Module {
      val io = new Bundle {
        val enq = Decoupled(UInt(width=w_io)).flip
        val deq = Decoupled(UInt(width=w_io))
      }

      val unpack = Module(new UnpackWords(w_io, w_int)).io
      val pack = Module(new PackWords(w_int, w_io)).io
      unpack.in <> io.enq
      pack.in <> unpack.out
      pack.out <> io.deq
    }

    // Tester-derived class to give stimulus and observe the outputs for the
    // Module to be tested
    class UnpackRepackTest(c: UnpackRepack, seriesLength: Int, packFactor: Int, isTrace: Boolean = true) extends Tester(c, isTrace) {
      val inputSeries = 0.until(seriesLength).toArray
      val outputSeries = Array.fill(seriesLength){ 0 }
      var readWords = 0
      var writtenWords = 0
      var writeClocks = 0
      var totalClocks = 0
      var writeWord: Boolean = false
      var readWord: Boolean = false
      while(readWords < seriesLength) {
        // Write words to the queue
        val ready_in = intToBoolean(peek(c.io.enq.ready))
        writeWord = writtenWords < seriesLength && ready_in
        if(writeWord) {
          poke(c.io.enq.valid, Bool(true).litValue())
          poke(c.io.enq.bits, UInt(inputSeries(writtenWords)).litValue())
          writtenWords += 1
        } else {
          poke(c.io.enq.valid, Bool(false).litValue())
          poke(c.io.enq.bits, UInt(0).litValue())
        }

        // Read words from the queue.
        val valid_out = intToBoolean(peek(c.io.deq.valid))
        readWord = valid_out
        poke(c.io.deq.ready, Bool(true).litValue())
        if(readWord) {
          outputSeries(readWords) = peek(c.io.deq.bits).toInt
          readWords += 1
        }

        // use step() to advance the clock cycle
        step(1)
        writeClocks += booleanToInt(writtenWords < seriesLength | writeWord)
        totalClocks += 1
      }
      for(i <- 0 until seriesLength) {
        assertEquals(inputSeries(i), outputSeries(i))
      }
      assertEquals(2*seriesLength-1, writeClocks)
      assertEquals(2*(seriesLength+1), totalClocks)
    }

    def booleanToInt(b: Boolean) = if(b) 1 else 0
    def intToBoolean(i: BigInt) = if(i == 0) false else true

    val wordlength = 32
    val seriesLength = 10
    val packedWordSize = 16
    val packFactor = wordlength / packedWordSize
    // actually run the test
    chiselMainTest(RosettaTest.stdArgs, () => Module(new UnpackRepack(wordlength, packedWordSize))){ c => new UnpackRepackTest(c, seriesLength, packFactor, isTrace=false) }
  }

}

