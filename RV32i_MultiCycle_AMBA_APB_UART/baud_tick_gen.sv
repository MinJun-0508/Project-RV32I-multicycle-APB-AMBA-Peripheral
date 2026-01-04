`timescale 1ns / 1ps

module baud_tick_gen (
    input  rst,
    input  clk,
    output tick
);

    parameter BAUDRATE = 9600 * 16;
    localparam BAUD_COUNT = 100_000_000 / BAUDRATE;

    reg [$clog2(BAUD_COUNT)-1:0] counter_reg, counter_next;
    reg tick_reg, tick_next;

    assign tick = tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 1'b0;
            tick_reg <= 1'b0;
        end else begin
            counter_reg <= counter_next;
            tick_reg <= tick_next;
        end
    end

    always @(*) begin
        counter_next = counter_reg;
        tick_next = tick_reg;
        if (counter_reg == BAUD_COUNT - 1) begin
            counter_next = 1'b0;
            tick_next = 1'b1;
        end else begin
            counter_next = counter_reg + 1;
            tick_next = 1'b0;
        end
    end


endmodule
