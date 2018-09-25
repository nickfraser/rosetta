package rosetta

import Chisel._
import fpgatidbits.dma._
import fpgatidbits.streams._
import fpgatidbits.PlatformWrapper._
import PKAF._

// Create a template to drop in a KNLMS Accelerator.
// Read in a 32-bit word, convert to two 16-bit words and push into a 
// FIFO with the same interface as the KNLMSTimeSeriesWrapperClass, then
// pack two results into a 32-bit word and send to the writer.
class KnlmsBoilerPlate() extends RosettaAccelerator {
  val numMemPorts = 2
  val io = new RosettaAcceleratorIF(numMemPorts) {
    val start = Bool(INPUT)
    val finished = Bool(OUTPUT)
    val srcAddr = UInt(INPUT, width = 64)
    val destAddr = UInt(INPUT, width = 64)
    val byteCount = UInt(INPUT, width = 32)
    val cycleCount = UInt(OUTPUT, width = 32)
  }
  // to read the data stream from DRAM, we'll use a component called StreamReader
  // from fpgatidbits.dma:
  // https://github.com/maltanar/fpga-tidbits/blob/master/src/main/scala/fpgatidbits/dma/StreamReader.scala
  // we'll start by describing the "static" (unchanging) properties of the data
  // stream
  val rdP = new StreamReaderParams(
    streamWidth = 32, /* read a stream of 32 bits */
    fifoElems = 8,    /* add a stream FIFO of 8 elements */
    mem = PYNQZ1Params.toMemReqParams(),  /* PYNQ memory request parameters */
    maxBeats = 1, /* do not use bursts (set to e.g. 8 for better DRAM bandwidth)*/
    chanID = 0, /* stream ID for distinguishing between returned responses */
    disableThrottle = true  /* disable throttling */
  )
  // now instantiate the StreamReader with these parameters
  val reader = Module(new StreamReader(rdP)).io

  // to read the data stream from DRAM, we'll use a component called StreamWriter
  // from fpgatidbits.dma:
  // https://github.com/maltanar/fpga-tidbits/blob/master/src/main/scala/fpgatidbits/dma/StreamWriter.scala
  // we'll start by describing the "static" (unchanging) properties of the data
  // stream
  val wdP = new StreamWriterParams(
    streamWidth = 32, /* read a stream of 32 bits */
    mem = PYNQZ1Params.toMemReqParams(),  /* PYNQ memory request parameters */
    maxBeats = 1, /* do not use bursts (set to e.g. 8 for better DRAM bandwidth)*/
    chanID = 0 /* stream ID for distinguishing between returned responses */
  )
  // now instantiate the StreamWriter with these parameters
  val writer = Module(new StreamWriter(wdP)).io

  // wire up the stream reader and writer to the parameters that will be
  // specified by the user at runtime
  // start signal
  reader.start := io.start
  reader.baseAddr := io.srcAddr    // pointer to start of the source data
  writer.start := io.start
  writer.baseAddr := io.destAddr   // pointer to start of the destination

  // number of bytes to read for both reader and writer
  // IMPORTANT: it's best to provide a byteCount which is divisible by
  // 64, as the fpgatidbits streaming DMA components have some limitations.
  reader.byteCount := io.byteCount
  writer.byteCount := io.byteCount

  // indicate when the transfer is finished.
  io.finished := writer.finished

  // Instantiate a dummy accelerator and connect to the streams.
  val accel = Module(new ValidToDecoupledWrapper(16, 15)).io
  val preproc = Module(new UnpackWords(32, 16)).io // Unpack words to send the accelerator.
  val postproc = Module(new PackWords(16, 32)).io // Repack words to send back to memory.
  preproc.in <> reader.out
  accel.in <> preproc.out
  postproc.in <> accel.out
  writer.in <> postproc.out

  // wire up the read requests-responses against the memory port interface
  reader.req <> io.memPort(0).memRdReq
  io.memPort(0).memRdRsp <> reader.rsp

  // plug the unused write port
  io.memPort(0).memWrReq.valid := Bool(false)
  io.memPort(0).memWrDat.valid := Bool(false)
  io.memPort(0).memWrRsp.ready := Bool(false)

  // wire up the write requests-responses against the memory port interface
  writer.req <> io.memPort(1).memWrReq
  io.memPort(1).memWrRsp <> writer.rsp
  writer.wdat <> io.memPort(1).memWrDat

  // plug the unused read port
  plugMemReadPort(1)  // read port not used

  // instantiate a cycle counter for benchmarking
  val regCycleCount = Reg(init = UInt(0, 32))
  io.cycleCount := regCycleCount
  when(!io.start) {regCycleCount := UInt(0)}
  .elsewhen(io.start & !io.finished) {regCycleCount := regCycleCount + UInt(1)}

  // the signature can be e.g. used for checking that the accelerator has the
  // correct version. here the signature is regenerated from the current date.
  io.signature := makeDefaultSignature()
}

// Wrap a basic valid interface inside a decoupled interface.
// The pipelength in the length of the dummy accelerator.
class ValidToDecoupledWrapper(w: Int, pipeLength: Int) extends Module {
  val io = new Bundle {
    val in = Decoupled(UInt(width=w)).flip
    val out = Decoupled(UInt(width=w))
  }
  //val accel = Module(new Pipe(UInt(width=w), pipeLength)).io // A standard pipe similar to my hardware with a valid interface.
  val queue = Module(new Queue(UInt(width=w), pipeLength+1, pipe=true)).io // A fall-through FIFO with a decoupled interface for I/O

