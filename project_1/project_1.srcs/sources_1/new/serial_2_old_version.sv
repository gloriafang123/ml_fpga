`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// the top serial with the large array output
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
    
    parse_data_fsm #(

        .INPUT_BITS(OUTPUT_BITS),
        .MAX_OUTPUTS(MAX_OUTPUTS),
        .NUM_X(NUM_X),
        .NUM_WEIGHTS(NUM_WEIGHTS),
        .NUM_BIASES(NUM_BIASES),
        .BITS_PER_WEIGHT(BITS_PER_WEIGHT),
        .BITS_PER_BIAS(BITS_PER_BIAS),
        .BITS_PER_X(BITS_PER_X),
        .X_TYPE(X_TYPE),
        .W_TYPE(W_TYPE),
        .B_TYPE(B_TYPE)

    ) pdf (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .input_ready(byte_ready),
        .input_value(cleaned_out),
        .output_type(output_type),
        .output_array(output_array),
        .output_valid(array_ready)
    ); // redesign this, so that it outputs single byte, index, type, and 1 when valid

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


// based on input including metadata, gets array of outputs
// outputs held constant until new inputs
module parse_data_fsm #(
    parameter INPUT_BITS = 8,
    parameter MAX_OUTPUTS = 100,
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
    output logic [MAX_OUTPUTS-1:0] output_array,
    output logic output_valid
);
    
    localparam IDLE = 0;
    localparam COLLECTING = 1;
    
    logic state;
    logic [INPUT_BITS-1:0] type_data;
    
    integer data_counter;
    integer data_counter_max;
    
    logic [MAX_OUTPUTS-1:0] tmp_output_array;
    
    
    localparam X_DATA = BITS_PER_X*NUM_X/INPUT_BITS;
    localparam W_DATA = BITS_PER_WEIGHT*NUM_WEIGHTS/INPUT_BITS;
    localparam B_DATA = BITS_PER_BIAS*NUM_BIASES/INPUT_BITS;
    
    // packet count basically
    // each has length input_bits
    always_comb begin
        case (type_data[1:0])
            X_TYPE: begin data_counter_max = X_DATA; end
            W_TYPE: begin data_counter_max = W_DATA; end
            B_TYPE: begin data_counter_max = B_DATA; end
            default: begin data_counter_max = 100; end //put some random number here
        endcase
    end
    
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
                        type_data <= input_value; //get data type (weight, in act)
                        tmp_output_array <= 0;
                        state <= COLLECTING;
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