`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:35:34 03/29/2024 
// Design Name: 
// Module Name:    regblock 
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
module REG_BL(
	input clk,
	output wire [7:0] dat_REG, //�������� ������
	input we, //���������� ������
	input [7:0] DI, //������� ������
	input [7:0] Adr_wr, //����� ������
	input [7:0] Adr_rd //����� ������
);

reg [7:0] MEM[255:0]; //������ ������
assign dat_REG = MEM[Adr_rd]; //��������� ������ (256 ���������)

always @(posedge clk) begin
	MEM[Adr_wr] <= we?  DI: MEM[Adr_wr]; //������ ��� we=1 �� ������ clk
end

endmodule
