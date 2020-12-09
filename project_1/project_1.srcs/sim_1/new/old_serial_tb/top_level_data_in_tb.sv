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
        btnc = 1;
        #10
        btnd = 0;
        btnc = 0;
        jb[0] = 1;
        #(2*651*308) //62*806, *2 bc clk   2*651*868
        jb[0] = 1;
        #(2*651) //868*2 bc clk is 2x
        jb[0] = 1;
        
        for (int i = 0; i < 39; i++) begin
            #(2*651*308) //62*806, *2 bc clk   2*651*868
            jb[0] = 1;
            #(2*651) // not sure why but needs extra wait
            jb[0] = 1;
            #(2*651) // not sure why but needs extra wait
            jb[0] = 1;
            #(2*651) // not sure why but needs extra wait
            jb[0] = 1;
            
            // send the same thing 3x
            for (int j=0; j<3; j++) begin
            #(2*651*16) //16x baud rate is this
            jb[0] = 0;
            #(2*651*16)
            jb[0] = 1;
            #(2*651*16)
            jb[0] = 0;
            #(2*651*16)
            jb[0] = 1;
            #(2*651*16)
            jb[0] = 0;
            #(2*651*16)
            jb[0] = 1;
            #(2*651*16)
            jb[0] = 0;
            #(2*651*16)
            jb[0] = 0;
            #(2*651*16)
            jb[0] = 1;
            #(2*651*16)
            jb[0] = 1;
            end
        end // 30 weights, 9 biases\
        // 41 ms to run whole thing
        
        // weights and biases written, i checked.
        
        
        // need to wait a lot here or else sw will happen when output_ready is 1
        // bc it needs to check on next enable if done.
        
        // now send the x_in
        #(2*651*16)
        sw[0] = 1;
        #1000
        sw[0] = 0;
        
        
        
        for (int k = 0; k < 5; k++) begin //4 weights = x_in, 1 dummy bias
            #(2*651*308) //62*806, *2 bc clk   2*651*868
            jb[0] = 1;
            #(2*651) // not sure why but needs extra wait
            jb[0] = 1;
            #(2*651) // not sure why but needs extra wait
            jb[0] = 1;
            #(2*651) // not sure why but needs extra wait
            jb[0] = 1;
            
            // send the same thing 3x
            for (int m=0; m<3; m++) begin
            #(2*651*16) //16x baud rate is this
            jb[0] = 0;
            #(2*651*16)
            jb[0] = 1;
            #(2*651*16)
            jb[0] = 1;
            #(2*651*16)
            jb[0] = 1;
            #(2*651*16)
            jb[0] = 1;
            #(2*651*16)
            jb[0] = 1;
            #(2*651*16)
            jb[0] = 1;
            #(2*651*16)
            jb[0] = 0;
            #(2*651*16)
            jb[0] = 1;
            #(2*651*16)
            jb[0] = 1;
            end
        end
        
        // check x_in written
        // check output_final
        
        
        
        
        #1000;
        #1000;
        $finish;
    end
    
    endmodule
