`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module top_level_tb(

    );
    logic               clk_100mhz;
    logic [15:0]        sw;
    logic               btnc;
    logic               btnd;
    logic [15:0] led;
    logic [1:0]  ja;
    
    top_level uut(
        .clk_100mhz(clk_100mhz),
        .sw(sw),
        .btnc(btnc),
         .btnd(btnd),
         .led(led),
       .ja(ja)
    );
    
    always begin
        #1;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk_100mhz = !clk_100mhz;
    end
    
    initial begin
        clk_100mhz = 0;
        btnd = 1;
        #10
        btnd = 0;
        #100;
        #1000;
        $finish;
    end
    
    endmodule
