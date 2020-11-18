`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module gather_weights_tb();

logic [14:0] [7:0] weights ;
logic [6:0] [7:0] biases ;
logic clk, start, valid_input, output_ready;
logic [7:0] x;
gather_weights_into_one_array uut(
    .clk_100mhz(clk),
    .start_gathering(start), //btnc
    .valid_input(valid_input), // bit true if valid
    .x(x), // input to gather
    .weights(weights),
    .biases(biases),
    .output_ready(output_ready)
    );

    always begin
        #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk = !clk;
    end

    //initial block...this is our test simulation
    initial begin
        clk = 0;
        start = 1;
        #10
        start = 0;
        #10;
        x = 15;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 14;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 13;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 12;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 11;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 10;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 9;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 8;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 7;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 6;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 5;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 4;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 15;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 15;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 1;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        #10
        #10
        
        
        x = 8;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 7;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 6;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 5;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 4;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 15;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 15;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        x = 1;
        valid_input = 1;
        #10
        valid_input = 0;
        #20
        #10
        #10
        
        
        
        #100;
    
        $finish;
    end

endmodule
