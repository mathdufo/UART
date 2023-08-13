module uart_rx #
(
  parameter DATA_WIDTH = 8
)
(
  input  wire                   clk,
  input  wire                   reset,
  input  wire                   clk_en,
  
  //AXI
  output reg  [DATA_WIDTH-1:0]  m_axis_tdata,
  output reg                    m_axis_tvalid,
  input  wire                   m_axis_tready,

  //UART
  input  wire                   rxd,

  //Errors
  output reg                    overrun_error,
  output reg                    frame_error
);

  localparam  IDLE  = 2'b00,
              START = 2'b01,
              DATA  = 2'b10,
              LAST  = 2'b11;
 
  reg [1:0] state = IDLE;

  reg [DATA_WIDTH-1:0] data_buffer;

  reg [3:0] tick_counter = 0;
  reg [$clog2(DATA_WIDTH)-1:0] bit_counter = 0;

  always @ (posedge clk) begin
    if (reset) begin
      state <= IDLE;
      m_axis_tdata <= 0;
      m_axis_tvalid <= 0;

      overrun_error <= 0;
      frame_error<= 0;

    end else begin
      overrun_error <= 0;
      frame_error <= 0;

      if (m_axis_tvalid && m_axis_tready)
        m_axis_tvalid <= 0;
      
      
      case (state)
        IDLE: begin
          if (~rxd) begin
            state <= START;
          end
        end

        START: begin
          if (clk_en) begin
            if (tick_counter == 8) begin
              tick_counter <= 0;
              state <= DATA;

            end else begin
              tick_counter <= tick_counter + 1;
            end
          end
        end

        DATA: begin
          if (clk_en) begin
            if (tick_counter == 15) begin
              tick_counter <= 0;
              data_buffer <= {rxd, data_buffer[DATA_WIDTH-1:1]};
          
              if (bit_counter == DATA_WIDTH-1) begin
                bit_counter <= 0;
                state <= LAST;
              end else begin
                bit_counter <= bit_counter + 1;
              end

            end else begin
              tick_counter <= tick_counter + 1;
            end
          end
        end

        LAST: begin
          if (clk_en) begin
            if (tick_counter == 15) begin
              tick_counter <= 0;
          
              if (rxd) begin
                m_axis_tdata <= data_buffer;
                m_axis_tvalid <= 1;
                overrun_error <= m_axis_tvalid;
              end else begin
                frame_error <= 1;
              end
            
              state <= IDLE;
            end else begin
              tick_counter <= tick_counter + 1;
            end
          end
        end
      endcase
    end
  end
endmodule