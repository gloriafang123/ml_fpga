`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module serial_3_top_tb;
    parameter PERIOD = 3; //sample clock
    parameter OUTPUT_BITS = 8;
    parameter COUNTER_2MS = 20; //enables till 2ms
    parameter SAMPLE_RATE = 16;
    parameter MAX_OUTPUTS = 200; //output_bits * largest of w,b,x count
    
    parameter NUM_WEIGHTS = 6;
    parameter NUM_BIASES = 6;
    parameter NUM_X = 6;
    parameter BITS_PER_WEIGHT = 24;
    parameter BITS_PER_BIAS = 24;
    parameter BITS_PER_X = 24;
    
    parameter X_TYPE = 2'b00;
    parameter W_TYPE = 2'b01;
    parameter B_TYPE = 2'b11;
    
    
    parameter CLK_PERIOD = 10;
    logic clk, reset, jb_data, ready_nn_update;
    logic [NUM_WEIGHTS-1:0][BITS_PER_WEIGHT-1:0] weights;
    logic [NUM_BIASES-1:0][BITS_PER_BIAS-1:0] biases;
    logic [NUM_X-1:0][BITS_PER_X-1:0] x;
    
    serial_3_top #(
        .PERIOD(PERIOD), 
        .OUTPUT_BITS(OUTPUT_BITS), 
        .COUNTER_2MS(COUNTER_2MS),
        .SAMPLE_RATE(SAMPLE_RATE),
//        .MAX_OUTPUTS(MAX_OUTPUTS),
        .NUM_WEIGHTS(NUM_WEIGHTS),
        .NUM_BIASES(NUM_BIASES),
        .NUM_X(NUM_X),
        .BITS_PER_WEIGHT(BITS_PER_WEIGHT),
        .BITS_PER_BIAS(BITS_PER_BIAS),
        .BITS_PER_X(BITS_PER_X),
        .X_TYPE(X_TYPE),
        .W_TYPE(W_TYPE),
        .B_TYPE(B_TYPE)
    )
    uut (
        .clk_100mhz(clk),
        .reset(reset),
        .jb_data(jb_data),
        .weights(weights),
        .biases(biases),
        .x(x),
        .ready_nn_update(ready_nn_update)
    );
    
    always begin
        #(CLK_PERIOD/2);  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk = !clk;
    end

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
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_5[i]; 
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
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = data_5[i]; 
        end
        
        jb_data = 1;

        $finish;
    end
endmodule


module serial_2_top_tb;
    parameter PERIOD = 3; //sample clock
    parameter OUTPUT_BITS = 8;
    parameter COUNTER_2MS = 20; //enables till 2ms
    parameter SAMPLE_RATE = 16;
    parameter MAX_OUTPUTS = 200; //output_bits * largest of w,b,x count
    
    parameter NUM_WEIGHTS = 6;
    parameter NUM_BIASES = 6;
    parameter NUM_X = 6;
    parameter BITS_PER_WEIGHT = 8;
    parameter BITS_PER_BIAS = 8;
    parameter BITS_PER_X = 8;
    
    parameter X_TYPE = 2'b00;
    parameter W_TYPE = 2'b01;
    parameter B_TYPE = 2'b11;
    
    
    parameter CLK_PERIOD = 10;
    logic clk, reset, jb_data, ready_nn_update;
    logic [NUM_WEIGHTS-1:0][BITS_PER_WEIGHT-1:0] weights;
    logic [NUM_BIASES-1:0][BITS_PER_BIAS-1:0] biases;
    logic [NUM_X-1:0][BITS_PER_X-1:0] x;
    
    serial_2_top #(
        .PERIOD(PERIOD), 
        .OUTPUT_BITS(OUTPUT_BITS), 
        .COUNTER_2MS(COUNTER_2MS),
        .SAMPLE_RATE(SAMPLE_RATE),
        .MAX_OUTPUTS(MAX_OUTPUTS),
        .NUM_WEIGHTS(NUM_WEIGHTS),
        .NUM_BIASES(NUM_BIASES),
        .NUM_X(NUM_X),
        .BITS_PER_WEIGHT(BITS_PER_WEIGHT),
        .BITS_PER_BIAS(BITS_PER_BIAS),
        .BITS_PER_X(BITS_PER_X),
        .X_TYPE(X_TYPE),
        .W_TYPE(W_TYPE),
        .B_TYPE(B_TYPE)
    )
    uut (
        .clk_100mhz(clk),
        .reset(reset),
        .jb_data(jb_data),
        .weights(weights),
        .biases(biases),
        .x(x),
        .ready_nn_update(ready_nn_update)
    );
    
    always begin
        #(CLK_PERIOD/2);  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk = !clk;
    end

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
        $display ("%d", uut.sdc.clock_period_counter);        
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
            jb_data = data_6[i]; 
        end
        
        jb_data = 1;
        
        // double check parse_data_fsm
            //ouput_array, array_ready, number of data out, bytessss per out,    output type
            
        // double check weights, biases, x
        
        
        //repeat above for biases and weights
        
//////// B update
        
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = metadata_b[i];
        end
        
        // check that the sample_single_byte_fsm has expected values
        
        
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
            jb_data = data_6[i]; 
        end

//////// W update
        
        jb_data = 1;
        #(PERIOD * CLK_PERIOD * COUNTER_2MS) //high for 2ms
        for (i = 0; i < OUTPUT_BITS+2; i++) begin
            #(PERIOD*CLK_PERIOD*SAMPLE_RATE)
            jb_data = metadata_w[i];
        end
        
        // check that the sample_single_byte_fsm has expected values
 
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
            jb_data = data_6[i]; 
        end


        $finish;
    end
endmodule


module sample_data_clk_2_tb;
    logic clk;
    logic reset;
    logic enable;
    parameter PERIOD = 5;
    
    sample_data_clk_2 #(.PERIOD(PERIOD)) uut_data_clk (
    .clk_100mhz(clk),
    .reset(reset),
    .enable(enable)
    );
    
    always begin
        #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk = !clk;
    end

    //initial block...this is our test simulation
    initial begin
        clk = 0;
        reset = 1;
        #10
        reset = 0;
        #100
        $finish;
    end
endmodule

module sample_single_byte_fsm_tb;

    parameter OUTPUT_BITS = 8; 
    parameter COUNTER_2MS = 10; //0.002s *100000000/651
    parameter SAMPLE_RATE = 4;

    logic clk;
    logic reset;
    logic enable;
    logic jb_data;
    logic valid_data;
    logic [OUTPUT_BITS+2-1:0] output_bits;
    
    sample_single_byte_fsm #(.OUTPUT_BITS(OUTPUT_BITS), .COUNTER_2MS(COUNTER_2MS), .SAMPLE_RATE(SAMPLE_RATE)) 
        uut_ (
        .clk_100mhz(clk),
        .reset(reset),
        .enable(enable),
        .jb_data(jb_data),
        .valid_data(valid_data),
        .output_bits(output_bits)
    );
    
    parameter CLK_PERIOD = 10;
    parameter ENABLE_PERIOD = 5*CLK_PERIOD;
    always begin
        #(CLK_PERIOD/2);  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk = !clk;
    end
    always begin
        #(ENABLE_PERIOD-CLK_PERIOD)
        enable = 1;
        #(CLK_PERIOD)
        enable = 0;
    end

    //initial block...this is our test simulation
    initial begin
        clk = 0;
        enable = 0;
        reset = 1;
        #CLK_PERIOD
        reset = 0;
        jb_data = 1;
        #(ENABLE_PERIOD*COUNTER_2MS)
        
        
        //0_1010_0100_1
        jb_data = 0;
        #(ENABLE_PERIOD* SAMPLE_RATE) //*9 is enough but this reflect realistic
        
        jb_data = 1;
        #(ENABLE_PERIOD * SAMPLE_RATE)
        jb_data = 0;
        #(ENABLE_PERIOD * SAMPLE_RATE)
        jb_data = 1;
        #(ENABLE_PERIOD * SAMPLE_RATE)
        jb_data = 0;
        #(ENABLE_PERIOD * SAMPLE_RATE)
        jb_data = 0;
        #(ENABLE_PERIOD * SAMPLE_RATE)
        jb_data = 1;
        #(ENABLE_PERIOD * SAMPLE_RATE)
        jb_data = 0;
        #(ENABLE_PERIOD * SAMPLE_RATE)
        jb_data = 0;
        #(ENABLE_PERIOD * SAMPLE_RATE)
        
        jb_data = 1;
        #(ENABLE_PERIOD*SAMPLE_RATE)
        
        
        ///////
        jb_data = 1;
        #(ENABLE_PERIOD*COUNTER_2MS)
        
        
        //0_1010_0101_1
        jb_data = 0;
        #(ENABLE_PERIOD* SAMPLE_RATE) //*9 is enough but this reflect realistic
        
        jb_data = 1;
        #(ENABLE_PERIOD * SAMPLE_RATE)
        jb_data = 0;
        #(ENABLE_PERIOD * SAMPLE_RATE)
        jb_data = 1;
        #(ENABLE_PERIOD * SAMPLE_RATE)
        jb_data = 0;
        #(ENABLE_PERIOD * SAMPLE_RATE)
        jb_data = 0;
        #(ENABLE_PERIOD * SAMPLE_RATE)
        jb_data = 1;
        #(ENABLE_PERIOD * SAMPLE_RATE)
        jb_data = 0;
        #(ENABLE_PERIOD * SAMPLE_RATE)
        jb_data = 1;
        #(ENABLE_PERIOD * SAMPLE_RATE)
        
        jb_data = 1;
        #(ENABLE_PERIOD*COUNTER_2MS)
        
        $finish;
    end
endmodule

module parse_data_fsm_byte_outputs_tb;

    logic clk;
    logic reset;
    logic input_ready;
    logic [1:0] output_type;
    logic output_valid;
    
    // works with input_bits = 6 for example too
    parameter INPUT_BITS = 8; // add some combo logic to deal with the 10 bit to 8 bit check
    parameter X_TYPE = 2'b00;
    parameter W_TYPE = 2'b01;
    parameter B_TYPE = 2'b11;
    parameter OUTPUT_BITS = 16;

    parameter NUM_X = 3;
    parameter NUM_WEIGHTS = 6;
    parameter NUM_BIASES = 3;
    parameter BITS_PER_WEIGHT = 1*INPUT_BITS; //takes larger of input_bits and this one
    parameter BITS_PER_BIAS = 5*INPUT_BITS;
    parameter BITS_PER_X = 3*INPUT_BITS;
    
    logic [INPUT_BITS-1:0] input_value;
    logic [OUTPUT_BITS-1:0] output_array;
    logic [OUTPUT_BITS-1:0] output_index;
    logic end_of_wbx;
    
    parse_data_fsm_byte_outputs #(
        .INPUT_BITS(INPUT_BITS),
        .OUTPUT_BITS(OUTPUT_BITS),
        .NUM_X(NUM_X),
        .NUM_WEIGHTS(NUM_WEIGHTS),
        .NUM_BIASES(NUM_BIASES),
        .BITS_PER_WEIGHT(BITS_PER_WEIGHT),
        .BITS_PER_BIAS(BITS_PER_BIAS),
        .BITS_PER_X(BITS_PER_X),
        .X_TYPE(X_TYPE),
        .W_TYPE(W_TYPE),
        .B_TYPE(B_TYPE)
    ) uut_fsm
    (
        .input_ready(input_ready),
        .input_value(input_value),
        .clk_100mhz(clk),
        .reset(reset),
        .output_type(output_type),
        .output_array(output_array),
        .output_valid(output_valid),
        .output_index(output_index),
        .end_of_wbx(end_of_wbx)
    );

    
    parameter CLK_PERIOD = 10;
    parameter INPUT_PERIOD = 5*CLK_PERIOD;
    always begin
        #(CLK_PERIOD/2);  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk = !clk;
    end

    //initial block...this is our test simulation
    initial begin
        clk = 0;
        reset = 1;
        #CLK_PERIOD
        reset = 0;
        
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = W_TYPE; //type_data, number_of_data, bytes_per_data;


        // now need 15 times
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 1;
        
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 1;
        
        
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 2;
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 2;
        
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 3;
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 3;
        
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 4;
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 4;
        
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 5;
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 5;
        
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 10;
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 10;
        
        #(CLK_PERIOD)
        input_ready = 0;
       
 
        ////////
        
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = X_TYPE; //type_data, number_of_data, bytes_per_data;
                        // type data: weights   
        
        
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 5;
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 5;
        
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 4;
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 33;
        
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 4;
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 5;
        #(CLK_PERIOD)
        input_ready = 0;
        
        $finish;
    end
endmodule

module parse_data_fsm_tb;

    logic clk;
    logic reset;
    logic input_ready;
    logic [1:0] output_type;
    logic output_valid;
    
    // works with input_bits = 6 for example too
    parameter INPUT_BITS = 8; // add some combo logic to deal with the 10 bit to 8 bit check
    parameter X_TYPE = 2'b00;
    parameter W_TYPE = 2'b01;
    parameter B_TYPE = 2'b11;

    parameter NUM_X = 5;
    parameter NUM_WEIGHTS = 15;
    parameter NUM_BIASES = 3;
    parameter BITS_PER_WEIGHT = 1*INPUT_BITS; //takes larger of input_bits and this one
    parameter BITS_PER_BIAS = 5*INPUT_BITS;
    parameter BITS_PER_X = 3*INPUT_BITS;

    parameter MAX_OUTPUTS = 200;
    
    logic [INPUT_BITS-1:0] input_value;
    logic [MAX_OUTPUTS-1:0] output_array;
    
    parse_data_fsm #(
        .INPUT_BITS(INPUT_BITS),
        .MAX_OUTPUTS(MAX_OUTPUTS),
        .NUM_X(NUM_X),
        .NUM_WEIGHTS(NUM_WEIGHTS),
        .NUM_BIASES(NUM_BIASES),
        .BITS_PER_WEIGHT(BITS_PER_WEIGHT),
        .BITS_PER_BIAS(BITS_PER_BIAS),
        .BITS_PER_X(BITS_PER_X),
        .X_TYPE(X_TYPE),
        .W_TYPE(W_TYPE),
        .B_TYPE(B_TYPE)
    ) uut_fsm
    (
        .input_ready(input_ready),
        .input_value(input_value),
        .clk_100mhz(clk),
        .reset(reset),
        .output_type(output_type),
        .output_array(output_array),
        .output_valid(output_valid)
    );

    
    parameter CLK_PERIOD = 10;
    parameter INPUT_PERIOD = 5*CLK_PERIOD;
    always begin
        #(CLK_PERIOD/2);  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk = !clk;
    end

    //initial block...this is our test simulation
    initial begin
        clk = 0;
        reset = 1;
        #CLK_PERIOD
        reset = 0;
        
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = W_TYPE; //type_data, number_of_data, bytes_per_data;
                        // type data: weights   
/*        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 5; //number_of_data
        
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 3; //bytes_per_data
*/

        // now need 15 times
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 1;
        #(CLK_PERIOD)
        input_ready = 0;
        $display ("%d", (uut_fsm.data_counter - 1)*(INPUT_BITS));
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 2;
        #(CLK_PERIOD)
        input_ready = 0;
        $display ("%d", (uut_fsm.data_counter - 1)*(INPUT_BITS));
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 3;
        #(CLK_PERIOD)
        input_ready = 0;
        $display ("%d", (uut_fsm.data_counter - 1)*(INPUT_BITS));
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 4;
        #(CLK_PERIOD)
        input_ready = 0;
        $display ("%d", (uut_fsm.data_counter - 1)*(INPUT_BITS));
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 5;
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 6;
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 7;
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 8;
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 9;
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 10;
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 11;
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 12;
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 13;
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value =14;
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value =20;
        #(CLK_PERIOD)
        input_ready = 0;
 
        ////////
        
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = X_TYPE; //type_data, number_of_data, bytes_per_data;
                        // type data: weights   
        
        // now need 5 times
        #(CLK_PERIOD)
        input_ready = 0;
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 5;
        #(CLK_PERIOD)
        input_ready = 0;
        $display ("%d", (uut_fsm.data_counter - 1)*(INPUT_BITS));
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 4;
        #(CLK_PERIOD)
        input_ready = 0;
        $display ("%d", (uut_fsm.data_counter - 1)*(INPUT_BITS));
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 33;
        #(CLK_PERIOD)
        input_ready = 0;
        $display ("%d", (uut_fsm.data_counter - 1)*(INPUT_BITS));
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 4;
        #(CLK_PERIOD)
        input_ready = 0;
        $display ("%d", (uut_fsm.data_counter - 1)*(INPUT_BITS));
        #(INPUT_PERIOD-CLK_PERIOD)
        input_ready = 1;
        input_value = 5;
        #(CLK_PERIOD)
        input_ready = 0;
        
        $finish;
    end
endmodule


module update_wbx_values_tb;
    parameter NUM_WEIGHTS = 2;
    parameter NUM_BIASES = 5;
    parameter NUM_X = 5;
    parameter BITS_PER_WEIGHT = 16;
    parameter BITS_PER_BIAS = 2;
    parameter BITS_PER_X = 6;
    parameter MAX_INPUT_SIZE = 200;
    
    parameter X_TYPE = 2'b00;
    parameter W_TYPE = 2'b01;
    parameter B_TYPE = 2'b11;

    logic [MAX_INPUT_SIZE-1:0] input_array;
    logic [NUM_WEIGHTS-1:0][BITS_PER_WEIGHT-1:0] weights;
    logic [NUM_BIASES-1:0][BITS_PER_BIAS-1:0] biases;
    logic [NUM_X-1:0][BITS_PER_X-1:0] x;

    logic clk;
    logic reset;
    logic valid_input, output_valid;
    logic [1:0] input_type, output_type;
    
    update_wbx_values #(
        .NUM_WEIGHTS(NUM_WEIGHTS),
        .NUM_BIASES(NUM_BIASES),
        .NUM_X(NUM_X),
        .BITS_PER_WEIGHT(BITS_PER_WEIGHT),
        .BITS_PER_BIAS(BITS_PER_BIAS),
        .BITS_PER_X(BITS_PER_X),
        .X_TYPE(X_TYPE),
        .W_TYPE(W_TYPE),
        .B_TYPE(B_TYPE),
        .MAX_INPUT_SIZE(MAX_INPUT_SIZE)
    ) uut_updater    
    (
        .clk_100mhz(clk),
        .reset(reset),
        .valid_input(valid_input),
        .input_type(input_type),
        .input_array(input_array),
        .weights(weights),
        .biases(biases),
        .x(x),
        .output_valid(output_valid),
        .output_type(output_type)
    );
    
    parameter CLK_PERIOD = 10;
    always begin
        #(CLK_PERIOD/2);  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk = !clk;
    end

    //initial block...this is our test simulation
    initial begin
    reset = 1;
    clk = 0;
    #CLK_PERIOD
    reset = 0;
    
    // basic test: set all to 1's
    valid_input = 1;
    input_type = X_TYPE;
    input_array = {NUM_X{{BITS_PER_X{1'b1}}}}; 
    #CLK_PERIOD
    valid_input = 0;
    
    #CLK_PERIOD
    valid_input = 1;
    input_type = X_TYPE;
    input_array = {
        6'b000_111,
        6'b000_110,
        6'b000_101,
        6'b000_100,
        6'b000_011
        }; 
    #CLK_PERIOD
    valid_input = 0;
    
    #CLK_PERIOD
    valid_input = 1;
    input_type = W_TYPE;
    input_array = {
        8'b0000_1110,
        8'b0001_1100,
        8'b1111_0001,
        8'b1111_0001
        }; 
    #CLK_PERIOD
    valid_input = 0;
    
    #CLK_PERIOD
    valid_input = 1;
    input_type = B_TYPE;
    input_array = {
        2'b11,
        2'b01,
        2'b11,
        2'b10,
        2'b00
        }; 
    #CLK_PERIOD
    valid_input = 0;
    
    $finish;
    end
endmodule


module check_wbx_all_updated_tb;
    parameter X_TYPE = 2'b00;
    parameter W_TYPE = 2'b01;
    parameter B_TYPE = 2'b11;
    logic clk, reset, valid_input, wbx_all_ready;
    logic [1:0] input_type;
    check_wbx_all_updated #(
        .X_TYPE(X_TYPE),
        .W_TYPE(W_TYPE),
        .B_TYPE(B_TYPE)
    ) uut_checker
    (
        .clk_100mhz(clk),
        .reset(reset),
        .input_type(input_type),
        .valid_input(valid_input),
        .wbx_all_ready(wbx_all_ready)
    );
    parameter CLK_PERIOD = 10;
    always begin
        #(CLK_PERIOD/2);  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk = !clk;
    end

    initial begin
    reset = 1;
    clk = 0;
    valid_input = 0;
    #CLK_PERIOD
    reset = 0;
    valid_input = 1;
    input_type = X_TYPE;
    #CLK_PERIOD
    valid_input = 0;
    
    #CLK_PERIOD
    valid_input = 1;
    input_type = X_TYPE;
    #CLK_PERIOD
    valid_input = 0;
    
    #CLK_PERIOD
    valid_input = 1;
    input_type = B_TYPE;
    #CLK_PERIOD
    valid_input = 0;
    
    #CLK_PERIOD
    valid_input = 1;
    input_type = W_TYPE;
    #CLK_PERIOD
    valid_input = 0;
    
    #CLK_PERIOD
    valid_input = 1;
    input_type = B_TYPE;
    #CLK_PERIOD
    valid_input = 0;
    
    #CLK_PERIOD
    #CLK_PERIOD
    #CLK_PERIOD
    valid_input = 1;
    input_type = X_TYPE;
    #CLK_PERIOD
    valid_input = 0;
    
    
    /////////
    reset = 1;
    #CLK_PERIOD
    reset = 0;
    
    #CLK_PERIOD
    valid_input = 1;
    input_type = B_TYPE;
    #CLK_PERIOD
    valid_input = 0;
     #CLK_PERIOD
    valid_input = 1;
    input_type = X_TYPE;
    #CLK_PERIOD
    valid_input = 0;
     #CLK_PERIOD
    valid_input = 1;
    input_type = W_TYPE;
    #CLK_PERIOD
    valid_input = 0;
    #CLK_PERIOD
    $finish;
    end
endmodule