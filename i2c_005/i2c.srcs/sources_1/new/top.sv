`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name : i2c_top
// Board       : Nexys A7
//
// Description:
// Top-level I2C demonstration design.
//
// Features
// --------
// • Push button starts I2C transaction
// • Switches provide transmit data
// • LEDs display controller status
// • I2C Master communicates with an external I2C slave
//
// Lab Tasks
// ---------
// 1. Connect board reset.
// 2. Detect push-button press.
// 3. Generate a one-clock start pulse.
// 4. Instantiate I2C Master.
// 5. Connect SDA and SCL signals.
// 6. Display controller status on LEDs.
//
//////////////////////////////////////////////////////////////////////////////////

module i2c_top #(
    parameter integer CLOCK_FREQ_HZ = 100_000_000,
    parameter integer I2C_FREQ_HZ   = 100_000
)
(
    input  wire        CLK100MHZ,
    input  wire        CPU_RESETN,
    input  wire        BTNC,
    input  wire [7:0]  SW,

    // I2C Interface
    inout  wire        i2c_sda,
    output wire        i2c_scl,

    output wire [15:0] LED
);

    //====================================================
    // Reset Signal
    //====================================================

    wire rst_n;

    // TODO:
    // Connect active-low reset signal
    //
    // Example:
    // assign rst_n = CPU_RESETN;

    assign rst_n = CPU_RESETN; // Connect


    //====================================================
    // Push Button Edge Detector
    //====================================================

    reg btnc_d;

    // TODO:
    // Register previous button value

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
    // Generate one-clock pulse when
    // the center push button is pressed

    wire start_i2c;

    assign start_i2c = BTNC & ~btnc_d; // Pulse


    //====================================================
    // Internal Signals
    //====================================================

    wire [7:0] rx_data;

    wire busy;
    wire done;

    wire ack_error;


    //====================================================
    // I2C Master
    //====================================================

    // TODO:
    // Instantiate I2C Master
    //
    // Inputs:
    //   Clock
    //   Reset
    //   Start Signal
    //   Read/Write Control
    //   Slave Address
    //   Transmit Data
    //
    // Outputs:
    //   Received Data
    //   Busy
    //   Done
    //   ACK Error
    //   SCL
    //   SDA

    i2c_master #(
        .CLOCK_FREQ_HZ(CLOCK_FREQ_HZ),
        .I2C_FREQ_HZ(I2C_FREQ_HZ)
    ) i2c_master_inst (
        .clk(CLK100MHZ),         // Clock
        .rst_n(rst_n),           // Reset
        .start(start_i2c),       // Start
        .rw(1'b0),               // Write
        .slave_addr(7'h50),      // Address
        .tx_data(SW),            // Data
        .rx_data(rx_data),       // Receive
        .busy(busy),             // Status
        .done(done),             // Status
        .ack_error(ack_error),   // Error
        .scl(i2c_scl),           // Clock
        .sda(i2c_sda)            // Data
    );                           // Instance


    //====================================================
    // LED Connections
    //====================================================

    // TODO:
    // Display switch value
    // on LED[7:0]

    assign LED[7:0] = SW; // Switches


    // TODO:
    // Display busy signal
    // on LED[8]

    assign LED[8] = busy; // Busy


    // TODO:
    // Display done signal
    // on LED[9]

    assign LED[9] = done; // Done


    // TODO:
    // Display ACK error
    // on LED[10]

    assign LED[10] = ack_error; // Error


    // TODO:
    // Turn OFF remaining LEDs

    assign LED[15:11] = 5'b0; // Off


endmodule