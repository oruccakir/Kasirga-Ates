`timescale 1ns / 1ps

module Processor_tb;

  reg [31:0] instruction;
  wire [6:0] type;

  // Instantiate the Processor module
  Processor uut (
    .instruction(instruction),
    .type(type)
  );

  initial begin
    // Apply some test inputs
    instruction = 32'h00000000;
    #10; // Wait for 10 time units

    instruction = 32'hFFFFFFFF;
    #10;

    // Add more test inputs as needed...

    // Finish the simulation
    $finish;
  end

  initial begin
    // Monitor the type output
    $monitor("At time %t, type = %b", $time, type);
  end

endmodule
