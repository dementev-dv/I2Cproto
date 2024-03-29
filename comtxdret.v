`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:14:04 03/29/2024 
// Design Name: 
// Module Name:    comtxdret 
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
`include "const.v"

module TXD_RET_BL(
	output wire [7:0] tx_dat,
	input clk,
	output wire TXD, //���������������� ������
	input st,
	output reg en_tx = 0, //�������� ��������
	input [7:0] ADR_COM, //����� �������
	input [7:0] adr_REG, //����� ��������
	input [7:0] dat_MASTER, //������ �������
	input [7:0] dat_SLAVE //������ ��������
);

parameter N_byte= 3; //���������
//------���������� ������-------------------------------------

reg [8:0] cb_tact; //������� ������������ ����� (����)
wire ce_tact = (cb_tact == `UART_Nt); //Tce_tact = 1/UARTvel
reg [3:0] cb_bit = 0; //������� ��� ����� 
reg [7:0] sr_dat = 0; //������� ������ ��� �����
reg [2:0] cb_byte = 0; //������� ������������ ����
wire T_start = ((cb_bit == 0) & en_tx); //�������� ����� ���� 
wire T_dat = (cb_bit < 9) & (cb_bit > 0); //�������� ������ ��� ����� 
assign ce_stop = (cb_bit == 9) & ce_tact; //������� ����� �����
wire rep_st = st | (ce_stop & en_tx); //�������� ������� �������� ����
assign TXD = T_start? 0 : en_tx?  sr_dat[0] : 1; //TXD���������
//--------�������������� ���������� ���� ������
assign tx_dat = (cb_byte == 0)? ADR_COM: //������� 
	(cb_byte==1)? adr_REG: //����� �������� 
	((cb_byte==2) & !ADR_COM[0])? dat_MASTER: //������ �������
	((cb_byte==2)&  ADR_COM[0])? dat_SLAVE : 8'hFF; //������ ��������
	
always @(posedge clk) begin
	cb_tact <= (st & !en_tx | ce_tact)? 1: cb_tact+1;
	cb_byte <= st? 0  : ce_stop? cb_byte+1 : cb_byte;
	cb_bit <= rep_st? 0 : (ce_tact & en_tx)? cb_bit+1 :cb_bit;
	sr_dat <= (T_start & ce_tact)? tx_dat : (en_sh & ce_tact)? sr_dat>>1 | 1<<7 : sr_dat;
	en_tx <= st? 1 : ((cb_byte==N_byte-1) & ce_stop)? 0 : en_tx;
end

endmodule
