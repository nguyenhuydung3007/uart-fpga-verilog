`timescale 1ns/1ps

module tb_Uart_Tx;

    parameter DATA_BITS = 8;

    reg clk;
    reg rst;
    reg [DATA_BITS-1:0] data_in;
    reg i_send;

    reg baud_tick;          // baud_tick giả
    wire tx;
    wire busy_flag;

    // Test / debug
    wire [1:0] state_o;
    wire [3:0] bits_count_o;

    // --------------------------------------------------
    // DUT
    // --------------------------------------------------
    Uart_Tx #(
        .DATA_BITS(DATA_BITS)
    ) utx (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .data_in(data_in),
        .i_send(i_send),
        .tx(tx),
        .busy_flag(busy_flag),

        // Test
        .state_o(state_o),
        .bits_count_o(bits_count_o)
    );

    // --------------------------------------------------
    // Clock generation (50 MHz)
    // --------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    // --------------------------------------------------
    // Fake baud_tick generation
    // --------------------------------------------------
    initial begin
        baud_tick = 1'b0;
        forever begin
            #320;           // khoảng thời gian tùy ý
            baud_tick = 1'b1;
            #20;            // 1 chu kỳ clk
            baud_tick = 1'b0;
        end
    end

    // --------------------------------------------------
    // Test sequence (giữ đúng style ban đầu)
    // --------------------------------------------------
    initial begin
        rst     = 1'b1;
        i_send = 1'b0;
        data_in = 8'h00;

        #200 rst = 1'b0;

        // -------- Byte 1 --------
        data_in = 8'b10010010;
        i_send  = 1'b1;
        #20 i_send = 1'b0;

        wait (busy_flag == 0);
        #5000;

        // -------- Byte 2 --------
        data_in = 8'b10101010;
        i_send  = 1'b1;
        #20 i_send = 1'b0;

        wait (busy_flag == 0);
        #5000;

        // -------- Byte 3 --------
        data_in = 8'b11001100;
        i_send  = 1'b1;
        #20 i_send = 1'b0;

        wait (busy_flag == 0);
        #5000;

        // -------- Byte 4 --------
        data_in = 8'b11110000;
        i_send  = 1'b1;
        #20 i_send = 1'b0;

        wait (busy_flag == 0);
        #10000;

        $finish;
    end

endmodule
