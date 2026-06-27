`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/08/2026 07:07:38 PM
// Design Name: 
// Module Name: compression_loop
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


module compression_loop(
    input [31:0] w,
    input w_valid,
    input clk,
    input rst_n,
    output [255:0] hash,
    output reg done
    );
    
localparam  [255:0] STARTING_HASH = {32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a, 32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19};


reg [31:0] h [0:7];
reg [31:0] working [0:7];
reg [5:0] k_index;
reg w_valid_d;

wire [31:0] s1;
wire [31:0] ch;
wire [31:0] temp1;
wire [31:0] s0;
wire [31:0] maj;
wire [31:0] temp2;
wire [31:0] k;

function [31:0] get_k;
    input [5:0] i;
    case(i)
        6'd0: get_k = 32'h428a2f98; 
        6'd1: get_k = 32'h71374491; 
        6'd2: get_k = 32'hb5c0fbcf; 
        6'd3: get_k = 32'he9b5dba5; 
        6'd4: get_k = 32'h3956c25b; 
        6'd5: get_k = 32'h59f111f1; 
        6'd6: get_k = 32'h923f82a4; 
        6'd7: get_k = 32'hab1c5ed5;
        6'd8: get_k = 32'hd807aa98; 
        6'd9: get_k = 32'h12835b01; 
        6'd10: get_k = 32'h243185be; 
        6'd11: get_k = 32'h550c7dc3; 
        6'd12: get_k = 32'h72be5d74; 
        6'd13: get_k = 32'h80deb1fe; 
        6'd14: get_k = 32'h9bdc06a7; 
        6'd15: get_k = 32'hc19bf174;
        6'd16: get_k = 32'he49b69c1; 
        6'd17: get_k = 32'hefbe4786; 
        6'd18: get_k = 32'h0fc19dc6; 
        6'd19: get_k = 32'h240ca1cc; 
        6'd20: get_k = 32'h2de92c6f; 
        6'd21: get_k = 32'h4a7484aa; 
        6'd22: get_k = 32'h5cb0a9dc; 
        6'd23: get_k = 32'h76f988da;
        6'd24: get_k = 32'h983e5152; 
        6'd25: get_k = 32'ha831c66d; 
        6'd26: get_k = 32'hb00327c8; 
        6'd27: get_k = 32'hbf597fc7; 
        6'd28: get_k = 32'hc6e00bf3; 
        6'd29: get_k = 32'hd5a79147; 
        6'd30: get_k = 32'h06ca6351; 
        6'd31: get_k = 32'h14292967;
        6'd32: get_k = 32'h27b70a85; 
        6'd33: get_k = 32'h2e1b2138; 
        6'd34: get_k = 32'h4d2c6dfc; 
        6'd35: get_k = 32'h53380d13; 
        6'd36: get_k = 32'h650a7354; 
        6'd37: get_k = 32'h766a0abb; 
        6'd38: get_k = 32'h81c2c92e; 
        6'd39: get_k = 32'h92722c85;
        6'd40: get_k = 32'ha2bfe8a1; 
        6'd41: get_k = 32'ha81a664b; 
        6'd42: get_k = 32'hc24b8b70; 
        6'd43: get_k = 32'hc76c51a3; 
        6'd44: get_k = 32'hd192e819; 
        6'd45: get_k = 32'hd6990624; 
        6'd46: get_k = 32'hf40e3585; 
        6'd47: get_k = 32'h106aa070;
        6'd48: get_k = 32'h19a4c116; 
        6'd49: get_k = 32'h1e376c08; 
        6'd50: get_k = 32'h2748774c; 
        6'd51: get_k = 32'h34b0bcb5; 
        6'd52: get_k = 32'h391c0cb3; 
        6'd53: get_k = 32'h4ed8aa4a; 
        6'd54: get_k = 32'h5b9cca4f; 
        6'd55: get_k = 32'h682e6ff3;
        6'd56: get_k = 32'h748f82ee; 
        6'd57: get_k = 32'h78a5636f; 
        6'd58: get_k = 32'h84c87814; 
        6'd59: get_k = 32'h8cc70208; 
        6'd60: get_k = 32'h90befffa; 
        6'd61: get_k = 32'ha4506ceb; 
        6'd62: get_k = 32'hbef9a3f7; 
        6'd63: get_k = 32'hc67178f2;           
    endcase
endfunction

integer i;

assign k = get_k(k_index);

assign s1 = {working[4][5:0], working[4][31:6]} ^ {working[4][10:0], working[4][31:11]} ^ {working[4][24:0], working[4][31:25]};
assign ch = (working[4] & working[5]) ^ ((~working[4]) & working[6]);
assign temp1 = working[7] + s1 + ch + k + w;
assign s0 = {working[0][1:0], working[0][31:2]} ^ {working[0][12:0], working[0][31:13]} ^ {working[0][21:0], working[0][31:22]};
assign maj = (working[0] & working[1]) ^ (working[0] & working[2]) ^ (working[1] & working[2]);
assign temp2 = s0 + maj;

assign hash = {h[0], h[1], h[2], h[3], h[4], h[5], h[6], h[7]};

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 8; i = i + 1) begin
            working[i] <= STARTING_HASH[(7-i)*32 +: 32];
            h[i] <= STARTING_HASH[(7-i)*32 +: 32];
        end
        k_index <= 0;
        done <= 0;
        w_valid_d <= 0;
    end else begin
        w_valid_d <= w_valid;
        if (w_valid_d && !w_valid) begin
            for (i = 0; i < 8; i = i + 1) begin
                h[i] <= h[i] + working[i];
                working[i] <= h[i] + working[i];
            end
            done <= 1;
            k_index <= 0;
        end else if (w_valid) begin
            done <= 0;
            k_index <= k_index + 1;
            working[7] <= working[6];
            working[6] <= working[5];
            working[5] <= working[4];
            working[4] <= working[3] + temp1;
            working[3] <= working[2];
            working[2] <= working[1];
            working[1] <= working[0];
            working[0] <= temp1 + temp2;
        end else begin
            done <= 0;
        end
    end
end


endmodule