  // Define the KNLMS style accelerator.
  val n: Int = 16
  val m: Int = 8
  val wL: Int = 18
  val iL: Int = 5
  val (divDelay, expDelay) = (6, 5)
  val delay = pipeLength // doReg is of size {(log2(m) + 4) + (2) + (log2(n) + 1) + 1 + (3)} + a*pmul + b*pdiv + c*padd + d*psub + e*pexp + f*pgt
  val (doReg, expReg, divReg) = KNLMS.estimateDoReg(n, m, delay, divDelay, expDelay)
  val pdiv: Int = CountReg.nreg(divReg)
  val pexp: Int = CountReg.nreg(expReg)
  val gamma: Double = 0.884545
  val mu0: Double = 0.746731
  val epsilon: Double = 0.089980
  val eta: Double = 0.067604
  val fromD: Double => PsspFixed = PsspFixed(_, wL, iL, 0, 0, 0, pdiv, 0)
  val div: (PsspFixed, PsspFixed) => PsspFixed = _.divLutLi(mu0, 1.0 + mu0*(n-1), 64, divReg, _)
  val exp: PsspFixed => PsspFixed = _.expLutLi(-4, 0, 64, expReg)
  val knlms = Module(new KNLMSTimeSeriesWrapper[PsspFixed](PsspFixed(width=wL,iL=iL,pdiv=pdiv), -gamma, mu0, epsilon, eta, doReg, n, m, _*_, div, _+_, _-_, exp, _ > _, fromD, pdiv=pdiv, pexp=pexp, singleDelay=false, addMask=true)).io

  // Connect the output to the queue.
  io.out <> queue.deq

  // Connect input data to the Pipe.
  knlms.y := PsspFixed(width=wL,iL=iL,pdiv=pdiv).castToPsspFixed(chiselCast(Cat(UInt(0,width=wL-w),io.in.bits)){ SInt() }, w, iL, 0, 0, 0, pdiv, 0)
  // Connect accel data to the queue.
  queue.enq.bits := chiselCast(knlms.ybar(w-1,0)){ UInt() }
  queue.enq.valid := knlms.valid_out

  // Create a ready signal to connect to the input.
  val ready = io.out.ready & queue.enq.ready
  io.in.ready := ready

  // Create a valid signal to connect to the accelerator.
  val valid = io.in.valid & ready
  knlms.valid_in := valid
}

// A class to unpack words from larger words to smaller sub-words.
class UnpackWords(w_in: Int, w_out: Int) extends Module {
  val io = new Bundle {
    val in = Decoupled(UInt(width=w_in)).flip
    val out = Decoupled(UInt(width=w_out))
  }
  val pack_factor: Int = w_in / w_out
  // Create a vector of queues so we can parallel load them.
  val shift = Vec.fill(pack_factor){ Module(new Queue(UInt(width=w_out), 1, pipe=true)).io }
  val is_empty = Vec.fill(pack_factor) { Bool() }
  val is_ready = Vec.fill(pack_factor) { Bool() }

  // Connect the output queue to the output of the module.
  io.out <> shift(0).deq

  // Create a ready signal to pass to the input.
  val all_empty = is_empty.reduce(_ & _)
  val all_ready = is_ready.reduce(_ & _)
  io.in.ready := all_empty & all_ready // If all queues are empty and ready, we're ready to parallel load.
  val fire = all_empty & all_ready & io.in.valid // Load if input is also valid.

  // Connect inputs to queues and make is_empty vector.
  for(i <- 0 until pack_factor) {
    if(i == 0) {
      is_empty(i) := Bool(true) // It doesn't matter if the output queue is ready.
    } else {
      is_empty(i) := !shift(i).deq.valid
    }
    is_ready(i) := shift(i).enq.ready
    when(fire) { // Parallel load from input
      shift(i).enq.valid := io.in.valid
      shift(i).enq.bits := io.in.bits((i+1)*w_out - 1, i*w_out)
    } .otherwise { // Serial push down the queues to the output.
      if(i == pack_factor-1) { // End of chain, set valid to false.
        shift(i).enq.valid := Bool(false)
        shift(i).enq.bits := UInt(0)
      } else { // Pass down the queues.
        shift(i).enq <> shift(i+1).deq
      }
    }
  }
}

// Pack small words into a larger word.
class PackWords(w_in: Int, w_out: Int) extends Module {
  val io = new Bundle {
    val in = Decoupled(UInt(width=w_in)).flip
    val out = Decoupled(UInt(width=w_out))
  }
  val pack_factor: Int = w_out / w_in
  // Create a vector of queues so we can parallel load them.
  val shift = Vec.fill(pack_factor){ Module(new Queue(UInt(width=w_in), 1, pipe=true)).io }
  val is_valid = Vec.fill(pack_factor) { Bool() }

  // Connect the output queue to the output of the module.
  shift(pack_factor-1).enq <> io.in

  // Create a ready signal to pass to the input.
  val all_valid = is_valid.reduce(_ & _)
  io.out.valid := all_valid // If all queues are empty and ready, we're internally ready to parallel load.
  val fire = all_valid & io.out.ready // Load output is also ready.

  // Connect inputs to queues and make is_empty vector.
  io.out.bits := UInt(0) // Default output when fire has not occurred.
  //val output = shift.reduce(Cat(_.deq.bits, _.deq.bits).toUInt)
  for(i <- 0 until pack_factor) {
    is_valid(i) := shift(i).deq.valid
    when(fire) { // Parallel load
      if(i != pack_factor-1) {
        shift(i).enq.valid := Bool(false)
        shift(i).enq.bits := UInt(0)
      }
      io.out.bits(i*w_in + w_in - 1, i*w_in) := shift(i).deq.bits
      shift(i).deq.ready := io.out.ready
    } .otherwise { // Serial load
      if(i != 0) {  // Pass down the queues.
        shift(i-1).enq <> shift(i).deq
      } else {
        shift(i).deq.ready := Bool(false)
      }
    }
  }
}

