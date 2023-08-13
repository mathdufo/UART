/*
This is a hacky solution to get a signal of the correct frequency for the a given baudrate. 
Prescale is a given  clk_frequency / (baudrate * 16)

tx_en receives a tick every clk_frequency / baudrate clock cycles
rx_en receives a tick every clk_frequency / (baudrate * 16) clock cycles
*/

module clk_enable(
  input  wire        clk,
  input  wire        reset,
  input  wire [15:0] prescale,
  
  output reg        rx_en, 
  output reg        tx_en
);
 
  reg [15:0] prescale_counter = 0;
  reg [3:0]  tx_counter = 0; 

  always @ (posedge clk) begin
    if (reset) begin
      prescale_counter <= 0;
      tx_counter <= 0;
      rx_en <= 0;
      tx_en <= 0;

    end else begin
      if (prescale_counter == prescale) begin
        prescale_counter <= 0;
        rx_en <= 1;

        if (tx_counter == 15) begin
          tx_counter <= 0;
          tx_en <= 1;

        end else begin
          tx_counter <= tx_counter + 1;
        end

      end else begin
        prescale_counter <= prescale_counter + 1;
        rx_en <= 0;
        tx_en <= 0;
      end
    end
  end
endmodule