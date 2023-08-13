module uart_tx # (
	parameter DATA_WIDTH = 8
) 
(
  input  wire                   clk,
  input  wire                   reset,
  input  wire                   clk_en,

  //AXI
  input  wire [DATA_WIDTH-1:0]  s_axis_tdata,
  input  wire                   s_axis_tvalid,
  output reg                    s_axis_tready,

  //UART
  output reg                    txd
);

localparam IDLE  = 2'b00,
					 START = 2'b01,
					 DATA  = 2'b10,
					 LAST  = 2'b11;

reg [1:0] state = IDLE;
reg [$clog2(DATA_WIDTH)-1:0] bit_counter = 0;

reg [DATA_WIDTH-1:0] data_buffer = 0;

always @ (posedge clk) begin
  if (reset) begin
    state <= IDLE;
    bit_counter <= 0;
    txd <= 1;
    s_axis_tready <= 1;
    
  end else begin
    case (state)
      IDLE: begin
        if (s_axis_tvalid) begin
          state <= START;
          data_buffer <= s_axis_tdata;
          s_axis_tready <= 0;
        end
      end

      START: begin
        if (clk_en) begin
          txd <= 0;
          state <= DATA;
        end
      end
      
      DATA: begin 
        if (clk_en) begin
          txd <= data_buffer[bit_counter];

          if (bit_counter == DATA_WIDTH-1) begin
            bit_counter <= 0;
            state <= LAST;
          end else begin
            bit_counter <= bit_counter + 1;
          end
        end
      end

      LAST: begin
        if (clk_en) begin
          txd <= 1;
          state <= IDLE;
          s_axis_tready <= 1;
        end
      end
    endcase
  end
end
endmodule