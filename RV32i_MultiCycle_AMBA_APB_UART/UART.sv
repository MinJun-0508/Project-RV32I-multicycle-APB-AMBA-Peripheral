`timescale 1ns / 1ps


module UART_Periph (
    // global signals
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic [31:0] PWDATA,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // External Port
    input  logic        rx,
    output logic        tx
);


    logic [3:0] w_USTATEREG;
    logic [7:0] w_UWDATA;
    logic [7:0] w_URDATA;
    logic       w_we_TX;
    logic       w_re_RX;

    APB_SlaveIntf_UART U_UART_Intf (
        .*,
        // Internal Port
        .USTATEREG(w_USTATEREG),
        .UWDATA   (w_UWDATA),
        .URDATA   (w_URDATA),
        .we_TX    (w_we_TX),
        .re_RX    (w_re_RX)
    );


    UART U_UART (
        .clk      (PCLK),
        .rst      (PRESET),
        .rx       (rx),
        .tx       (tx),
        .USTATEREG(w_USTATEREG),
        .UWDATA   (w_UWDATA),
        .URDATA   (w_URDATA),
        .we_tx    (w_we_TX),
        .re_rx    (w_re_RX)
    );

endmodule


module APB_SlaveIntf_UART (
    // global signals
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic [31:0] PWDATA,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // Internal Port
    input  logic [ 3:0] USTATEREG,
    output logic [ 7:0] UWDATA,
    input  logic [ 7:0] URDATA,
    output logic        we_TX,
    output logic        re_RX
);

    logic [31:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3;
    logic [31:0] slv_reg1_next, slv_reg2_next;

    logic we_reg, we_next;
    logic re_reg, re_next;
    logic [31:0] PRDATA_reg, PRDATA_next;
    logic PREADY_reg, PREADY_next;

    assign we_TX = we_reg;
    assign re_RX = re_reg;

    typedef enum {
        IDLE,
        READ,
        WRITE
    } state_e;

    state_e state_reg, state_next;

    assign slv_reg0[3:0] = USTATEREG;
    assign UWDATA = slv_reg2[7:0];
    assign slv_reg3[7:0] = URDATA;
    assign ULOOPSIG = slv_reg1;

    assign PRDATA = PRDATA_reg;
    assign PREADY = PREADY_reg;

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0[31:4] <= 0;  //USTATEREG 
            slv_reg1       <= 0;  //USTATEREG_RX
            slv_reg3[31:8] <= 0;
            slv_reg2       <= 0;
            state_reg      <= IDLE;
            we_reg         <= 0;
            re_reg         <= 0;
            PRDATA_reg     <= 32'bx;
            PREADY_reg     <= 1'b0;
        end else begin
            slv_reg1   <= slv_reg1_next;
            slv_reg2   <= slv_reg2_next;
            state_reg  <= state_next;
            we_reg     <= we_next;
            re_reg     <= re_next;
            PRDATA_reg <= PRDATA_next;
            PREADY_reg <= PREADY_next;
        end
    end

    always_comb begin
        state_next    = state_reg;
        slv_reg1_next = slv_reg1;
        slv_reg2_next = slv_reg2;
        we_next       = we_reg;
        re_next       = re_reg;
        PRDATA_next   = PRDATA_reg;
        PREADY_next   = PREADY_reg;

        case (state_reg)
            IDLE: begin
                PREADY_next = 1'b0;
                if (PSEL && PENABLE) begin
                    if (PWRITE) begin
                        state_next = WRITE;
                        we_next = 1'b1;
                        re_next = 1'b0;
                        PREADY_next = 1'b1;
                        case (PADDR[3:2])
                            2'd0: ;
                            2'd1: slv_reg1_next = PWDATA;
                            2'd2: begin
                                slv_reg2_next = PWDATA;
                            end
                            2'd3: ;
                        endcase
                    end else begin
                        state_next = READ;
                        PREADY_next = 1'b1;
                        we_next = 1'b0;
                        case (PADDR[3:2])
                            2'd0: begin
                                PRDATA_next = slv_reg0;
                                re_next = 1'b0;
                            end
                            2'd1: begin
                                PRDATA_next = slv_reg1;
                                re_next = 1'b0;
                            end
                            2'd2: begin
                                PRDATA_next = slv_reg2;
                                re_next = 1'b0;
                            end
                            2'd3: begin
                                PRDATA_next = slv_reg3;
                                re_next = 1'b1;
                            end
                        endcase
                    end
                end
            end

            READ: begin
                re_next = 1'b0;
                we_next = 1'b0;
                PREADY_next = 1'b0;
                state_next = IDLE;
            end

            WRITE: begin
                we_next = 1'b0;
                re_next = 1'b0;
                state_next = IDLE;
                PREADY_next = 1'b0;
            end
        endcase
    end

endmodule

module UART (
    input  logic       clk,
    input  logic       rst,
    input  logic       rx,
    output logic       tx,
    output logic [3:0] USTATEREG,
    input  logic [7:0] UWDATA,
    output logic [7:0] URDATA,
    input  logic       we_tx,
    input  logic       re_rx
);

    logic w_tick;
    logic w_rx_done;
    logic w_tx_busy;
    logic w_tx_fifo_empty;
    logic w_rx_fifo_empty;
    logic w_rx_fifo_full;
    logic w_tx_fifo_full;
    logic [7:0] w_rx_wdata, w_rx_rdata, w_tx_wdata, w_tx_rdata;

    assign USTATEREG = {
        w_rx_fifo_full, w_tx_fifo_empty, w_tx_fifo_full, w_rx_fifo_empty
    };
    
    assign w_tx_wdata = UWDATA;
    assign URDATA = w_rx_rdata;


    baud_tick_gen U_BAUD_TICK_GEN (
        .rst (rst),
        .clk (clk),
        .tick(w_tick)
    );


    fifo U_UART_TX_FIFO (
        .clk  (clk),
        .rst  (rst),
        .wr   (we_tx),
        .rd   (~w_tx_busy),
        .wdata(w_tx_wdata),
        .rdata(w_tx_rdata),
        .full (w_tx_fifo_full),
        .empty(w_tx_fifo_empty)
    );

    fifo U_UART_RX_FIFO (
        .clk  (clk),
        .rst  (rst),
        .wr   (w_rx_done),
        .rd   (re_rx),
        .wdata(w_rx_wdata),
        .rdata(w_rx_rdata),
        .full (w_rx_fifo_full),
        .empty(w_rx_fifo_empty)
    );

    uart_tx U_UART_TX (
        .clk     (clk),
        .rst     (rst),
        .tx_start(~w_tx_fifo_empty),
        .tx_data (w_tx_rdata),
        .tick    (w_tick),
        .tx_busy (w_tx_busy),
        .tx      (tx)
    );


    uart_rx U_UART_RX (
        .clk    (clk),
        .rst    (rst),
        .tick   (w_tick),
        .rx     (rx),
        .rx_data(w_rx_wdata),
        .rx_done(w_rx_done)
    );

endmodule
