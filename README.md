# FPGA Serial Communication Protocols

This repository contains Verilog/SystemVerilog implementations of common serial communication protocols: I2C, SPI, and UART. These projects are designed for Xilinx FPGAs using the Vivado Design Suite and are targeted for the **Nexys A7** development board.

## Repository Structure

The repository is organized into individual Vivado projects for each protocol:

* **`i2c_005/`**: I2C (Inter-Integrated Circuit) protocol implementation. Includes an I2C Master controller and a top-level demonstration module.
* **`spi_005/`**: SPI (Serial Peripheral Interface) protocol implementation. Includes SPI Master and Slave controllers (Mode 0) and a top-level demonstration module.
* **`uart_005_2018/`**: UART (Universal Asynchronous Receiver-Transmitter) protocol implementation (older version). Includes a UART transmitter and top-level integration.
* **`uart_005_2025/`**: UART (Universal Asynchronous Receiver-Transmitter) protocol implementation (updated version). Includes full UART transmitter and receiver with 16x oversampling, and top-level demonstration.

## Hardware & Software Requirements

* **Hardware:** Digilent Nexys A7 FPGA Development Board (or similar board with adjustments to constraints).
* **Software:** Xilinx Vivado Design Suite (Tested with Vivado).
* **Peripherals:** Buttons, Switches, and LEDs on the development board are used for interaction and status indication. The UART project interfaces via USB-UART.

## Module Details

### 1. I2C (`i2c_005/`)

Implements an I2C Master controller.

* **Features:** Handles START/STOP conditions, address transmission, read/write operations, and ACK/NACK generation/detection.
* **Demonstration:** A push-button initiates an I2C transaction. Switches provide the data to be transmitted. LEDs display the controller's status (busy, done, ACK error) and transmitted data.

### 2. SPI (`spi_005/`)

Implements both SPI Master and SPI Slave controllers.

* **Features:** Supports SPI Mode 0 (CPOL = 0, CPHA = 0), 8-bit full-duplex communication.
* **Demonstration:** A push-button starts the SPI transmission. Switches provide the transmit data. The Master communicates with the Slave. LEDs display the received data and the SPI transaction status.

### 3. UART (`uart_005_2025/` & `uart_005_2018/`)

Implements a UART transmitter and receiver.

* **Features:** Configurable baud rate, 8 data bits, 1 stop bit, no parity. The receiver uses a 16x oversampling technique for reliable data recovery and framing error detection.
* **Demonstration:** A push-button starts transmission of data set by the switches over the UART TX line. The receiver listens on the UART RX line. LEDs display the received data, busy/done status, valid reception, and framing errors.

## Getting Started

1. **Clone the repository:**

   ```bash
   git clone <repository_url>
   cd <repository_name>
   ```

2. **Open a project in Vivado:**
   * Launch Xilinx Vivado.
   * Click **Open Project**.
   * Navigate to the desired protocol directory (e.g., `uart_005_2025/`).
   * Select the `.xpr` file (e.g., `uart.xpr`) and click Open.

3. **Run Synthesis, Implementation, and Bitstream Generation:**
   * In the Vivado Flow Navigator, click **Generate Bitstream**. This will automatically run synthesis and implementation if needed.

4. **Program the Device:**
   * Connect your Nexys A7 board.
   * Open the Hardware Manager.
   * Auto-connect to the target and program the FPGA with the generated `.bit` file.

## Verification / Simulation

Each project directory includes artifacts from simulation to verify correct behavior:

* `.png` files (e.g., `i2c_sim.png`, `uart_log.png`) showing waveforms and console output from Vivado simulations.
* `.wcfg` (Waveform Configuration) files to quickly open and view saved simulation states in Vivado.
