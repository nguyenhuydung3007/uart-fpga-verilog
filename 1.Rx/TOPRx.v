module TOPRx #(
    parameter integer CLK_SYS    = 50_000_000,
    parameter integer BAUD_RATE  = 9600,
    parameter integer DATA_BITS  = 8,
    parameter integer OVERSAMPLE = 16,
    parameter integer CNT_W      = 9
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   rx,        // RX from CP2102

    output wire [DATA_BITS-1:0]   data_out,  // Received data
    output wire                   recieved_flag,

    // debug / test
    output wire [CNT_W-1:0]       count_o
);

    // --------------------------------------------------
    // Internal signal
    // --------------------------------------------------
    wire baud_tick;

    // --------------------------------------------------
    // Baud rate generator for RX
    // --------------------------------------------------
    Baud_Gen_Rx #(
        .CLK_SYS    (CLK_SYS),
        .BAUD_RATE  (BAUD_RATE),
        .OVERSAMPLE (OVERSAMPLE),
        .CNT_W      (CNT_W)
    ) u_baud_gen_rx (
        .clk       (clk),
        .rst       (rst),
        .baud_tick (baud_tick),
        .count_o   (count_o)
    );

    // --------------------------------------------------
    // UART Receiver
    // --------------------------------------------------
    Uart_Rx #(
        .DATA_BITS  (DATA_BITS),
        .OVERSAMPLE (OVERSAMPLE)
    ) u_uart_rx (
        .clk           (clk),
        .rst           (rst),
        .baud_tick     (baud_tick),
        .rx            (rx),
        .data_out      (data_out),
        .recieved_flag (recieved_flag)
    );

endmodule
