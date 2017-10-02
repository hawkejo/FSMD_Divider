`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Joseph Hawker
// 
// Create Date: 09/26/2017 04:23:35 PM
// Design Name: FSMD Divider
// Module Name: divider
// Project Name: FSMD Divider
// Target Devices: Nexys 4 DDR, Basys 3, Nexys 4
// Tool Versions: Vivado 2017.2
// Description: A finite state machine  with data design designed to divide two
//              numbers and return the result and remainder.
//
//              < INPUTS >
//              divisor, dividend:  The operands for the operation performed in the
//                                  following manner: dividend / divisor.
//              start:              Starts the division operation.
//              rst:                Stops the operation, and sets all registers to 0.
//                                  This signal is low asserted.
//              clk:                The clock signal for the state machine.  The design
//                                  runs on the rising clock edge and has been tested at
//                                  100 MHz.
//
//              < OUTPUTS >
//              quotient:           The result of the division operation.
//              remainder:          The remainder, or extra values of the division
//                                  operation.  remainder / divisor
//
//              < PARAMETERS >
//              WORD_SIZE:          The number of bits of the numbers to be used
//                                  in the division operation.
//              COUNTER_SIZE:       The size of the down counter indicating that the
//                                  operation is done.  The size should be computed
//                                  as follows: log_base2(WORD_SIZE) + 1
// 
// Dependencies: 100 MHz clock
// 
// Revision: 1.00 - File Completed with design scaled to 32 bits.  Tested with the
//                  design scaled at 8, 16, and 32 bits.
// Revision 0.01 - File Created
// Additional Comments: In theory, the design should easily scale to 64-bits, 128-
//                      bits and beyond.  I just have no way to test with numbers
//                      of that size.
//////////////////////////////////////////////////////////////////////////////////


module divider(quotient, remainder, divisor, dividend, start, clk, rst);
    // Parameters used to define the word size used by the state machine
    parameter WORD_SIZE     = 32;
    parameter COUNTER_SIZE  = 6;    // log_base2(WORD_SIZE = 32) + 1 = 5 + 1 = 6
    
    // Define the states used by the state machine divider.
    parameter INIT          = 2'h0;
    parameter SHIFT_LEFT    = 2'h1;
    parameter LOAD          = 2'h2;
    parameter DONE          = 2'h3;
    
    // Inputs and the output for the divider
    output reg [WORD_SIZE - 1:0] quotient, remainder;
    input [WORD_SIZE - 1:0] divisor, dividend;
    input [0:0] start, clk, rst;
    
    // Register declarations
    reg [1:0] state, nextState;         // Registers for the current and next states.
    reg [WORD_SIZE - 1:0] D;            // Divisor register.  The value is positive.
    reg [WORD_SIZE - 1:0] count;            // Counter to determine if we're done.
    
    // Wire and signal declarations
    reg initReg;                       // Load signal for the initial loading of the registers.
    wire N_GTE_D;                       // Signal indicating numerator >= divisor
    reg shiftQuotient;                 // Signal to shift the quotient reg left
    reg enShiftLeft;                   // Signal to shift the remainder reg left
    reg enLoad;                        // Signal to enable loading the remainder reg
    reg selDifference;                 // Source select for loading the remainder reg
    wire done;                          // Signal from counter to indicate that we're done.
    wire [WORD_SIZE - 1:0] T;           // Negated divisor value.
    wire [WORD_SIZE - 1:0] difference;  // Difference for subtraction operation.
    
    // Handle the next state registers for the design    
    // Start in the done state indicating that we are waiting for inputs
    initial state = DONE;
    
    // Every clock edge, load the new state based on the IFL.
    // Unconditional reset present for paranoia.
    always_ff @(posedge clk, negedge rst) begin
        if (~rst)
            state <= DONE;
        else
            state <= nextState;
    end
    
    // Implement the logic for the divisor register    
    initial D <= 0;
    
    // Used to hold the value of the divisor used in the design.
    // A low asserted reset is included out of paranoia.
    always_ff @(posedge clk, negedge rst) begin
        if (~rst)
            D <= 0;
        else if (initReg)
            D <= divisor;
    end
    
    // Used to handle the dividend and the quotient.  The register value
    // is the output quotient for the deisgn.
    initial quotient <= 0;
    
    always_ff @(posedge clk, negedge rst) begin
        if (~rst)
            quotient <= 0;
        else if (initReg)
            quotient <= dividend;
        else if (shiftQuotient)
            quotient <= {quotient[WORD_SIZE - 2:0], N_GTE_D};
        else
            quotient <= quotient;
    end
    
    // Used to handle the remainder and the dividend.  The register value
    // is the output remainder for the design.
    initial remainder <= 0;
    
    always_ff @(posedge clk, negedge rst) begin
        if (~rst)
            remainder <= 0;
        else if (enLoad) begin
            if (selDifference)
                remainder <= difference;
            else // !selDifference
                remainder <= 0;
        end
        else if (enShiftLeft)
            remainder <= {remainder[WORD_SIZE - 2:0], quotient[WORD_SIZE - 1]};
        else
            remainder <= remainder;
    end
    
    // The counter block used to determine whether or not we're done.
    initial count <= 0;
    
    always_ff @(posedge clk, negedge rst) begin
        if (~rst)
            count <= 0;
        else if (initReg)
            count <= WORD_SIZE;
        else if (count > 0)
            count <= count - 1;
    end
    
    assign done = (count == 0)?1'b1:1'b0;
    
    // The subtractor circuit for use in the divider.
    // First, negate the divisor with a 2's complement method.
    assign T = ~D + 1;
    // Second, perform the subtraction operation with black voodoo magic.
    assign {N_GTE_D, difference} = {remainder[WORD_SIZE - 2:0], quotient[WORD_SIZE - 1]} + T;
    
    // The next state logic.  Uses the signals being passed around to determine what
    // state the divider should go into next.
    always @(state, start, N_GTE_D, done) begin
        case (state)
            INIT: begin
                if (!start && !N_GTE_D)     nextState = SHIFT_LEFT;
                else if (!start && N_GTE_D) nextState = LOAD;
                else                        nextState = INIT;
            end
            SHIFT_LEFT: begin
                if (!N_GTE_D && !done)      nextState = SHIFT_LEFT;
                else if (!N_GTE_D && done)  nextState = DONE;
                else if (N_GTE_D && !done)  nextState = LOAD;
                else if (N_GTE_D && done)   nextState = DONE;
                else                        nextState = DONE;
            end
            LOAD: begin
                if (!N_GTE_D && !done)      nextState = SHIFT_LEFT;
                else if (!N_GTE_D && done)  nextState = DONE;
                else if (N_GTE_D && !done)  nextState = LOAD;
                else if (N_GTE_D && done)   nextState = DONE;
                else                        nextState = DONE;
            end
            DONE: begin
                if (start)                  nextState = INIT;
                else /* !start */           nextState = DONE;
            end
        endcase
    end
    
    // Signal circuitry for controlling the rest of the divider.
    always @ (nextState) begin
        case (nextState)
            INIT:       begin initReg = 1'b1; enShiftLeft = 1'b0;
                        enLoad = 1'b1; selDifference = 1'b0; shiftQuotient = 1'b0; end
            SHIFT_LEFT: begin initReg = 1'b0; enShiftLeft = 1'b1;
                        enLoad = 1'b0; selDifference = 1'b0; shiftQuotient = 1'b1; end
            LOAD:       begin initReg = 1'b0; enShiftLeft = 1'b0;
                        enLoad = 1'b1; selDifference = 1'b1; shiftQuotient = 1'b1; end
            DONE:       begin initReg = 1'b0; enShiftLeft = 1'b0;
                        enLoad = 1'b0; selDifference = 1'b0; shiftQuotient = 1'b0; end
        endcase
    end
    
endmodule
