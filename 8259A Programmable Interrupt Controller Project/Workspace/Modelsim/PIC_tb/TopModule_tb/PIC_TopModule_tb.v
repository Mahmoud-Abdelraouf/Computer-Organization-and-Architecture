module PIC_TopModule_tb;

// Inputs
reg INTA;
reg RD;
reg WR; 
reg A0; 
reg CS; 
wire [3:0] CAS; 
reg SP;
reg [7:0] IR0_to_IR7;

// Outputs
wire INT;
wire [7:0] sys_DataLine;

integer i, j, k, l, m, n, o, p;

PIC_TopModule topModuleInstance(
    .INTA(INTA),
    .INT(INT),
    .sys_DataLine(sys_DataLine),
    .RD(RD),
    .WR(WR),
    .A0(A0),
    .CS(CS),
    .CAS(CAS),
    .SP(SP),
    .IR0_to_IR7(IR0_to_IR7)
);



initial begin
    // initialize inputs
    INTA = 1;
    RD = 1;
    WR = 1;
    A0 = 0;
    CS = 1;
    SP = 0;
    IR0_to_IR7 = 8'b00000000;
    #10000

    // Apply Stimulus


   // Exhaustive simulation
  for (m = 0;m <= 10; m = m + 1) begin
    
  end
   

    // Loop through all possible combinations
    
    for (i = 0; i <= 1; i = i + 1) // INTA
      for (j = 0; j <= 1; j = j + 1) // RD
        for (k = 0; k <= 1; k = k + 1) // WR
          for (l = 0; l <= 1; l = l + 1) // A0
              for (n = 0; n <= 1; n = n + 1) // SP_EN
                for (o = 0; o <= 15; o = o + 1) // CAS
                  for (p = 0; p <= 255; p = p + 1) begin // IR0_to_IR7
                    INTA = i;
                    RD = j;
                    WR = k;
                    A0 = l;
                    SP = n;
                    IR0_to_IR7 = p;

                    // Add a delay for observation
                    #10;
                end
                


    $finish; // End Simulation
end

endmodule //PIC_TopModule_tb