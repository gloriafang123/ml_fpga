# ml_fpga
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
