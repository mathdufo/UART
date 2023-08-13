module uart # (
  parameter DATA_WIDTH = 8
)
(
  input  wire                   clk,
  input  wire                   reset,

  
  //AXI input
  input  wire [DATA_WIDTH-1:0]  s_axis_tdata,
  input  wire                   s_axis_tvalid,
  output wire                   s_axis_tready,

  
  //AXI output
  output wire [DATA_WIDTH-1:0]  m_axis_tdata,
  output wire                   m_axis_tvalid,
  input  wire                   m_axis_tready,

  
  //UART interface
  input  wire                   rxd,
  output wire                   txd,

  //Errors
  output wire                   rx_overrun_error,
  output wire                   rx_frame_error,

  //Configuration
  input  wire [15:0]            prescale
);
  wire tx_clk_en;
  wire rx_clk_en;

  clk_enable clk_enable_inst(
    .clk(clk),
    .reset(reset),
    .prescale(prescale),

    .rx_en(rx_clk_en),
    .tx_en(tx_clk_en)
  );


  uart_tx #(
    .DATA_WIDTH(DATA_WIDTH)
  )
  uart_tx_inst (
    .clk(clk),
    .reset(reset),
    .clk_en(tx_clk_en),
    //AXI
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    //UART
    .txd(txd)
  );

  uart_rx #(
	  .DATA_WIDTH(DATA_WIDTH)
  )
  uart_rx_inst (
    .clk(clk),
    .reset(reset),
    .clk_en(rx_clk_en),
    //AXI
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    //UART
    .rxd(rxd),
    //Status
    .overrun_error(rx_overrun_error),
    .frame_error(rx_frame_error)
  );
endmodule