`timescale 1ns/1ps

module tb_TOPTx;

    // ---------------------------------
    // Parameters
    // ---------------------------------
    parameter CLK_SYS   = 50_000_000;
    parameter BAUD_RATE = 9600;
    parameter DATA_BITS = 8;

    // ---------------------------------
    // Signals
    // ---------------------------------
    reg                     clk;
    reg                     rst;
    reg [DATA_BITS-1:0]     data_in;
    reg                     i_send;

    wire                    tx;
    wire                    busy_flag;

    // Test / debug
    wire [15:0]             count_o;
    wire [1:0]              state_o;
    wire [3:0]              bits_count_o;

    // ---------------------------------
    // DUT
    // ---------------------------------
    TOPTx #(
        .CLK_SYS   (CLK_SYS),
        .BAUD_RATE (BAUD_RATE),
        .DATA_BITS (DATA_BITS)
    ) dut (
        .clk          (clk),
        .rst          (rst),
        .data_in      (data_in),
        .i_send       (i_send),
        .tx           (tx),
        .busy_flag    (busy_flag),

        // Test
        .count_o      (count_o),
        .state_o      (state_o),
        .bits_count_o (bits_count_o)
    );

    // ---------------------------------
    // Clock generation (50 MHz)
    // ---------------------------------
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    // ---------------------------------
    // Test sequence (GIỮ NGUYÊN LOGIC CỦA BẠN)
    // ---------------------------------
    initial begin
        // Init
        rst     = 1'b1;
        i_send = 1'b0;
        data_in = 8'h00;

        #200;
        rst = 1'b0;

        // -------- Byte 1 --------
        data_in = 8'b1001_0010;
        i_send  = 1'b1;
        #20;
        i_send  = 1'b0;

        wait (busy_flag == 1'b0);
        #500_000;

        // -------- Byte 2 --------
        data_in = 8'b1010_1010;
        i_send  = 1'b1;
        #20;
        i_send  = 1'b0;

        wait (busy_flag == 1'b0);
        #500_000;

        // -------- Byte 3 --------
        data_in = 8'b1100_1100;
        i_send  = 1'b1;
        #20;
        i_send  = 1'b0;

        wait (busy_flag == 1'b0);
        #500_000;

        // -------- Byte 4 --------
        data_in = 8'b1111_0000;
        i_send  = 1'b1;
        #20;
        i_send  = 1'b0;

        wait (busy_flag == 1'b0);
        #800_000;

        $finish;
    end

endmodule
