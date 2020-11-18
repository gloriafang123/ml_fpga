`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


// 100mhz clock, 
module sample_data_clk(
    input clk_100mhz,
    input reset,
    output logic enable
    );
    
    parameter PERIOD = 651; //100MHz/(9600*16)
                            //62;//100 MHz/ (115_200*14 sample rate) //450 bad.
                            // using 14x baud rate because 62.00 is 100000000/(115200*14)
    logic [9:0] clock_period_counter;
    
    always_comb begin
        enable = (clock_period_counter == PERIOD);
    end
    
    always_ff @(posedge clk_100mhz) begin
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
    input clk_100mhz,
    input enable, // data sample rate
    input jb_data, // the 16x sampled jb data
    input reset,
    output logic valid_data, //output ready, give 60 sample
    output logic [29:0] z_y_x_hold_output
);
    parameter HIGH_2MS = 2'b00;
    parameter START_PULSE = 2'b10;
    parameter SAMPLE_EVERY_16 = 2'b11;
    
    parameter COUNTER_2MS_MAX = 308;//100mHz/651 clk, so for 2ms that is 308 counter
                                     //806; // let's do 0.5ms bc we want fast.
                                     // .5ms in 100mhz clock is 
                                     //65000000*0.002/423
                                     // 100_000_000 * 0.0005/62 where 62 is period = 806.45
    
    logic [1:0] state;
    logic [15:0] jb_16; // we're sampling at 14x baud instead of 16x
    logic [29:0] z_y_x;
    logic [9:0] counter_2ms; // counts up to COUNTER_2MS
    
    logic [4:0] counter_16; // 0 to 15
    logic [5:0] filled_30; // 1 to 60 //30 is 3 bytes
    
    always_ff @(posedge clk_100mhz) begin
        valid_data <= 0; // nov 17 added bc need it to be 1 clk pulse not 1 enable pulse
        if (enable) begin // sample rate
            case (state)
                HIGH_2MS: begin
                    valid_data <= 0; //nov 17 added
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
                    valid_data <= 0;
                    jb_16 <= {jb_data, jb_16[15:1]}; // shift down right
                    // pulse detected (high to low
                    if (jb_16 == 16'b0000_0000_1111_1111) begin
                        state <= SAMPLE_EVERY_16;
                        z_y_x <= {jb_16[15], 29'b0}; // shifting right and also resetting
                        counter_16 <= 1; // done 1 by next step
                        jb_16 <= 16'b0;
                        filled_30 <= 1; //filled i currently have
                    end
                end
                SAMPLE_EVERY_16: begin
                    // (tested with 13 but did not work)
                    counter_16 <= (counter_16 == 15)? 0 : (counter_16 + 1);
                    if (counter_16 == 0) begin // done 16
                        // shift z y x
                        z_y_x <= {jb_data, z_y_x[29:1]}; //shift down
                        filled_30 <= filled_30 + 1; // by next step i will have filled_60+1
                    end
                    if (filled_30 == 30) begin
                        valid_data <= 1; // valid for 1 clk cycle
                        filled_30 <= 0;
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
            z_y_x_hold_output <= 30'b0;
            z_y_x <= 30'b0;
            state <= HIGH_2MS;
            jb_16 <= 16'b0;
            counter_2ms <= 0;
            counter_16 <= 0;
            filled_30 <= 0;
        end // reset case
    end // alwaysff
endmodule
    
    

/*
post processing module: (purely combinatorial)
gets the byte from the 2 byte input
*/
module process_60_bits (
    input [29:0] z_y_x,
    input valid_input, // 1 if data from previous stage ready to be read
    input clk_100mhz,
    output logic valid_data, // 1 if data ready to be read for next stage
    output logic [7:0] x
);

/*    logic [15:0] x_16;*/
//    logic [15:0] y_16;
    always_comb begin
        // data in this stage only ready if prev module ready, and if start/end bits correct
        if (valid_input) begin
            // check all starts and end bits are correct
//            valid_data = ({z_y_x[0], z_y_x[10], z_y_x[20], z_y_x[30], z_y_x[40], z_y_x[50]} == 6'b00_0000)
//                        &&
//                        ({z_y_x[9],z_y_x[19], z_y_x[29] ,z_y_x[39],z_y_x[49],z_y_x[59]} == 6'b11_1111);
            valid_data = (z_y_x[0] == 0) && (z_y_x[9] == 1);//({z_y_x[0],z_y_x[10]}==2'b00) && ({z_y_x[9], z_y_x[19]}==2'b11);
            
        end else begin
            valid_data = 0;
        end
        
      /*  x_16 = z_y_x[8:1];*/
      x = z_y_x[8:1];

    end
  /*  
    always_ff @(posedge clk_100mhz) begin
            x <= x_16; // 13 bits
//            y <= y_16[15:3];
    end
    */
endmodule