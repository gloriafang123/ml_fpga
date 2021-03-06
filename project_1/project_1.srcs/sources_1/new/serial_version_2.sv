`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module serial_3_top #(
    parameter PERIOD = 3, //sample clock
    parameter OUTPUT_BITS = 8,
    parameter COUNTER_2MS = 4, //enables till 2ms
    parameter SAMPLE_RATE = 16,
    // this parameter was deprecated and changed compared to previous version:
    // parameter MAX_OUTPUTS = 200, //output_bits * largest of w,b,x count
    
    parameter NUM_WEIGHTS = 6,
    parameter NUM_BIASES = 6,
    parameter NUM_X = 6,
    parameter BITS_PER_WEIGHT = 16,
    parameter BITS_PER_BIAS = 16,
    parameter BITS_PER_X = 16,
    
    parameter X_TYPE = 2'b00,
    parameter W_TYPE = 2'b01,
    parameter B_TYPE = 2'b11
    
)
(
    input clk_100mhz,
    input reset,
    input jb_data,
    output logic [NUM_WEIGHTS-1:0][BITS_PER_WEIGHT-1:0] weights,
    output logic [NUM_BIASES-1:0][BITS_PER_BIAS-1:0] biases,
    output logic [NUM_X-1:0][BITS_PER_X-1:0] x,
    output logic ready_nn_update
);

    logic enable;
    
    sample_data_clk_2 #(.PERIOD(PERIOD)) sdc (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .enable(enable)
    );
    
    logic byte_ready;
    logic [OUTPUT_BITS-1+2:0] output_bits;
    
    sample_single_byte_fsm #(.OUTPUT_BITS(OUTPUT_BITS),
        .COUNTER_2MS(COUNTER_2MS),
        .SAMPLE_RATE(SAMPLE_RATE))
        ssbf
        (
        .clk_100mhz(clk_100mhz),
        .enable(enable),
        .jb_data(jb_data),
        .reset(reset),
        .valid_data(byte_ready),
        .output_bits(output_bits)
        );
    
    logic [OUTPUT_BITS-1:0] cleaned_out;
    assign cleaned_out = output_bits[1 +: OUTPUT_BITS]; //remove start/end bits
    logic [1:0] output_type;
    logic [BITS_PER_WEIGHT - 1:0] output_array;
    logic array_ready, end_of_wbx;
    
    integer output_index;
    
    // figures out how many inputs to package together,
    // what type of intput it is,
    // and which index to make the update at
    // better than previous serial because outputs small packets of updates
    //   (rather than waiting for entire array to finish)
    parse_data_fsm_byte_outputs #(
        .INPUT_BITS(OUTPUT_BITS),
        .OUTPUT_BITS(BITS_PER_WEIGHT), // assumes these are 16
        .NUM_X(NUM_X),
        .NUM_WEIGHTS(NUM_WEIGHTS),
        .NUM_BIASES(NUM_BIASES),
        .BITS_PER_WEIGHT(BITS_PER_WEIGHT),
        .BITS_PER_BIAS(BITS_PER_BIAS),
        .BITS_PER_X(BITS_PER_X),
        .X_TYPE(X_TYPE),
        .W_TYPE(W_TYPE),
        .B_TYPE(B_TYPE)
    ) uut_fsm
    (
        .input_ready(byte_ready),
        .input_value(cleaned_out),
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .output_type(output_type),
        .output_array(output_array),
        .output_valid(array_ready),
        .output_index(output_index),
        .end_of_wbx(end_of_wbx)
    );
    
    logic updated_weights, updated_biases, updated_x;
    
    // based on above module, make the correct updates
    logic wbx_update;
    logic [1:0] wbx_type;  
    
    always_ff @(posedge clk_100mhz) begin
        if (reset) begin
            wbx_update <= 0;
            wbx_type <= 2'b10; // this one is not equal to any existing type.
        end
        else begin
            wbx_update <= 0;
            if (array_ready) begin
                case (output_type)
                    X_TYPE: begin
                        x[output_index] <= output_array;
                    end
                    W_TYPE: begin
                        weights[output_index] <= output_array;
                    end
                    B_TYPE: begin
                        biases[output_index] <= output_array;
                    end
                    default:;
                endcase
                
                if (end_of_wbx) begin
                    wbx_update <= 1;
                    wbx_type <= output_type;
                end
            end
        end
    end
    
    check_wbx_all_updated #(
        .X_TYPE(X_TYPE),
        .W_TYPE(W_TYPE),
        .B_TYPE(B_TYPE)
    ) cwau (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .input_type(wbx_type),
        .valid_input(wbx_update),
        .wbx_all_ready(ready_nn_update)
    );
endmodule


// takes 100mhz clock and creates enable signal for when to sample data
// parameter: period per sample
module sample_data_clk_2(
    input clk_100mhz,
    input reset,
    output logic enable
    );
    
    parameter PERIOD = 651; //100MHz/(9600*16)
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

// gathers a single byte of data
// gets OUTPUT_BITS + 2 bits of data
// valid_data pulse
module sample_single_byte_fsm #(
    parameter OUTPUT_BITS = 8, 
    parameter COUNTER_2MS = 308, //0.002s *100000000/651)(
    parameter SAMPLE_RATE = 16
) (
    input clk_100mhz,
    input enable,           //data clock
    input jb_data,          //tie to jb[0]
    input reset,            // tie to some reset button
    output logic valid_data, //pulse 1 if data ready
    output logic [OUTPUT_BITS-1 + 2:0] output_bits  // gets single output byte, plus start/stop
);
    // parameters for states
    localparam IDLE = 2'b00;
    localparam START_PULSE = 2'b10;
    localparam SAMPLE_EVERY_16 = 2'b11;
    
    
    logic [SAMPLE_RATE-1:0] jb_16;     //last 16 inputs read
    logic [1:0] state;
    logic [OUTPUT_BITS-1 + 2:0] tmp_output;  //outupt when it's being shifted (not ready)
    
    logic [8:0] counter_2ms;
    
    logic [4:0] counter_16;
    
    logic [3:0] filled_bits;
    
    
    always_ff @(posedge clk_100mhz) begin
        if (reset) begin
            jb_16 <= {SAMPLE_RATE{1'b0}};
            state <= IDLE;
            output_bits <= 0;
            valid_data <= 0;
            counter_2ms <= 0;
            counter_16 <= 0;
            filled_bits <= 0;
        end
        else begin
            valid_data <= 0; // ensure this is pulse
            
            if (enable) begin
                case (state)
                
                IDLE: begin 
                    // increment or reset counteer
                    if (jb_data == 1) begin
                        counter_2ms <= counter_2ms + 1;
                    end else begin
                        counter_2ms <= 0;
                    end
                    
                    // high for 2ms
                    if (counter_2ms == COUNTER_2MS) begin
                        state <= START_PULSE;
                        jb_16 <= {SAMPLE_RATE{1'b1}};
                        counter_2ms <= 0;
                    end
                end
                
                START_PULSE: begin 
                    jb_16 <= {jb_data, jb_16[SAMPLE_RATE-1:1]}; // shift down right
                    
                    if (jb_16 == {{(SAMPLE_RATE/2){1'b0}},{(SAMPLE_RATE/2){1'b1}}}) begin
                        state <= SAMPLE_EVERY_16;
                        tmp_output <= {jb_16[SAMPLE_RATE-1], {(OUTPUT_BITS-1+2){1'b0}}}; // shifting right and also resetting
                        jb_16 <= {SAMPLE_RATE{1'b0}};
                        
                        counter_16 <= 1; // done 1 by next step
                        filled_bits <= 1; //filled i currently have
                        
                    end
                end
                SAMPLE_EVERY_16: begin 
                    // increment counter
                    counter_16 <= (counter_16 == SAMPLE_RATE)? 1 : (counter_16 + 1);
                    if (counter_16 == SAMPLE_RATE) begin
                        // done
                        if ((filled_bits) == (OUTPUT_BITS-1+2)) begin // need to be sure stop bit included
                            valid_data <= 1;
                            filled_bits <= 0;
                            output_bits <= {jb_data, tmp_output[OUTPUT_BITS-1+2:1]};
                            tmp_output <= 0;
                            state <= IDLE;
                        end
                        
                        // not done
                        else begin
                            tmp_output <= {jb_data, tmp_output[OUTPUT_BITS-1+2:1]}; //shift down
                            filled_bits <= filled_bits + 1; // by next step i will have filled_60+1
                        end
                    end
                end
                
                default: begin state <= IDLE; end
            
                endcase
            end
        end
    end

endmodule

// parse data fsm with small output size
// superior to old version because of small outputs
// outputs the array, the corresponding index, the type, and 1 when output valid.
module parse_data_fsm_byte_outputs #(
    parameter INPUT_BITS = 8, // add some combo logic to deal with the 10 bit to 8 bit check
    parameter OUTPUT_BITS = 16, //max of bits per weight, bias, x
    parameter NUM_X = 7,
    parameter NUM_WEIGHTS =  7,
    parameter NUM_BIASES =  7,
    parameter BITS_PER_WEIGHT = 8,
    parameter BITS_PER_BIAS = 8,
    parameter BITS_PER_X = 8,
    parameter X_TYPE = 2'b00,
    parameter W_TYPE = 2'b01,
    parameter B_TYPE = 2'b11
)
(
    input input_ready, //pulse
    input [INPUT_BITS-1:0] input_value,
    input clk_100mhz,
    input reset,
    output logic [1:0] output_type,
    output logic [OUTPUT_BITS-1:0] output_array,
    output logic output_valid,
    output integer output_index,  
    output logic end_of_wbx     // pulse 1 if end of an array. may not be needed
);

    // states: depend on the type (metadata).
    // idle state: wait for type, then get the type - change state; then in state - do counter until done
    
    localparam IDLE = 2'b10; // await metadata
    localparam X = 2'b00;   // x (input)
    localparam W = 2'b01;   // weights
    localparam B = 2'b11;   // biases
    
    logic [1:0] state;
    logic [1:0] cycle_counter; // just goes to 2 when 2 bytes of data per weight
    integer data_counter, data_counter_max;
    
    logic [OUTPUT_BITS-1:0] tmp_output_array;
    
    // gather every output_bits/input_bits into a single array
    localparam CYCLES_MAX = OUTPUT_BITS/INPUT_BITS;
    
    always_comb begin
        case (state)
            IDLE: begin data_counter_max = 100; end // just put some dummy value
            X_TYPE: begin data_counter_max = NUM_X; end
            W_TYPE: begin data_counter_max = NUM_WEIGHTS; end
            B_TYPE: begin data_counter_max = NUM_BIASES; end
        endcase
    end
    
    always_ff @(posedge clk_100mhz) begin
        if (reset) begin
            output_valid <= 0;
            end_of_wbx <= 0;
            output_array <= 0;
            output_index <= 0;
            state <= IDLE;
            cycle_counter <= 0;
            data_counter <= 0;
        end
        else begin
            output_valid <= 0;
            end_of_wbx <= 0;
            // if input valid, new incoming byte
            if (input_ready) begin
                case (state)
                    IDLE: begin
                        // this means it just received the type.
                        state <= input_value[1:0]; //get data type (weight, in act)
                        data_counter <= 1;
                        cycle_counter <= 1;
                        tmp_output_array <= 0;
                        
                    end
                    W,B,X: begin //W,B,X states
                        cycle_counter <= cycle_counter + 1;
                        
                        // update tmp_output with input value
                        tmp_output_array[(cycle_counter - 1)*INPUT_BITS +: INPUT_BITS] <= input_value;
                        
                        // this just filled a single output data
                        if (cycle_counter == CYCLES_MAX) begin
                            cycle_counter <= 1;
                            data_counter <= data_counter + 1; 
                            
                            // update all outputs
                            output_array <= tmp_output_array;
                            output_array[(cycle_counter - 1)*INPUT_BITS +: INPUT_BITS] <= input_value;
                            output_valid <= 1;
                            output_index <= data_counter - 1;
                            output_type <= state;
                            
                            // if this was the last data counter update, then done entire array
                            // end_of_wbx signifies end of an entire array (not just a single output number)
                            if (data_counter == data_counter_max) begin
                                state <= IDLE;
                                end_of_wbx <= 1;
                                cycle_counter <= 0;
                                data_counter <= 0;
                            end
                        end
                        
                    end
                    
                    default: begin
                        state <= IDLE;
                    end
                endcase
            end
        end
        
    end
    
endmodule



// outputs 1 whenever all w,b,x ready
// or when new w,b,x update happens
// needed to generate pulse for NN
module check_wbx_all_updated #(
    parameter X_TYPE = 2'b00,
    parameter W_TYPE = 2'b01,
    parameter B_TYPE = 2'b11
)
(
    input clk_100mhz,
    input reset,
    input [1:0] input_type,
    input valid_input,
    output logic wbx_all_ready //pulse
);
    logic done_x, done_w, done_b;
    
    always_ff @(posedge clk_100mhz) begin
        if (reset) begin
            done_x <= 0;
            done_w <= 0;
            done_b <= 0;
            wbx_all_ready <= 0;
        end 
        else begin
            wbx_all_ready <= 0;
            if (valid_input) begin
                // update done_x, done_w, done_b based on input_type
                // also send pulse if all done
                // so if update many time, then each time valid input sends pulse ONCE
                case (input_type)
                    X_TYPE: begin done_x <= 1; 
                        if (done_w && done_b) begin
                            wbx_all_ready <= 1;
                        end
                    end
                    W_TYPE: begin done_w <= 1; 
                        if (done_x && done_b) begin
                            wbx_all_ready <= 1;
                        end
                    end
                    B_TYPE: begin done_b <= 1; 
                        if (done_x && done_w) begin
                            wbx_all_ready <= 1;
                        end
                    end
                    default :;
                endcase
            end
            
        end
    end

endmodule