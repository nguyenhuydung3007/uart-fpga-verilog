`timescale 1ns/1ps

module tb_Uart_Rx;

    // --------------------------------------------------
    // Parameters
    // --------------------------------------------------
    parameter integer CLK_SYS    = 50_000_000;
    parameter integer BAUD_RATE  = 9600;
    parameter integer DATA_BITS  = 8;
    parameter integer OVERSAMPLE = 16;

    localparam integer CLK_PERIOD = 20; // 50 MHz
    localparam integer BIT_TIME   = 1_000_000_000 / BAUD_RATE;
    localparam integer TICK_TIME  = BIT_TIME / OVERSAMPLE;

    // --------------------------------------------------
    // Signals
    // --------------------------------------------------
    reg clk;
    reg rst;
    reg rx;
    reg baud_tick;

    wire [DATA_BITS-1:0] data_out;
    wire recieved_flag;

    // --------------------------------------------------
    // DUT
    // --------------------------------------------------
    Uart_Rx #(
        .DATA_BITS  (DATA_BITS),
        .OVERSAMPLE (OVERSAMPLE)
    ) dut (
        .clk           (clk),
        .rst           (rst),
        .baud_tick     (baud_tick),
        .rx            (rx),
        .data_out      (data_out),
        .recieved_flag (recieved_flag)
    );

    // --------------------------------------------------
    // System clock (50 MHz)
    // --------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // --------------------------------------------------
    // FAKE baud_tick generator (oversample)
    // --------------------------------------------------
    initial begin
        baud_tick = 1'b0;
        forever begin
            #(TICK_TIME/2) baud_tick = 1'b1;
            #(TICK_TIME/2) baud_tick = 1'b0;
        end
    end

    // --------------------------------------------------
    // Test case (GIỮ NGUYÊN STYLE CỦA BẠN)
    // --------------------------------------------------
    initial begin
        rst = 1'b1;
        rx  = 1'b1;   // idle

        #200;
        rst = 1'b0;

        // =========================
        // START BIT
        // =========================
        rx = 1'b0;
        #(BIT_TIME);

        // =========================
        // DATA: 8'b11011001 (0xD9)
        // LSB first
        // =========================
        rx = 1'b1; #(BIT_TIME); // bit 0
        rx = 1'b0; #(BIT_TIME); // bit 1
        rx = 1'b0; #(BIT_TIME); // bit 2
        rx = 1'b1; #(BIT_TIME); // bit 3
        rx = 1'b1; #(BIT_TIME); // bit 4
        rx = 1'b0; #(BIT_TIME); // bit 5
        rx = 1'b1; #(BIT_TIME); // bit 6
        rx = 1'b1; #(BIT_TIME); // bit 7

        // =========================
        // STOP BIT
        // =========================
        rx = 1'b1;
        #(BIT_TIME * 2);

        $finish;
    end

endmodule
