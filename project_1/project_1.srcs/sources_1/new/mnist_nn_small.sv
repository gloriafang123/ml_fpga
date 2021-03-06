`timescale 1ns / 1ps

module mnist_nn_small #(parameter WIDTH = 16, DECIMALS = 4) (
   input clk,
   input rst,
   input logic ready,
   input logic [99:0] [WIDTH-1:0] x_in,
   input logic [869:0] [WIDTH-1:0] weights,
   input logic [26:0] [WIDTH-1:0] biases,
   output logic [9:0] [WIDTH-1:0] output_final,
   output logic done
);

localparam HIDDEN_LAYERS = 2; // number of hidden layers
localparam NEURONS_LAYER_1 = 7; // neurons in hidden layer 1
localparam NEURONS_PER_LAYER = 10; // neurons in each hidden layer after that
localparam MAX_LOG_LENGTH = 10; // maximum log(# of neurons in one layer)
localparam OUTPUT_NEURONS = 10; // number of output neurons

// lengths[i] = # of neurons in layer i-1
logic [MAX_LOG_LENGTH-1:0] lengths[HIDDEN_LAYERS:0];
assign lengths = {10'b000_000_1010, 10'b000_000_0111, 10'b000_110_0100}; // 10 7 100

// first layer weights, neuron j connection k
logic [NEURONS_LAYER_1-1:0][99:0][WIDTH-1:0] nn_weights_0;

// layer i, neuron j, connection to previous layer k
logic [NEURONS_PER_LAYER-1:0][NEURONS_PER_LAYER-1:0][WIDTH-1:0] nn_weights [HIDDEN_LAYERS:0];

// layer i, neuron j biases
logic [NEURONS_PER_LAYER-1:0][WIDTH-1:0] nn_biases [HIDDEN_LAYERS:0];

// unpack the weights into nn_weights
genvar a;
generate
    for (a = 0; a < 7; a = a + 1) begin
        assign nn_weights_0[a][99:0] = weights[100*(a+1)-1:100*a]; 
    end
endgenerate

generate
    for (a = 0; a < 10; a = a + 1) begin
        assign nn_weights[1][a][9:0] = weights[700+(a+1)*7-1:700+a*7];
    end
endgenerate

generate
    for (a = 0; a < 10; a = a + 1) begin
        assign nn_weights[2][a][9:0] = weights[770+(a+1)*10-1:770+a*10];
    end
endgenerate

// unpack the biases into nn_biases
assign nn_biases[0][6:0] = biases[6:0];
assign nn_biases[1][9:0] = biases[16:7];
assign nn_biases[2][9:0] = biases[26:17];

// pre-activation output for each layer except last layer (which feeds to output of the module)
logic [NEURONS_PER_LAYER-1:0] [WIDTH-1:0] nn_pre_activations [HIDDEN_LAYERS:0];

// post-activation output for each layer
logic [NEURONS_PER_LAYER-1:0] [WIDTH-1:0] nn_output [HIDDEN_LAYERS:0];

// whether a neuron is done computing (so it can send a signal for the next layer to start)
logic [NEURONS_PER_LAYER-1:0] nn_done [HIDDEN_LAYERS:0] ;

// a neuron's previous neuron outputs, to feed into the neuron module
logic [NEURONS_PER_LAYER-1:0] [WIDTH-1:0] nn_previous_neurons [HIDDEN_LAYERS:0];
assign nn_previous_neurons[1] = nn_output[0];
assign nn_previous_neurons[2] = nn_output[1];

// first layer
genvar i;
generate
    for (i=0; i<NEURONS_LAYER_1; i=i+1) begin  
        // neuron component       
        neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS), 
                       .NUM_PREVIOUS_NEURONS(100), 
                       .LOG_LENGTH(10)) fc_initial (
            .clk(clk), 
            .rst(rst), 
            .ready(ready),
            .length(lengths[0]), 
            .weights(nn_weights_0[i]), 
            .bias(nn_biases[0][i]), 
            .previous_neurons(x_in),
            .neuron_output(nn_pre_activations[0][i]),
            .done(nn_done[0][i])
        );
        
        // activation function
        relu #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) relu_initial (
            .relu_in(nn_pre_activations[0][i]),
            .relu_out(nn_output[0][i])
        );
     end
endgenerate

// intermediate layers
generate
    for (i=0; i<10; i=i+1) begin
        neuron #(.WIDTH(WIDTH), .DECIMALS(DECIMALS), 
                 .NUM_PREVIOUS_NEURONS(10), 
                 .LOG_LENGTH(MAX_LOG_LENGTH)) fc_hidden (
        .clk(clk), 
        .rst(rst), 
        .ready(
            nn_done[0][0] && nn_done[0][1] && nn_done[0][2] &&
            nn_done[0][3] && nn_done[0][4] && nn_done[0][5] &&
            nn_done[0][6]
         ),
        .length(lengths[1]), 
        .weights(nn_weights[1][i]), 
        .bias(nn_biases[1][i]),
        .previous_neurons(nn_previous_neurons[1]),
        .neuron_output(nn_pre_activations[1][i]),
        .done(nn_done[1][i])
        );
        
        relu #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) relu_hidden (
            .relu_in(nn_pre_activations[1][i]), 
            .relu_out(nn_output[1][i])
        );
    end
endgenerate

// final layer
generate
    for (i=0; i<OUTPUT_NEURONS; i=i+1) begin
        // final layer
        neuron #(.WIDTH(WIDTH), 
                 .DECIMALS(DECIMALS), 
                 .NUM_PREVIOUS_NEURONS(NEURONS_PER_LAYER), 
                 .LOG_LENGTH(MAX_LOG_LENGTH)) fc_final
        (
            .clk(clk), 
            .rst(rst), 
            .ready(
                nn_done[HIDDEN_LAYERS-1][0] && nn_done[HIDDEN_LAYERS-1][1] && nn_done[HIDDEN_LAYERS-1][2] &&
                nn_done[HIDDEN_LAYERS-1][3] && nn_done[HIDDEN_LAYERS-1][4] && nn_done[HIDDEN_LAYERS-1][5] &&
                nn_done[HIDDEN_LAYERS-1][6] && nn_done[HIDDEN_LAYERS-1][7] && nn_done[HIDDEN_LAYERS-1][8] &&
                nn_done[HIDDEN_LAYERS-1][9]),
            .length(lengths[HIDDEN_LAYERS]),
            .weights(nn_weights[HIDDEN_LAYERS][i]), 
            .bias(nn_biases[HIDDEN_LAYERS][i]), 
            .previous_neurons(nn_previous_neurons[HIDDEN_LAYERS]),
            .neuron_output(nn_pre_activations[HIDDEN_LAYERS][i]),
            .done(nn_done[HIDDEN_LAYERS][i])
        );
        assign nn_output[HIDDEN_LAYERS][i] = nn_pre_activations[HIDDEN_LAYERS][i];
     end
endgenerate

// final output of whole network
assign output_final = nn_output[HIDDEN_LAYERS];

// neural network is done if last layer neurons are all done
assign done = nn_done[HIDDEN_LAYERS][0] && nn_done[HIDDEN_LAYERS][1] && nn_done[HIDDEN_LAYERS][2] &&
              nn_done[HIDDEN_LAYERS][3] && nn_done[HIDDEN_LAYERS][4] && nn_done[HIDDEN_LAYERS][5] &&
              nn_done[HIDDEN_LAYERS][6] && nn_done[HIDDEN_LAYERS][7] && nn_done[HIDDEN_LAYERS][8] &&
              nn_done[HIDDEN_LAYERS][9];

endmodule