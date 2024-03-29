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
	output wire [7:0] dat_REG, //Выходные данные
	input we, //Разрешение записи
	input [7:0] DI, //Входные данные
	input [7:0] Adr_wr, //Адрес записи
	input [7:0] Adr_rd //Адрес чтения
);

reg [7:0] MEM[255:0]; //Модуль памяти
assign dat_REG = MEM[Adr_rd]; //Слайсовая память (256 регистров)

always @(posedge clk) begin
	MEM[Adr_wr] <= we?  DI: MEM[Adr_wr]; //Запись при we=1 по фронту clk
end

endmodule
