// Purpose  : This module is the functios of the processor.
// Functionality : This module is responsible for defining the functions of the processor.
// File : functions.vh
// DEFINE THE FUNCTIONS

// Include the definitions
`include "definitions.vh"

task determine_the_unit(    
    input wire [3:0] unit_type
);
    begin
        case(unit_type):
            `ARITHMETIC_LOGIC_UNIT:
                begin
                    $display("The unit is Arithmetic Logic Unit");
                end
            `CONTROL_UNIT:
                begin
                    $display("The unit is Control Unit");
                end
            `INTEGER_DIVISION_UNIT:
                begin
                    $display("The unit is Integer Division Unit");
                end
            `FLOATING_POINT_UNIT:
                begin
                    $display("The unit is Floating Point Unit");
                end
            `INTEGER_DIVISION_UNIT:
                begin
                    $display("The unit is Integer Division Unit");
                end
            `BRANCH_RESOLVER_UNIT:
                begin
                    $display("The unit is Branch Resolver Unit");
                end
            `CONTROL_STATUS_UNIT:
                begin
                    $display("The unit is Control Status Unit");
                end
            `ATOMIC_UNIT:
                begin
                    $display("The unit is Atomic Unit");
                end
            `BIT_MANIPULATION_UNIT:
                begin
                    $display("The unit is Bit Manipulation Unit");
                end
            default:
        endcase
    end

endtask

