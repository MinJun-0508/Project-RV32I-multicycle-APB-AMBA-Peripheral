`timescale 1ns / 1ps

module uart_tx (
    input  logic       clk,
    input  logic       rst,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    input  logic       tick,
    output logic       tx_busy,
    output logic       tx
);

    localparam [1:0] IDLE = 2'b00, TX_START = 2'b01, TX_DATA = 2'b10, TX_STOP = 2'b11;

    logic [1:0] c_state, n_state;
    logic [2:0] bit_cnt_reg, bit_cnt_next;
    logic [3:0] tick_cnt_reg, tick_cnt_next;
    logic [7:0] data_buf_reg, data_buf_next;
    logic tx_reg, tx_next;
    logic tx_busy_reg, tx_busy_next;

    assign tx_busy = tx_busy_reg;
    assign tx = tx_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state      <= IDLE;
            bit_cnt_reg  <= 3'b000;
            tick_cnt_reg <= 4'b0000;
            data_buf_reg <= 8'h00;
            tx_reg       <= 1'b1;
            tx_busy_reg  <= 1'b0;
        end else begin
            c_state      <= n_state;
            bit_cnt_reg  <= bit_cnt_next;
            tick_cnt_reg <= tick_cnt_next;
            data_buf_reg <= data_buf_next;
            tx_reg       <= tx_next;
            tx_busy_reg  <= tx_busy_next;
        end
    end

    always @(*) begin
        n_state       = c_state;
        bit_cnt_next  = bit_cnt_reg;
        tick_cnt_next = tick_cnt_reg;
        data_buf_next = data_buf_reg;
        tx_next       = tx_reg;
        tx_busy_next  = tx_busy_reg;
        case (c_state)
            IDLE: begin
                tx_next = 1'b1;
                tx_busy_next = 1'b0;
                if (tx_start) begin
                    tick_cnt_next = 0;
                    data_buf_next = tx_data;
                    n_state = TX_START;
                end
            end
            TX_START: begin
                tx_next = 1'b0;
                tx_busy_next = 1'b1;
                if (tick) begin
                    if (tick_cnt_reg == 15) begin
                        tick_cnt_next = 0;
                        bit_cnt_next = 0;
                        n_state = TX_DATA;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            TX_DATA: begin
                tx_next = data_buf_reg[0];
                if (tick) begin
                    if (tick_cnt_reg == 15) begin
                        //tick_cnt_next = 0;
                        if (bit_cnt_reg == 7) begin
                            tick_cnt_next = 0;
                            n_state = TX_STOP;
                        end else begin
                            tick_cnt_next = 0;
                            bit_cnt_next  = bit_cnt_reg + 1;
                            data_buf_next = data_buf_reg >> 1;
                        end
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            TX_STOP: begin
                tx_next = 1'b1;
                if (tick) begin
                    if (tick_cnt_reg == 15) begin
                        tx_busy_next = 1'b0;
                        n_state = IDLE;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end




endmodule
