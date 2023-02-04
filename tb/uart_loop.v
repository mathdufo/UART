`default_nettype none

module uart_loop # (
  parameter DATA_WIDTH = 8
  )
  (
  input  wire                   clk,
  input  wire                   rst,

  //AXI input
  input  wire [DATA_WIDTH-1:0]  s_axis_tdata,
  input  wire                   s_axis_tvalid,
  output wire                   s_axis_tready,

  
  //AXI output
  output wire [DATA_WIDTH-1:0]  m_axis_tdata,
  output wire                   m_axis_tvalid,
  input  wire                   m_axis_tready,

  //Status
  output wire                   tx_busy,
  output wire                   rx_busy,
  output wire                   rx_overrun_error,
  output wire                   rx_frame_error,

  //Configuration
  input  wire [15:0]            prescale
);
  wire loop_wire;

  uart uart_inst(
    .clk(clk),
    .rst(rst),

    //AXI input
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),

  
    //AXI output
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),

  
    //UART interface
    .rxd(loop_wire),
    .txd(loop_wire),

    //Status
    .tx_busy(tx_busy),
    .rx_busy(rx_busy),
    .rx_overrun_error(rx_overrun_error),
    .rx_frame_error(rx_frame_error),

    //Configuration
    .prescale(prescale)
  );
endmodule

