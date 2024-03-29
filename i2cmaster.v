`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:34:39 03/29/2024 
// Design Name: 
// Module Name:    i2cmaster 
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
module MASTER_I2C(
	inout wireSDA, //Физический сигнал SDA мастера
	input st,
	output reg SCL = 1, //Сигнал SCL мастера
	input clk,
	output reg SDA_MASTER = 1, //Логический сигнал SDA мастера
	input [7:0] ADR_COM,
	output reg T_start = 0,	//Старт передачи
	input [7:0] adr_REG,
	output reg T_stop=0, //Стоп передачи
	input [7:0] dat_REG,
	output reg [3:0] cb_bit = 0, //Счетчик бит
	output wire T_AC, //Такт подтверждения 
	output reg en_tx = 0, //Разрешение передачи
	output wire ce_tact, // Границы тактов
	output wire ce_bit, // Середины тактов
	output wire ce_byte,	//Границы байт
	output wire ce_AC, //Строб такта T_AC
	output reg err_AC = 0, //Триггер подтверждения
	output reg [2:0] cb_byte = 0, //Счетчик байт
	output reg [7:0] sr_rx_SDA = 0, //Регистр сдвига принимаемых данных
	output reg [7:0] RX_dat = 0 //Регистр данных от ведомого
);

PULLUP DA1(SDA); //PULLUP Резистор
//-----T-буфер--(T=0 O=I, T=1 SDA=O=Z)-----------------

BUFT DD1 ( .I(1'b0),.O(SDA),.T(SDA_MASTER));

parameter Fclk=50000000; //Fclk =50 000 kHz
parameter Fvel= 1250000 ; //Fvel = 1 250 kHz
parameter N4vel=Fclk/(4*Fvel); //50000000/(4*1250000)=10
parameter N_byte= 3 ; //Число байт (адрес ведомого, адрес регистра, данные)

reg [10:0]cb_ce=4*N4vel;
assign ce_tact =(cb_ce==1*N4vel);//10
assign ce_bit = (cb_ce==3*N4vel) & en_tx;//30
reg[7:0]sr_tx_SDA=8'h00; //Регистр сдвига передаваемых данных

assign T_AC= (cb_bit==8); //Контрольный такт
wire T_dat = en_tx & !T_start & !T_stop & !T_AC;
assign ce_AC= T_AC & ce_bit; //Строб контроля AC
assign ce_byte = ce_tact & T_AC; //ce_byte

wire R_W= ADR_COM[0]; //1-чтение, 0-запись
reg rep_st= 0; //Интевал передачи данных
wire[7:0]TX_dat =(cb_byte==0)? ADR_COM://Адрес_команда
	(cb_byte==1)? adr_REG: //Адрес регистра
	((cb_byte==2) &!R_W)? dat_REG: 8'hFF; //Данные регистра

always @(posedge clk) begin
	cb_ce <= st? 3*N4vel : (cb_ce==1)? 4*N4vel : cb_ce-1; // 3*N4vel-задержка первого ce_bit от st
	T_start <= st? 1 : ce_tact? 0 : T_start;
	cb_bit <= (st | ce_byte)? 0 : (ce_tact &en_tx & !T_start)? cb_bit+1 : cb_bit;
	
T_stop <= ce_byte & ((cb_byte==N_byte-1) | err_AC)? 1 : ce_bit? 0 : T_stop;
en_tx <= st? 1 : (T_stop & ce_bit)? 0 : en_tx;
SCL <= (cb_ce>2*N4vel) | !en_tx;
SDA_MASTER <= (T_start | T_stop)? 0 : en_tx? (sr_tx_SDA[7] | T_AC) : 1;

sr_tx_SDA <= rep_st? TX_dat : (ce_tact & T_dat)? sr_tx_SDA<<1 | 1'b1 : sr_tx_SDA;
cb_byte <= st? 0 : (ce_byte & en_tx)? cb_byte+1 : cb_byte;
err_AC <= st? 0 : (ce_AC & SDA)? 1 : err_AC; //1-нет подтверждения (AC_SLAVE=1)
rep_st = (st | (ce_byte & en_tx));

//Последовательный прием данных от ведомого на интервале третьего байта
sr_rx_SDA <= ((cb_byte==N_byte-1) & ce_bit & T_dat)? sr_rx_SDA<<1 | SDA : sr_rx_SDA;
RX_dat <= ((cb_byte==N_byte-1) & ce_byte & R_W)? sr_rx_SDA : RX_dat; //N_byte-1

end

endmodule
