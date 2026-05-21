`timescale 1ns/1ps

module tb_TOPRx;

    // --------------------------------------------------
    // Parameters (match DUT)
    // --------------------------------------------------
    parameter integer CLK_SYS    = 50_000_000;
    parameter integer BAUD_RATE  = 9600;
    parameter integer DATA_BITS  = 8;
    parameter integer OVERSAMPLE = 16;
    parameter integer CNT_W      = 9;

    localparam integer CLK_PERIOD = 20; // 50 MHz
    localparam integer BIT_TIME   = 1_000_000_000 / BAUD_RATE; // ns

    // --------------------------------------------------
    // Signals
    // --------------------------------------------------
    reg clk;
    reg rst;
    reg rx;

    wire [DATA_BITS-1:0] data_out;
    wire recieved_flag;
    wire [CNT_W-1:0] count_o;

    // --------------------------------------------------
    // DUT
    // --------------------------------------------------
    TOPRx #(
        .CLK_SYS    (CLK_SYS),
        .BAUD_RATE  (BAUD_RATE),
        .DATA_BITS  (DATA_BITS),
        .OVERSAMPLE (OVERSAMPLE),
        .CNT_W      (CNT_W)
    ) dut (
        .clk           (clk),
        .rst           (rst),
        .rx            (rx),
        .data_out      (data_out),
        .recieved_flag (recieved_flag),
        .count_o       (count_o)
    );

    // --------------------------------------------------
    // System clock 50 MHz
    // --------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // --------------------------------------------------
    // UART RX stimulus (giữ style của bạn)
    // --------------------------------------------------
    initial begin
        rst = 1'b1;
        rx  = 1'b1;   // idle HIGH

        #200;
        rst = 1'b0;

        // ===============================
        // Send byte: 8'b11011001 (0xD9)
        // LSB first
        // ===============================

        // START bit
        rx = 1'b0;
        #(BIT_TIME);

        // DATA bits
        rx = 1'b1; #(BIT_TIME); // bit 0
        rx = 1'b0; #(BIT_TIME); // bit 1
        rx = 1'b0; #(BIT_TIME); // bit 2
        rx = 1'b1; #(BIT_TIME); // bit 3
        rx = 1'b1; #(BIT_TIME); // bit 4
        rx = 1'b0; #(BIT_TIME); // bit 5
        rx = 1'b1; #(BIT_TIME); // bit 6
        rx = 1'b1; #(BIT_TIME); // bit 7

        // STOP bit
        rx = 1'b1;
        #(BIT_TIME * 2);

        // ===============================
        // Send another byte: 0x55
        // ===============================
        rx = 1'b0; #(BIT_TIME);   // start

        rx = 1'b1; #(BIT_TIME);
        rx = 1'b0; #(BIT_TIME);
        rx = 1'b1; #(BIT_TIME);
        rx = 1'b0; #(BIT_TIME);
        rx = 1'b1; #(BIT_TIME);
        rx = 1'b0; #(BIT_TIME);
        rx = 1'b1; #(BIT_TIME);
        rx = 1'b0; #(BIT_TIME);

        rx = 1'b1; #(BIT_TIME * 2);
		  
		  
		  #10000
        $finish;
    end

endmodule
