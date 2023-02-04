`default_nettype none

module uart_tx # (
	parameter DATA_WIDTH = 8
) 
(
  input  wire                   clk,
  input  wire                   rst,
  input  wire                   clk_en,

  //AXI
  input  wire [DATA_WIDTH-1:0]  s_axis_tdata,
  input  wire                   s_axis_tvalid,
  output wire                   s_axis_tready,

  //UART
  output wire                   txd,

  //Status
  output wire                   busy
);

localparam IDLE  = 2'b00,
					 START = 2'b01,
					 DATA  = 2'b10,
					 LAST  = 2'b11;

reg [1:0] state = IDLE;
reg [$clog2(DATA_WIDTH)-1:0] bit_cnt = 0;

reg s_axis_tready_reg = 0;
reg [DATA_WIDTH-1:0] data_reg = 0;

reg txd_reg = 0;
reg busy_reg = 0;

assign txd = txd_reg;
assign busy = busy_reg;

assign s_axis_tready = s_axis_tready_reg;

always @ (posedge clk) begin
  if (rst) begin
    state <= IDLE;
    bit_cnt <= 0;
    busy_reg <= 0;
    txd_reg <= 1;
    s_axis_tready_reg <= 1;
    
  end else begin
    case (state)
      IDLE: begin
        if (s_axis_tvalid) begin
          state <= START;
          data_reg <= s_axis_tdata;
          s_axis_tready_reg <= 0;
          busy_reg <= 1;
        end
      end

      START: begin
        if (clk_en) begin
          txd_reg <= 0;
          state <= DATA;
        end
      end
      
      DATA: begin 
        if (clk_en) begin
          txd_reg <= data_reg[bit_cnt];

          if (bit_cnt == DATA_WIDTH-1) begin
            bit_cnt <= 0;
            state <= LAST;
          end else begin
            bit_cnt <= bit_cnt + 1;
          end
        end
      end

      LAST: begin
        if (clk_en) begin
          txd_reg <= 1;
          state <= IDLE;
          s_axis_tready_reg <= 1;
          busy_reg <= 0;
        end
      end
    endcase
  end
end
endmodule
