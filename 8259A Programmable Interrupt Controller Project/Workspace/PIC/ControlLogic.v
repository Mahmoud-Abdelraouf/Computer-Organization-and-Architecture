module ControlLogic(
    input INTA,                             // Input: Interrupt acknowledge from CPU
    input INT_request,                      // Input: Interrupt request from priority resolver
    input cascade_flag,                     // Input: In case of slave, it will be sent from cascade in case of desired slave
    input read_cmd_to_ctrl_logic,           // Input: Sent from read/write logic to read status of ISR or IRR or priority
    input [7:0] OCW3,                       // Input: Will be used to know which register to read its status 
    input write_flag,                       // Input: to indicate that there are writing operation 
    input [2:0] interrupt_index,
    input SP,
    input [7:0]ICW3,

    output reg read_IRR,                    // Output: Signal to read IRR status ( will be sent to IRR)
    output reg read_priority,               // Output: Is set after the first INTA pulse (will be sent to IRR and ISR)
    output reg freezing,                    // Output: Is set between to INTA pulse.
    output reg read_ISR,                    // Output: Signal to read ISR status ( will be sent to ISR)
    output reg pulse_ACK,                   // Output: Acknowledge will be sent to ISR
    output reg INT,                         // Output: Interrupt request will be sent to CPU
    output reg cascade_signal,              // Output: Signal will be sent to cascade controller to start working
    output reg desired_slave                // Output: Slave ID that will be sent to cascade controller in case of master
    output reg send_vector_isr 
);
   // Configurations for read_ISR and read_IRR flags
    localparam read_from_ISR =2'b11;        // Local parameter representing read from ISR mode
    localparam read_from_IRR =2'b01;        // Local parameter representing read from IRR mode
    reg [1:0] read_register;    
    always @(OCW3)begin
        read_register=OCW3[1:0]; 
    end
    
    // Do configurations when recieving signal from read/write logic
    always @(posedge read_cmd_to_ctrl_logic) begin
        // Decide what flag to set based on coming signal 
        case(read_register)
            read_from_ISR: begin
                read_ISR<=1'b1; // set read from ISR flag to send ISR register
                read_IRR<=1'b0; // reset read from IRR flag 
            end
            read_from_IRR: begin
                read_IRR<=1'b1; // set read from IRR flag to send IRR register
                read_ISR<=1'b0; // reser read from ISR flag
            end
        endcase 
    end

    // Configurations for freezing and read_priority flags
    localparam first_INTA=1'b0;         // Local parameter representing first INTA
    localparam second_INTA=1'b1;        // Local parameter representing second INTA
    reg counter=0; //  counter for first and second INTA
    always@(negedge INTA)begin
        // if it's the first INTA set read_priority and freezing flags
        if(counter==first_INTA)begin
            read_priority<=1'b1;
            freezing<=1'b1;
            counter=counter+1;
        end
        // if it't the second INTA reset read_priority and freezing flags
        else if(counter==second_INTA)begin
            read_priority<=1'b0;
            freezing<=1'b0;
            counter=1'b0;
        end
    end

    // Handling INT request which will be sent to Processor
    // if there are any reading or writing operations we cann't send any interrupt
    always@(posedge INT_request)
    begin
        if(write_flag == 1'b0 && read_cmd_to_ctrl_logic == 1'b0)
        begin
            INT <= 1'b1;
        end
    end
    localparam Slave = 1'b0;
    localparam Master = 1'b1;
    always@(*)
    begin
        if(Slave == SP)
        begin
            send_vector_isr <= 1'b1;
        end
        else if (Master == SP)
        begin
            case(interrupt_index)
                // 110 -> isr / *****************
            endcase
        end
    end


endmodule