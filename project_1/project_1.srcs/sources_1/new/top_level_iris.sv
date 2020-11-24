`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module top_level_read_in(   
                    input               clk_100mhz,
                    input [15:0]        sw,
                    input [3:0]         jb,
                    output [1:0]        ja,
                    input               btnc,
                    input               btnd,
                    input    btnu,
                    output logic ca, cb, cc, cd, ce, cf, cg, dp,  // segments a-g, dp
                    output logic[7:0] an,    // Display location 0-7
                    output logic [15:0] led
    );
    parameter NUM_WEIGHTS = 30;
    parameter NUM_BIASES = 9;
    // set up the sampling clock
    logic enable;
    sample_data_clk data_clk(
        .clk_100mhz(clk_100mhz),
        .reset(btnd),
        .enable(enable)
    );
    
    // set up fsm that is always grabbing input from computer
    logic output_ready;
    logic [29:0] output_bits;
    parameter COUNTER_2MS_MAX = 308;// default
    sample_data_fsm #(.COUNTER_2MS_MAX()) data_fsm(
        .clk_100mhz(clk_100mhz),
        .enable(enable), // data sample rate
        .jb_data(jb[0]), // the 16x sampled jb data
        .reset(btnd),
        .valid_data(output_ready), //output ready, give 60 sample
        .z_y_x_hold_output(output_bits)
    );
    
    // get the latest number from computer and put it into x
    logic[7:0] x;
    logic valid_x; // not necessarily a pulse
    process_60_bits processor(
        .z_y_x(output_bits),
        .valid_input(output_ready), // 1 if data from previous stage ready to be read
        .clk_100mhz(clk_100mhz),
        .valid_data(valid_x), // 1 if data ready to be read for next stage
        .x(x)
    );
    // x is the bytes
    
    // read the stuff currently being sent into weights and biases arrays
    logic weights_biases_ready;
    logic [NUM_WEIGHTS-1:0] [7:0] weights ;
    logic [NUM_BIASES-1:0] [7:0] biases ;
    // new module that gathers the next 15+7 = 22 bits and saves those as weights/biases
    // starts gathering when we press C
    gather_weights_into_one_array #(.NUM_WEIGHTS(30), .NUM_BIASES(9)) gather_w_b (
        .clk_100mhz(clk_100mhz),
        .start_gathering(btnc), //btnc
        .valid_input(valid_x & output_ready), // bit true if valid, and only look at when new input comes in
        .x(x), // input to gather
        .weights(weights),
        .biases(biases),
        .output_ready(weights_biases_ready)
    );
    
// TODO
// debounce btnd, btnc,
// also wire btnu OR weights_biases_ready to nn's .ready()
// that way i dont have to send weights just to turn ready() signal on (to run nn)
   
   // read the stuff being sent into the x_in array
   // if we turn on sw[0], then the python sent in will be considered an input.
   logic x_in_ready;
   logic [3:0][7:0] x_in;
   logic [1:0][7:0] dummy_bias; // a hacky placeholder because i want to reuse this module
   
   // todo parametrize this too
   logic [2:0][7:0] output_final;
   
   gather_weights_into_one_array #(.NUM_WEIGHTS(4), .NUM_BIASES(1)) gather_x_in (
        .clk_100mhz(clk_100mhz),
        .start_gathering(sw[0]), //note: need to turn on then off...
        .valid_input(valid_x & output_ready), // bit true if valid, and only look at when new input comes in
        .x(x), // input to gather
        .weights(x_in),
        .biases(dummy_bias),
        .output_ready(x_in_ready)
    );

   // nn that triggers if either the weights are ready, or if x_in is ready
   iris_nn #(.WIDTH(8), .DECIMALS(3)) nn (
       .clk(clk_100mhz),
       .rst(btnd), //randomly made this btnd the reset for now
       .ready(/*weights_biases_ready |*/ btnu),
       .x_in(x_in),
       .weights(weights),
       .biases(biases),
       .output_final(output_final),
       .done(done)
    );
    
    // display result to the seven seg
    assign led[0] = valid_x;
    assign led[1] = output_ready;
    logic [31:0] value;
    assign value = {
                    4'b0,
                    biases[6][7:4], 
                    weights[14][7:4], 
                    x_in[3][6:3],
                    4'b0,
                    output_final[0][6:3],
                    output_final[1][6:3],
                    output_final[2][6:3]
                };

    logic [6:0] segments;
    assign {cg, cf, ce, cd, cc, cb, ca} = segments[6:0];
    display_8hex display(.clk_in(clk_100mhz), .data_in(value), .seg_out(segments), .strobe_out(an));
    
endmodule



module display_8hex(
    input clk_in,                 // system clock
    input [31:0] data_in,         // 8 hex numbers, msb first
    output logic [6:0] seg_out,     // seven segment display output
    output logic [7:0] strobe_out   // digit strobe
    );

    localparam bits = 13;
     
    logic [bits:0] counter = 0;  // clear on power up
     
    logic [6:0] segments[15:0]; // 16 7 bit memorys
    assign segments[0]  = 7'b100_0000;  // inverted logic
    assign segments[1]  = 7'b111_1001;  // gfedcba
    assign segments[2]  = 7'b010_0100;
    assign segments[3]  = 7'b011_0000;
    assign segments[4]  = 7'b001_1001;
    assign segments[5]  = 7'b001_0010;
    assign segments[6]  = 7'b000_0010;
    assign segments[7]  = 7'b111_1000;
    assign segments[8]  = 7'b000_0000;
    assign segments[9]  = 7'b001_1000;
    assign segments[10] = 7'b000_1000;
    assign segments[11] = 7'b000_0011;
    assign segments[12] = 7'b010_0111;
    assign segments[13] = 7'b010_0001;
    assign segments[14] = 7'b000_0110;
    assign segments[15] = 7'b000_1110;
     
    always_ff @(posedge clk_in) begin
      // Here I am using a counter and select 3 bits which provides
      // a reasonable refresh rate starting the left most digit
      // and moving left.
      counter <= counter + 1;
      case (counter[bits:bits-2])
          3'b000: begin  // use the MSB 4 bits
                  seg_out <= segments[data_in[31:28]];
                  strobe_out <= 8'b0111_1111 ;
                 end

          3'b001: begin
                  seg_out <= segments[data_in[27:24]];
                  strobe_out <= 8'b1011_1111 ;
                 end

          3'b010: begin
                   seg_out <= segments[data_in[23:20]];
                   strobe_out <= 8'b1101_1111 ;
                  end
          3'b011: begin
                  seg_out <= segments[data_in[19:16]];
                  strobe_out <= 8'b1110_1111;        
                 end
          3'b100: begin
                  seg_out <= segments[data_in[15:12]];
                  strobe_out <= 8'b1111_0111;
                 end

          3'b101: begin
                  seg_out <= segments[data_in[11:8]];
                  strobe_out <= 8'b1111_1011;
                 end

          3'b110: begin
                   seg_out <= segments[data_in[7:4]];
                   strobe_out <= 8'b1111_1101;
                  end
          3'b111: begin
                  seg_out <= segments[data_in[3:0]];
                  strobe_out <= 8'b1111_1110;
                 end

       endcase
      end

endmodule