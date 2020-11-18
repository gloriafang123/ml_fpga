`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module neural_network_tb;
    parameter WIDTH = 8;
    parameter DECIMALS = 3;
    
    logic clk;
    logic rst;
    logic ready;
    logic [WIDTH-1:0] x_in;
    logic [14:0] [WIDTH-1:0] weights;
    logic [6:0] [WIDTH-1:0] biases;
    logic [WIDTH-1:0] output_final;
    neural_network #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) uut (
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
        x_in = 8'b0_0000_010;
        biases[0] = 8'b0_0001_000;
        biases[1] = 8'b0_0001_000;
        biases[2] = 8'b0_0001_000;
        biases[3] = 8'b0_0001_000;
        biases[4] = 8'b0_0001_000;
        biases[5] = 8'b0_0001_000;
        biases[6] = 8'b0_0001_000;
        weights[0] = 8'b0_0001_000;
        weights[1] = 8'b0_0001_000;
        weights[2] = 8'b0_0001_000;
        weights[3] = 8'b0_0001_000;
        weights[4] = 8'b0_0001_000;
        weights[5] = 8'b0_0001_000;
        weights[6] = 8'b0_0001_000;
        weights[7] = 8'b0_0001_000;
        weights[8] = 8'b0_0001_000;
        weights[9] = 8'b0_0001_000;
        weights[10] = 8'b0_0001_000;
        weights[11] = 8'b0_0001_000;
        weights[12] = 8'b0_0001_000;
        weights[13] = 8'b0_0001_000;
        weights[14] = 8'b0_0001_000;
        weights[15] = 8'b0_0001_000;
        #10;
        rst = 1;
        #10;
        rst = 0;
        ready = 1;
        #10
        ready = 0;
        #10;
        #1000;
        // TODO(test decimals, handle overflows)
        $finish;
    end
endmodule
