# ml_fpga
## Important files:

## Neural Net Files:
mnist_nn_small.sv
multiplier.sv
neuron.sv
relu.sv
neural_network.sv
iris_nn.sv

## Serial and Top Files:
top_digits_1.sv
serial_version_2.sv (includes all 5 modules)

### Early versions of serial:
uart_read.sv
uart_write.sv
gather_weights.sv

# Python files:
## For neural net:
(insert here)

## For serial
send_data.py, arduino file


# Instructions
Send data using send_data.py (weights, biases, x)
Watch the final_output update in the ILA (or on seven_seg)!




# Old Version Instructions
#How to run the whole thing
1. upload write\_to\_python\_nov\_11.ino to the arduino.
2. generate bistream using top level: top\_level\_read\_in.sv 
3. upload bitfile to fpga
4. connect gnd on fpga to gnd on arduino; connect jb\[0\] to pin 2 on arduino.
5. press btnc (tells fpga to get ready to receive weights. kind of hacky right now.)
6. press btnd (wired to the nn's reset right now)
7. run wso\_example\_weights.py. watch the seven seg update. the digits on the display are \[bias 6, weight 14, x\_in, final\_output\]. (also the digits only go up to f, so bias 6 shows up as 0 because it is 16.)

#Other notes
1. wso.py has hardcoded weights right now. I ran them by doing 8 times the actual weight (bc we have 3 decimals). But I'm pretty sure the two's complement is done wrong for some of the negatives.
2. x\_in is hardcoded in the top level


project_1/project_1.srcs/sources_1/ has sources
project_1/project_1.srcs/sim_1/ has testbenches
