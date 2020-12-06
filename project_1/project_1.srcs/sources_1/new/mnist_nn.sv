`timescale 1ns / 1ps

module mnist_nn #(parameter WIDTH = 16, DECIMALS = 4) (
   input clk,
   input rst,
   input logic ready,
   input logic [783:0] [WIDTH-1:0] x_in,
   input logic [8039:0] [WIDTH-1:0] weights,
   input logic [29:0] [WIDTH-1:0] biases,
   output logic [9:0] [WIDTH-1:0] output_final,
   output logic done
);

// layer 1
localparam HIDDEN_LAYERS = 1;
localparam NEURONS_PER_LAYER = 10;
localparam LOG_LENGTH = 10;
localparam OUTPUT_NEURONS = 10;

// length = # of neurons in previous layer = 1
logic [LOG_LENGTH-1:0] lengths[HIDDEN_LAYERS+1:0];
assign lengths = {10'b00000_01010, 10'b0000001010, 10'b11000_10000};

// layer i, neuron j, field k
logic [NEURONS_PER_LAYER-1:0] [783:0][WIDTH-1:0] nn_weights_0;
logic [NEURONS_PER_LAYER-1:0] [NEURONS_PER_LAYER-1:0][WIDTH-1:0] nn_weights [HIDDEN_LAYERS+1:0];

genvar a;
generate
    for (a = 0; a < 10; a = a + 1) begin
        assign nn_weights_0[a][783:0] = weights[784*(a+1)-1:784*a]; 
    end
endgenerate


generate
    for (a = 0; a < 10; a = a + 1) begin
        assign nn_weights[1][a][9:0] = weights[7840+(a+1)*10-1:7840+a*10];
    end
endgenerate

generate
    for (a = 0; a < 10; a = a + 1) begin
        assign nn_weights[2][a][9:0] = weights[7940+(a+1)*10-1:7940+a*10];
    end
endgenerate

// layer i, neuron j
logic [NEURONS_PER_LAYER-1:0][WIDTH-1:0] nn_biases [HIDDEN_LAYERS+1:0];
assign nn_biases[0][9:0] = biases[9:0];
assign nn_biases[1][9:0] = biases[19:10];
assign nn_biases[2][9:0] = biases[29:20];

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
                       .NEURONS_PER_LAYER(784), 
                       .LOG_LENGTH(10)) fc_initial (
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
                               .NEURONS_PER_LAYER(NEURONS_PER_LAYER), 
                               .LOG_LENGTH(LOG_LENGTH)) fc_hidden (
                .clk(clk), .rst(rst), 
                .ready(
                    nn_done[j-1][0] && nn_done[j-1][1] && nn_done[j-1][2] &&
                    nn_done[j-1][3] && nn_done[j-1][4] && nn_done[j-1][5] &&
                    nn_done[j-1][6] && nn_done[j-1][7] && nn_done[j-1][8] &&
                    nn_done[j-1][9]
                 ),
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
        neuron #(.WIDTH(WIDTH), 
                 .DECIMALS(DECIMALS), 
                 .NEURONS_PER_LAYER(NEURONS_PER_LAYER), 
                 .LOG_LENGTH(LOG_LENGTH)) fc_final 
        (
            .clk(clk), 
            .rst(rst), 
            .ready(
                nn_done[HIDDEN_LAYERS][0] && nn_done[HIDDEN_LAYERS][1] && nn_done[HIDDEN_LAYERS][2] &&
                nn_done[HIDDEN_LAYERS][3] && nn_done[HIDDEN_LAYERS][4] && nn_done[HIDDEN_LAYERS][5] &&
                nn_done[HIDDEN_LAYERS][6] && nn_done[HIDDEN_LAYERS][7] && nn_done[HIDDEN_LAYERS][8] &&
                nn_done[HIDDEN_LAYERS][9]),
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
assign done = nn_done[HIDDEN_LAYERS+1][0] && nn_done[HIDDEN_LAYERS+1][1] && nn_done[HIDDEN_LAYERS+1][2] &&
              nn_done[HIDDEN_LAYERS+1][3] && nn_done[HIDDEN_LAYERS+1][4] && nn_done[HIDDEN_LAYERS+1][5] &&
              nn_done[HIDDEN_LAYERS+1][6] && nn_done[HIDDEN_LAYERS+1][7] && nn_done[HIDDEN_LAYERS+1][8] &&
              nn_done[HIDDEN_LAYERS+1][9];

endmodule
