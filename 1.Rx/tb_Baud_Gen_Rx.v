`timescale 1ns/1ps

module tb_Baud_Gen_Rx;

    // --------------------------------------------------
    // Parameters (match DUT)
    // --------------------------------------------------
    parameter integer CLK_SYS    = 50_000_000;
    parameter integer BAUD_RATE  = 9600;
    parameter integer OVERSAMPLE = 16;
    parameter integer CNT_W      = 9;   // MUST match DUT

    // --------------------------------------------------
    // Signals
    // --------------------------------------------------
    reg  clk;
    reg  rst;
    wire baud_tick;
    wire [CNT_W-1:0] count_o;

    // --------------------------------------------------
    // DUT instantiation
    // --------------------------------------------------
    Baud_Gen_Tx #(
        .CLK_SYS    (CLK_SYS),
        .BAUD_RATE  (BAUD_RATE),
        .OVERSAMPLE (OVERSAMPLE),
        .CNT_W      (CNT_W)
    ) dut (
        .clk       (clk),
        .rst       (rst),
        .baud_tick (baud_tick),
        .count_o   (count_o)
    );

    // --------------------------------------------------
    // Clock generation: 50 MHz (20 ns period)
    // --------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    // --------------------------------------------------
    // Reset sequence (synchronous reset)
    // --------------------------------------------------
    initial begin
        rst = 1'b1;
        #100;
        rst = 1'b0;
    end

    // --------------------------------------------------
    // Simulation control
    // --------------------------------------------------
    initial begin
        #200_000;
        $finish;
    end

endmodule
