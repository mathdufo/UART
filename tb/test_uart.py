import os
import cocotb

from cocotb.clock import Clock
from cocotbext.axi import AxiStreamBus, AxiStreamSource, AxiStreamSink
from cocotb.triggers import RisingEdge

class TB:
  def __init__(self, dut):
    self.dut = dut
    
    cocotb.start_soon(Clock(dut.clk, 2, units='ns').start())

    self.axis_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axis"), dut.clk, dut.rst)
    self.axis_sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_axis"), dut.clk, dut.rst)
  
  async def reset(self):
    self.dut.rst.setimmediatevalue(0)
    await RisingEdge(self.dut.clk)
    await RisingEdge(self.dut.clk)
    self.dut.rst.value = 1
    await RisingEdge(self.dut.clk)
    await RisingEdge(self.dut.clk)
    self.dut.rst.value = 0
    await RisingEdge(self.dut.clk)
    await RisingEdge(self.dut.clk)
    

@cocotb.test()
async def test(dut):
  tb = TB(dut)
  baud_rate_list = [9600, 115200, 921600]

  for baud_rate in baud_rate_list:
    await tb.reset()
    tb.dut.prescale.setimmediatevalue(int(1/(8e-9 * 16 * baud_rate)))
    
    tx_data = bytearray(os.urandom(16))

    await tb.axis_source.write(tx_data)
    rx_data = bytearray()

    while len(rx_data) < len(tx_data):
      rx_data.extend(await tb.axis_sink.read())
    
    if (rx_data != tx_data):
      raise cocotb.test.TestFailure("Failed loop with baudrate:%", baud_rate)





    
    

    
