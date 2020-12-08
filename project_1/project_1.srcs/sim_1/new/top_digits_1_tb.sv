`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// todo - not tested, not work
module top_digits_1_tb();

logic clk;
logic [15:0] sw;
logic [3:0] jb;
logic [1:0] ja;
logic btnc, btnd, btnu;
logic ca,cb,cc,cd,ce,cf,cg,dp;
logic [7:0] an;
logic [15:0] led;


    parameter CLK_PERIOD = 10;
    parameter PERIOD = 3; //sample clock, enable_period
    parameter COUNTER_2MS = 20; //enables till 2ms
    parameter NUM_WEIGHTS = 6;
    parameter NUM_BIASES = 6;
    parameter NUM_X = 6;
    
    parameter SAMPLE_RATE = 16;

top_digits_1 #(
    .ENABLE_PERIOD(PERIOD),
    .COUNTER_2MS(COUNTER_2MS),
    .NUM_WEIGHTS(NUM_WEIGHTS),
    .NUM_BIASES(NUM_BIASES),
    .NUM_X(NUM_X)
)
top_uut (
    .clk_100mhz(clk),
    .sw(sw),
    .jb(jb),
    .ja(ja),
    .btnc(btnc),
    .btnd(btnd),
    .btnu(btnu),
    .ca(ca),
    .cb(cb),
    .cc(cc),
    .cd(cd),
    .ce(ce),
    .cf(cf),
    .cg(cg),
    .dp(dp),
    .an(an),
    .led(led)
);






    always begin
        #(CLK_PERIOD/2);  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk = !clk;
    end
    
    logic jb_data;
    assign jb[0] = jb_data;
    logic reset;
    assign btnc = reset;
    
    parameter OUTPUT_BITS = 8;
    
    logic [OUTPUT_BITS-1+2:0] metadata_x = 10'b1_0000_0000_0; //x type 00
    logic [OUTPUT_BITS-1+2:0] metadata_w = 10'b1_0000_0001_0; //w type 01
    logic [OUTPUT_BITS-1+2:0] metadata_b = 10'b1_0000_0011_0; //b type 11
    
    logic [OUTPUT_BITS-1+2:0] data_1 = 10'b1_0000_0001_0; //2 bytes each
    logic [OUTPUT_BITS-1+2:0] data_2 = 10'b1_0000_0010_0; //2 bytes each
    logic [OUTPUT_BITS-1+2:0] data_3 = 10'b1_0000_0011_0; //2 bytes each
    logic [OUTPUT_BITS-1+2:0] data_4 = 10'b1_0000_0100_0; //2 bytes each
    logic [OUTPUT_BITS-1+2:0] data_5 = 10'b1_0000_0101_0; //2 bytes each
    logic [OUTPUT_BITS-1+2:0] data_6 = 10'b1_0000_0111_0; //2 bytes each
    
    integer i;
    
    initial begin
        clk = 0;
        reset = 1;
        #CLK_PERIOD
        reset = 0;
        #CLK_PERIOD
        
        // send: x type, 3 data, 2 bytes each, then 3*2=6 bytes of data
        // each has 0 and 1 apppended to start, end (lsb to msb)
        
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = metadata_x[i];
        end
        
        // check that the sample_single_byte_fsm has expected values
        
        jb_data = 1;
        // can make this even longer
        //    #(100*CLK_PERIOD)
        
        //send rest 6
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_1[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_1[i]; 
        end

        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_2[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_2[i]; 
        end

        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_3[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_3[i]; 
        end
        
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_4[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_4[i]; 
        end

        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_5[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_5[i]; 
        end

        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_6[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_6[i]; 
        end
        
        jb_data = 1;
        
////// B update

        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = metadata_b[i];
        end
        
        // check that the sample_single_byte_fsm has expected values
        
        jb_data = 1;
        // can make this even longer
        //    #(100*CLK_PERIOD)
        
        //send rest 6
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_1[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_1[i]; 
        end

        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_2[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_2[i]; 
        end

        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_3[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_3[i]; 
        end
        
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_4[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_4[i]; 
        end

        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_5[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_5[i]; 
        end

        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_6[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_6[i]; 
        end
        
        jb_data = 1;

//// X update
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = metadata_x[i];
        end
        
        // check that the sample_single_byte_fsm has expected values
        
        jb_data = 1;
        // can make this even longer
        //    #(100*CLK_PERIOD)
        
        //send rest 6
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_2[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_1[i]; 
        end

        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_2[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_2[i]; 
        end

        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_3[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_3[i]; 
        end
        
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_4[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_4[i]; 
        end

        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_5[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_5[i]; 
        end

        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_6[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_6[i]; 
        end
        
        jb_data = 1;

//// W update
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = metadata_w[i];
        end
        
        // check that the sample_single_byte_fsm has expected values
        
        jb_data = 1;
        // can make this even longer
        //    #(100*CLK_PERIOD)
        
        //send rest 6
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_1[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_1[i]; 
        end

        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_2[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_2[i]; 
        end

        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_3[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_3[i]; 
        end
        
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_4[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_4[i]; 
        end

        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_5[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_5[i]; 
        end

        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_6[i]; 
        end
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_6[i]; 
        end
        
        jb_data = 1;

        $finish;
    end
endmodule