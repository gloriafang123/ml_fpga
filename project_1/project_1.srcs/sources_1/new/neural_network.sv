`timescale 1ns / 1ps

// 3 layer identity
// 3 x 1, 3 x 1
// 3 x 3, 3 x 1
// 3 x 1, 1 x 1

//fc1.weight 	 
// tensor([[-0.8666],
//             [ 0.6558],
//             [-0.5218]])

// fc1.bias 	 tensor([-0.1178,  0.1937,  0.9878])

//fc2.weight 	 
// tensor([[-0.2823, -0.4885, -0.3291],
//             [ 0.0103, -0.5161,  0.8364],
//             [ 0.6439, -0.1529,  0.3964]])

//fc2.bias 	 tensor([0.5107, 0.8385, 0.2501])

//fc3.weight 	 tensor([[-0.3267, -0.9650, -0.7214]])

//fc3.bias 	 tensor([1.9906])

module neural_network #(parameter WIDTH = 8, DECIMALS = 3) (
   input clk,
   input rst,
   input logic ready,
   input logic [WIDTH-1:0] x_in,
   input logic [14:0] [WIDTH-1:0] weights,
   input logic [6:0] [WIDTH-1:0] biases,
   output logic [WIDTH-1:0] output_final,
   output logic done
);

// layer 1
localparam HIDDEN_LAYERS = 1;
localparam NEURONS_PER_LAYER = 3;

// length = # of neurons in previous layer = 1
logic [1:0] lengths[HIDDEN_LAYERS+1:0];
assign lengths = {2'b11, 2'b11, 2'b01};

// layer i, neuron j, field k
logic [NEURONS_PER_LAYER-1:0] [NEURONS_PER_LAYER-1:0][WIDTH-1:0] nn_weights [HIDDEN_LAYERS+1:0];
// first layer weights only 3x1
assign nn_weights[0][0][0] = weights[0]; 
assign nn_weights[0][1][0] = weights[1];
assign nn_weights[0][2][0] = weights[2];

// hidden layer weights 3x3
assign nn_weights[1][0][2:0] = weights[5:3];
assign nn_weights[1][1][2:0] = weights[8:6];
assign nn_weights[1][2][2:0] = weights[11:9];

// last layer weights 3x1
assign nn_weights[2][0][2:0] = weights[14:12];

// layer i, neuron j
logic [NEURONS_PER_LAYER-1:0][WIDTH-1:0] nn_biases [HIDDEN_LAYERS+1:0];
assign nn_biases[0][2:0] = biases[2:0];
assign nn_biases[1][2:0] = biases[5:3];
assign nn_biases[2][0] = biases[6];

// outputs for each layer except last layer (which feeds to output of the module)
logic [NEURONS_PER_LAYER-1:0] [WIDTH-1:0] nn_pre_activations [HIDDEN_LAYERS+1:0];
logic [NEURONS_PER_LAYER-1:0] [WIDTH-1:0] nn_output [HIDDEN_LAYERS+1:0];

// layer i, neuron j is done
logic [NEURONS_PER_LAYER-1:0] nn_done [HIDDEN_LAYERS+1:0] ;

// previous neurons that feed to next neuron
logic [NEURONS_PER_LAYER-1:0] [WIDTH-1:0] nn_previous_neurons [HIDDEN_LAYERS+1:0];
assign nn_previous_neurons[0][0] = x_in; 
assign nn_previous_neurons[1] = nn_output[0];
assign nn_previous_neurons[2] = nn_output[1];

// first layer
genvar i;
generate
    for (i=0; i<NEURONS_PER_LAYER; i=i+1) begin         
        neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) fc_initial (
            .clk(clk), .rst(rst), .ready(ready),
            .length(lengths[0]), 
            .weights(nn_weights[0][i]), .bias(nn_biases[0][i]), .previous_neurons(nn_previous_neurons[0]),
            .neuron_output(nn_pre_activations[0][i]),
            .done(nn_done[0][i])
        );
        
        relu #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) relu_initial (
            .relu_in(nn_pre_activations[0][i]), .relu_out(nn_output[0][i])
        );
     end
endgenerate

// intermediate layers
genvar j;
generate
    for (j=1; j<1+HIDDEN_LAYERS; j=j+1) begin
        for (i=0; i<NEURONS_PER_LAYER; i=i+1) begin
            neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) fc_hidden (
                .clk(clk), .rst(rst), .ready(nn_done[j-1][0] && nn_done[j-1][1] && nn_done[j-1][2]), // remember to change this
                .length(lengths[j]), 
                .weights(nn_weights[j][i]), .bias(nn_biases[j][i]), .previous_neurons(nn_previous_neurons[j]),
                .neuron_output(nn_pre_activations[j][i]),
                .done(nn_done[j][i])
            );
            relu #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) relu_hidden (
                .relu_in(nn_pre_activations[j][i]), .relu_out(nn_output[j][i])
            );
         end
      end
endgenerate

// final layer
neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) fc_final (
    .clk(clk), .rst(rst), .ready(nn_done[HIDDEN_LAYERS][0] && nn_done[HIDDEN_LAYERS][1] && nn_done[HIDDEN_LAYERS][2]), // change this
    .length(lengths[HIDDEN_LAYERS+1]),
    .weights(nn_weights[HIDDEN_LAYERS+1][0]), 
    .bias(nn_biases[HIDDEN_LAYERS+1][0]), 
    .previous_neurons(nn_previous_neurons[HIDDEN_LAYERS+1]),
    .neuron_output(nn_pre_activations[HIDDEN_LAYERS+1][0]),
    .done(nn_done[HIDDEN_LAYERS+1][0])
);

assign nn_output[HIDDEN_LAYERS+1][0] = nn_pre_activations[HIDDEN_LAYERS+1][0];
assign output_final = nn_output[HIDDEN_LAYERS+1][0];
assign done = nn_done[HIDDEN_LAYERS+1][0];

endmodule
