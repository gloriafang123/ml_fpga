`timescale 1ns / 1ps

module relu #(parameter WIDTH = 8, DECIMALS = 3) (
    input [WIDTH-1:0] relu_in,
    output [WIDTH-1:0] relu_out
);

// relu_out = max(relu_in, 0)
// if sign bit is off (positive), then relu_out = relu_in
// otherwise, 0
assign relu_out = (relu_in[WIDTH-1] == 0) ? relu_in : 0;

endmodule
