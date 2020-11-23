`timescale 1ns / 1ps

module neuron #(parameter WIDTH = 8, DECIMALS = 3, NEURONS_PER_LAYER = 3, LOG_LENGTH = 2) (
    input clk,
    input rst,
    input logic ready,
    input logic [LOG_LENGTH-1:0] length, // dimension of weight matrix
    input logic [NEURONS_PER_LAYER-1:0] [WIDTH-1:0] weights, // w[i], TODO(parametrize)
    input logic [WIDTH-1:0] bias, // b
    input logic [NEURONS_PER_LAYER-1:0] [WIDTH-1:0] previous_neurons, // x[i], TODO(parametrize)
    output logic done,
    output logic [WIDTH-1:0] neuron_output // sum of w[i] x[i] + b
);
    
    logic [WIDTH-1:0] w_i;
    logic [WIDTH-1:0] x_i;
    logic [WIDTH-1:0] product_i; // product holds w_i * x_i at each step
    multiplier #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) product_calculator (
        .x(x_i),
        .y(w_i),
        .product(product_i)
    );
    
    logic [10:0] i; // TODO: parametrize
    logic counting; // whether or not module is counting
    always_ff @(posedge clk) begin
        if (rst) begin 
            counting <= 0;
        end
        if (ready) begin 
            counting <= 1;
        end
        
        if (rst || ready) begin 
            neuron_output <= bias; // start at bias, and add weights one by one
            done <= 0;
            i <= 1;
            w_i <= weights[0];
            x_i <= previous_neurons[0];
        end
        else if (counting && i < length) begin // at step i, add w[i-1] * x[i-1] to the product
            w_i <= weights[i];
            x_i <= previous_neurons[i];
            neuron_output <= neuron_output + product_i;
            i <= i+1;
        end
        else if (counting && i == length) begin // do the final computation and assert done
            neuron_output <= neuron_output + product_i;
            i <= i+1;
            done <= 1;
        end
        else if (counting && i == length + 1) begin // set done back to 0
            done <= 0;
            counting <= 0;
        end
    end

endmodule
