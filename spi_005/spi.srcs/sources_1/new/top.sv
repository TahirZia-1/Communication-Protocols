`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2026 11:09:05 AM
// Design Name: 
// Module Name: top
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
// Module Name : spi_top
// Board       : Nexys A7
//
// Description:
// Top-level SPI demonstration design.
//
// Features
// --------
// • Push button starts SPI transmission
// • Switches provide transmit data
// • LEDs display received data and SPI status
// • Communicates with an external SPI slave
//
// Lab Tasks
// ---------
// 1. Connect the reset signal.
// 2. Detect push-button press.
// 3. Generate a one-clock-cycle start pulse.
// 4. Instantiate the SPI Master.
// 5. Connect the SPI interface.
// 6. Display received data and status on LEDs.
//
//////////////////////////////////////////////////////////////////////////////////

module spi_top #(
    parameter integer CLOCK_DIV = 50
)
(
    input  wire        CLK100MHZ,
    input  wire        CPU_RESETN,
    input  wire        BTNC,
    input  wire [7:0]  SW,

    // SPI Interface
    input  wire        spi_miso,
    output wire        spi_mosi,
    output wire        spi_sclk,
    output wire        spi_cs_n,

    output wire [15:0] LED
);

    //====================================================
    // Reset Signal
    //====================================================

    wire rst_n;

    // TODO:
    // Connect active-low reset
    //
    // Example:
    // assign rst_n = CPU_RESETN;
    
    assign rst_n = CPU_RESETN; // Connect


    //====================================================
    // Push Button Edge Detector
    //====================================================

    reg btnc_d;

    // TODO:
    // Store previous push-button value

    always @(posedge CLK100MHZ or negedge rst_n) begin
        if (!rst_n) begin
            btnc_d <= 1'b0; // Reset
        end else begin
            btnc_d <= BTNC; // Store
        end
    end


    //====================================================
    // Generate Start Pulse
    //====================================================

    // TODO:
    // Generate one-clock-cycle pulse
    // when BTNC is pressed

    wire start_spi;
    
    assign start_spi = BTNC & ~btnc_d; // Pulse


    //====================================================
    // Internal Signals
    //====================================================

    wire [7:0] rx_data;

    wire busy;

    wire done;


    //====================================================
    // SPI Master
    //====================================================

    // TODO:
    // Instantiate SPI Master
    //
    // Connect:
    //   Clock
    //   Reset
    //   Start
    //   Switches (SW)
    //   SPI Interface
    //
    // Outputs:
    //   rx_data
    //   busy
    //   done

    spi_master #(
        .CLOCK_DIV(CLOCK_DIV) // Configure
    ) master_inst (
        .clk(CLK100MHZ),   // Clock
        .rst_n(rst_n),     // Reset
        .start(start_spi), // Start
        .tx_data(SW),      // Data
        .miso(spi_miso),   // Receive
        .mosi(spi_mosi),   // Transmit
        .sclk(spi_sclk),   // Clock
        .cs_n(spi_cs_n),   // Select
        .rx_data(rx_data), // Output
        .busy(busy),       // Status
        .done(done)        // Status
    );                     // Instance


    //====================================================
    // LED Connections
    //====================================================

    // TODO:
    // Display received data
    // on LED[7:0]

    assign LED[7:0] = rx_data; // Receive


    // TODO:
    // Display busy signal
    // on LED[8]

    assign LED[8] = busy; // Busy


    // TODO:
    // Display done signal
    // on LED[9]

    assign LED[9] = done; // Done


    // TODO:
    // Turn OFF remaining LEDs

    assign LED[15:10] = 6'b0; // Off


endmodule