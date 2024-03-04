// File: CsrRegisterFile.v
// Purpose: Define a module for the CSR register file

module CsrRegisterFile(
    input wire clk_i, // clock signal
    input wire rst_i, // reset signal
    input wire csr_write_enable_i, // write enable
    input wire [11:0] csr_address_i, // address of CSR to write
    input wire [31:0] csr_write_data_i, // data to write
    input wire csr_read_enable_i, // read enable
    output reg [31:0] csr_read_data_o // data from CSR
);

// Define CSRs
// Machine Status: Contains the global interrupt enable/disable bit.
reg [31:0] mstatus; // Machine status register

//  Machine Interrupt Pending: Contains the Machine-Level interrupt pending bits. A bit is set if its associated interrupt is pending
reg [31:0] mip; // Machine interrupt pending register

// Machine Cause: Holds the cause of the interrupt or exception.
reg [31:0] mcause; // Machine cause register

// Machine ISA: Contains the supported ISA extensions.
reg [31:0] misa; // ISA register                       // will be examined later

// Machine Exception Program Counter: Contains the address of the instruction that caused the exception.
reg [31:0] mepc; // Machine exception program counter register

// Machine Interrupt Enable: Contains the Machine-Level interrupt enable/disable bits
reg [31:0] mie; // Machine interrupt enable register

// Machine Trap Vector: Holds the base address of the interrupt/exception handler.
reg [31:0] mtvec; // Machine trap vector base address

// Machine Scratch: Dedicated register for Machine-Level code. 
reg [31:0] mscratch; // Machine scratch register

// CSR read and write logic
always @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        // Initialize CSRs to default values on reset
        mstatus <= 32'b0;
        misa <= 32'b0; 
        mepc <= 32'b0;
        mip <= 32'b0;
        mcause <= 32'b0;
        mie <= 32'b0;
        mtvec <= 32'b0;
        mscratch <= 32'b0;
    end else if (csr_write_enable_i) begin
        // Write data to CSR based on csr_address
        case (csr_address_i)
            12'h300: mstatus <= csr_write_data_i;
            12'h301: misa <= csr_write_data_i;
            12'h341: mepc <= csr_write_data_i;
            12'h344: mip <= csr_write_data_i;
            12'h342: mcause <= csr_write_data_i;
            12'h304: mie <= csr_write_data_i;
            12'h305: mtvec <= csr_write_data_i;
            12'h340: mscratch <= csr_write_data_i;
            default: ;
        endcase
    end
    // Read data from CSR based on csr_address
    if (csr_read_enable_i) begin
        case (csr_address_i)
            12'h300: csr_read_data_o <= mstatus;
            12'h301: csr_read_data_o <= misa;
            12'h341: csr_read_data_o <= mepc;
            12'h344: csr_read_data_o <= mip;
            12'h342: csr_read_data_o <= mcause;
            12'h304: csr_read_data_o <= mie;
            12'h305: csr_read_data_o <= mtvec;
            12'h340: csr_read_data_o <= mscratch;
            default: csr_read_data_o <= 32'b0; // Return 0 for unsupported addresses
        endcase
    end
end

endmodule
