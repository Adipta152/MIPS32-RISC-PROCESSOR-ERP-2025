//DONE

`include "mips_defines.vh"
`timescale 1ns/1ns
/**********************************************************************************.
**********************************************************************************/
module sign_extend (
    input  [15:0] immediate_in,
    output [31:0] immediate_out
);
    assign immediate_out = { {16{immediate_in[15]}}, immediate_in };

endmodule