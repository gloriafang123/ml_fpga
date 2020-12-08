`timescale 1ns / 1ps

// this top level simulates a fake nn
// that continuously outputs a counter
// and writes to ja[0].
// currently works: we load the arduino with the 
// serial reader,
// and python gets the correct decimal values!
module top_level(   input               clk_100mhz,
                    input [15:0]        sw,
                    input               btnc,
                    input               btnd,
                    //output logic [15:0] led,
                    output logic [1:0]  ja
    );
    
    logic               clean;
    logic               old_clean;
    //assign led = sw;
    assign ja[1] = 0; //just assign this to be 0
    
    logic input_ready;
    
    always_ff @(posedge clk_100mhz)begin
        old_clean <= clean;  //for rising edge detection
    end
    
    logic [7:0] value;
    
    nn_output_simulator nn(
        .clk_in (clk_100mhz),
        .rst_in (btnd),
        .value(value),
        .output_ready(input_ready)
    );
    
    serial_tx my_tx(.clk_in(clk_100mhz), 
                    .rst_in(btnd), 
                    .input_ready(input_ready),
                    .val_in(value), // this is the one we care about
                    .data_out(ja[0]));
endmodule//top_level

module nn_output_simulator(
    input clk_in,
    input rst_in,
    output logic [7:0] value,
    output logic output_ready
    );
    // one problem is outputting faster than I can write serial.
    // what's the best way to solve this?
    parameter COMPUTE_CYCLES = 868*11; //DIVISOR from serial_tx module * (10+1)
    logic [14:0] count;
    always @(posedge clk_in) begin
        if (rst_in) begin
            count <= 0;
            output_ready <= 0;
            value <= 0;
        end
        else begin
            output_ready <= 0;
            count <= (count + 1);
            if (count + 1 == COMPUTE_CYCLES) begin
                count <= 0;
                output_ready <= 1;
                value <= value + 1;
            end
        end
    end
endmodule

// 8 sw switches, specifies ascii and transmits over ja[0]
// DIVISOR is clk rate/baud rate 115200
// serial_tx reads from nn, writes to the output data_out ja[0] > microcontroller
module serial_tx(   input           clk_in,
                    input           rst_in,
                    input           input_ready,
                    input [7:0]     val_in,
                    output logic    data_out);
    parameter   DIVISOR = 868;// 
    
    logic [9:0]         shift_buffer; //10 bits...interesting
    logic [31:0]        count = 0;    
    assign data_out = shift_buffer[0];
    /*
    use a counter to go up to 868
    use another counter to pick the bit in shift buffer to send
    whenever reset is clicked, set both counters to 0
    when trigger is sent, start counting down bit counter until it goes to zero
        > so the bit counter is always decreasing and when at 0 it does nothing
    */

    always @(posedge clk_in)begin
        if (rst_in) begin
            shift_buffer [9:0] <= 10'b11_1111_1111;
            count <= 0;
        end
        else begin
            count <= (count + 1);
            if (count + 1 == DIVISOR) begin
                count <= 0;
            end
                 
            //data_out<=shift_buffer[0];
            if (count == 0) begin
                shift_buffer [9:0] <= {1'b1, shift_buffer[9:1]}; // always shifting 1's
            end
            
            if (input_ready) begin
                    shift_buffer [9:0] <= {1'b1, val_in[7:0], 1'b0};
                    count <= 1; // using 1 will make it immediately shift the next round, so the start bit isn't 0 enough
            end   
        end
     
    end              
endmodule