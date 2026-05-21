module Baud_Gen_Rx #(
    parameter integer CLK_SYS    = 50_000_000,
    parameter integer BAUD_RATE  = 9600,
    parameter integer OVERSAMPLE = 16,
    parameter integer CNT_W      = 9   // << FIX WIDTH TẠI ĐÂY
)(
    input  wire clk,
    input  wire rst,          // synchronous active-high reset

    output reg  baud_tick,

    // debug / test
    output wire [CNT_W-1:0] count_o
);

    // --------------------------------------------------
    // Baud divider
    // --------------------------------------------------
    localparam integer BAUD_DIV = CLK_SYS / (BAUD_RATE * OVERSAMPLE);

    // --------------------------------------------------
    // Counter
    // --------------------------------------------------
    reg [CNT_W-1:0] count;

    assign count_o = count;

    // --------------------------------------------------
    // Baud tick generator
    // --------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            count     <= {CNT_W{1'b0}};
            baud_tick <= 1'b0;
        end
        else if (count == BAUD_DIV - 1) begin
            count     <= {CNT_W{1'b0}};
            baud_tick <= 1'b1;
        end
        else begin
            count     <= count + 1'b1;
            baud_tick <= 1'b0;
        end
    end

endmodule
