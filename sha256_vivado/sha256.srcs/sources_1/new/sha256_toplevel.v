`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2026 03:49:15 AM
// Design Name: 
// Module Name: sha256_toplevel
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


module sha256_toplevel(
    input [511:0] in,
    input start,
    input last_block,
    input clk,
    input rst_n,
    output reg [255:0] hash_latched,
    output reg done
);

localparam IDLE = 0,
           RUNNING = 1;

wire ms_done;
wire cl_done;
wire [31:0] w_out;
wire w_valid;
wire [255:0] hash;

reg state;
reg is_last;

message_schedule ms(
    .in(in),
    .start(start),
    .clk(clk),
    .rst_n(rst_n),
    .w_out(w_out),
    .w_valid(w_valid),
    .done(ms_done)
);

compression_loop cl(
    .w(w_out),
    .w_valid(w_valid),
    .clk(clk),
    .rst_n(rst_n),
    .hash(hash),
    .done(cl_done)
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        done <= 0;
        state <= IDLE;
        hash_latched <= 0;
        is_last <= 0;
    end else begin
        case(state)
            IDLE:
            begin
                done <= 0;
                if (start) begin
                    state <= RUNNING;
                    is_last <= last_block;
                end
            end
            RUNNING:
            begin
                if (start) begin
                    is_last <= last_block;
                end
                if (cl_done && is_last) begin
                    hash_latched <= hash;
                    done <= 1;
                    state <= IDLE;
                end 
            end 
        endcase
    end
end

endmodule
