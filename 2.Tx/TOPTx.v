module TOPTx #(
    parameter integer CLK_SYS    = 50_000_000,
    parameter integer BAUD_RATE  = 9600,
    parameter integer DATA_BITS  = 8,
    parameter integer OVERSAMPLE = 16,
    parameter integer CNT_W      = 16
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire [DATA_BITS-1:0]   data_in,
    input  wire                   i_send,

    output wire                   tx,
    output wire                   busy_flag,

    // debug / test
    output wire [CNT_W-1:0]       count_o,
    output wire [1:0]             state_o,
    output wire [3:0]             bits_count_o
);

    // --------------------------------------------------
    // Internal signal
    // --------------------------------------------------
    wire baud_tick;

    // --------------------------------------------------
    // Baud rate generator
    // --------------------------------------------------
    Baud_Gen_Tx #(
        .CLK_SYS    (CLK_SYS),
        .BAUD_RATE  (BAUD_RATE),
        .OVERSAMPLE (OVERSAMPLE),
        .CNT_W      (CNT_W)
    ) u_baud_gen (
        .clk       (clk),
        .rst       (rst),
        .baud_tick (baud_tick),
        .count_o   (count_o)
    );

    // --------------------------------------------------
    // UART transmitter
    // --------------------------------------------------
    Uart_Tx #(
        .DATA_BITS  (DATA_BITS),
        .OVERSAMPLE (OVERSAMPLE)
    ) u_uart_tx (
        .clk          (clk),
        .rst          (rst),
        .baud_tick    (baud_tick),
        .data_in      (data_in),
        .i_send       (i_send),
        .tx           (tx),
        .busy_flag    (busy_flag),
        .state_o      (state_o),
        .bits_count_o (bits_count_o)
    );

endmodule
