module Uart_Rx #(
    parameter integer DATA_BITS  = 8,
    parameter integer OVERSAMPLE = 16
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   baud_tick,
    input  wire                   rx,          // Serial input

    output reg  [DATA_BITS-1:0]   data_out,
    output reg                    recieved_flag
);

    // --------------------------------------------------
    // State encoding
    // --------------------------------------------------
    localparam [1:0]
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11;

    // --------------------------------------------------
    // Registers
    // --------------------------------------------------
    reg [1:0] state;

    reg [$clog2(OVERSAMPLE):0] tick_count;
    reg [$clog2(DATA_BITS):0]  bits_count;
    reg [DATA_BITS-1:0]        data_temp;

    // --------------------------------------------------
    // RX synchronizer
    // --------------------------------------------------
    reg rx_d1, rx_d2;
    always @(posedge clk) begin
        rx_d1 <= rx;
        rx_d2 <= rx_d1;
    end

    // --------------------------------------------------
    // UART RX FSM
    // --------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state          <= IDLE;
            tick_count     <= 'd0;
            bits_count     <= 'd0;
            data_temp      <= 'd0;
            data_out       <= 'd0;
            recieved_flag  <= 1'b0;
        end
        else begin
            recieved_flag <= 1'b0;

            case (state)

                // ---------------- IDLE ----------------
                IDLE: begin
                    tick_count <= 'd0;
                    bits_count <= 'd0;

                    if (rx_d2 == 1'b0) begin
                        state <= START;
                    end
                end

                // ---------------- START ----------------
                START: begin
                    if (baud_tick) begin
                        if (tick_count == (OVERSAMPLE/2 - 1)) begin
                            if (rx_d2 == 1'b0) begin
                                tick_count <= 'd0;
                                bits_count <= 'd0;	
                                state      <= DATA;
                            end
                            else begin
                                state <= IDLE; // false start bit
                            end
                        end
                        else begin
                            tick_count <= tick_count + 1'b1;
                        end
                    end
                end

                // ---------------- DATA ----------------
                DATA: begin
                    if (baud_tick) begin
                        if (tick_count == OVERSAMPLE-1) begin
                            tick_count <= 'd0;
                            data_temp  <= {rx_d2, data_temp[DATA_BITS-1:1]};

                            if (bits_count == DATA_BITS-1) begin
                                bits_count <= 'd0;
                                state      <= STOP;
                            end
                            else begin
                                bits_count <= bits_count + 1'b1;
                            end
                        end
                        else begin
                            tick_count <= tick_count + 1'b1;
                        end
                    end
                end

                // ---------------- STOP ----------------
                STOP: begin
                    if (baud_tick) begin
                        if (tick_count == OVERSAMPLE-1) begin
                            data_out      <= data_temp;
                            recieved_flag <= 1'b1;
                            tick_count    <= 'd0;
                            state         <= IDLE;
                        end
                        else begin
                            tick_count <= tick_count + 1'b1;
                        end
                    end
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule
