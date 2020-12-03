`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module gather_weights_into_one_array(
     clk_100mhz,
     start_gathering, //btnc
     valid_input, // bit true if valid
    x, // input to gather
    
    weights,
    biases ,
    output_ready
    );
    
    parameter NUM_WEIGHTS = 15;
    parameter NUM_BIASES = 7;
    
    parameter BITS = 8;
    
    input clk_100mhz;
    input start_gathering; //btnc
    input valid_input; // bit true if valid
    input [BITS-1:0] x; // input to gather
    
    output logic [NUM_WEIGHTS-1:0]  [BITS-1:0] weights;
    output logic [NUM_BIASES-1:0] [BITS-1:0] biases ;
    output logic output_ready;
    
    
    
    logic state; //1 if gathering
    // start gathering when start_gathering is true
    // end gathering when weights and biases are filled
    // state 0 do nothing
    
    logic [6:0] input_counter;
    
    always_ff @(posedge clk_100mhz) begin
        output_ready <= 0; // only pulses to 1 if ready
        if (start_gathering) begin
            state <= 1; //gathering
            input_counter <= 0;
        end
        if (state == 1) begin
            
            if (valid_input) begin
                input_counter <= input_counter + 1;
                if (input_counter <= (NUM_WEIGHTS - 1)) begin
                    weights[input_counter] <= x;
                end
                else begin
                    biases[input_counter-NUM_WEIGHTS] <= x;
                end
                
                // do this inside valid_input only
                if ((input_counter + 1) == (NUM_WEIGHTS + NUM_BIASES)) begin //15+7
                    state <= 0;
                    output_ready <= 1; // pulse
                end
            end
            
        end
    end
endmodule
