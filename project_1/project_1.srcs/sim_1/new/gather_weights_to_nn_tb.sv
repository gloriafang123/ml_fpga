`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module gather_weights_to_nn_tb();
    logic clk;
    logic weights_biases_ready;
    logic [14:0] [7:0] weights ;
    logic [6:0] [7:0] biases ;
    logic btnc, btnd;
    logic input_ready;
    logic [7:0] x;
    
    gather_weights_into_one_array uut(
        .clk_100mhz(clk),
        .start_gathering(btnc), //btnc
        .valid_input(input_ready), // bit true if valid, and only look at when new input comes in
        .x(x), // input to gather
        .weights(weights),
        .biases(biases),
        .output_ready(weights_biases_ready)
    );
   
   logic [7:0] x_in;
   assign x_in = 8'b0_0011_000;//8 bit input = 3
   logic [7:0] output_final;
   logic done;
    
   neural_network #(.WIDTH(8), .DECIMALS(3)) nn (
       .clk(clk),
       .rst(btnd), //randomly made this btnd the reset for now
       .ready(weights_biases_ready),
       .x_in(x_in),
       .weights(weights),
       .biases(biases),
       .output_final(output_final),
       .done(done)
    );
    
    always begin
        #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk = !clk;
    end

    //initial block...this is our test simulation
    initial begin
        clk = 0;
        btnc = 1;
        btnd = 1;
        #10
        btnc=0;
        btnd=0;
        #10
        // enter 15 weights and 7 biases

input_ready = 1;
x = 8'd249;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd5;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd252;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd254;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd252;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd253;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd0;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd252;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd7;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd5;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd255;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd3;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd253;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd248;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd250;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd255;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd2;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd8;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd4;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd7;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd2;
#10
input_ready=0;
#10
input_ready = 1;
x = 8'd16;
#10
input_ready=0;
#10



        
        // see what 'done' is
        #100;
    
        $finish;
    end

endmodule
