`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module top_digits_1 (
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

    parameter ENABLE_PERIOD = 651;
    parameter OUTPUT_BITS = 8; //1 byte at a time
    parameter COUNTER_2MS = 308;
    parameter SAMPLE_RATE = 16; //fixed
    parameter NUM_WEIGHTS = 8040;
    parameter NUM_BIASES = 30;
    parameter NUM_X = 784;

    parameter BITS_PER_BIAS = 16;
    parameter BITS_PER_X = 16;
    parameter X_TYPE = 2'b00;
    parameter W_TYPE = 2'b01;
    parameter B_TYPE = 2'b11;


    parameter BITS_PER_WEIGHT = 16;
    parameter DECIMAL_BITS = 5;
    parameter NUM_OUTPUTS = 10;
    parameter BITS_PER_OUTPUT = 16;
    
    parameter MAX_OUTPUTS = NUM_WEIGHTS*BITS_PER_WEIGHT + 8;


    logic [NUM_WEIGHTS-1:0][BITS_PER_WEIGHT-1:0] weights;
    logic [NUM_BIASES-1:0][BITS_PER_BIAS-1:0] biases;
    logic [NUM_X-1:0][BITS_PER_X-1:0] x;
    logic ready_nn_update;
    
    logic reset;
    assign reset = btnc;

    serial_2_top #(
        .PERIOD(ENABLE_PERIOD),
        .OUTPUT_BITS(OUTPUT_BITS),
        .COUNTER_2MS(COUNTER_2MS),
        .SAMPLE_RATE(SAMPLE_RATE),
        .MAX_OUTPUTS(MAX_OUTPUTS),
        .NUM_WEIGHTS(NUM_WEIGHTS),
        .NUM_BIASES(NUM_BIASES),
        .NUM_X(NUM_X),
        .BITS_PER_WEIGHT(BITS_PER_WEIGHT),
        .BITS_PER_BIAS(BITS_PER_BIAS),
        .BITS_PER_X(BITS_PER_X),
        .X_TYPE(X_TYPE),
        .W_TYPE(W_TYPE),
        .B_TYPE(B_TYPE)
    ) s2t (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .jb_data(jb[0]),
        .weights(weights),
        .biases(biases),
        .x(x),
        .ready_nn_update(ready_nn_update)
    );

    logic [NUM_OUTPUTS-1:0][BITS_PER_OUTPUT-1:0] output_final;
    logic nn_done;

    mnist_nn #(.WIDTH(BITS_PER_WEIGHT), .DECIMALS(DECIMAL_BITS)) (
        .clk(clk_100mhz),
        .rst(reset),
        .ready(ready_nn_update),
        .x_in(x),
        .weights(weights),
        .biases(biases),
        .output_final(output_final),
        .done(nn_done)
    );

    // show that nn is done
    assign led[15] = nn_done;
    parameter SHOW_OUTPUT = 2'b10;

    // use switches to show display for what values have been received
    logic [1:0] xwb_type; //x, w, or b
    assign xwb_type = sw[1:0]; // use switches to control
    
    logic [31:0] display_data;

    always_comb begin
        case (xwb_type)
            X_TYPE: begin //00
                display_data = {
                    x[NUM_X-1][3:0],
                    x[6][3:0],
                    x[5][3:0],
                    x[4][3:0],
                    x[3][3:0],
                    x[2][3:0],
                    x[1][3:0],
                    x[0][3:0]
                };
            end

            W_TYPE: begin //01
                display_data = {
                    weights[NUM_WEIGHTS-1][3:0],
                    weights[6][3:0],
                    weights[5][3:0],
                    weights[4][3:0],
                    weights[3][3:0],
                    weights[2][3:0],
                    weights[1][3:0],
                    weights[0][3:0]
                };
            end

            B_TYPE: begin //11
                display_data = {
                    biases[NUM_BIASES-1][3:0],
                    biases[6][3:0],
                    biases[5][3:0],
                    biases[4][3:0],
                    biases[3][3:0],
                    biases[2][3:0],
                    biases[1][3:0],
                    biases[0][3:0]
                };
            end

            SHOW_OUTPUT: begin // 10
                display_data = {
                    output_final[NUM_OUTPUTS-1][3:0],
                    output_final[6][3:0],
                    output_final[5][3:0],
                    output_final[4][3:0],
                    output_final[3][3:0],
                    output_final[2][3:0],
                    output_final[1][3:0],
                    output_final[0][3:0]
                };
            end
        endcase
    end

    logic [6:0] segments;
    assign {cg, cf, ce, cd, cc, cb, ca} = segments[6:0];
    display_8hex display(.clk_in(clk_100mhz), .data_in(display_data), .seg_out(segments), .strobe_out(an));
   
   
    // update led light when everything received
    always_ff @(posedge clk_100mhz) begin
        if (reset) begin
            led[0] <= 0;
        end
        if (ready_nn_update) begin
            led[0] <= ~led[0]; //change status if new update
        end
    end


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