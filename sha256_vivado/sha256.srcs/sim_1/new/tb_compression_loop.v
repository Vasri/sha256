`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 03:12:18 AM
// Design Name: 
// Module Name: tb_compression_loop
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


module tb_compression_loop;

reg [31:0] k;
reg [31:0] w;
reg w_valid;
reg clk;
reg rst_n;
wire [255:0] hash;
wire done;

compression_loop uut (
    .k(k),
    .w(w),
    .w_valid(w_valid),
    .clk(clk),
    .rst_n(rst_n),
    .hash(hash),
    .done(done)
);

always #5 clk <= ~clk;

initial begin
    clk <= 1;
    rst_n <= 0;
    w_valid <= 0;
    repeat(5) @(posedge clk);
    rst_n <= 1;
    
    k <= 32'h428a2f98;
    w <= 32'h68656C6C;
    w_valid <= 1;
    @(posedge clk);
    
    k <= 32'h71374491;
    w <= 32'h6F20776F;
    @(posedge clk);
    
    k <= 32'hb5c0fbcf;
    w <= 32'h726C6480;
    @(posedge clk);
    
    k <= 32'he9b5dba5;
    w <= 32'h00000000;
    @(posedge clk);
    
    k <= 32'h3956c25b;
    w <= 32'h00000000;
    @(posedge clk);
    
    $finish;
end

endmodule
