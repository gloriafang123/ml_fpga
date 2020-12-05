`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module serial_2_top #(
    parameter PERIOD = 3, //sample clock
    parameter OUTPUT_BITS = 8,
    parameter COUNTER_2MS = 4, //enables till 2ms
    parameter SAMPLE_RATE = 16,
    parameter MAX_OUTPUTS = 200, //output_bits * largest of w,b,x count
    
    parameter NUM_WEIGHTS = 6,
    parameter NUM_BIASES = 6,
    parameter NUM_X = 6,
    parameter BITS_PER_WEIGHT = 8,
    parameter BITS_PER_BIAS = 8,
    parameter BITS_PER_X = 8,
    
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
    logic [MAX_OUTPUTS - 1:0] output_array;
    logic array_ready;
    logic [OUTPUT_BITS-1:0] number_of_data_out, bytes_per_data_out;
    
    parse_data_fsm #(
        .INPUT_BITS(OUTPUT_BITS),
        .MAX_OUTPUTS(MAX_OUTPUTS)
    ) pdf (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .input_ready(byte_ready),
        .input_value(cleaned_out),
        .output_type(output_type),
        .output_array(output_array),
        .output_valid(array_ready),
        .number_of_data_out(number_of_data_out),
        .bytes_per_data_out(bytes_per_data_out)
    );

    // above testbenched works
    logic wbx_update;
    logic [1:0] wbx_type;    
    
    
    update_wbx_values #(
        .NUM_WEIGHTS(NUM_WEIGHTS),
        .NUM_BIASES(NUM_BIASES),
        .NUM_X(NUM_X),
        .BITS_PER_WEIGHT(BITS_PER_WEIGHT),
        .BITS_PER_BIAS(BITS_PER_BIAS),
        .BITS_PER_X(BITS_PER_X),
        .MAX_INPUT_SIZE(MAX_OUTPUTS),
        .X_TYPE(X_TYPE),
        .W_TYPE(W_TYPE),
        .B_TYPE(B_TYPE)
    ) uwv (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .valid_input(array_ready),
        .input_type(output_type),
        .input_array(output_array),
        .weights(weights),
        .biases(biases),
        .x(x),
        .output_valid(wbx_update),
        .output_type(wbx_type)
    );
    
    // working testbench
    logic ready_nn_update; //1 if time to update nn
    
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

// based on input including metadata, gets array of outputs
// outputs held constant until new inputs
module parse_data_fsm #(
    parameter INPUT_BITS = 8, // add some combo logic to deal with the 10 bit to 8 bit check
    parameter MAX_OUTPUTS = 100
)
(
    input input_ready, //pulse
    input [INPUT_BITS-1:0] input_value,
    input clk_100mhz,
    input reset,
    output logic [1:0] output_type,
    output logic [MAX_OUTPUTS-1:0] output_array,
    output logic output_valid,
    output logic [INPUT_BITS-1:0] number_of_data_out, bytes_per_data_out
);
    
    localparam IDLE = 0;
    localparam METADATA_1 = 1;
    localparam METADATA_2 = 2; 
    localparam COLLECTING = 3;
    
    logic [1:0] state;
    logic [INPUT_BITS-1:0] type_data, number_of_data, bytes_per_data;
    
    logic [INPUT_BITS*2-1:0] data_counter;
    logic [INPUT_BITS*2-1:0] data_counter_max;
    
    logic [MAX_OUTPUTS-1:0] tmp_output_array;
    
    // packet count basically
    // each has length input_bits
    assign data_counter_max = number_of_data*bytes_per_data;
    // probably want to add outputs for data_counter and byte_counter too

    always_ff @(posedge clk_100mhz) begin
        if (reset) begin
            state <= IDLE;
            output_valid <= 0;
            tmp_output_array <= 0;
            data_counter <= 0;
            //reset counters here too
        end
        else begin
            output_valid <= 0;
            case (state)
                IDLE: begin 
                    if(input_ready) begin 
                        state <= METADATA_1; 
                        type_data <= input_value; //get data type (weight, in act)
                        tmp_output_array <= 0;
                    end 
                end
                
                METADATA_1:begin
                    if (input_ready) begin
                        number_of_data <= input_value;
                        state <= METADATA_2;    // get the number of data
                    end
                end
                
                METADATA_2: begin
                    if (input_ready) begin
                        bytes_per_data <= input_value;
                        state <= COLLECTING;      // get the number of bytes per data
                        
                        data_counter <= 1;
                    end
                end
                
                COLLECTING: begin
                    // use data counter and byte_counter
                    if (input_ready) begin
                        data_counter <= data_counter + 1;
                        tmp_output_array[(data_counter-1)*INPUT_BITS +:INPUT_BITS] <= input_value;
                        if (data_counter == data_counter_max) begin
                            data_counter <= data_counter + 1;
                            
                            output_valid <= 1;
                            output_array <= tmp_output_array;
                            output_array[(data_counter-1)*INPUT_BITS +:INPUT_BITS] <= input_value;
                            
                            number_of_data_out <= number_of_data;
                            bytes_per_data_out <= bytes_per_data;
                            output_type <= type_data[1:0];
                            
                            state <= IDLE;
                            
                        end
                        
                    
                    end
                end
                default: begin state <= IDLE; end
            endcase
        end
    end

endmodule

// updates one of w,b,x based on input
module update_wbx_values #(
    parameter NUM_WEIGHTS = 10,
    parameter NUM_BIASES = 10,
    parameter NUM_X = 5,
    parameter BITS_PER_WEIGHT = 6,
    parameter BITS_PER_BIAS = 6,
    parameter BITS_PER_X = 6,
    parameter MAX_INPUT_SIZE = 200,
    
    parameter X_TYPE = 2'b00,
    parameter W_TYPE = 2'b01,
    parameter B_TYPE = 2'b11
)
(
    input clk_100mhz,
    input reset,
    input valid_input,
    input [1:0] input_type,
    input [MAX_INPUT_SIZE-1:0] input_array,
    output logic [NUM_WEIGHTS-1:0][BITS_PER_WEIGHT-1:0] weights,
    output logic [NUM_BIASES-1:0][BITS_PER_BIAS-1:0] biases,
    output logic [NUM_X-1:0][BITS_PER_X-1:0] x,
    output logic output_valid, // pulse
    output logic [1:0] output_type // holds input_type
);

// when the input is valid,
// check type and assign to weight/bias/x

    integer i;
    always_ff @(posedge clk_100mhz) begin
        if (reset) begin
            // set all nn values to 0
            for (i = 0; i < NUM_X; i++) begin
                x[i] <= 0;
            end
            output_valid <= 0;
        end
        else begin
            output_valid <= 0;
            if (valid_input) begin
                case (input_type)
                    X_TYPE: begin
                        for (i = 0; i < NUM_X; i++) begin
                            x[i] <= input_array[(i*BITS_PER_X) +: BITS_PER_X];
                        end
                        output_valid <= 1;
                        output_type <= input_type;
                    end
                    
                    W_TYPE: begin 
                        for (i = 0; i < NUM_WEIGHTS; i++) begin
                            weights[i] <= input_array[(i*BITS_PER_WEIGHT) +: BITS_PER_WEIGHT];
                        end
                        output_valid <= 1;
                        output_type <= input_type;
                    end
                    
                    B_TYPE: begin 
                        for (i = 0; i < NUM_BIASES; i++) begin
                            biases[i] <= input_array[(i*BITS_PER_BIAS) +: BITS_PER_BIAS];
                        end
                        output_valid <= 1;
                        output_type <= input_type;
                    end
                    
                    default:;
                    
                endcase
            end
        end
    end

endmodule

// outputs 1 whenever all w,b,x ready
// or when new w,b,x update happens
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