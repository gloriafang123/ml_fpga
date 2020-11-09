`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module relu_tb;
    parameter WIDTH = 8;
    parameter DECIMALS = 3;
    logic [WIDTH-1:0] x;
    logic [WIDTH-1:0] y;
    logic clk;

    relu #(.WIDTH(WIDTH), .DECIMALS(DECIMALS)) uut (
        .relu_in(x),
        .relu_out(y)
    );
    
    always begin
        #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk = !clk;
    end

    //initial block...this is our test simulation
    initial begin
        clk = 0;
        x = 8'b00001000; // relu(+1) = +1
        #10
        assert (y == 8'b00001000) else $error("relu failed");

        x = 8'b10001000; // relu(-1) = -1
        #10
        assert (y == 8'b00000000) else $error("relu failed");

        x = 8'b10001100; // relu(-1.5) = 0
        #10
        assert (y == 8'b00000000) else $error("relu failed");

        $finish;
    end
endmodule
