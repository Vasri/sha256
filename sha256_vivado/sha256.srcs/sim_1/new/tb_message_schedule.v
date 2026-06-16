`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2026 02:54:56 AM
// Design Name: 
// Module Name: tb_message_schedule
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


module tb_message_schedule;

reg [511:0] in;
reg start;
reg clk;
reg rst_n;
wire [31:0] w_out;
wire w_valid;
wire done;

localparam test_input = 512'h68656C6C6F20776F726C648000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000058;

message_schedule uut(
    .in(in),
    .start(start),
    .clk(clk),
    .rst_n(rst_n),
    .w_out(w_out),
    .done(done)
    );

always #5 clk <= ~clk;

task pulseStart();
    begin
        start <= 1;
        @(posedge clk);
        start <= 0;
    end
endtask

wire [511:0] combined_16;

assign combined_16 = {
                        uut.w[0], uut.w[1], uut.w[2], uut.w[3], 
                        uut.w[4], uut.w[5], uut.w[6], uut.w[7], 
                        uut.w[8], uut.w[9], uut.w[10], uut.w[11], 
                        uut.w[12], uut.w[13], uut.w[14], uut.w[15]
                    };

initial begin
    clk <= 0;
    rst_n <= 0;
    in <= 0;
    start <= 0;
    
    repeat(5) @(posedge clk);
    rst_n <= 1;
    
    // hello world converted to a 512-bit message block
    in <= test_input;
    pulseStart();
    in <= 0;
    @(posedge clk);
    
    // the first 16 words of w[] should match our input
    if (combined_16 === test_input) begin
        $display("SUCCESS: w matches input");
    end else begin
        $display("FAIL: w does not match input");
    end
    
    repeat(63) @(posedge clk);
    $finish;
end

endmodule
