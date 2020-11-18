`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module gather_weights_into_one_array(
    input clk_100mhz,
    input start_gathering, //btnc
    input valid_input, // bit true if valid
    input [7:0] x, // input to gather
    
    output logic [14:0]  [7:0] weights,
    output logic [6:0] [7:0] biases ,
    output logic output_ready
    );
    
    logic state; //1 if gathering
    // start gathering when start_gathering is true
    // end gathering when weights and biases are filled
    logic [6:0] input_counter;
    
    always_ff @(posedge clk_100mhz) begin
        if (start_gathering) begin
            state <= 1; //gathering
            input_counter <= 0;
            output_ready <= 0;
        end
        if (state == 1) begin
            output_ready <= 0;
            if (valid_input) begin
                input_counter <= input_counter + 1;
                if (input_counter <= 14) begin
                    weights[input_counter] <= x;
                end
                else begin
                    biases[input_counter-15] <= x;
                end
                
                // do this inside valid_input only
                if ((input_counter + 1) == 22) begin //15+7
                    state <= 0;
                    output_ready <= 1;
                end
            end
            
            
        end
    end
endmodule
