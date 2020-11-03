`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module multiply_tb;
    parameter WIDTH = 8;
    parameter DECIMALS = 3;
    logic [WIDTH-1:0] x;
    logic [WIDTH-1:0] y;
    logic [WIDTH-1:0] product;
    logic clk; // not clocked purely combinational
    
    multiplier #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) uut (
        .x(x),
        .y(y),
        .product(product)
    );
    
    always begin
        #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk = !clk;
    end

    //initial block...this is our test simulation
    initial begin
        clk = 0;
        x = 8'b00001000;
        y = 8'b00011000;
        #10
        assert (product == 8'b00011000) else $error("bad product");
        x = 8'b00000000;
        y = 8'b00011000;
        #10
        assert (product == 8'b00000000) else $error("bad product");
        x = 8'b00011000;
        y = 8'b11111000;
        #10
        assert (product == 8'b11101000) else $error("bad product");
    
    
        $finish;
    end
endmodule
