`default_nettype none

module uart_rx #
(
  parameter DATA_WIDTH = 8
)
(
  input  wire                   clk,
  input  wire                   rst,
  input  wire                   clk_en,
  //AXI
  output wire [DATA_WIDTH-1:0]  m_axis_tdata,
  output wire                   m_axis_tvalid,
  input  wire                   m_axis_tready,

  //UART
  input  wire                   rxd,

  //Status
  output wire                   busy,
  output wire                   overrun_error,
  output wire                   frame_error
);

  localparam  IDLE  = 2'b00,
              START = 2'b01,
              DATA  = 2'b10,
              LAST  = 2'b11;
 
  reg [1:0] state = IDLE;

  reg [DATA_WIDTH-1:0] m_axis_tdata_reg = 0;
  reg m_axis_tvalid_reg = 0;

  reg rxd_reg = 0;
  reg [DATA_WIDTH-1:0] data_reg = 0;

  reg busy_reg = 0;
  reg overrun_error_reg = 0;
  reg frame_error_reg = 0;

  reg [3:0] tick_cnt = 0;
  reg [$clog2(DATA_WIDTH)-1:0] bit_cnt = 0;
  
  assign m_axis_tdata = m_axis_tdata_reg;
  assign m_axis_tvalid = m_axis_tvalid_reg;

  assign busy = busy_reg;
  assign overrun_error = overrun_error_reg;
  assign frame_error = frame_error_reg;

  always @ (posedge clk) begin
    if (rst) begin
      state <= IDLE;
      m_axis_tdata_reg <= 0;
      m_axis_tvalid_reg <= 0;

      rxd_reg <= 1;

      busy_reg <= 0;
      overrun_error_reg <= 0;
      frame_error_reg <= 0;
    end else begin
      rxd_reg <= rxd;
      overrun_error_reg <= 0;
      frame_error_reg <= 0;

      if (m_axis_tvalid && m_axis_tready) begin
        m_axis_tvalid_reg <= 0;
      end
      
      
      case (state)
        IDLE: begin
          if (~rxd_reg) begin
            state <= START;
            busy_reg <= 1;
          end
        end

        START: begin
          if (clk_en) begin
            if (tick_cnt == 8) begin
              tick_cnt <= 0;
              state <= DATA;
            end else begin
              tick_cnt <= tick_cnt + 1;
            end
          end
        end

        DATA: begin
          if (clk_en) begin
            if (tick_cnt == 15) begin
              tick_cnt <= 0;
              data_reg <= {rxd_reg, data_reg[DATA_WIDTH-1:1]};
          
              if (bit_cnt == DATA_WIDTH-1) begin
                bit_cnt <= 0;
                state <= LAST;
              end else begin
                bit_cnt <= bit_cnt + 1;
              end
            end else begin
              tick_cnt <= tick_cnt + 1;
            end
          end
        end

        LAST: begin
          if (clk_en) begin
            if (tick_cnt == 15) begin
              tick_cnt <= 0;
          
              if (rxd_reg) begin
                m_axis_tdata_reg <= data_reg;
                m_axis_tvalid_reg <= 1;
                overrun_error_reg <= m_axis_tvalid_reg;
              end else begin
                frame_error_reg <= 1;
              end
            
              state <= IDLE;
              busy_reg <= 0;
            end else begin
              tick_cnt <= tick_cnt + 1;
            end
          end
        end
      endcase
    end
  end
endmodule
