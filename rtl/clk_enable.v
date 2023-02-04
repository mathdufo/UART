`default_nettype none

module clk_enable(
  input  wire        clk,
  input  wire        rst,
  input  wire [15:0] prescale,
  
  output wire        rx_en,
  output wire        tx_en
);
 
  reg [15:0] prescale_reg = 0;
  reg [3:0] cnt = 0;
  reg rx_en_reg = 0;
  reg tx_en_reg = 0;

  assign rx_en = rx_en_reg;
  assign tx_en = tx_en_reg;

  always @ (posedge clk) begin
    if (rst) begin
      prescale_reg <= 0;
      cnt <= 0;
      rx_en_reg <= 0;
      tx_en_reg <= 0;
    end else begin
      if (prescale_reg == prescale) begin
        prescale_reg <= 0;
        rx_en_reg <= 1;

        if (cnt == 15) begin
          cnt <= 0;
          tx_en_reg <= 1;
        end else begin
          cnt <= cnt + 1;
        end
      end else begin
        prescale_reg <= prescale_reg + 1;
        rx_en_reg <= 0;
        tx_en_reg <= 0;
      end
    end
  end
endmodule
