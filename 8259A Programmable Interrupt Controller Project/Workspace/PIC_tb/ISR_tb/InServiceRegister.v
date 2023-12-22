module InServiceRegister (
  input wire [2:0] toSet,                 // Input: Signals indicating which interrupts to service (IR0-IR7)
  input wire readPriority,                // Input: Signal to read values from toSet
  input wire readIsr,                     // Input: Signal to output value of isrReg to IsrRegValue
  input wire sendVector,                  // Input: Signal to output vectorTable value to dataBuffer
  input wire [2:0] zeroLevelIndex,        // Input: Signals indicating IRx with highest priority
  input wire [7:0] ICW2,                  // Input: Initialization Command Word 2
  input wire [7:0] ICW4,                  // Input: Initialization Command Word 4
  input wire secondACK,                   // Input: Second acknowledge signal
  input wire changeInOCW2,                // Input: Signal indicating change in OCW2
  input wire [7:0] OCW2,                  // Input: Operation Command Word 2
  
  output reg [2:0] INTIndex,              // Output: Signals indicating which interrupts to service (IR0-IR7)
  output reg [7:0] dataBuffer,            // Output: Value of isrReg to the dataBuffer
  output reg [7:0] isrRegValue,           // Output: Value of isrReg to the PriorityResolver
  output reg [2:0] resetedIndex           // Output: Signal indicating end of interrupt mode
);

  reg [7:0] isrReg;                       // Register to store interrupts to be serviced
  reg [7:0] vectorAddress;                // Register to store calculated vector address
  reg [2:0] circularIndex_1;              // Register for circular iteration
  reg [2:0] circularIndex_2;              // Register for circular iteration
  
  // Logic to handle storing interrupts to be serviced
  always @(*) begin
    if (readPriority) begin
      // If readPriority is set, read the value on the toSet lines and update isrReg
      if (toSet) begin
        isrReg[toSet] = 1'b1; // Set corresponding bit in isrReg based on toSet value
      end
    end
  end
  
  // Logic to calculate vector address and output to dataBuffer if sendVector is set
  always @(*) begin
    if (sendVector) begin
      // Calculate vector address based on ICW2 and toSet values
      vectorAddress = {ICW2[7:3], toSet};
      // Output vector address to dataBuffer
      dataBuffer = vectorAddress;
    end
  end
  
  // Logic to output isrReg value if readIsr is set
  always @(*) begin
    if (readIsr) begin
      // Output value of isrReg to dataBuffer
      dataBuffer = isrReg;
    end
  end

  // Logic to output isrReg value for the PriorityResolver
  always @(*) begin
    // Output value of isrReg to PriorityResolver
    isrRegValue = isrReg;
  end
  
  // Logic to determine resetedIndex based on EOI
  always @(*) begin
    if (secondACK) begin
      if (ICW2[0] && ICW4[1]) begin // Checking IC4 in ICW1 and AEOI in ICW4
        // Automatic EOI logic
        for (circularIndex_1 = zeroLevelIndex; circularIndex_1 < (zeroLevelIndex + 8); circularIndex_1 = circularIndex_1 + 1) begin
          if (isrReg[circularIndex_1 % 8]) begin // Wrap around the circular index
            isrReg[circularIndex_1 % 8] = 1'b0; // Reset corresponding line in isrReg
            resetedIndex = circularIndex_1 % 8; // Store the resetedIndex
            break;
          end
        end
      end
    end
  end
  
  // Normal EOI logic for both non-specific and specific modes
  always @(*) begin
    if (changeInOCW2) begin
      if ((ICW2[0] == 0) && (OCW2[7:5] == 3'b001)) begin // Non-specific mode check
        if (OCW2[2:0]) begin
          isrReg[OCW2[2:0]] = 1'b0; // Reset specified lines in isrReg
          resetedIndex = OCW2[2:0]; // Store the resetedIndex
        end
      end else if ((ICW2[0] == 0) && (OCW2[7:5] == 3'b011)) begin // Specific mode check
        for (circularIndex_2 = zeroLevelIndex; circularIndex_2 < (zeroLevelIndex + 8); circularIndex_2 = circularIndex_2 + 1) begin
          if (isrReg[circularIndex_2 % 8]) begin // Wrap around the circular index
            isrReg[circularIndex_2 % 8] = 1'b0; // Reset corresponding line in isrReg
            resetedIndex = circularIndex_2 % 8; // Store the resetedIndex
            break;
          end
        end
      end
    end
  end
  
  // Logic to determine INTIndex based on toSet
  always @(*) begin
    INTIndex = toSet;
  end
endmodule