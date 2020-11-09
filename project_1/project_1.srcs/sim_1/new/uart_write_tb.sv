`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module uart_write_tb;

    logic clk; // not clocked purely combinational
    logic rst;
    logic [7:0] value;
    logic input_ready;
    logic data_out;
    // this nn_sim is working as expected
    nn_output_simulator #(.COMPUTE_CYCLES(22)) nn_sim ( 
        // this needs to be > 10*serial_tx cycle + 1 so that the output sees the 1
        // can pyserial detect if it goes low at any point? will all the future reads be skewed relative
            // to first point it goes low?
        .clk_in(clk),
        .rst_in(rst),
        .value(value),
        .output_ready(input_ready)
    );
    
    serial_tx #(.DIVISOR(2)) my_tx(.clk_in(clk), 
                    .rst_in(rst), 
                    .input_ready(input_ready),
                    .val_in(value), // this is the one we care about
                    .data_out(data_out));
    always begin
        #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk = !clk;
    end

    //initial block...this is our test simulation
    initial begin
        clk = 0;
        rst = 1;
        #10
        rst = 0;
        #100;
    
        $finish;
    end
endmodule
