`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2026 11:07:57 AM
// Design Name: 
// Module Name: spi
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
// Module Name : spi_master
//
// Description:
// SPI Master Controller
//
// Features
// --------
// • SPI Mode 0 (CPOL = 0, CPHA = 0)
// • Full-Duplex Communication
// • 8-bit Data Transfer
// • Programmable Clock Divider
//
// Lab Tasks
// ---------
// 1. Generate SPI clock.
// 2. Generate Chip Select.
// 3. Transmit one byte.
// 4. Receive one byte.
// 5. Control SPI transfer using an FSM.
//
//////////////////////////////////////////////////////////////////////////////////

module spi_master #(
    parameter integer CLOCK_DIV = 50
)
(
    input  wire       clk,
    input  wire       rst_n,

    input  wire       start,

    input  wire [7:0] tx_data,

    input  wire       miso,

    output reg        mosi,
    output reg        sclk,
    output reg        cs_n,

    output reg [7:0]  rx_data,

    output reg        busy,
    output reg        done
);

    //====================================================
    // State Encoding
    //====================================================

    localparam ST_IDLE      = 2'd0;
    localparam ST_TRANSFER  = 2'd1;
    localparam ST_DONE      = 2'd2;


    //====================================================
    // Internal Registers
    //====================================================

    reg [1:0] state;

    reg [7:0] tx_shift;

    reg [7:0] rx_shift;

    reg [2:0] bit_cnt;

    reg [31:0] div_cnt;


    //====================================================
    // Clock Divider Tick
    //====================================================

    // TODO:
    // Generate divider tick

    wire div_tick;
    assign div_tick = (div_cnt == (CLOCK_DIV/2) - 1); // Assign


    //====================================================
    // SPI Master FSM
    //====================================================

    always @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            //--------------------------------------------
            // TODO:
            // Initialize all registers
            //--------------------------------------------
            state    <= ST_IDLE; // Reset
            tx_shift <= 8'd0;    // Reset
            rx_shift <= 8'd0;    // Reset
            bit_cnt  <= 3'd0;    // Reset
            div_cnt  <= 32'd0;   // Reset
            mosi     <= 1'b0;    // Reset
            sclk     <= 1'b0;    // Reset
            cs_n     <= 1'b1;    // Reset
            rx_data  <= 8'd0;    // Reset
            busy     <= 1'b0;    // Reset
            done     <= 1'b0;    // Reset

        end
        else
        begin

            //--------------------------------------------
            // TODO:
            // Default done signal
            //--------------------------------------------
            done <= 1'b0; // Default

            case(state)

            //------------------------------------------------
            // IDLE State
            //------------------------------------------------
            ST_IDLE:
            begin

                // TODO:
                // Wait for start signal
                // Load transmit register
                // Activate Chip Select
                if (start) begin         // Check
                    tx_shift <= tx_data; // Load
                    cs_n     <= 1'b0;    // Activate
                    mosi     <= tx_data[7]; // Drive
                    sclk     <= 1'b0;    // Idle
                    bit_cnt  <= 3'd0;    // Clear
                    div_cnt  <= 32'd0;   // Clear
                    busy     <= 1'b1;    // Set
                    state    <= ST_TRANSFER; // Transition
                end

            end


            //------------------------------------------------
            // Transfer State
            //------------------------------------------------
            ST_TRANSFER:
            begin

                // TODO:
                // Generate SPI clock
                //
                // Rising Edge:
                //   Sample MISO
                //
                // Falling Edge:
                //   Shift next MOSI bit
                if (div_tick) begin              // Tick
                    div_cnt <= 32'd0;            // Reset
                    sclk    <= ~sclk;            // Toggle
                    if (~sclk) begin             // Rising
                        rx_shift <= {rx_shift[6:0], miso}; // Sample
                    end else begin               // Falling
                        if (bit_cnt == 3'd7) begin // End
                            state <= ST_DONE;    // Transition
                        end else begin           // Shift
                            tx_shift <= {tx_shift[6:0], 1'b0}; // Shift
                            mosi     <= tx_shift[6]; // Drive
                            bit_cnt  <= bit_cnt + 1'b1; // Increment
                        end
                    end
                end else begin                   // Wait
                    div_cnt <= div_cnt + 1'b1;   // Increment
                end

            end


            //------------------------------------------------
            // DONE State
            //------------------------------------------------
            ST_DONE:
            begin

                // TODO:
                // Deactivate Chip Select
                // Assert done signal
                // Return to IDLE
                cs_n    <= 1'b1;      // Deactivate
                rx_data <= rx_shift;  // Store
                busy    <= 1'b0;      // Clear
                done    <= 1'b1;      // Assert
                state   <= ST_IDLE;   // Return

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

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Module Name : spi_slave
//
// Description:
// SPI Slave Controller
//
// Features
// --------
// • SPI Mode 0 (CPOL = 0, CPHA = 0)
// • 8-bit Full-Duplex Communication
// • Receives data from MOSI
// • Sends data on MISO
//
// Lab Tasks
// ---------
// 1. Detect SPI clock edges.
// 2. Detect Chip Select.
// 3. Receive one byte.
// 4. Transmit one byte.
// 5. Generate data_valid after reception.
//
//////////////////////////////////////////////////////////////////////////////////

module spi_slave
(
    input  wire       clk,
    input  wire       rst_n,

    input  wire       sclk,
    input  wire       cs_n,

    input  wire       mosi,
    output reg        miso,

    input  wire [7:0] tx_data,

    output reg [7:0]  rx_data,

    output reg        data_valid
);

    //====================================================
    // Internal Registers
    //====================================================

    reg sclk_d;

    reg cs_d;

    reg [2:0] bit_cnt;

    reg [7:0] tx_shift;

    reg [7:0] rx_shift;


    //====================================================
    // Edge Detection
    //====================================================

    // TODO:
    // Detect SCLK rising edge

    wire sclk_rise = sclk & ~sclk_d; // Rising


    // TODO:
    // Detect SCLK falling edge

    wire sclk_fall = ~sclk & sclk_d; // Falling


    // TODO:
    // Detect Chip Select falling edge

    wire cs_fall = ~cs_n & cs_d; // Falling


    //====================================================
    // Synchronize Signals
    //====================================================

    always @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            //--------------------------------------------
            // TODO:
            // Initialize delayed signals
            //--------------------------------------------
            sclk_d <= 1'b0; // Reset
            cs_d   <= 1'b1; // Reset

        end
        else
        begin

            //--------------------------------------------
            // TODO:
            // Store previous values of
            // SCLK and CS
            //--------------------------------------------
            sclk_d <= sclk; // Store
            cs_d   <= cs_n; // Store

        end

    end


    //====================================================
    // SPI Slave Logic
    //====================================================

    always @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            //--------------------------------------------
            // TODO:
            // Initialize all registers
            //--------------------------------------------
            bit_cnt    <= 3'd0; // Reset
            tx_shift   <= 8'd0; // Reset
            rx_shift   <= 8'd0; // Reset
            miso       <= 1'b0; // Reset
            rx_data    <= 8'd0; // Reset
            data_valid <= 1'b0; // Reset

        end
        else
        begin

            //--------------------------------------------
            // TODO:
            // Default data_valid signal
            //--------------------------------------------
            data_valid <= 1'b0; // Default


            //------------------------------------------------
            // Chip Select Inactive
            //------------------------------------------------
            if(cs_n)
            begin

                //----------------------------------------
                // TODO:
                // Load transmit data
                // Reset bit counter
                //----------------------------------------
                tx_shift <= tx_data; // Load
                bit_cnt  <= 3'd0;    // Reset

            end
            else
            begin

                //----------------------------------------
                // TODO:
                // Detect beginning of
                // SPI transaction
                //----------------------------------------
                if (cs_fall) begin       // Detect
                    miso <= tx_shift[7]; // Drive
                end


                //----------------------------------------
                // TODO:
                // Rising Edge:
                // Receive data from MOSI
                //----------------------------------------
                if (sclk_rise) begin                   // Rising
                    rx_shift <= {rx_shift[6:0], mosi}; // Sample
                end


                //----------------------------------------
                // TODO:
                // Falling Edge:
                // Shift next transmit bit
                // onto MISO
                //----------------------------------------
                if (sclk_fall) begin                   // Falling
                    tx_shift <= {tx_shift[6:0], 1'b0}; // Shift
                    miso     <= tx_shift[6];           // Drive
                    bit_cnt  <= bit_cnt + 1'b1;        // Increment

                    if (bit_cnt == 3'd7) begin         // End
                        rx_data    <= rx_shift;        // Store
                        data_valid <= 1'b1;            // Assert
                    end
                end

            end

        end

    end

endmodule