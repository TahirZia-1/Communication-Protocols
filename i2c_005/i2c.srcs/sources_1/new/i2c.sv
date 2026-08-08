`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2026 09:35:30 AM
// Design Name: 
// Module Name: i2c
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Module Name : i2c_master
//
// Description:
// Single-Master I2C Controller
//
// Features:
// • Single-byte Write
// • Single-byte Read
// • 7-bit Slave Address
// • Standard Mode (100 kHz)
//
// Lab Tasks
// ----------
// 1. Generate I2C timing tick.
// 2. Generate START condition.
// 3. Transmit slave address + R/W bit.
// 4. Receive ACK from slave.
// 5. Write one data byte.
// 6. Read one data byte.
// 7. Generate ACK/NACK.
// 8. Generate STOP condition.
//
//////////////////////////////////////////////////////////////////////////////////

module i2c_master #(
    parameter integer CLOCK_FREQ_HZ = 100_000_000,
    parameter integer I2C_FREQ_HZ   = 100_000
)
(
    input  wire       clk,
    input  wire       rst_n,

    input  wire       start,
    input  wire       rw,          // 0 = Write, 1 = Read

    input  wire [6:0] slave_addr,
    input  wire [7:0] tx_data,

    output reg [7:0]  rx_data,

    output reg        busy,
    output reg        done,
    output reg        ack_error,

    output reg        scl,

    inout  wire       sda
);

    //====================================================
    // Clock Divider
    //====================================================

    // TODO:
    // Calculate tick divider

    parameter integer TICK_DIV = CLOCK_FREQ_HZ / I2C_FREQ_HZ;


    //====================================================
    // State Encoding
    //====================================================

    localparam ST_IDLE      = 4'd0;
    localparam ST_START     = 4'd1;
    localparam ST_SEND_ADDR = 4'd2;
    localparam ST_ADDR_ACK  = 4'd3;
    localparam ST_WRITE     = 4'd4;
    localparam ST_WRITE_ACK = 4'd5;
    localparam ST_READ      = 4'd6;
    localparam ST_READ_ACK  = 4'd7;
    localparam ST_STOP      = 4'd8;
    localparam ST_DONE      = 4'd9;


    //====================================================
    // Internal Registers
    //====================================================

    reg [3:0] state;

    reg [1:0] phase;

    reg [3:0] bit_cnt;

    reg [7:0] shift_reg;

    reg [31:0] tick_count;

    reg tick;

    reg sda_drive_low;


    //====================================================
    // SDA Open-Drain Driver
    //====================================================

    // TODO:
    // Drive SDA LOW when required.
    // Otherwise release the line.

    assign sda = sda_drive_low ? 1'b0 : 1'bz;


    //====================================================
    // Tick Generator
    //====================================================

    always @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin
        tick_count <= 32'd0;
        tick <= 1'b0;

            //--------------------------------------------
            // TODO:
            // Reset counter
            //--------------------------------------------

        end
        else
        begin
         if (tick_count == TICK_DIV - 1) begin
             tick_count <= 32'd0;
             tick       <= 1'b1;
         end else begin
             tick_count <= tick_count + 1;
             tick       <= 1'b0;
         end

            //--------------------------------------------
            // TODO:
            // Generate timing tick
            //--------------------------------------------

        end

    end


    //====================================================
    // I2C Master State Machine
    //====================================================

    always @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin
        state <= ST_IDLE;
        phase <= 2'd0;
        bit_cnt <= 4'd0;
        shift_reg <= 8'd0;
        
        scl <= 1'b1; 
        sda_drive_low <= 1'b0;  
        
        rx_data <= 8'd0;
        busy <= 1'b0;
        done <= 1'b0;
        ack_error <= 1'b0;

            //--------------------------------------------
            // TODO:
            // Initialize all registers
            //--------------------------------------------

        end
        else
        begin
        done <= 1'b0;

            //--------------------------------------------
            // TODO:
            // Default done signal
            //--------------------------------------------

            if(tick)
            begin

                case(state)

                //------------------------------------------------
                // IDLE State
                //------------------------------------------------
                ST_IDLE:
                begin
                if (start) begin
                shift_reg <= {slave_addr, rw};
                bit_cnt <= 4'b0000;
                
                busy <= 1'b1;
                ack_error <= 1'b0;
                
                state <= ST_START;
                end else begin
                busy <= 1'b0;
                end
                

                    // TODO:
                    // Wait for start command
                    // Load slave address
                    // Initialize bit counter

                end


                //------------------------------------------------
                // START Condition
                //------------------------------------------------
                ST_START:
                begin
                case(phase)
                        2'd0: begin
                            sda_drive_low <= 1'b0; 
                            scl <= 1'b1; 
                            phase <= 2'd1;
                        end
                        2'd1: begin
                            //START
                            sda_drive_low <= 1'b1; 
                            scl <= 1'b1; 
                            phase <= 2'd2;
                        end
                        2'd2: begin
                            sda_drive_low <= 1'b1; 
                            scl <= 1'b1; 
                            phase <= 2'd3;
                        end
                        2'd3: begin
                            //ready for data transmission
                            sda_drive_low <= 1'b1; 
                            scl <= 1'b0; 
                            
                            phase <= 2'd0;
                            state <= ST_SEND_ADDR;
                        end
                    endcase
                

                    // TODO:
                    // Generate I2C START condition

                end


                //------------------------------------------------
                // Send Slave Address + R/W
                //------------------------------------------------
                ST_SEND_ADDR:
                begin
                case(phase)
                        2'd0: begin
                            sda_drive_low <= ~shift_reg[7]; 
                            scl <= 1'b0; 
                            phase <= 2'd1;
                        end
                        2'd1: begin
                            // PHASE 1: Pull SCL HIGH. 
                            scl <= 1'b1; 
                            phase <= 2'd2;
                        end
                        2'd2: begin
                            // PHASE 2: Hold SCL HIGH.
                            scl <= 1'b1; 
                            phase <= 2'd3;
                        end
                        2'd3: begin
                            // PHASE 3: Pull SCL LOW.
                            scl <= 1'b0; 
                            
                            shift_reg <= {shift_reg[6:0], 1'b0};
                            
                            bit_cnt <= bit_cnt + 1'b1;
                            
                            if (bit_cnt == 4'd7) begin
                                state <= ST_ADDR_ACK;
                                bit_cnt <= 4'd0;
                            end
                            
                            phase <= 2'd0;
                        end
                    endcase
                

                    // TODO:
                    // Send address bits
                    // MSB first

                end


                //------------------------------------------------
                // Address ACK
                //------------------------------------------------
                ST_ADDR_ACK:
                begin
                case(phase)
                        2'd0: begin
                            sda_drive_low <= 1'b0; // Release SDA
                            scl           <= 1'b0; 
                            phase         <= 2'd1;
                        end
                        2'd1: begin
                            scl           <= 1'b1; 
                            phase         <= 2'd2;
                        end
                        2'd2: begin
                            ack_error     <= sda;  // Read ACK
                            scl           <= 1'b1; 
                            phase         <= 2'd3;
                        end
                        2'd3: begin
                            scl           <= 1'b0; 
                            phase         <= 2'd0;
                            
                            if (ack_error == 1'b1) begin
                                state <= ST_STOP;  // NACK 
                            end else begin
                                if (rw == 1'b0) begin
                                    state     <= ST_WRITE;
                                    shift_reg <= tx_data; // Pre-load TX
                                end else begin
                                    state     <= ST_READ;
                                end
                            end
                        end
                    endcase

                    // TODO:
                    // Release SDA
                    // Read ACK bit

                end


                //------------------------------------------------
                // Write Data
                //------------------------------------------------
                ST_WRITE:
                begin
                case(phase)
                        2'd0: begin sda_drive_low <= ~shift_reg[7]; scl <= 1'b0; phase <= 2'd1; end
                        2'd1: begin scl <= 1'b1; phase <= 2'd2; end
                        2'd2: begin scl <= 1'b1; phase <= 2'd3; end
                        2'd3: begin
                            scl       <= 1'b0; 
                            shift_reg <= {shift_reg[6:0], 1'b0}; // Shift left
                            bit_cnt   <= bit_cnt + 1'b1;
                            
                            if (bit_cnt == 4'd7) begin
                                state   <= ST_WRITE_ACK;
                                bit_cnt <= 4'd0;
                            end
                            phase <= 2'd0;
                        end
                    endcase

                    // TODO:
                    // Send one data byte

                end


                //------------------------------------------------
                // Write ACK
                //------------------------------------------------
                ST_WRITE_ACK:
                begin
                case(phase)
                        2'd0: begin sda_drive_low <= 1'b0; scl <= 1'b0; phase <= 2'd1; end // Release SDA
                        2'd1: begin scl <= 1'b1; phase <= 2'd2; end
                        2'd2: begin ack_error <= sda; scl <= 1'b1; phase <= 2'd3; end      // Read ACK
                        2'd3: begin
                            scl   <= 1'b0; 
                            phase <= 2'd0;
                            state <= ST_STOP; // Single byte done
                        end
                    endcase

                    // TODO:
                    // Receive ACK from slave

                end


                //------------------------------------------------
                // Read Data
                //------------------------------------------------
                ST_READ:
                begin
                case(phase)
                        2'd0: begin sda_drive_low <= 1'b0; scl <= 1'b0; phase <= 2'd1; end // Release SDA
                        2'd1: begin scl <= 1'b1; phase <= 2'd2; end
                        2'd2: begin 
                            rx_data <= {rx_data[6:0], sda}; // Sample SDA
                            scl     <= 1'b1; 
                            phase   <= 2'd3; 
                        end
                        2'd3: begin
                            scl     <= 1'b0; 
                            bit_cnt <= bit_cnt + 1'b1;
                            
                            if (bit_cnt == 4'd7) begin
                                state   <= ST_READ_ACK;
                                bit_cnt <= 4'd0;
                            end
                            phase <= 2'd0;
                        end
                    endcase

                    // TODO:
                    // Read one byte
                    // Store into rx_data

                end


                //------------------------------------------------
                // Read ACK/NACK
                //------------------------------------------------
                ST_READ_ACK:
                begin
                case(phase)
                        2'd0: begin 
                            sda_drive_low <= 1'b0; // NACK (Float HIGH) to end read
                            scl           <= 1'b0; 
                            phase         <= 2'd1; 
                        end
                        2'd1: begin scl <= 1'b1; phase <= 2'd2; end
                        2'd2: begin scl <= 1'b1; phase <= 2'd3; end
                        2'd3: begin 
                            scl   <= 1'b0; 
                            phase <= 2'd0; 
                            state <= ST_STOP; 
                        end
                    endcase

                    // TODO:
                    // Send NACK after last byte

                end


                //------------------------------------------------
                // STOP Condition
                //------------------------------------------------
                ST_STOP:
                begin
                case(phase)
                        2'd0: begin sda_drive_low <= 1'b1; scl <= 1'b0; phase <= 2'd1; end // SDA LOW
                        2'd1: begin sda_drive_low <= 1'b1; scl <= 1'b1; phase <= 2'd2; end // SCL HIGH
                        2'd2: begin sda_drive_low <= 1'b0; scl <= 1'b1; phase <= 2'd3; end // SDA HIGH (STOP)
                        2'd3: begin phase <= 2'd0; state <= ST_DONE; end // Wait, then finish
                    endcase

                    // TODO:
                    // Generate STOP condition

                end


                //------------------------------------------------
                // DONE State
                //------------------------------------------------
                ST_DONE:
                begin
                busy  <= 1'b0; // Clear busy
                done  <= 1'b1; // Assert done
                state <= ST_IDLE; // Return

                    // TODO:
                    // Clear busy
                    // Assert done
                    // Return to IDLE

                end


                //------------------------------------------------
                // Default
                //------------------------------------------------
                default:
                begin
                state <= ST_IDLE;

                    // TODO:
                    // Return to IDLE

                end

                endcase

            end

        end

    end

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name : i2c_slave
//
// Description:
// Educational I2C Slave Controller
//
// Features
// --------
// • 7-bit Slave Address
// • Single-byte Write
// • Single-byte Read
// • ACK Generation
// • Open-Drain SDA
//
// Lab Tasks
// ---------
// 1. Detect START condition.
// 2. Detect STOP condition.
// 3. Receive slave address.
// 4. Compare received address with SLAVE_ADDR.
// 5. Generate ACK.
// 6. Receive one data byte.
// 7. Transmit one data byte.
// 8. Generate ACK after write.
//
//////////////////////////////////////////////////////////////////////////////////

module i2c_slave #(
    parameter [6:0] SLAVE_ADDR = 7'h50
)
(
    input  wire       clk,
    input  wire       rst_n,

    input  wire       scl,
    inout  wire       sda,

    output reg [7:0]  received_data,
    input  wire [7:0] transmit_data,

    output reg        data_valid
);

    //====================================================
    // State Encoding
    //====================================================

    localparam ST_IDLE      = 3'd0;
    localparam ST_ADDR      = 3'd1;
    localparam ST_ACK_ADDR  = 3'd2;
    localparam ST_WRITE     = 3'd3;
    localparam ST_ACK_DATA  = 3'd4;
    localparam ST_READ      = 3'd5;


    //====================================================
    // Internal Registers
    //====================================================

    reg [2:0] state;

    reg [3:0] bit_cnt;

    reg [7:0] shift_reg;

    reg rw_bit;

    reg sda_drive_low;

    reg scl_d;
    reg sda_d;


    //====================================================
    // Open-Drain SDA Driver
    //====================================================

    // TODO:
    // Drive SDA LOW when required.
    // Otherwise release the line.

    assign sda = sda_drive_low ? 1'b0 : 1'bz; // Driver


    //====================================================
    // Edge Detection
    //====================================================

    // TODO:
    // Detect SCL rising edge

    wire scl_rise = scl & ~scl_d; // Rising


    // TODO:
    // Detect SCL falling edge

    wire scl_fall = ~scl & scl_d; // Falling


    // TODO:
    // Detect START condition

    wire start_condition = scl & ~sda & sda_d; // Start


    // TODO:
    // Detect STOP condition

    wire stop_condition = scl & sda & ~sda_d; // Stop


    //====================================================
    // Synchronize SCL and SDA
    //====================================================

    always @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            //--------------------------------------------
            // TODO:
            // Initialize delayed signals
            //--------------------------------------------
            scl_d <= 1'b1; // Idle-high
            sda_d <= 1'b1; // Idle-high

        end
        else
        begin

            //--------------------------------------------
            // TODO:
            // Store previous values of
            // SCL and SDA
            //--------------------------------------------
            scl_d <= scl; // Store
            sda_d <= sda; // Store

        end

    end


    //====================================================
    // I2C Slave State Machine
    //====================================================

    always @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            //--------------------------------------------
            // TODO:
            // Initialize all registers
            //--------------------------------------------
            state         <= ST_IDLE; // Reset
            bit_cnt       <= 4'd0;    // Reset
            shift_reg     <= 8'd0;    // Reset
            rw_bit        <= 1'b0;    // Reset
            sda_drive_low <= 1'b0;    // Reset
            received_data <= 8'd0;    // Reset
            data_valid    <= 1'b0;    // Reset

        end
        else
        begin

            //--------------------------------------------
            // TODO:
            // Default data_valid signal
            //--------------------------------------------
            data_valid <= 1'b0; // Default


            //--------------------------------------------
            // TODO:
            // Handle STOP condition
            //--------------------------------------------
            if (stop_condition) begin // Check
                state         <= ST_IDLE; // Abort
                sda_drive_low <= 1'b0;    // Release
            end


            //--------------------------------------------
            // TODO:
            // Handle START condition
            //--------------------------------------------
            else if (start_condition) begin // Check
                state         <= ST_ADDR; // Begin
                bit_cnt       <= 4'd0;    // Clear
                sda_drive_low <= 1'b0;    // Release
            end


            else begin
                case(state)

                //------------------------------------------------
                // IDLE State
                //------------------------------------------------
                ST_IDLE:
                begin

                    // TODO:
                    // Release SDA
                    // Wait for START condition
                    sda_drive_low <= 1'b0; // Release
                    // (Wait handled by start_condition above)

                end


                //------------------------------------------------
                // Receive Address
                //------------------------------------------------
                ST_ADDR:
                begin

                    // TODO:
                    // Receive 7-bit address
                    // Receive R/W bit
                    if (scl_rise) begin // Sample
                        shift_reg <= {shift_reg[6:0], sda}; // Shift
                        bit_cnt   <= bit_cnt + 1'b1;        // Increment
                        if (bit_cnt == 4'd7) begin          // 8-bits
                            state <= ST_ACK_ADDR;           // Transition
                        end
                    end

                end


                //------------------------------------------------
                // Address ACK
                //------------------------------------------------
                ST_ACK_ADDR:
                begin

                    // TODO:
                    // Compare received address
                    // with SLAVE_ADDR
                    //
                    // Generate ACK
                    //
                    // Decide whether to
                    // READ or WRITE
                    if (scl_fall) begin // Edge
                        if (bit_cnt == 4'd8) begin // Start-ACK
                            if (shift_reg[7:1] == SLAVE_ADDR) begin // Compare
                                sda_drive_low <= 1'b1;         // ACK
                                rw_bit        <= shift_reg[0]; // Store
                                bit_cnt       <= 4'd9;         // Next
                            end else begin
                                state <= ST_IDLE;              // NACK
                            end
                        end else if (bit_cnt == 4'd9) begin // End-ACK
                            bit_cnt <= 4'd0; // Reset
                            if (rw_bit == 1'b0) begin // Write
                                sda_drive_low <= 1'b0;    // Release
                                state         <= ST_WRITE; // Transition
                            end else begin // Read
                                state         <= ST_READ; // Transition
                                shift_reg     <= {transmit_data[6:0], 1'b0}; // Load
                                sda_drive_low <= ~transmit_data[7]; // Drive
                            end
                        end
                    end

                end


                //------------------------------------------------
                // Write Operation
                //------------------------------------------------
                ST_WRITE:
                begin

                    // TODO:
                    // Receive one data byte
                    // Store into received_data
                    // Assert data_valid
                    if (scl_rise) begin // Sample
                        shift_reg <= {shift_reg[6:0], sda}; // Shift
                        bit_cnt   <= bit_cnt + 1'b1;        // Increment
                        if (bit_cnt == 4'd7) begin          // 8-bits
                            state <= ST_ACK_DATA;           // Transition
                        end
                    end

                end


                //------------------------------------------------
                // ACK Data
                //------------------------------------------------
                ST_ACK_DATA:
                begin

                    // TODO:
                    // Generate ACK
                    // Return to IDLE
                    if (scl_fall) begin // Edge
                        if (bit_cnt == 4'd8) begin // Start-ACK
                            sda_drive_low <= 1'b1;      // ACK
                            received_data <= shift_reg; // Store
                            data_valid    <= 1'b1;      // Assert
                            bit_cnt       <= 4'd9;      // Next
                        end else if (bit_cnt == 4'd9) begin // End-ACK
                            sda_drive_low <= 1'b0;    // Release
                            state         <= ST_IDLE; // Return
                            bit_cnt       <= 4'd0;    // Reset
                        end
                    end

                end


                //------------------------------------------------
                // Read Operation
                //------------------------------------------------
                ST_READ:
                begin

                    // TODO:
                    // Send transmit_data
                    // MSB first
                    // Release SDA after last bit
                    if (scl_fall) begin // Edge
                        bit_cnt <= bit_cnt + 1'b1; // Increment
                        if (bit_cnt == 4'd7) begin // End
                            sda_drive_low <= 1'b0;    // Release
                            state         <= ST_IDLE; // Return
                        end else begin
                            sda_drive_low <= ~shift_reg[7]; // Drive
                            shift_reg     <= {shift_reg[6:0], 1'b0}; // Shift
                        end
                    end

                end


                //------------------------------------------------
                // Default
                //------------------------------------------------
                default:
                begin

                    // TODO:
                    // Return to IDLE
                    state <= ST_IDLE; // Return

                end

                endcase
            end

        end

    end

endmodule


