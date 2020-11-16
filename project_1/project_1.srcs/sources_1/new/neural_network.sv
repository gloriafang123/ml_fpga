`timescale 1ns / 1ps

module neural_network #(parameter WIDTH = 8, DECIMALS = 3) (
   input clk,
   input rst,
   input logic ready,
   input logic [WIDTH-1:0] x_in,
   input logic [7:0] [WIDTH-1:0] weights,
   input logic [3:0] [WIDTH-1:0] biases,
   output logic [WIDTH-1:0] output_final,
   output logic done
);

// layer 1

// length = # of neurons in previous layer = 1
logic [1:0]            length_1;
assign length_1 = 2'b01;

logic [1:0] [1:0][WIDTH-1:0] weights_1;
assign weights_1[0][0] = weights[0];
assign weights_1[1][0] = weights[1];

logic [1:0][WIDTH-1:0] bias_1;
assign bias_1 = biases[1:0];

logic [1:0] [WIDTH-1:0] previous_neurons_1;
assign previous_neurons_1[0] = x_in;
assign previous_neurons_1[1] = x_in;

logic [1:0] [WIDTH-1:0] pre_activations_1;
logic [1:0] [WIDTH-1:0] output_1;

logic done_1[1:0];

neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) fc_11 (
    .clk(clk), .rst(rst), .ready(ready),
    .length(length_1), 
    .weights(weights_1[0]), .bias(bias_1[0]), .previous_neurons(previous_neurons_1),
    .neuron_output(pre_activations_1[0]),
    .done(done_1[0])
);

relu #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) relu_11 (
    .relu_in(pre_activations_1[0]), .relu_out(output_1[0])
);

neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) fc_12 (
    .clk(clk), .rst(rst), .ready(ready),
    .length(length_1), 
    .weights(weights_1[1]), .bias(bias_1[1]), .previous_neurons(previous_neurons_1),
    .neuron_output(pre_activations_1[1]),
    .done(done_1[1])
);

relu #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) relu_12 (
    .relu_in(pre_activations_1[1]), .relu_out(output_1[1])
);

// layer 2

logic [1:0]            length_2;
assign length_2 = 2'b10;

logic [1:0] [1:0][WIDTH-1:0] weights_2;
assign weights_2[0][1:0] = weights[3:2];
assign weights_2[1][1:0] = weights[5:4];

logic [1:0][WIDTH-1:0] bias_2;
assign bias_2[0] = biases[2];
assign bias_2[1] = biases[3];

logic [1:0] [WIDTH-1:0] previous_neurons_2;
assign previous_neurons_2 = output_1;

logic [1:0] [WIDTH-1:0] pre_activations_2;
logic [1:0] [WIDTH-1:0] output_2;

logic done_2[1:0];

neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) fc_21 (
    .clk(clk), .rst(rst), .ready(done_1[0] && done_1[1]),
    .length(length_2), 
    .weights(weights_2[0]), .bias(bias_2[0]), .previous_neurons(previous_neurons_2),
    .neuron_output(pre_activations_2[0]),
    .done(done_2[0])
);

relu #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) relu_21 (
    .relu_in(pre_activations_2[0]), .relu_out(output_2[0])
);

neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) fc_22 (
    .clk(clk), .rst(rst), .ready(done_1[0] && done_1[1]),
    .length(length_2), 
    .weights(weights_2[1]), .bias(bias_2[1]), .previous_neurons(previous_neurons_2),
    .neuron_output(pre_activations_2[1]),
    .done(done_2[1])
);

relu #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) relu_22 (
    .relu_in(pre_activations_2[1]), .relu_out(output_2[1])
);

// final layer
logic [1:0]            length_final;
logic [1:0] [WIDTH-1:0] weights_final;
logic [WIDTH-1:0] bias_final;
logic [1:0] [WIDTH-1:0] previous_neurons_final ;

assign length_final = 2'b10;
assign weights_final[1:0] = weights[7:6];
assign bias_final = 0; // no bias for final layer
assign previous_neurons_final[1] = output_2[1];
assign previous_neurons_final[0] = output_2[0];

neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) fc_final (
    .clk(clk),
    .rst(rst),
    .ready(done_2[0] && done_2[1]),
    .length(length_final),
    .weights(weights_final),
    .bias(bias_final),
    .previous_neurons(previous_neurons_final),
    .neuron_output(output_final),
    .done(done)
);

endmodule
