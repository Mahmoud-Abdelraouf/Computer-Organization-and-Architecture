/**
 * @file PriorityResolver_tbAutoRotation.v .
 * @brief Testbench for the Priority Resolver module with automatic rotation mode.
 */

 /**
 * @brief Testbench for the Priority Resolver module.
 * @details Simulates various scenarios to verify the functionality of the Priority Resolver module.
 */
 module PriorityResolver_tbAutoRotation();
 // Inputs
    reg freezing;
    reg [7:0] IRR_reg;
    reg [7:0] ISR_reg;
    reg [2:0] resetedISR_index;
    reg [7:0] OCW2;
    reg INT_requestAck = 0;


    // Outputs
    wire [2:0] serviced_interrupt_index;
    wire [2:0] zeroLevelPriorityBit;
    wire INT_request;


    // Instantiate the InterruptRequestRegister module
    PriorityResolver pr_inst(
        .freezing(freezing),
        .IRR_reg(IRR_reg),
        .ISR_reg(ISR_reg),
        .resetedISR_index(resetedISR_index),
        .OCW2(OCW2),
        .INT_requestAck,
        .serviced_interrupt_index(serviced_interrupt_index),
        .zeroLevelPriorityBit(zeroLevelPriorityBit),
        .INT_request(INT_request)
    );
    
    integer testCaseNo;
    integer i;
    integer j;
    integer k;
    integer oldISR;
    // Stimulus
    initial begin
      /*
       * Automatic rotation tests.
       * OCW2 will have the value of 000xxxxx or 100xxxxx or 101xxxxx.
       * Zero priority level index must equal resetedISR_index + 1 all the time.
       * Check All the expected outputs to be as expected.
       */
       #20 testCaseNo = 0;
        //->Test case 0: 
        // -Inputs: ISR empty, IRR changes randomly, resetedISR_index is the test variable, will be all the possible values, 
        // OCW2 indicates for AUTO_ROTATION_MODE (Test variable), INT_requestAck is zero.
        // -Expected Outputs: serviced_interrupt_index is x,
        // (important) zeroLevelPriorityBit is resetedISR_index + 1 all the time, INT_request is changes with IRR_reg.
        // -The test flow: check all the values of OCW2 to give all the expected outputs.
        ISR_reg = 8'b0;
        IRR_reg = 8'b0;
        resetedISR_index = 3'b0;
        INT_requestAck = 1'b0;
        freezing = 1'b0;
        for(i = 0; i < 32; i = i + 1) begin
            OCW2 = {3'b000, i[4:0]};
            IRR_reg = $urandom;
            resetedISR_index = $urandom;
            #10;
        end
        for(i = 0; i < 32; i = i + 1) begin
            OCW2 = {3'b100, i[4:0]};
            IRR_reg = $urandom;
            resetedISR_index = $urandom;
            #10;
        end        
        for(i = 0; i < 32; i = i + 1) begin
            OCW2 = {3'b101, i[4:0]};
            IRR_reg = $urandom;
            resetedISR_index = $urandom;
            #10;
        end
        //reset values
        ISR_reg = 8'bx;
        IRR_reg = 8'bx;
        resetedISR_index = 1'bx;
        INT_requestAck = 1'bx;
        OCW2 = 1'bx;
        freezing = 1'bx;


        #20 testCaseNo = 1;
        //->Test case 1: 
        // -Inputs: ISR changes (test variable), IRR changes (test variable), resetedISR_index changes (test variable), 
        // OCW2 indicates for AUTO_ROTATION_MODE, INT_requestAck is zero at the beginning.
        // The freezing signal is zero.
        // -Expected Outputs: (important) serviced_interrupt_index is the index of higher bit in IRR,
        // (important) zeroLevelPriorityBit is zero always, INT_request is impulse always when needed, we will respond with ack for each INT_request.
        // -The test flow: check all the values of IRR_reg according to ISR values to give all the expected outputs.
        resetedISR_index = 3'b0;
        INT_requestAck = 1'b0;
        freezing = 1'b0;
        ISR_reg = 8'b0;
        IRR_reg = 8'b0;
        oldISR = 8'b0;
        OCW2 = ($urandom & 8'b00011111) | ($urandom_range(0, 1) ? 8'b00000000 : 8'b10100000);
        #10
        for(i = 0; i < 256; i = i + 1) begin
            for(j = 0; j < 256; j = j + 1) begin
            ISR_reg = i;
            IRR_reg = j;
            for(k = 0; k < 8; k = k + 1) begin
              if(oldISR[k] == 1) begin
                resetedISR_index = k;
                k = 8;
              end
            end
            #10;
            end
            oldISR <= ISR_reg;
        end

        $stop;
    end
    /*
    * When an INT_request arrived, INT_requestAck must be inverted.
    */
    always @(posedge INT_request) begin
        INT_requestAck <= ~INT_requestAck;
    end
    
 endmodule    