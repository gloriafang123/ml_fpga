`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module neuron_tb;
    parameter WIDTH = 8;
    parameter DECIMALS = 3;
    
    logic clk;
    logic rst;
    logic ready;
    logic [1:0] length;
    logic [WIDTH-1:0] weights[1:0];
    logic [WIDTH-1:0] bias;
    logic [WIDTH-1:0] previous_neurons [1:0];
    logic [WIDTH-1:0] neuron_output;
    logic done;
    
    neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) uut (
        .clk(clk),
        .rst(rst),
        .ready(ready),
        .length(length),
        .weights(weights),
        .bias(bias),
        .previous_neurons(previous_neurons),
        .neuron_output(neuron_output),
        .done(done)    
    );
    
    always begin
        #5;  // 100 MHz clock
        clk = !clk;
    end

    initial begin
        clk = 0;
        rst = 0;
        length = 2;
        bias = 8'b0;
        weights[1] = 8'b0_0010_000;
        weights[0] = 8'b0_0010_000;
        previous_neurons[1] = 8'b0_0010_000;
        previous_neurons[0] = 8'b0_0101_000;
        #10;
        rst = 1;
        ready = 1;
        #10;
        rst = 0;
        ready = 0;
        #10;
        #100;
        assert (neuron_output == 8'b0_1110_000) else $error("fc network failed to multiply :(");
        // TODO(test decimals, handle overflows)
        $finish;
    end
endmodule
