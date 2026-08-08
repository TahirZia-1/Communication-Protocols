`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name : tb_i2c
//
// Description:
// Testbench for I2C Master and I2C Slave
//
// Lab Tasks
// ----------
// 1. Generate a 100 MHz clock.
// 2. Apply reset.
// 3. Instantiate the I2C Master.
// 4. Instantiate the I2C Slave.
// 5. Connect SDA using an open-drain bus.
// 6. Perform an I2C write transaction.
// 7. Verify received data.
// 8. Observe SDA and SCL waveforms.
//
//////////////////////////////////////////////////////////////////////////////////


module tb_i2c;

    //====================================================
    // Testbench Registers
    //====================================================

    reg clk;

    reg rst_n;

    reg start;

    reg rw;

    reg [7:0] tx_data;


    //====================================================
    // Testbench Wires
    //====================================================

    wire [7:0] rx_data;

    wire busy;

    wire done;

    wire ack_error;

    wire scl;

    // TODO:
    // Declare SDA as a pull-up line

    tri1 sda;


    //====================================================
    // Slave Outputs
    //====================================================

    wire [7:0] slave_received;

    wire slave_valid;


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
    // I2C Master
    //====================================================

    // TODO:
    // Instantiate I2C Master
    //
    // Parameters:
    //   CLOCK_FREQ_HZ
    //   I2C_FREQ_HZ
    //
    // Connect all ports
    
    i2c_master #(
        .CLOCK_FREQ_HZ(100_000_000), // Configure
        .I2C_FREQ_HZ(100_000)        // Configure
    ) master_inst (
        .clk(clk),             // Connect
        .rst_n(rst_n),         // Connect
        .start(start),         // Connect
        .rw(rw),               // Connect
        .slave_addr(7'h50),    // Connect
        .tx_data(tx_data),     // Connect
        .rx_data(rx_data),     // Connect
        .busy(busy),           // Connect
        .done(done),           // Connect
        .ack_error(ack_error), // Connect
        .scl(scl),             // Connect
        .sda(sda)              // Connect
    );                         // Instance


    //====================================================
    // I2C Slave
    //====================================================

    // TODO:
    // Instantiate I2C Slave
    //
    // Slave Address = 7'h50
    //
    // Connect SDA and SCL
    
    i2c_slave #(
        .SLAVE_ADDR(7'h50) // Configure
    ) slave_inst (
        .clk(clk),                      // Connect
        .rst_n(rst_n),                  // Connect
        .scl(scl),                      // Connect
        .sda(sda),                      // Connect
        .received_data(slave_received), // Connect
        .transmit_data(8'h00),          // Connect
        .data_valid(slave_valid)        // Connect
    );                                  // Instance


    //====================================================
    // Test Sequence
    //====================================================

    initial
    begin


        //------------------------------------------------
        // TODO:
        // Initialize all signals
        //------------------------------------------------
        rst_n   = 1'b1; // Set
        start   = 1'b0; // Set
        rw      = 1'b0; // Set
        tx_data = 8'd0; // Set


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
        #100; // Delay


        //------------------------------------------------
        // TODO:
        // Perform WRITE transaction
        //------------------------------------------------
        rw      = 1'b0;  // Write
        tx_data = 8'hA5; // Data


        //------------------------------------------------
        // TODO:
        // Assert start signal
        //------------------------------------------------
        start = 1'b1; // Pulse


        //------------------------------------------------
        // TODO:
        // Wait until master becomes busy
        //------------------------------------------------
        @(posedge busy); // Wait
        start = 1'b0;    // Clear


        //------------------------------------------------
        // TODO:
        // Wait until transaction finishes
        //------------------------------------------------
        @(posedge done); // Wait


        //------------------------------------------------
        // TODO:
        // Check ACK status
        //------------------------------------------------
        if (ack_error) begin // Branch
            $display("Transaction Failed: NACK received."); // Print
        end else begin
            $display("Transaction Success: ACK received."); // Print
        end


        //------------------------------------------------
        // TODO:
        // Display received data
        //------------------------------------------------
        $display("TX Data: %h | RX Data (Slave): %h", tx_data, slave_received); // Print


        //------------------------------------------------
        // TODO:
        // Wait for waveform observation
        //------------------------------------------------
        #5000; // Delay


        //------------------------------------------------
        // TODO:
        // Finish simulation
        //------------------------------------------------
        $finish; // End

    end

endmodule