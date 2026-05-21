module TOPRx_DE10 (
    input  wire        CLOCK_50,
    input  wire        KEY0,        // Reset, active LOW
    input  wire        GPIO_RX,     // RX từ CP2102 TX

    output wire [7:0]  LEDR,        // Hiển thị data nhận
    output wire        LED_DONE,     // Báo nhận xong
	 output wire [6:0]  HEX0,
	 output wire [6:0]  HEX1
);

    // --------------------------------------------------
    // Reset
    // --------------------------------------------------
    wire rst;
    assign rst = ~KEY0;

    // --------------------------------------------------
    // Internal signals
    // --------------------------------------------------
    wire [7:0] rx_data;
    wire       rx_flag;
    wire [8:0] baud_count;   // debug (có thể bỏ)
	 
	 // ===================================================
	 // MÀN HÌNH LED 7 ĐOẠN HIỂN THỊ MÃ HEX CỦA ASCII
	 // ===================================================
	 bin_to_7seg hex0 (
		  .bin (rx_data[3:0]),
		  .seg (HEX0)
	 );
	 
	 bin_to_7seg hex1 (
		  .bin (rx_data[7:4]),
		  .seg (HEX1)
	 );

    // --------------------------------------------------
    // TOPRx core
    // --------------------------------------------------
    TOPRx #(
        .CLK_SYS    (50_000_000),
        .BAUD_RATE  (9600),
        .DATA_BITS  (8),
        .OVERSAMPLE (16),
        .CNT_W      (9)
    ) u_top_rx (
        .clk            (CLOCK_50),
        .rst            (rst),
        .rx             (GPIO_RX),
        .data_out       (rx_data),
        .recieved_flag  (rx_flag),
        .count_o        (baud_count)
    );

    // --------------------------------------------------
    // Output mapping
    // --------------------------------------------------
    assign LEDR     = rx_data;
    assign LED_DONE = rx_flag;

endmodule
