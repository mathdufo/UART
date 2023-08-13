import os
import cocotb

from cocotb.clock import Clock
from cocotbext.axi import AxiStreamBus, AxiStreamSource, AxiStreamSink
from cocotbext.uart import UartSource, UartSink
from cocotb.triggers import RisingEdge

class TB:
    def __init__(self, dut):
        self.dut = dut
        
        cocotb.start_soon(Clock(dut.clk, 1, units='ns').start())
    
        self.axis_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axis"), dut.clk, dut.reset)
        self.axis_sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_axis"), dut.clk, dut.reset)
  
    async def reset(self):
        self.dut.reset.setimmediatevalue(0)
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.reset.value = 1
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.reset.value = 0
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)

    async def rx_test(self, rx_data:bytes, baudrate:int):
        await self.reset()
        self.dut.prescale.setimmediatevalue(int(1/(1e-9 * 16 * baudrate)))
    
        uart_source = UartSource(self.dut.rxd, baud=baudrate, bits=8)
        await uart_source.write(rx_data)
        await uart_source.wait()

        tx_data = bytearray()
        while len(tx_data) < len(rx_data):
          tx_data.extend(await self.axis_sink.read())
        
        return tx_data

    async def tx_test(self, tx_data:bytes,  baudrate:int):
        await self.reset()
        self.dut.prescale.setimmediatevalue(int(1/(1e-9 * 16 * baudrate)))
    
        await self.axis_source.write(tx_data)
        
        uart_sink = UartSink(self.dut.txd, baud=baudrate, bits=8)
        rx_data = bytearray()
        while len(rx_data) < len(tx_data):
          rx_data.extend(await uart_sink.read())
        
        return rx_data
  
@cocotb.test()
async def test(dut):
    tb = TB(dut)
    baudrates = [9600, 115200, 921600]
  
    for baudrate in baudrates:
        data = bytes(os.urandom(16))

        assert await tb.rx_test(data, baudrate) == data
        assert await tb.tx_test(data, baudrate) == data