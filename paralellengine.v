module matmul_par #(parameter N=4, DW=8)(
    input clk,
    input rst_n,
    input start,
    output reg done,

    input  [N*N*DW-1:0] A_flat,
    input  [N*N*DW-1:0] B_flat,
    output [N*N*20-1:0] C_flat
);

    reg en, clear_acc;
    reg [2:0] k;
    reg [1:0] state;

    localparam IDLE=0, INIT=1, COMPUTE=2, DONE=3;

    // Extract elements from flattened matrices
    wire [DW-1:0] A [0:N-1][0:N-1];
    wire [DW-1:0] B [0:N-1][0:N-1];
    wire [19:0]   C [0:N-1][0:N-1];

    genvar i, j;

    // Unflatten A and B
    generate
        for (i=0;i<N;i=i+1) begin: A_ROW
            for (j=0;j<N;j=j+1) begin: A_COL
                assign A[i][j] = A_flat[(i*N+j)*DW +: DW];
                assign B[i][j] = B_flat[(i*N+j)*DW +: DW];
            end
        end
    endgenerate

    // Instantiate PE array
    generate
        for (i=0;i<N;i=i+1) begin: ROW
            for (j=0;j<N;j=j+1) begin: COL

                pe #(DW) PE (
                    .clk(clk),
                    .rst_n(rst_n),
                    .en(en),
                    .clear_acc(clear_acc),
                    .a(A[i][k]),
                    .b(B[k][j]),
                    .acc(C[i][j])
                );

            end
        end
    endgenerate

    // Flatten output
    generate
        for (i=0;i<N;i=i+1) begin: C_ROW
            for (j=0;j<N;j=j+1) begin: C_COL
                assign C_flat[(i*N+j)*20 +: 20] = C[i][j];
            end
        end
    endgenerate

    // FSM control
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            done  <= 0;
            en    <= 0;
            clear_acc <= 0;
            k <= 0;
        end else begin
            case(state)

                IDLE: begin
                    done <= 0;
                    if (start)
                        state <= INIT;
                end

                INIT: begin
                    k <= 0;
                    clear_acc <= 1;
                    en <= 0;
                    state <= COMPUTE;
                end

                COMPUTE: begin
                    clear_acc <= 0;
                    en <= 1;

                    if (k < N-1)
                        k <= k + 1;
                    else
                        state <= DONE;
                end

                DONE: begin
                    en <= 0;
                    done <= 1;
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule