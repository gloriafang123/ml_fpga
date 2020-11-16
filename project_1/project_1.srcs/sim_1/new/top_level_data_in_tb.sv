`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module top_level_data_in_tb(

    );
    logic               clk_100mhz;
    logic [15:0]        sw;
    logic               btnc;
    logic               btnd;
    logic [15:0] led;
    logic [1:0]  ja;
    logic [7:0] jb;
    logic ca,cb,cc,cd,ce,cf,cg,dp;
    
    top_level_read_in uut(
        .clk_100mhz(clk_100mhz),
        .sw(sw),
        .jb(jb),
        .btnc(btnc),
         .btnd(btnd),
         .ca(ca),
         .cb(cb),
         .cc(cc),
         .cd(cd),
         .ce(ce),
         .cf(cf),
         .cg(cg),
         .dp(dp),
       .an(an)
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
        jb[0] = 1;
        #99945 //62*806, *2 bc clk
        jb[0] = 1;
        #1736 //868*2 bc clk is 2x
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 0;
        #1736
        
        
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        jb[0] = 1;
        #1736
        jb[0] = 0;
        #1736
        #1000;
        #1000;
        $finish;
    end
    
    endmodule
