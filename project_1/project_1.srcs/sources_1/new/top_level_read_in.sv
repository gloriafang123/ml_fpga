//// TOP LEVEL FOR FX_X. backup.
//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////

//module top_level_read_in(   
//                    input               clk_100mhz,
//                    input [15:0]        sw,
//                    input [3:0]         jb,
//                    output [1:0]        ja,
//                    input               btnc,
//                    input               btnd,
//                    output logic ca, cb, cc, cd, ce, cf, cg, dp,  // segments a-g, dp
//                    output logic[7:0] an,    // Display location 0-7
//                    output logic [15:0] led
//    );
//    //DEBUGGING
//    //assign ja[0] = sw[0]; // for debugging, make jb[4] output equal sw[0]
//    // then feed jb[4] into jb[0], which then changes the sw[0]
//    // so when i change sw[0], it should make the 7 seg display bit change
//    // this worked. so the error shouldn't be in jb[0].
    
//    logic enable;
//    //  initialize sample_data_clk, sample_data_fsm
//    sample_data_clk data_clk(
//        .clk_100mhz(clk_100mhz),
//        .reset(btnd),
//        .enable(enable)
//    );
    
//    logic output_ready;
//    logic [29:0] output_60_bit;
//    sample_data_fsm data_fsm(
//        .clk_100mhz(clk_100mhz),
//        .enable(enable), // data sample rate
//        .jb_data(jb[0]), // the 16x sampled jb data
//        .reset(btnd),
//        .valid_data(output_ready), //output ready, give 60 sample
//        .z_y_x_hold_output(output_60_bit)
//    );
    
//    logic[7:0] x;
//    logic valid_x; // not necessarily a pulse
    
//    process_60_bits processor(
//        .z_y_x(output_60_bit),
//        .valid_input(output_ready), // 1 if data from previous stage ready to be read
//        .clk_100mhz(clk_100mhz),
//        .valid_data(valid_x), // 1 if data ready to be read for next stage
//        .x(x)
//    );
    
//    // x is the bytes
    
    
//    logic weights_biases_ready;
//    logic [14:0] [7:0] weights ;
//    logic [6:0] [7:0] biases ;
//    // new module that gathers the next 15+7 = 22 bits and saves those as weights/biases
//    // starts gathering when we press C, a hacky/dumb approach right now
//    gather_weights_into_one_array uut(
//        .clk_100mhz(clk_100mhz),
//        .start_gathering(btnc), //btnc
//        .valid_input(valid_x & output_ready), // bit true if valid, and only look at when new input comes in
//        .x(x), // input to gather
//        .weights(weights),
//        .biases(biases),
//        .output_ready(weights_biases_ready)
//    );
    
//// TODO
//// debounce btnd, btnc,
//// also wire btnu OR weights_biases_ready to nn's .ready()
//// that way i dont have to send weights just to turn ready() signal on (to run nn)
   
//   logic [7:0] x_in;
//   assign x_in = sw[7:0];//8'b0_0011_000;//8 bit input
//   logic [7:0] output_final;
//   logic done;
    
//   neural_network #(.WIDTH(8), .DECIMALS(3)) nn (
//       .clk(clk_100mhz),
//       .rst(btnd), //randomly made this btnd the reset for now
//       .ready(weights_biases_ready),
//       .x_in(x_in),
//       .weights(weights),
//       .biases(biases),
//       .output_final(output_final),
//       .done(done)
//    );
    
//    // display result to the seven seg
//    assign led[0] = valid_x;
//    assign led[1] = output_ready;
//    logic [31:0] value;
//    assign value = {
//    //22'b0, output_ready, valid_x, x 
//                    biases[6][7:4],biases[6][3:0], 
//                    weights[14][7:4], weights[14][3:0],
//                    x_in[6:3], 1'b0, x_in[2:0],
//                    output_final[6:3], 1'b0, output_final[2:0]
//                };
////    assign value = {24'b0, x};
////    assign value = {8'b0, output_60_bit[28:25],output_60_bit[24:21],output_60_bit[18:15],
////                    output_60_bit[14:11],output_60_bit[8:5],output_60_bit[4:1]};/*{31'b0, jb[0]};*/ /*{24'b0, output_60_bit[8:1]}*/;
//    logic [6:0] segments;
//    assign {cg, cf, ce, cd, cc, cb, ca} = segments[6:0];
//    display_8hex display(.clk_in(clk_100mhz), .data_in(value), .seg_out(segments), .strobe_out(an));
    
//endmodule



//module display_8hex(
//    input clk_in,                 // system clock
//    input [31:0] data_in,         // 8 hex numbers, msb first
//    output logic [6:0] seg_out,     // seven segment display output
//    output logic [7:0] strobe_out   // digit strobe
//    );

//    localparam bits = 13;
     
//    logic [bits:0] counter = 0;  // clear on power up
     
//    logic [6:0] segments[15:0]; // 16 7 bit memorys
//    assign segments[0]  = 7'b100_0000;  // inverted logic
//    assign segments[1]  = 7'b111_1001;  // gfedcba
//    assign segments[2]  = 7'b010_0100;
//    assign segments[3]  = 7'b011_0000;
//    assign segments[4]  = 7'b001_1001;
//    assign segments[5]  = 7'b001_0010;
//    assign segments[6]  = 7'b000_0010;
//    assign segments[7]  = 7'b111_1000;
//    assign segments[8]  = 7'b000_0000;
//    assign segments[9]  = 7'b001_1000;
//    assign segments[10] = 7'b000_1000;
//    assign segments[11] = 7'b000_0011;
//    assign segments[12] = 7'b010_0111;
//    assign segments[13] = 7'b010_0001;
//    assign segments[14] = 7'b000_0110;
//    assign segments[15] = 7'b000_1110;
     
//    always_ff @(posedge clk_in) begin
//      // Here I am using a counter and select 3 bits which provides
//      // a reasonable refresh rate starting the left most digit
//      // and moving left.
//      counter <= counter + 1;
//      case (counter[bits:bits-2])
//          3'b000: begin  // use the MSB 4 bits
//                  seg_out <= segments[data_in[31:28]];
//                  strobe_out <= 8'b0111_1111 ;
//                 end

//          3'b001: begin
//                  seg_out <= segments[data_in[27:24]];
//                  strobe_out <= 8'b1011_1111 ;
//                 end

//          3'b010: begin
//                   seg_out <= segments[data_in[23:20]];
//                   strobe_out <= 8'b1101_1111 ;
//                  end
//          3'b011: begin
//                  seg_out <= segments[data_in[19:16]];
//                  strobe_out <= 8'b1110_1111;        
//                 end
//          3'b100: begin
//                  seg_out <= segments[data_in[15:12]];
//                  strobe_out <= 8'b1111_0111;
//                 end

//          3'b101: begin
//                  seg_out <= segments[data_in[11:8]];
//                  strobe_out <= 8'b1111_1011;
//                 end

//          3'b110: begin
//                   seg_out <= segments[data_in[7:4]];
//                   strobe_out <= 8'b1111_1101;
//                  end
//          3'b111: begin
//                  seg_out <= segments[data_in[3:0]];
//                  strobe_out <= 8'b1111_1110;
//                 end

//       endcase
//      end

//endmodule