`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module iris_nn_tb;
    parameter WIDTH = 8;
    parameter DECIMALS = 3;
    
    logic clk;
    logic rst;
    logic ready;
    logic [3:0] [WIDTH-1:0] x_in;
    logic [29:0] [WIDTH-1:0] weights;
    logic [8:0] [WIDTH-1:0] biases;
    logic [2:0] [WIDTH-1:0] output_final;
    iris_nn #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) uut (
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
        x_in[0] = 8'b00101001;
        x_in[1] = 8'b00011100;
        x_in[2] = 8'b00001011;
        x_in[3] = 8'b00000010;
        weights[0] = 8'b11111101;
        weights[1] = 8'b00000011;
        weights[2] = 8'b11111110;
        weights[3] = 8'b100000000;
        weights[4] = 8'b00000011;
        weights[5] = 8'b00000111;
        weights[6] = 8'b11111000;
        weights[7] = 8'b11111001;
        weights[8] = 8'b11111110;
        weights[9] = 8'b11111101;
        weights[10] = 8'b11111101;
        weights[11] = 8'b00000010;
        weights[12] = 8'b00000100;
        weights[13] = 8'b00001100;
        weights[14] = 8'b00000010;
        weights[15] = 8'b11111101;
        weights[16] = 8'b11111100;
        weights[17] = 8'b11111101;
        weights[18] = 8'b00000011;
        weights[19] = 8'b00000010;
        weights[20] = 8'b00000100;
        weights[21] = 8'b00001001;
        weights[22] = 8'b11110001;
        weights[23] = 8'b00000010;
        weights[24] = 8'b11111011;
        weights[25] = 8'b00000100;
        weights[26] = 8'b00000010;
        weights[27] = 8'b11111100;
        weights[28] = 8'b00000010;
        weights[29] = 8'b11111101;
        biases[0] = 8'b00000010;
        biases[1] = 8'b00000011;
        biases[2] = 8'b11111111;
        biases[3] = 8'b100000000;
        biases[4] = 8'b00001111;
        biases[5] = 8'b00000000;
        biases[6] = 8'b11111010;
        biases[7] = 8'b00000110;
        biases[8] = 8'b00000011;
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
