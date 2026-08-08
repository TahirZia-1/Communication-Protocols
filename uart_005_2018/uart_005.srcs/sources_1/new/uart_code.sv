`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2026 02:44:09 PM
// Design Name: 
// Module Name: uart_code
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
// Module Name : baud_rate_generator
//
// Description:
// Parameterized Baud Rate Generator
//
// Lab Tasks:
// 1. Calculate the divider value.
// 2. Implement a counter.
// 3. Generate a one-clock-cycle tick.
// 4. Reset the counter.
//
// Applications:
// • UART Transmitter  : TICK_RATE_HZ = BAUD_RATE
// • UART Receiver     : TICK_RATE_HZ = BAUD_RATE × OVERSAMPLE
//
//////////////////////////////////////////////////////////////////////////////////

module baud_rate_generator #(
    parameter integer CLOCK_FREQ_HZ = 100_000_000,
    parameter integer TICK_RATE_HZ  = 9600
)
(
    input  wire clk,
    input  wire rst_n,

    output reg  tick
);

    //====================================================
    // Divider Calculation
    //====================================================

    // TODO:
    // Calculate the divider value
    //
    // Divider =
    // CLOCK_FREQ_HZ / TICK_RATE_HZ

    parameter DIVIDER = CLOCK_FREQ_HZ / TICK_RATE_HZ;


    //====================================================
    // Counter Register
    //====================================================

    // TODO:
    // Declare a counter register

    reg [31:0] count; 


    //====================================================
    // Baud Rate Generator
    //====================================================

    always @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin
        count <= 32'd0;
        tick <= 1'b0;

            //------------------------------------------------
            // TODO:
            // Reset counter
            // Clear tick signal
            //------------------------------------------------

        end
        else
        begin

            //------------------------------------------------
            // TODO:
            // Check whether the counter has reached
            // (DIVIDER - 1)
            //------------------------------------------------

            if( count == DIVIDER-1 )
            begin
            count <= 32'd0;
            tick <= 1'b1;


                //--------------------------------------------
                // TODO:
                // Reset counter
                // Generate one-clock-cycle tick
                //--------------------------------------------

            end
            else
            begin
            count <= count+1;
            tick <= 1'b0;

                //--------------------------------------------
                // TODO:
                // Increment counter
                // Keep tick LOW
                //--------------------------------------------

            end

        end

    end

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Module Name: uart_rx
// Description:
// UART Receiver using 16x oversampling.
//
// Lab Task:
// Complete the UART Receiver by implementing:
//   1. Input synchronization
//   2. UART state machine
//   3. Start bit detection
//   4. Data bit reception
//   5. Stop bit verification
//   6. Data valid and framing error generation
//////////////////////////////////////////////////////////////////////////////////

module uart_rx #(
    parameter integer OVERSAMPLE = 16
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       sample_tick,
    input  wire       rx,

    output reg [7:0]  data_out,
    output reg        data_valid,
    output reg        framing_error
);

    //====================================================
    // State Encoding
    //====================================================
    localparam ST_IDLE  = 2'd0;
    localparam ST_START = 2'd1;
    localparam ST_DATA  = 2'd2;
    localparam ST_STOP  = 2'd3;

    //====================================================
    // Internal Registers
    //====================================================
    reg [1:0] state;

    reg [3:0] sample_count;

    reg [2:0] bit_index;

    reg [7:0] shift_reg;

    // Synchronizer Registers
    reg rx_meta;
    reg rx_sync;

    //====================================================
    // Part 1
    // Synchronize the asynchronous RX input
    //====================================================
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
        rx_meta <= 1'b1;
        rx_sync <= 1'b1;
            // TODO:
            // Initialize synchronizer registers
        end
        else
        begin
        rx_meta <= rx;
        rx_sync <= rx_meta;
            // TODO:
            // Implement two-stage synchronizer
        end
    end


    //====================================================
    // Part 2
    // UART Receiver State Machine
    //====================================================
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
        sample_count <= 4'b0000;
        state <= 2'b00;
        bit_index <= 3'b000;
        shift_reg <= 8'h0;
        data_out <= 8'h0;
        data_valid <= 1'b0;
        framing_error <= 1'b0;
            // TODO:
            // Reset all registers
        end
        else
        begin

            // Default output
            data_valid <= 1'b0;

            if(sample_tick)
            begin

                case(state)

                //------------------------------------------------
                // IDLE State
                //------------------------------------------------
                ST_IDLE:
                begin
                sample_count <= 4'b0000;
                bit_index <= 3'b000;
                
                if (!rx_sync) begin
                state <= ST_START; end end
                    // TODO:
                    // Wait for start bit (RX goes LOW)

                //------------------------------------------------
                // START State
                //------------------------------------------------
                ST_START:
                begin
                    if (sample_count == 4'd7) begin
                        sample_count <= 4'd0; 
                        
                        if (!rx_sync) begin
                            state <= ST_DATA; 
                        end
                        else begin
                            state <= ST_IDLE; 
                        end
                    end
                    else begin
                        sample_count <= sample_count + 1'b1;
                    end
                end


                //------------------------------------------------
                // DATA State
                //------------------------------------------------
                ST_DATA:
                begin
                    if (sample_count == 4'd15) begin
                        sample_count <= 4'd0;
                        
                        shift_reg[bit_index] <= rx_sync;
                        
                        if (bit_index == 3'd7) begin
                            state <= ST_STOP; 
                        end
                        else begin
                            bit_index <= bit_index + 1'b1; 
                        end
                    end
                    else begin
                        sample_count <= sample_count + 1'b1; 
                    end
                end
                    // TODO:
                    // Receive 8 data bits
                    // Store each bit into shift register
                    // Increment bit counter
                


                //------------------------------------------------
                // STOP State
                //------------------------------------------------
                ST_STOP:
                begin
                    if (sample_count == 4'd15) begin
                        sample_count <= 4'd0; 
                        state <= ST_IDLE; 
                        
                        if (rx_sync == 1'b1) begin
                            data_out <= shift_reg; 
                            data_valid <= 1'b1;      
                            framing_error <= 1'b0;      
                        end
                        else begin
                            data_valid <= 1'b0;
                            framing_error <= 1'b1;      
                        end
                    end
                    else begin
                        sample_count <= sample_count + 1'b1; 
                    end
                end
                    // TODO:
                    // Check stop bit
                    // Copy received byte to data_out
                    // Assert data_valid if stop bit is HIGH
                    // Otherwise generate framing_error
                


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

//////////////////////////////////////////////////////////////////////////////////
// Module Name: uart_tx
// Description:
// UART Transmitter (8 Data Bits, No Parity, 1 Stop Bit)
//
// Lab Task:
// Complete the UART transmitter by implementing:
//   1. Idle state
//   2. Start bit transmission
//   3. Data bit transmission (LSB first)
//   4. Stop bit transmission
//   5. Busy and done signal generation
//////////////////////////////////////////////////////////////////////////////////

module uart_tx(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       baud_tick,
    input  wire       start,
    input  wire [7:0] data_in,

    output reg        tx,
    output reg        busy,
    output reg        done
);

    //====================================================
    // State Encoding
    //====================================================
    localparam ST_IDLE  = 2'd0;
    localparam ST_START = 2'd1;
    localparam ST_DATA  = 2'd2;
    localparam ST_STOP  = 2'd3;

    //====================================================
    // Internal Registers
    //====================================================
    reg [1:0] state;

    reg [2:0] bit_index;

    reg [7:0] shift_reg;

    //====================================================
    // UART Transmitter State Machine
    //====================================================
    always @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin
        state <= 2'b00;
        bit_index <= 3'b000;
        shift_reg <= 8'h0;
        tx <= 1'b1;
        busy <= 1'b0;
        done <= 1'b0;
            //------------------------------------------------
            // TODO:
            // Reset all registers
            // Set TX line HIGH (Idle)
            //------------------------------------------------
        end
        else
        begin
            //------------------------------------------------
            // TODO:
            // Make done signal active for only one clock cycle
            //------------------------------------------------
            done <= 1'b0;

            case(state)

            //------------------------------------------------
            // IDLE State
            //------------------------------------------------
            ST_IDLE:
                begin
                    tx <= 1'b1;
                    
                    if (start) begin
                        shift_reg <= data_in;
                        busy <= 1'b1;
                    end
                    
                    if ((start || busy) && baud_tick) begin
                        state <= ST_START;
                        bit_index <= 3'b000;
                    end
                end


            //------------------------------------------------
            // START State
            //------------------------------------------------
            ST_START:
            begin
            tx <= 1'b0;
            if (baud_tick) begin
            state <= ST_DATA; end

                // TODO:
                // Transmit start bit (Logic LOW)
                // Wait for baud_tick
                // Move to DATA state

            end


            //------------------------------------------------
            // DATA State
            //------------------------------------------------
                        //------------------------------------------------
            // DATA State
            //------------------------------------------------
            ST_DATA:
            begin
                tx <= shift_reg[bit_index];

                if (baud_tick) begin
                    if (bit_index == 3'd7) begin
                        state <= ST_STOP;  
                    end
                    else begin
                        bit_index <= bit_index + 1'b1;
                    end
                end
            end

                // TODO:
                // Transmit one data bit
                // Send LSB first
                // Increment bit counter
                // After transmitting all 8 bits,
                // move to STOP state


            //------------------------------------------------
            // STOP State
            //------------------------------------------------
            ST_STOP:
            begin
            tx <= 1'b1;
            
            if (baud_tick) begin
            busy <= 1'b0;
            done <= 1'b1;
            state <= ST_IDLE; 
            end

                // TODO:
                // Transmit stop bit (Logic HIGH)
                // Wait for baud_tick
                // Clear busy signal
                // Generate done pulse
                // Return to IDLE state

            end


            //------------------------------------------------
            // Default State
            //------------------------------------------------
            default:
            begin
            state <= ST_IDLE;

                // TODO:
                // Return to IDLE state

            end

            endcase

        end

    end

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Module Name : uart_top
// Board       : NEXYS A7
//
// Description:
// Top-level UART design.
//
// Lab Tasks:
// 1. Generate baud-rate ticks for transmitter.
// 2. Generate 16× oversampling ticks for receiver.
// 3. Detect push-button press to start transmission.
// 4. Instantiate UART Transmitter.
// 5. Instantiate UART Receiver.
// 6. Display received data on LEDs.
// 7. Display UART status signals.
//
//////////////////////////////////////////////////////////////////////////////////

module uart_top #(
    parameter integer CLOCK_FREQ_HZ = 100_000_000,
    parameter integer BAUD_RATE      = 9600
)
(
    input  wire        CLK100MHZ,
    input  wire        CPU_RESETN,
    input  wire        BTNC,
    input  wire [7:0]  SW,

    // USB-UART Interface
    input  wire        UART_TXD_IN,
    output wire        UART_RXD_OUT,

    output wire [15:0] LED
);

    //====================================================
    // Reset Signal
    //====================================================
    wire rst_n;

    // TODO:
    // Connect the board reset signal
    // Example:
    assign rst_n = CPU_RESETN;


    //====================================================
    // Internal Signals
    //====================================================

    // Baud-rate generator outputs
    wire tx_tick;
    wire rx_sample_tick;

    // UART Transmitter signals
    wire tx_busy;
    wire tx_done;

    // UART Receiver signals
    wire rx_valid;
    wire framing_error;
    wire [7:0] rx_data;

    //====================================================
    // Push Button Edge Detector
    //====================================================

    reg btnc_d;
    
    always @(posedge CLK100MHZ or negedge rst_n)
    begin
        if(!rst_n)
        begin
            btnc_d <= 1'b0;
        end
        else
        begin
            btnc_d <= BTNC; 
        end
    end

    // TODO:
    // Register previous button value


    // TODO:
    // Generate one-clock pulse
    // when push button is pressed

    wire start_tx;
    assign start_tx = BTNC & ~btnc_d;


    //====================================================
    // Baud Rate Generator
    //====================================================

    // TODO:
    // Instantiate baud-rate generator
    // for UART transmitter
    //
    // Tick Frequency = BAUD_RATE
    
    baud_rate_generator #(
        .CLOCK_FREQ_HZ(CLOCK_FREQ_HZ),
        .TICK_RATE_HZ(BAUD_RATE)) tx_baud_gen (
        .clk(CLK100MHZ), 
        .rst_n(rst_n), 
        .tick(tx_tick)
    );


    //====================================================
    // Receiver Sample Generator
    //====================================================

    // TODO:
    // Instantiate baud-rate generator
    // for UART receiver
    //
    // Tick Frequency = BAUD_RATE × 16
    
    baud_rate_generator #(
        .CLOCK_FREQ_HZ(CLOCK_FREQ_HZ),
        .TICK_RATE_HZ(BAUD_RATE * 16)) rx_baud_gen (
        .clk(CLK100MHZ), 
        .rst_n(rst_n), 
        .tick(rx_sample_tick)
    );


    //====================================================
    // UART Transmitter
    //====================================================

    // TODO:
    // Instantiate UART Transmitter
    //
    // Inputs:
    //  Clock
    //  Reset
    //  Baud Tick
    //  Start Signal
    //  Switches (SW)
    //
    // Outputs:
    //  UART_RXD_OUT
    //  tx_busy
    //  tx_done
    
    uart_tx uart_trans (
    .clk(CLK100MHZ), .rst_n(rst_n), .baud_tick(tx_tick), .start(start_tx), .data_in(SW),
    .tx(UART_RXD_OUT), .busy(tx_busy), .done(tx_done));
    //====================================================
    // UART Receiver
    //====================================================

    // TODO:
    // Instantiate UART Receiver
    //
    // Inputs:
    //  Clock
    //  Reset
    //  Sample Tick
    //  UART_TXD_IN
    //
    // Outputs:
    //  rx_data
    //  rx_valid
    //  framing_error
    
    uart_rx #(.OVERSAMPLE(16)) uart_rcv (
        .clk(CLK100MHZ), .rst_n(rst_n), .sample_tick(rx_sample_tick), .rx(UART_TXD_IN),           
        .data_out(rx_data), .data_valid(rx_valid), .framing_error(framing_error));


    //====================================================
    // LED Connections
    //====================================================

    // TODO:
    // Display received data
    // on LED[7:0]
    assign LED[7:0]   = rx_data;


    // TODO:
    // Display transmitter busy signal
    // on LED[8]
    assign LED[8]     = tx_busy;


    // TODO:
    // Display transmitter done signal
    // on LED[9]
    assign LED[9]     = tx_done;


    // TODO:
    // Display receiver valid signal
    // on LED[10]
    assign LED[10]    = rx_valid;


    // TODO:
    // Display framing error
    // on LED[11]
    assign LED[11]    = framing_error;


    // TODO:
    // Turn OFF remaining LEDs
    assign LED[15:12] = 4'b0000;
    
//    assign LED = { 4'b0000, framing_error, rx_valid, tx_done, tx_busy, rx_data };


endmodule