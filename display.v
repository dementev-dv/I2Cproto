`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:21:18 03/29/2024 
// Design Name: 
// Module Name:    display 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Display(
	input clk,
	output wire [3:0] AN, //�����
	input [7:0] adr_REG,
	output wire [6:0] seg, //��������
	input [7:0] dat_MASTER,
	output wire seg_P, //�����
	input [7:0] dat_SLAVE, //������ ��������
	input R_W //�������
);

parameter Fclk=50000; //50000 kHz
parameter F1kHz=1; //1 kHz
wire [1:0] ptr_P = 2'b10; //����� � ������
reg [15:0] cb_1ms = 0;
wire ce = (cb_1ms == Fclk/F1kHz);

always @(posedge clk) begin
	cb_1ms <= ce? 1 : cb_1ms+1;
end

reg [1:0] cb_an = 0; //������� ������
//-----------------

always @(posedge clk) if(ce) begin
	cb_an <= cb_an+1;
end

//-------������������� ������-------------

assign AN = (cb_an==0)? 4'b1110: //��������� ����� 0 (�������)
				(cb_an==1)? 4'b1101: //��������� ����� 1
				(cb_an==2)? 4'b1011: //��������� ����� 2
								4'b0111; //��������� ����� 3 (�������)
								
//-------������������� ������ ��� ����������
wire [15:0] dat = R_W? {adr_REG,dat_SLAVE} : {adr_REG,dat_MASTER};

//-------������������� ������(HEX ����)-------------
wire [3:0] dig = (cb_an == 0)? dat[3:0]: (cb_an == 1)? dat[7:4]: (cb_an == 2)? dat[11:8]: dat[15:12];

//-------�������������� ����������----------
//gfedcba
assign seg = 	(dig== 0)?  7'b1000000: //0 a
					(dig== 1)?  7'b1111001: //1 f| |b
					(dig== 2)?  7'b0100100: //2    g
					(dig== 3)?  7'b0110000: //3 e| |c
					(dig== 4)?  7'b0011001: //4    d
					(dig== 5)?  7'b0010010: //5
					(dig== 6)?  7'b0000010: //6
					(dig== 7)?  7'b1111000: //7
					(dig== 8)?  7'b0000000: //8
					(dig== 9)?  7'b0010000: //9
					(dig==10)?  7'b0001000: //A
					(dig==11)?  7'b0000011: //b
					(dig==12)?  7'b1000110: //C
					(dig==13)?  7'b0100001: //d
					(dig==14)?  7'b0000110: //E
									7'b0001110 ;//F
									
//-------��������������-------
assign seg_P = !(ptr_P == cb_an);

endmodule
