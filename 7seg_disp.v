`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/10 22:31:29
// Design Name: 
// Module Name: 7seg_disp
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


module top_module(
        input wire CLK100MHZ
        , input wire ck_rst
        , output wire [3:0] ja
        , output wire [3:0] jb
    );

    wire [7:0] disp_number;
    wire [3:0] disp_number_digit1;
    wire [3:0] disp_number_digit2;
    wire [6:0] disp_signal;
    wire [6:0] disp_signal_digit1;
    wire [6:0] disp_signal_digit2;
    wire sel;

    /*1秒ごとにnumをカウントアップする*/
    one_sec_counter one_sec_counter(.clk(CLK100MHZ), .rst(ck_rst), .num(disp_number));

    /*2桁の16進数を、桁別のレジスタに分ける*/
    split_digit split_digit(.num(disp_number), .digit1(disp_number_digit1), .digit2(disp_number_digit2));

    /*numに入れた数字を7seg表示用の信号にデコードする*/
    convert_num_to_segment convert_num_to_segment_digit1(.clk(CLK100MHZ),.num(disp_number_digit1), .rst(ck_rst), .segment(disp_signal_digit1));
    convert_num_to_segment convert_num_to_segment_digit2(.clk(CLK100MHZ),.num(disp_number_digit2), .rst(ck_rst), .segment(disp_signal_digit2));

    /*表示桁切り替え信号selを高速で切り替える*/
    toggle_sel toggle_sel(.clk(CLK100MHZ), .rst(ck_rst), .sel(sel));

    /*sel信号に応じて、表示内容を切り替える。*/
    toggle_digit toggle_digit(.clk(CLK100MHZ), .sel(sel), .digit1(disp_signal_digit1), .digit2(disp_signal_digit2), .disp(disp_signal));

    assign ja[0] = disp_signal[0];
    assign ja[1] = disp_signal[1];
    assign ja[2] = disp_signal[2];
    assign ja[3] = disp_signal[3];
    assign jb[0] = disp_signal[4];
    assign jb[1] = disp_signal[5];
    assign jb[2] = disp_signal[6];
    assign jb[3] = sel;
endmodule

module one_sec_counter(input wire clk, input wire rst, output reg [7:0] num);
    reg [26:0] one_sec_counter;
    parameter CLK_OF_1SEC = 100000000;
    //parameter CLK_OF_1SEC = 1000;
    
    always @ (posedge clk) begin
        if(rst == 0) begin 
            one_sec_counter <= 27'b0;
            num <= 8'b0;
        end else begin
            if(one_sec_counter > CLK_OF_1SEC ) begin
                one_sec_counter <= 27'b0;
                if(num == 8'hFF) begin
                    num <= 8'b0;
                end else begin
                    num <= num+8'b1;
                end
            end else begin
                one_sec_counter <= one_sec_counter + 27'b1;
            end
        end
    end
endmodule

module split_digit(input wire [7:0]num, output wire [3:0]digit1, output wire [3:0]digit2);
    assign digit1 = num[3:0];
    assign digit2 = num[7:4];
endmodule
module convert_num_to_segment(input wire clk, input wire rst, input wire [3:0] num, output reg [6:0] segment);
    always @(posedge clk) begin 
        if(rst == 0) begin
            segment <= 0;
        end else begin
            segment <= segdec(num);
        end
    end

    function [6:0] segdec;/*数字を7seg displayの表示データにデコードする。*/
        input [7:0] din;
        begin
            case(din)
                4'h0 : segdec = 7'b0111111;
                4'h1 : segdec = 7'b0000110;
                4'h2 : segdec = 7'b1011011;
                4'h3 : segdec = 7'b1001111;
                4'h4 : segdec = 7'b1100110;
                4'h5 : segdec = 7'b1101101;
                4'h6 : segdec = 7'b1111101;
                4'h7 : segdec = 7'b0100111;
                4'h8 : segdec = 7'b1111111;
                4'h9 : segdec = 7'b1101111;
                4'hA : segdec = 7'b1110111;//A
                4'hB : segdec = 7'b1111100;//b
                4'hC : segdec = 7'b0111001;//C
                4'hD : segdec = 7'b1011110;//d
                4'hE : segdec = 7'b1111001;//E
                4'hF : segdec = 7'b1110001;//F
                default:segdec = 7'b1000000;
            endcase
        end
    endfunction
endmodule

module toggle_sel(input wire clk, input wire rst,output reg sel);
    parameter count_up = 1000000;//100MHz * 10msec
    //parameter count_up = 10000;//100MHz * 10msec
    reg [19:0] counter;
    always @ (posedge clk) begin
        if(rst == 0) begin
            sel <= 0;
            counter <= 20'b0;
        end else begin
            if(counter == count_up) begin
                counter <= 20'b0;
                sel <=~sel;
            end else begin
                counter <= counter +20'b1;
            end
        end
    end
endmodule

module toggle_digit(input wire clk, input wire sel, input wire [6:0] digit1, input wire [6:0] digit2, output reg [6:0] disp );
    always @ (posedge clk) begin
        if(sel == 0) begin
            disp <= digit1;
        end else begin
            disp <= digit2;
        end
    end
endmodule
