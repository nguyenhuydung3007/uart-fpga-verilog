module Uart_Tx #(
    parameter integer DATA_BITS  = 8,
    parameter integer OVERSAMPLE = 16
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   baud_tick,
    input  wire [DATA_BITS-1:0]   data_in,
    input  wire                   i_send,

    output reg                    tx,
    output reg                    busy_flag,

    // debug
    output wire [1:0]             state_o,
    output wire [3:0]             bits_count_o
);

    // State encoding
    localparam [1:0]
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11;

    localparam integer TICK_W = $clog2(OVERSAMPLE);

    reg [1:0]           state;
    reg [3:0]           bits_count;
    reg [DATA_BITS-1:0] data_shift;
    reg [TICK_W-1:0]    tick_count;

    assign state_o      = state;
    assign bits_count_o = bits_count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            tx          <= 1'b1;
            busy_flag   <= 1'b0;
            bits_count  <= 4'd0;
            data_shift  <= {DATA_BITS{1'b0}};
            tick_count  <= {TICK_W{1'b0}};
        end
        else begin
            case (state)

                IDLE: begin
                    tx        <= 1'b1;
                    busy_flag <= 1'b0;
                    if (i_send) begin
                        busy_flag  <= 1'b1;
                        data_shift <= data_in;
                        bits_count <= 4'd0;
                        tick_count <= {TICK_W{1'b0}};
                        state      <= START;
                    end
                end

                START: begin
                    if (baud_tick) begin
                        if (tick_count == OVERSAMPLE-1) begin
                            tx         <= 1'b0;
                            tick_count <= {TICK_W{1'b0}};
                            state      <= DATA;
                        end
                        else
                            tick_count <= tick_count + 1'b1;
                    end
                end

                DATA: begin
                    if (baud_tick) begin
                        if (tick_count == OVERSAMPLE-1) begin
                            tx         <= data_shift[0];
                            data_shift <= {1'b0, data_shift[DATA_BITS-1:1]};
                            tick_count <= {TICK_W{1'b0}};
                            if (bits_count == DATA_BITS-1)
                                state <= STOP;
                            else
                                bits_count <= bits_count + 1'b1;
                        end
                        else
                            tick_count <= tick_count + 1'b1;
                    end
                end

                STOP: begin
                    if (baud_tick) begin
                        if (tick_count == OVERSAMPLE-1) begin
                            tx         <= 1'b1;
                            tick_count <= {TICK_W{1'b0}};
                            state      <= IDLE;
                        end
                        else
                            tick_count <= tick_count + 1'b1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
