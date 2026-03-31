`timescale 1ns/1ps
module matrix_tb;
reg clk;
reg rst_n;
reg start;
reg select;

reg [127:0] A_in;
reg [127:0] B_in;

wire [319:0] C_out;
wire done;

top_matrix DUT(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .select(select),
    .A_in(A_in),
    .B_in(B_in),
    .C_out(C_out),
    .done(done)
);

initial clk=0;
always #5 clk=~clk;

reg [7:0] A[0:15];
reg [7:0] B[0:15];
reg [19:0] golden[0:15];

integer i,r,c,k;
initial begin
    rst_n=0;
    start=0;
    select=0;
    #20 rst_n=1;
    for(i=0;i<16;i=i+1) begin
        A[i]=i+1;
        B[i]=i%4;
    end
    
    for(i=0;i<16;i=i+1) begin    //pack into 128 bit
        A_in[i*8+:8]=A[i];
        B_in[i*8+:8]=B[i];
    end

    for(r=0;r<4;r=r+1)
    for(c=0;c<4;c=c+1) begin
        golden[r*4+c]=0;
        for(k=0;k<4;k=k+1)
            golden[r*4+c]=golden[r*4+c] + A[r*4+k]*B[k*4+c];
    end

    select=0; //0 for sequential
    #20 start=1;
    #10 start=0;
    wait(done);

    $display("---- SEQUENTIAL ----");
    check_result;

    #20;
    select=1; //1 for parallel
    #20 start=1;
    #10 start=0;
    wait(done);

    $display("---- PARALLEL ----");
    check_result;

    $finish;
end

//task
task check_result;
begin
    $display("RESULT CHECK");
    for(i=0;i<16;i=i+1) begin
        if(C_out[i*20+:20] !== golden[i])
            $display("FAIL %0d exp=%0d got=%0d",i,golden[i],C_out[i*20+:20]);
        else
            $display("PASS %0d",i);
    end
end
endtask
endmodule