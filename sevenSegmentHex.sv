`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Joseph Hawker
// 
// Module Name: sevenSegmentHex
// Target Devices: Nexys 4 DDR, Basys 3
// Tool Versions: Vivado 2016.2
// Description: This module is designed to take a binary number and then convert it
//              to display on a single seven-segment display.  It is a binary to
//              seven-segment display decoder.
//
//              -a-             a = segData[0]   e = segData[4]
//            f|   |b           b = segData[1]   f = segData[5]
//              -g-             c = segData[2]   g = segData[6]
//            e|   |c           d = segData[3]   dp = segData[7]
//              -d-  . <dp>
//
// Inputs:      [3:0] number    - Input number in full binary
// Outputs:     [7:0] segData   - Output data for putting number on a seven segment
//                                display as above.
// 
// Revision: 1.50
// Revision 1.50 - Converted to SystemVerilog
// Revision 1.00 - File completed
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module sevenSegmentHex(output reg [7:0] segData, input [3:0] number );

    always @ (number) begin
        case (number)
            4'h0: segData <= 8'b11000000;
            4'h1: segData <= 8'b11111001;
            4'h2: segData <= 8'b10100100;
            4'h3: segData <= 8'b10110000;
            4'h4: segData <= 8'b10011001;
            4'h5: segData <= 8'b10010010;
            4'h6: segData <= 8'b10000010;
            4'h7: segData <= 8'b11111000;
            4'h8: segData <= 8'b10000000;
            4'h9: segData <= 8'b10011000;
            4'hA: segData <= 8'b10001000;
            4'hB: segData <= 8'b10000011;
            4'hC: segData <= 8'b10100111;
            4'hD: segData <= 8'b10100001;
            4'hE: segData <= 8'b10000110;
            4'hF: segData <= 8'b10001110;
            default: segData <= 8'b01111111;
        endcase
    end

endmodule
