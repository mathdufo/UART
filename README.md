This is a basic UART with an AXI-Stream interface written in verilog. Heavily inspired by https://github.com/alexforencich/verilog-uart. There's no reason to use this instead of the aforementioned.

The baud rate is specified by the prescale bus. It must be set to 
```
prescale = Fclk/(baud*16)

```

The width of the data bus and the number of bits sent/received on the serial lined is specified by the DATA_WIDTH parameter.

