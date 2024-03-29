`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:48:36 03/29/2024 
// Design Name: 
// Module Name:    comadrdat 
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
module ADR_COM_DAT_BL(
	input Inp1,
	output reg [7:0] adr_COM = 0, //�����. �������
	input Inp2,
	output reg [7:0] adr_REG = 0, //����� ��������
	input clk,
	output reg [7:0] dat_REG = 0,
	//������ ��������
	output wire ok_rx_bl
);

wire Inp = Inp1 & Inp2;
//--------�������� ������ ����------------------------------
reg [11:0] cb_tact; //������� ������������ ����� (����)
wire ce_tact = (cb_tact == `UART_Nt); //Tce_tact=1/UARTvel
wire ce_bit = (cb_tact == (`UART_Nt / 2)); //�������� �����
reg [3:0] cb_bit = 0; //������� ��� � ����� UART
reg [7:0] cb_res = 0; //������� �����
reg [7:0] cb_byte = 0; //������� �������� ����
reg [7:0] rx_dat = 0; //�������� ����
reg en_rx_byte = 0, en_rx_bl = 0;
reg RXD = 0, tRXD = 0; 

wire dRXD = !RXD & tRXD; //"�����" �������� ������� RXD
wire ok_rx_byte = (ce_bit & (cb_bit == 9) & en_rx_byte & tRXD); //�������� ����� �����
wire start_rx_byte= dRXD & !en_rx_byte; //����� ������ ���������� �����

assign ok_rx_bl = (cb_res == 10) &  ce_tact; 
/*�������� ����� ����� ���� (�� ����� � 10 ������ ����� �������)*/
wire T_dat = (cb_bit < 9) & (cb_bit > 0);

always @(posedge clk) begin
	RXD <= Inp;
	tRXD <= RXD;
	cb_tact <= ((dRXD & !en_rx_byte) | ce_tact)? 1 : cb_tact+1;
	cb_bit  <=  (start_rx_byte  |  ((cb_bit==9)  &  ce_tact))?  0  :  (ce_tact  &  en_rx_byte)?  cb_bit+1  : cb_bit;
	en_rx_byte <= (ce_bit & !RXD)? 1 : ((cb_bit==9) & ce_bit)? 0 : en_rx_byte;
	rx_dat <= (ce_bit & T_dat)? rx_dat >> 1 | RXD << 7 : rx_dat; 
	cb_byte <= ok_rx_bl? 0 : ok_rx_byte? cb_byte+1 : cb_byte ;cb_res <= en_rx_byte? 0 : (ce_tact & en_rx_bl)? cb_res+1 : cb_res;
	en_rx_bl <= start_rx_byte? 1 : ok_rx_bl? 0 : en_rx_bl;
end

//---������ ���������--------------------------

wire T_adr_COM = (cb_byte==0);
wire T_adr_REG = (cb_byte==1);
wire T_dat_REG = (cb_byte==2);

//---�������� ��������� ������, �������� ������

always @(posedge clk) begin
	adr_COM <= (T_adr_COM & ok_rx_byte)? rx_dat : adr_COM;
	adr_REG <= (T_adr_REG & ok_rx_byte)? rx_dat : adr_REG;
	dat_REG <= (T_dat_REG & ok_rx_byte)? rx_dat : dat_REG;
end

endmodule
