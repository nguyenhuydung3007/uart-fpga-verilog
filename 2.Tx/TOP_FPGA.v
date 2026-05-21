/*
=====================================================================
MODULE KẾT NỐI VỚI KIT FPGA DE10 - Lite
KẾT NỐI CHÂN Rx CỦA CP2102 VỚI CHÂN GPIO[0] CỦA KIT FPGA
GẠT CÁC CÔNG TẮC (SW) TƯƠNG ỨNG VỚI CÁC GIÁ TRỊ TRONG BẢNG MÃ ASCII
NHẤN KEY1 ĐẺ GỬI TÍN HIỆU ĐÉN CP2102
=====================================================================
*/
module TOP_FPGA (
    input  wire        CLOCK_50,
    input  wire [1:0]  KEY,        // KEY[0]=reset, KEY[1]=send
    input  wire [7:0]  SW,
    output wire [0:0]  GPIO,        // GPIO[0] → CP2102 RX
	 output wire [6:0]  HEX0,
	 output wire [6:0]  HEX1
);

    // --------------------------------------------------
    // Parameters
    // --------------------------------------------------
    localparam integer CLK_SYS    = 50_000_000;
    localparam integer BAUD_RATE  = 9600;
    localparam integer DATA_BITS  = 8;
    localparam integer OVERSAMPLE = 16;
    localparam integer CNT_W      = 16;

    // --------------------------------------------------
    // Signals
    // --------------------------------------------------
    wire rst;
    wire i_send;
    wire tx;
    wire busy_flag;

    assign rst     = ~KEY[0];   // KEY active LOW
    assign GPIO[0] = tx;        // UART TX → CP2102 RX
	 
	 // ==================================================
	 // LED 7 ĐOẠN HIỂN THỊ MÃ HEX CỦA ASCII
	 // ==================================================
	 bin_to_7seg hex0 (
		  .bin (SW[3:0]),
		  .seg (HEX0)
	 );
	 
	 bin_to_7seg hex1 (
		  .bin (SW[7:4]),
		  .seg (HEX1)
	 );

    // --------------------------------------------------
    // Button → one pulse
    // --------------------------------------------------
    key_one_pluse u_key_send (
        .clk   (CLOCK_50),
        .key_n (KEY[1]),
        .pluse (i_send)
    );

    // --------------------------------------------------
    // UART TX TOP
    // --------------------------------------------------
    TOPTx #(
        .CLK_SYS    (CLK_SYS),
        .BAUD_RATE  (BAUD_RATE),
        .DATA_BITS  (DATA_BITS),
        .OVERSAMPLE (OVERSAMPLE),
        .CNT_W      (CNT_W)
    ) u_top_tx (
        .clk       (CLOCK_50),
        .rst       (rst),
        .data_in   (SW),
        .i_send    (i_send),
        .tx        (tx),
        .busy_flag (busy_flag),

        // debug (optional)
        .count_o(),
        .state_o(),
        .bits_count_o()
    );

endmodule
