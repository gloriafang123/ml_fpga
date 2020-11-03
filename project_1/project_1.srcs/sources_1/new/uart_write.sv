`timescale 1ns / 1ps

module top_level(
    input logic [7:0] data,             //  data to be sent
    input logic big_endian,             //  programmable switch, if true, output = big endian
    output logic [7:0] send_data  //  send_data[0] is sent first.
    );
    
   //  if big_endian, send out data[7] first. otw, send out data[0] first.
   always_comb begin
    if (big_endian == 1'b1) begin //big endian, so we flip it
      for (int i = 0; i < 8; i = i+1) begin
          send_data[i] = data[7-i];
      end
    end else begin
      send_data[7:0] = data[7:0]; //little endian, send data[0] first
    end
   end
   //
endmodule