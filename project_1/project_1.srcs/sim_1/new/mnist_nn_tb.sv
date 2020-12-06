`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module mnist_nn_tb;
    parameter WIDTH = 16;
    parameter DECIMALS = 4;
    
    logic clk;
    logic rst;
    logic ready;
    logic [783:0] [WIDTH-1:0] x_in;
    logic [8039:0] [WIDTH-1:0] weights;
    logic [29:0] [WIDTH-1:0] biases;
    logic [9:0] [WIDTH-1:0] output_final;
    mnist_nn #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) uut (
        .clk(clk),
        .rst(rst),
        .ready(ready),
        .x_in(x_in),
        .weights(weights),
        .biases(biases),
        .output_final(output_final)
    );
    
    always begin
        #5;  // 100 MHz clock
        clk = !clk;
    end

    initial begin
        clk = 0;
        rst = 0;
        ready = 0;
        for (int i = 0; i < 784; i++) x_in[i] = 0;
        for (int i = 0; i < 8040; i++) weights[i] = 0;
        for (int i = 0; i < 30; i++) biases[i] = 0;
        #10;
        rst = 1;
        #10;
        rst = 0;
        ready = 1;
        #10
        ready = 0;
        #10;
        #1000;
        $finish;
    end
endmodule
