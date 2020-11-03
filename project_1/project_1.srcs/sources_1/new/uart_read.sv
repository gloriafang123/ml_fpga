`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


// pulse every 423 cycles of the 65MHz clock (ref one_hz)
// Updated to 440 after piazza post
module sample_data_clk(
    input clk_65mhz,
    input reset,
    output logic enable
    );
    
    parameter PERIOD = 440;//423;//65 MHz/ (9600*16 sample rate) //450 bad.
    logic [9:0] clock_period_counter;
    
    always_comb begin
        enable = (clock_period_counter == PERIOD);
    end
    
    always_ff @(posedge clk_65mhz) begin
        if (reset) begin
            clock_period_counter <= 1;
        end
        else begin
            clock_period_counter <= (enable ?  31'b1 : (clock_period_counter + 1));
        end
    end
endmodule

/*
State 1: read every 2ns high
after 2ns high, look for start bit pulse.
if start bit pulse,
go to State 2: read last one and read every 8
State 2: done reading all 60, 
go to post processing module
*/
module sample_data_fsm (
    input clk_65mhz,
    input enable, // data sample rate
    input jb_data, // the 16x sampled jb data
    input reset,
    output logic valid_data, //output ready, give 60 sample
    output logic [59:0] z_y_x_hold_output
);
    parameter HIGH_2MS = 2'b00;
    parameter START_PULSE = 2'b10;
    parameter SAMPLE_EVERY_16 = 2'b11;
    
    parameter COUNTER_2MS_MAX = 308;
    
    logic [1:0] state;
    logic [15:0] jb_16;
    logic [59:0] z_y_x;
    logic [8:0] counter_2ms; // counts up to COUNTER_2MS
    
    logic [4:0] counter_16; // 0 to 15
    logic [5:0] filled_60; // 1 to 60
    
    always_ff @(posedge clk_65mhz) begin
        
        if (enable) begin // sample rate
            case (state)
                HIGH_2MS: begin
                    if (jb_data == 1) begin //high
                        counter_2ms <= counter_2ms + 1;
                    end else begin // low, reset counter
                        counter_2ms <= 0;
                    end
                    // high for 2ms
                    if (counter_2ms == COUNTER_2MS_MAX) begin
                        counter_2ms <= 0; // reset for later
                        state <= START_PULSE;
                        jb_16 <= 16'b1000_0000_0000_0000; // shift 1 in for current high
                    end
                end
                START_PULSE: begin 
                    jb_16 <= {jb_data, jb_16[15:1]}; // shift down right
                    // pulse detected (high to low
                    if (jb_16 == 16'b0000_0000_1111_1111) begin
                        state <= SAMPLE_EVERY_16;
                        z_y_x <= {jb_16[15], 59'b0}; // shifting right and also resetting
                        counter_16 <= 1; // done 1 by next step
                        jb_16 <= 16'b0;
                        filled_60 <= 1; //filled i currently have
                    end
                end
                SAMPLE_EVERY_16: begin
                    // (tested with 13 but did not work)
                    counter_16 <= (counter_16 == 15)? 0 : (counter_16 + 1);
                    if (counter_16 == 0) begin // done 16
                        // shift z y x
                        z_y_x <= {jb_data, z_y_x[59:1]}; //shift down
                        filled_60 <= filled_60 + 1; // by next step i will have filled_60+1
                    end
                    if (filled_60 == 60) begin
                        valid_data <= 1; // valid for 1 clk cycle
                        filled_60 <= 0;
                        counter_16 <= 0;
                        z_y_x_hold_output <= z_y_x; // take z_y_x of current round
                        state <= HIGH_2MS;
                    end
                
                end
                default: begin state<= HIGH_2MS; end
            endcase
        end // enable
        if (reset) begin
            valid_data <= 0;
            z_y_x_hold_output <= 60'b0;
            z_y_x <= 60'b0;
            state <= HIGH_2MS;
            jb_16 <= 16'b0;
            counter_2ms <= 0;
            counter_16 <= 0;
            filled_60 <= 0;
        end // reset case
    end // alwaysff
endmodule
    
    

/*
post processing module: (purely combinatorial)
check if bytes are all ok. If not ok, ignore.
If ok, data-read-ok is sent to next module
(next module will read data-60 bit)
*/
module process_60_bits (
    input [59:0] z_y_x,
    input valid_input, // 1 if data from previous stage ready to be read
    input clk_65mhz,
    output logic valid_data, // 1 if data ready to be read for next stage
    output logic [12:0] x,
    output logic [12:0] y
);

    logic [15:0] x_16;
    logic [15:0] y_16;
    always_comb begin
        // data in this stage only ready if prev module ready, and if start/end bits correct
        if (valid_input) begin
            // check all starts and end bits are correct
            valid_data = ({z_y_x[0], z_y_x[10], z_y_x[20], z_y_x[30], z_y_x[40], z_y_x[50]} == 6'b00_0000)
                        &&
                        ({z_y_x[9],z_y_x[19], z_y_x[29] ,z_y_x[39],z_y_x[49],z_y_x[59]} == 6'b11_1111);
        end else begin
            valid_data = 0;
        end
        
        // checks removed after piazza update about baud rate
        
        // always_comb this part
        // if data in this stage is ready, determine what it is
        // if (valid_data) begin
            x_16 = {z_y_x[18:11], z_y_x[8:1]}; //16 bit
            y_16 = {z_y_x[38:31], z_y_x[28:21]}; // 16 bit
        // end

        // always_ff this part            
//            x = x_16[15:3]; // 13 bits
//            y = y_16[15:3];
//        end
    end
    
    always_ff @(posedge clk_65mhz) begin
//        if (valid_data) begin
            x <= x_16[15:3]; // 13 bits
            y <= y_16[15:3];
//        end
//        else begin
//            x <= x;
//            y <= y;
//        end
    end
    
endmodule