`timescale 1ns / 1ps

module iris_nn #(parameter WIDTH = 8, DECIMALS = 3) (
   input clk,
   input rst,
   input logic ready,
   input logic [3:0] [WIDTH-1:0] x_in,
   input logic [29:0] [WIDTH-1:0] weights,
   input logic [8:0] [WIDTH-1:0] biases,
   output logic [2:0] [WIDTH-1:0] output_final,
   output logic done
);

// layer 1
localparam HIDDEN_LAYERS = 1;
localparam NEURONS_PER_LAYER = 3;
localparam LOG_LENGTH = 3;
localparam OUTPUT_NEURONS = 3;

// length = # of neurons in previous layer = 1
logic [LOG_LENGTH-1:0] lengths[HIDDEN_LAYERS+1:0];
assign lengths = {3'b011, 3'b011, 3'b100};

// layer i, neuron j, field k
logic [NEURONS_PER_LAYER-1:0] [3:0][WIDTH-1:0] nn_weights_0;
logic [NEURONS_PER_LAYER-1:0] [NEURONS_PER_LAYER-1:0][WIDTH-1:0] nn_weights [HIDDEN_LAYERS+1:0];
// first layer weights 3x4
assign nn_weights_0[0][3:0] = weights[3:0]; 
assign nn_weights_0[1][3:0] = weights[7:4];
assign nn_weights_0[2][3:0] = weights[11:8];

// hidden layer weights 3x3
assign nn_weights[1][0][2:0] = weights[14:12];
assign nn_weights[1][1][2:0] = weights[17:15];
assign nn_weights[1][2][2:0] = weights[20:18];

// last layer weights 3x1
assign nn_weights[2][0][2:0] = weights[23:21];
assign nn_weights[2][1][2:0] = weights[26:24];
assign nn_weights[2][2][2:0] = weights[29:27];

// layer i, neuron j
logic [NEURONS_PER_LAYER-1:0][WIDTH-1:0] nn_biases [HIDDEN_LAYERS+1:0];
assign nn_biases[0][2:0] = biases[2:0];
assign nn_biases[1][2:0] = biases[5:3];
assign nn_biases[2][2:0] = biases[8:6];

// outputs for each layer except last layer (which feeds to output of the module)
logic [NEURONS_PER_LAYER-1:0] [WIDTH-1:0] nn_pre_activations [HIDDEN_LAYERS+1:0];
logic [NEURONS_PER_LAYER-1:0] [WIDTH-1:0] nn_output [HIDDEN_LAYERS+1:0];

// layer i, neuron j is done
logic [NEURONS_PER_LAYER-1:0] nn_done [HIDDEN_LAYERS+1:0] ;

// previous neurons that feed to next neuron
logic [NEURONS_PER_LAYER-1:0] [WIDTH-1:0] nn_previous_neurons [HIDDEN_LAYERS+1:0];
assign nn_previous_neurons[1] = nn_output[0];
assign nn_previous_neurons[2] = nn_output[1];

// first layer
genvar i;
generate
    for (i=0; i<NEURONS_PER_LAYER; i=i+1) begin         
        neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS), 
                       .NUM_PREVIOUS_NEURONS(4), 
                       .LOG_LENGTH(3)) fc_initial (
            .clk(clk), .rst(rst), .ready(ready),
            .length(lengths[0]), 
            .weights(nn_weights_0[i]), .bias(nn_biases[0][i]), .previous_neurons(x_in),
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
                neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS), 
                               .NUM_PREVIOUS_NEURONS(NEURONS_PER_LAYER), 
                               .LOG_LENGTH(LOG_LENGTH)) fc_hidden (
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

generate
    for (i=0; i<OUTPUT_NEURONS; i=i+1) begin
        // final layer
        neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS), 
                               .NUM_PREVIOUS_NEURONS(NEURONS_PER_LAYER), 
                               .LOG_LENGTH(LOG_LENGTH)) fc_final (
            .clk(clk), .rst(rst), .ready(nn_done[HIDDEN_LAYERS][0] && nn_done[HIDDEN_LAYERS][1] && nn_done[HIDDEN_LAYERS][2]), // change this
            .length(lengths[HIDDEN_LAYERS+1]),
            .weights(nn_weights[HIDDEN_LAYERS+1][i]), 
            .bias(nn_biases[HIDDEN_LAYERS+1][i]), 
            .previous_neurons(nn_previous_neurons[HIDDEN_LAYERS+1]),
            .neuron_output(nn_pre_activations[HIDDEN_LAYERS+1][i]),
            .done(nn_done[HIDDEN_LAYERS+1][i])
        );
        assign nn_output[HIDDEN_LAYERS+1][i] = nn_pre_activations[HIDDEN_LAYERS+1][i];

     end
endgenerate

assign output_final = nn_output[HIDDEN_LAYERS+1];
assign done = nn_done[HIDDEN_LAYERS+1][0] && nn_done[HIDDEN_LAYERS+1][1] && nn_done[HIDDEN_LAYERS+1][2];

endmodule
