`timescale 1ns / 1ps

module neural_network #(parameter WIDTH = 8, DECIMALS = 3) (
   input clk,
   input rst,
   input logic ready,
   input logic [WIDTH-1:0] x_in,
   input logic [WIDTH-1:0] weights[7:0],
   input logic [WIDTH-1:0] biases[3:0],
   output logic [WIDTH-1:0] output_final,
   output logic done
);

// layer 1 neuron 1
logic [1:0]            length_11;
logic [WIDTH-1:0] weights_11[1:0];
logic [WIDTH-1:0] bias_11;
logic [WIDTH-1:0] previous_neurons_11 [1:0];
logic [WIDTH-1:0] pre_activations_11;
logic [WIDTH-1:0] output_11;
logic done_11;

assign length_11 = 2'b01;
assign weights_11[0] = weights[0];
assign bias_11 = biases[0];
assign previous_neurons_11[0] = x_in;

neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) fc_11 (
    .clk(clk),
    .rst(rst),
    .ready(ready),
    .length(length_11), // only 1 previous neuron
    .weights(weights_11),
    .bias(bias_11),
    .previous_neurons(previous_neurons_11),
    .neuron_output(pre_activations_11),
    .done(done_11)
);

relu #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) relu_11 (
    .relu_in(pre_activations_11),
    .relu_out(output_11)
);

// layer 1 neuron 2
logic [1:0]            length_12;
logic [WIDTH-1:0] weights_12[1:0];
logic [WIDTH-1:0] bias_12;
logic [WIDTH-1:0] previous_neurons_12 [1:0];
logic [WIDTH-1:0] pre_activations_12;
logic [WIDTH-1:0] output_12;
logic done_12;
assign length_12 = 2'b01;
assign weights_12[0] = weights[1];
assign bias_12 = biases[1];
assign previous_neurons_12[0] = x_in;

neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) fc_12 (
    .clk(clk),
    .rst(rst),
    .ready(ready),
    .length(length_12), // only 1 previous neuron
    .weights(weights_12),
    .bias(bias_12),
    .previous_neurons(previous_neurons_12),
    .neuron_output(pre_activations_12),
    .done(done_12)
);

relu #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) relu_12 (
    .relu_in(pre_activations_12),
    .relu_out(output_12)
);

// layer 2 neuron 1
logic [1:0]            length_21;
logic [WIDTH-1:0] weights_21[1:0];
logic [WIDTH-1:0] bias_21;
logic [WIDTH-1:0] previous_neurons_21 [1:0];
logic [WIDTH-1:0] pre_activations_21;
logic [WIDTH-1:0] output_21;
logic done_21;
assign length_21 = 2'b10;
assign weights_21[1:0] = weights[3:2];
assign bias_21 = biases[2];
assign previous_neurons_21[1] = output_12;
assign previous_neurons_21[0] = output_11;

neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) fc_21 (
    .clk(clk),
    .rst(rst),
    .ready(done_11 & done_12), // watch out if previous layers are not identical
    .length(length_21),
    .weights(weights_21),
    .bias(bias_21),
    .previous_neurons(previous_neurons_21),
    .neuron_output(pre_activations_21),
    .done(done_21)
);

relu #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) relu_21 (
    .relu_in(pre_activations_21),
    .relu_out(output_21)
);

// layer 2 neuron 2
logic [1:0]            length_22;
logic [WIDTH-1:0] weights_22[1:0];
logic [WIDTH-1:0] bias_22;
logic [WIDTH-1:0] previous_neurons_22 [1:0];
logic [WIDTH-1:0] pre_activations_22;
logic [WIDTH-1:0] output_22;
logic done_22;

assign length_22 = 2'b10;
assign weights_22[1:0] = weights[5:4];
assign bias_22 = biases[3];
assign previous_neurons_22[1] = output_12;
assign previous_neurons_22[0] = output_11;

neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) fc_22 (
    .clk(clk),
    .rst(rst),
    .ready(done_11 & done_12), // watch out if previous layers aren't identical
    .length(length_22),
    .weights(weights_22),
    .bias(bias_22),
    .previous_neurons(previous_neurons_22),
    .neuron_output(pre_activations_22),
    .done(done_22)
);

relu #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) relu_22 (
    .relu_in(pre_activations_22),
    .relu_out(output_22)
);

// final layer
logic [1:0]            length_final;
logic [WIDTH-1:0] weights_final[1:0];
logic [WIDTH-1:0] bias_final;
logic [WIDTH-1:0] previous_neurons_final [1:0];

assign length_final = 2'b10;
assign weights_final[1:0] = weights[7:6];
assign bias_final = 0; // no bias for final layer
assign previous_neurons_final[1] = output_22;
assign previous_neurons_final[0] = output_21;

neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) fc_final (
    .clk(clk),
    .rst(rst),
    .ready(done_21 & done_22),
    .length(length_final),
    .weights(weights_final),
    .bias(bias_final),
    .previous_neurons(previous_neurons_final),
    .neuron_output(output_final),
    .done(done)
);

endmodule
