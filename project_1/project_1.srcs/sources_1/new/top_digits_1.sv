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

    parameter ENABLE_PERIOD = 651; //fixed
    parameter OUTPUT_BITS = 8; //1 byte at a time
    parameter COUNTER_2MS = 308; //fixed
    parameter SAMPLE_RATE = 16; //fixed
    parameter NUM_WEIGHTS = 870;
    parameter NUM_BIASES = 27;
    parameter NUM_X = 100;

    parameter BITS_PER_BIAS = 16;
    parameter BITS_PER_X = 16;

    parameter X_TYPE = 2'b00; //fixed
    parameter W_TYPE = 2'b01; //fixed
    parameter B_TYPE = 2'b11; //fixed


//iris: width 8, decimals 3,
//num_x 4,
//num_weights 30,
//num_biases 9,
//num_output 3

//mnist: width = 16, decimals = 5
//num_x = 784, 
//num_weights = 8040,
//num_biases = 30,
//num_output = 10,
//bits per output = 16

//mnist small:
//width = 16, decimals = 4,
//num_x = 100,
//num_weights = 870,
//num_biases = 27,
//num_output = 10,
//bits per each = 16


    parameter BITS_PER_WEIGHT = 16;
    parameter DECIMAL_BITS = 8;
    parameter NUM_OUTPUTS = 10;
    parameter BITS_PER_OUTPUT = 16;
    
    // only needed for serial_2_top, not needed for serial_3_top
    parameter MAX_OUTPUTS = NUM_WEIGHTS*BITS_PER_WEIGHT + 8; //fixed


    logic [NUM_WEIGHTS-1:0][BITS_PER_WEIGHT-1:0] weights;
    logic [NUM_BIASES-1:0][BITS_PER_BIAS-1:0] biases;
    logic [NUM_X-1:0][BITS_PER_X-1:0] x;
    logic ready_nn_update;
    
    logic reset;
    debounce dbnc_instance (
            .clk_in(clk_100mhz),
            .rst_in(btnc),
            .bouncey_in(btnc),
            .clean_out(reset)
    );
    // assign reset = btnc;

    serial_3_top #(
        .PERIOD(ENABLE_PERIOD),
        .OUTPUT_BITS(OUTPUT_BITS),
        .COUNTER_2MS(COUNTER_2MS),
        .SAMPLE_RATE(SAMPLE_RATE),
        //.MAX_OUTPUTS(MAX_OUTPUTS), // comment if using serial_3_top
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

    mnist_nn_small #(.WIDTH(BITS_PER_WEIGHT), .DECIMALS(DECIMAL_BITS)) mnist_nn_instance (
        .clk(clk_100mhz),
        .rst(reset),
        .ready(ready_nn_update),
        .x_in(x),
        .weights(weights),
        .biases(biases),
        .output_final(output_final),
        .done(nn_done)
    );

    /// ILA
    ila_0 ila_instance (
        .clk(clk_100mhz), // input wire clk
    
        .probe0(output_final[0][15:0]), // input wire [15:0]  probe0  
        .probe1(output_final[1][15:0]), // input wire [15:0]  probe1 
        .probe2(output_final[2][15:0]), // input wire [15:0]  probe2 
        .probe3(output_final[3][15:0]), // input wire [15:0]  probe3 
        .probe4(output_final[4][15:0]), // input wire [15:0]  probe4 
        .probe5(output_final[5][15:0]), // input wire [15:0]  probe5 
        .probe6(output_final[6][15:0]), // input wire [15:0]  probe6 
        .probe7(output_final[7][15:0]), // input wire [15:0]  probe7 
        .probe8(output_final[8][15:0]), // input wire [15:0]  probe8 
        .probe9(output_final[9][15:0]), // input wire [15:0]  probe9 
        .probe10(weights[0][15:0]), // input wire [15:0]  probe10 
        .probe11(weights[NUM_WEIGHTS-1][15:0]), // input wire [15:0]  probe11 
        .probe12(biases[0][15:0]), // input wire [15:0]  probe12 
        .probe13(biases[NUM_BIASES-1][15:0]) // input wire [15:0]  probe13
    );


    // show that nn is done (pulse)
    // assign led[15] = nn_done;
    
    // 7 seg display logic for showing some weights, biases, and x
    
    // switch state to show output x (also visible on ILA)
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
                if (sw[15:14] == 2'b00) begin
                    display_data = {
                        output_final[7][3:0],
                        output_final[6][3:0],
                        output_final[5][3:0],
                        output_final[4][3:0],
                        output_final[3][3:0],
                        output_final[2][3:0],
                        output_final[1][3:0],
                        output_final[0][3:0]
                    };
                end 
                if (sw[15:14] == 2'b01) begin // make top switch high to see upper bits
                    display_data = {
                        output_final[7][7:4],
                        output_final[6][7:4],
                        output_final[5][7:4],
                        output_final[4][7:4],
                        output_final[3][7:4],
                        output_final[2][7:4],
                        output_final[1][7:4],
                        output_final[0][7:4]
                    };
                end
                if (sw[15:14] == 2'b10) begin
                    display_data = {
                        24'b0,
                        output_final[NUM_OUTPUTS-1][3:0], // 10-1=9
                        output_final[8][3:0]
                    };
                end 
                if (sw[15:14] == 2'b11) begin // make top switch high to see upper bits
                    display_data = {
                        24'b0,
                        output_final[NUM_OUTPUTS-1][7:4],
                        output_final[8][7:4]
                    };
                end
                
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
    
    // added this for visual (doesnt change anything)
    always_ff @(posedge clk_100mhz) begin
        if (reset) begin
            led[1] <= 0;
        end
        if (nn_done) begin
            led[1] <= ~led[1]; //change status if new update
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

module debounce(    input  logic    clk_in, //clock in
                    input  logic     rst_in, //reset in
                    input  logic     bouncey_in,//raw input to the system
                    output logic    clean_out //debounced output
    );
   logic [19:0] count; // is 20 bits enough? > yes because 20 bits can represent up to 2^20-1 > 1Mil
   
   logic old;
   always_ff @(posedge clk_in) begin
        old <= bouncey_in;
        if ((old != bouncey_in) || (rst_in == 1)) begin
            count <=  20'd0;
        end else begin // bouncey and old are same
            if (count == 20'd1_000_000) begin
                clean_out <= old;
            end
            count <= count + 1;
        end 

   end
endmodule