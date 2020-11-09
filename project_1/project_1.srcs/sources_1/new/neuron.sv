`timescale 1ns / 1ps

module neuron #(parameter WIDTH = 8, DECIMALS = 3) (
    input clk,
    input rst,
    input logic ready,
    input logic [1:0] length, // shape of the weight matrix
    input logic [WIDTH-1:0] weights[1:0], // w[i], TODO(parametrize)
    input logic [WIDTH-1:0] bias, // b
    input logic [WIDTH-1:0] previous_neurons [1:0], // x[i], TODO(parametrize)
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
    
    logic [1:0] i; // TODO: parametrize
    always_ff @(posedge clk) begin
        if (rst || ready) begin 
            neuron_output <= bias; // start at bias, and add weights one by one
            done <= 0;
            i <= 1;
            w_i <= weights[0];
            x_i <= previous_neurons[0];
        end
        else if (i < length) begin // at step i, add w[i-1] * x[i-1] to the product
            w_i <= weights[i];
            x_i <= previous_neurons[i];
            neuron_output <= neuron_output + product_i;
            i <= i+1;
        end
        else if (i == length) begin // do the final computation and assert done
            neuron_output <= neuron_output + product_i;
            i <= i+1;
            done <= 1;
        end
        else if (i == length + 1) begin // set done back to 0
            done <= 0;
        end
    end

endmodule
