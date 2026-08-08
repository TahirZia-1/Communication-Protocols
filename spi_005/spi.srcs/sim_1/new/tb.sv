`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2026 11:09:47 AM
// Design Name: 
// Module Name: tb
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
// Module Name : tb_spi
//
// Description:
// Testbench for SPI Master and SPI Slave
//
// Lab Tasks
// ---------
// 1. Generate a 100 MHz clock.
// 2. Apply reset.
// 3. Instantiate SPI Master.
// 4. Instantiate SPI Slave.
// 5. Connect SPI signals.
// 6. Perform one SPI transaction.
// 7. Verify transmitted and received data.
// 8. Observe SPI waveforms.
//
//////////////////////////////////////////////////////////////////////////////////

module tb_spi;

    //====================================================
    // Testbench Registers
    //====================================================

    reg clk;

    reg rst_n;

    reg start;

    reg [7:0] master_tx;


    //====================================================
    // Testbench Wires
    //====================================================

    wire [7:0] master_rx;

    wire busy;

    wire done;

    wire mosi;

    wire miso;

    wire sclk;

    wire cs_n;

    wire [7:0] slave_rx;

    wire slave_valid;


    //====================================================
    // SPI Master
    //====================================================

    // TODO:
    // Instantiate SPI Master
    //
    // Parameter:
    //   CLOCK_DIV
    //
    // Connect all ports

    spi_master #(
        .CLOCK_DIV(50) // Configure
    ) master_inst (
        .clk(clk),           // Connect
        .rst_n(rst_n),       // Connect
        .start(start),       // Connect
        .tx_data(master_tx), // Connect
        .miso(miso),         // Connect
        .mosi(mosi),         // Connect
        .sclk(sclk),         // Connect
        .cs_n(cs_n),         // Connect
        .rx_data(master_rx), // Connect
        .busy(busy),         // Connect
        .done(done)          // Connect
    );                       // Instance


    //====================================================
    // SPI Slave
    //====================================================

    // TODO:
    // Instantiate SPI Slave
    //
    // Example transmit data:
    // 8'h5A

    spi_slave slave_inst (
        .clk(clk),               // Connect
        .rst_n(rst_n),           // Connect
        .sclk(sclk),             // Connect
        .cs_n(cs_n),             // Connect
        .mosi(mosi),             // Connect
        .miso(miso),             // Connect
        .tx_data(8'h5A),         // Connect
        .rx_data(slave_rx),      // Connect
        .data_valid(slave_valid) // Connect
    );                           // Instance


    //====================================================
    // Clock Generation
    //====================================================

    // TODO:
    // Generate a 100 MHz clock
    //
    // Clock Period = 10 ns

    initial
    begin

        // TODO
        clk = 1'b0; // Init

    end


    always
    begin

        // TODO
        #5 clk = ~clk; // Toggle

    end


    //====================================================
    // Test Sequence
    //====================================================

    initial
    begin


        //------------------------------------------------
        // TODO:
        // Initialize all signals
        //------------------------------------------------
        rst_n     = 1'b1; // Set
        start     = 1'b0; // Set
        master_tx = 8'd0; // Set


        //------------------------------------------------
        // TODO:
        // Apply reset
        //------------------------------------------------
        #10 rst_n = 1'b0; // Assert
        #20 rst_n = 1'b1; // Deassert


        //------------------------------------------------
        // TODO:
        // Wait after reset
        //------------------------------------------------
        #100; 


        //------------------------------------------------
        // Start SPI transaction
        //------------------------------------------------
        master_tx = 8'hC3; 
        start     = 1'b1;  // Pulse
        
        @(posedge busy);   
        start     = 1'b0;  


        //------------------------------------------------
        // TODO:
        // Wait until transfer completes
        //------------------------------------------------
        @(posedge done); // Wait


        //------------------------------------------------
        // TODO:
        // Compare transmitted
        // and received data
        //------------------------------------------------
        // Master sent C3, should receive 5A
        // Slave sent 5A, should receive C3
        
        //------------------------------------------------
        // TODO:
        // Display PASS or FAIL
        //------------------------------------------------
        if ((master_rx == 8'h5A) && (slave_rx == 8'hC3)) begin // Check
            $display("PASS: Master RX = %h, Slave RX = %h", master_rx, slave_rx); // Print
        end else begin                                         // Branch
            $display("FAIL: Master RX = %h, Slave RX = %h", master_rx, slave_rx); // Print
        end


        //------------------------------------------------
        // TODO:
        // Wait for waveform viewing
        //------------------------------------------------
        #5000; // Delay


        //------------------------------------------------
        // TODO:
        // Finish simulation
        //------------------------------------------------
        $finish; // End

    end

endmodule