`timescale 1ns / 1ps

/*
combinational multiplier that takes inputs of WIDTH, with
DECIMALS digits after decimal
*/
module multiplier #(parameter WIDTH = 8, DECIMALS = 3) (
    input [WIDTH-1:0] x,
    input [WIDTH-1:0] y,
    output [WIDTH-1:0] product
);
    logic [2*WIDTH - 1:0] tmp_product;
    assign tmp_product = {{WIDTH{x[WIDTH-1]}}, x}*{{WIDTH{y[WIDTH-1]}}, y};
    assign product = tmp_product [DECIMALS + WIDTH - 1:DECIMALS];
    
endmodule



