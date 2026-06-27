`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/25/2026 03:26:21 AM
// Design Name: 
// Module Name: tb_sha256_toplevel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_sha256_toplevel;

localparam test_input = 1024'h6162636462636465636465666465666765666768666768696768696A68696A6B696A6B6C6A6B6C6D6B6C6D6E6C6D6E6F6D6E6F706E6F70718000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001C0;

reg [511:0] in;
reg start;
reg clk;
reg rst_n;
reg last_block;
wire [255:0] out;
wire done;

sha256_toplevel uut(
    .in(in),
    .start(start),
    .last_block(last_block),
    .clk(clk),
    .rst_n(rst_n),
    .hash_latched(out),
    .done(done)
);

always #5 clk <= ~clk;

initial begin
    in <= test_input[1024:512];
    start <= 0;
    last_block <= 0;
    clk <= 0;
    rst_n <= 0;
    repeat(5) @(posedge clk);
    rst_n <= 1;
    
    start <= 1;
    @(posedge clk);
    start <= 0;
    
    @(posedge uut.cl_done);
    repeat(5) @(posedge clk);
    
    in <= test_input[511:0];
    last_block <= 1;
    start <= 1;
    @(posedge clk);
    start <= 0;
    last_block <= 0;
    
    @(posedge done);
    $finish;
end

endmodule
