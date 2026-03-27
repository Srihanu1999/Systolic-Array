`timescale 1ns / 1ps
module matmul_seq #(
    parameter N  = 4,
    parameter DW = 8
)(
    input clk,
    input rst_n,
    input start,
    output reg done,
    output reg [$clog2(N)-1:0] a_row, a_col,
    input      [DW-1:0]        a_data,
    output reg [$clog2(N)-1:0] b_row, b_col,
    input      [DW-1:0]        b_data,
    output reg [$clog2(N)-1:0] c_row, c_col,
    output reg [19:0]          c_data,
    output reg                 c_we
);
    reg [$clog2(N):0] i, j, k;
    reg [2:0] state;

    localparam IDLE    = 0,
               INIT    = 1,
               LOAD    = 2,
               COMPUTE = 3,
               STORE   = 4,
               NEXT    = 5,
               DONE    = 6;

    reg en, clear_acc;
    wire [19:0] acc;

    pe #(DW) pe_inst (
        .clk(clk), .rst_n(rst_n),
        .en(en), .clear_acc(clear_acc),
        .a(a_data), .b(b_data),
        .acc(acc)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; done <= 0;
            c_we <= 0; en <= 0; clear_acc <= 0;
            i <= 0; j <= 0; k <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) state <= INIT;
                end

                INIT: begin
                    i <= 0; j <= 0; k <= 0;
                    clear_acc <= 1;
                    en <= 0;
                    state <= LOAD;
                end

                LOAD: begin
                    clear_acc <= 0;
                    en    <= 1;          
                    a_row <= i; a_col <= k;
                    b_row <= k; b_col <= j;
                    state <= COMPUTE;
                end

                COMPUTE: begin
                    en <= 0;             
                    if (k < N-1) begin
                        k     <= k + 1;
                        state <= LOAD;    
                    end else begin
                        state <= STORE;
                    end
                end

                STORE: begin
                    c_row  <= i;
                    c_col  <= j;
                    c_data <= acc;
                    c_we   <= 1;
                    state  <= NEXT;
                end

                NEXT: begin
                    c_we      <= 0;
                    k         <= 0;
                    clear_acc <= 1;
                    if (j < N-1) begin
                        j <= j + 1; state <= LOAD;
                    end else if (i < N-1) begin
                        j <= 0; i <= i + 1; state <= LOAD;
                    end else begin
                        state <= DONE;
                    end
                end

                DONE: begin
                    done  <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule