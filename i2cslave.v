`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:34:57 03/29/2024 
// Design Name: 
// Module Name:    i2cslave 
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
`timescale 1ns / 1ps

`include "const.v"

module SLAVE_I2C(
	inout SDA,
	input SCL,
	output wire SDA_SLAVE,
	input clk,
	output wire T_AC,
	input [7:1] adr_SLAVE,
	output reg en_rx=0,
	output reg [7:0] cb_bit=0,
	output reg [2:0] cb_byte=0,
	output reg my_adr=0,
	output reg my_reg=0,
	output reg R_W=0,
	output wire ce_start,
	output wire ce_stop,
	output wire ce_bit,
	output wire ce_byte,
	output wire ce_ADR_COM,
	output wire back_SDA,
	output wire front_SDA,
	output wire back_SCL,
	output wire front_SCL,
	output reg Q_start=0,
	output reg [7:0] sr_tx=0,
	output reg [7:0] sr_rx=0,
	output reg [7:1] rx_ADR=0,
	output reg [7:0] rx_reg_ADR=0,
	output reg [7:0] rx_DAT=0
);
	 
	//----- T-буфер--(T=0 O=I, T=1 SDA=O=Z)-----------------
BUFT DD1 ( .I(1'b0), .O(SDA), .T(SDA_SLAVE));

reg tSDA=0, ttSDA=0, tSCL=0, ttSCL=0; //D-триггеры
assign back_SDA = !tSDA & ttSDA;
assign front_SDA = tSDA & !ttSDA;
assign ce_start = back_SDA & SCL;
assign ce_stop = front_SDA & SCL;
assign back_SCL = !tSCL & ttSCL;
assign front_SCL = tSCL & !ttSCL;
	
assign SDA_SLAVE =	!(T_AC & my_adr & (cb_byte==0)) &
							!(T_AC & my_adr & my_reg) &
							!(R_W & my_reg & (cb_byte==2) & !sr_tx[7]);
	
assign T_AC = (cb_bit == 8);
	
assign ce_bit = front_SCL & en_rx; // correct data on SDA
	
wire ce_tact = back_SCL & en_rx; // update cb_bit
assign ce_byte = ce_tact & T_AC; // update cb_byte
	
wire ce_rx_byte = ce_tact & (cb_bit == 7); // end of recieving byte
assign ce_ADR_COM = ce_rx_byte & (cb_byte == 0);
wire ce_reg_ADR = ce_rx_byte & (cb_byte == 1);
wire ce_reg_DAT = ce_rx_byte & (cb_byte == 2) & !R_W;
	
wire [7:0] reg_dat;
reg tce_reg_DAT = 0; // delay 1 cycle for date to be correct
reg tce_reg_ADR = 0;
REG_BL mem(	.clk(clk),				
				.dat_REG(reg_dat),
				.we(tce_reg_DAT),
				.DI(rx_DAT),
				.Adr_wr(rx_reg_ADR),
				.Adr_rd(rx_reg_ADR)
				);
	
always @ (posedge clk) begin
	tSDA <= SDA;
	ttSDA <= tSDA; //Задержка на Tclk
	tSCL <= SCL;
	ttSCL <= tSCL; // Задержка на Tclk
	
	tce_reg_DAT <= ce_reg_DAT;
	tce_reg_ADR <= ce_reg_ADR;
	
	Q_start <= ce_start ? 1 : front_SCL ? 0 : Q_start;
	en_rx <= (Q_start & back_SCL) ? 1 : (T_AC & ce_bit & SDA_SLAVE) ? 0 : en_rx;
	
	cb_bit <= (ce_byte | Q_start) ? 0 : ce_tact ? cb_bit + 1 : cb_bit;
	cb_byte <= Q_start ? 0 : ce_byte ? cb_byte + 1 : cb_byte;
	
	sr_rx <= ce_bit ? sr_rx << 1 | SDA : sr_rx;
	sr_tx <= (ce_byte | Q_start) ? reg_dat : ce_tact ? sr_tx << 1 | 1'b1 : sr_tx;
	
	R_W <= (ce_ADR_COM) ? sr_rx[0] : R_W;
	rx_ADR <= (ce_ADR_COM) ? sr_rx[7:1] : rx_ADR;
	my_adr <= (ce_ADR_COM) ? (adr_SLAVE == sr_rx[7:1]) : my_adr;
	
	rx_reg_ADR <= (ce_reg_ADR) ? sr_rx : rx_reg_ADR;
	my_reg <= (ce_reg_ADR) ? (sr_rx >= `BASE_ADR) & (sr_rx < `BASE_ADR + `N_REG) : my_reg;
	
	rx_DAT <= (ce_reg_DAT) ? sr_rx : rx_DAT;
end

endmodule
