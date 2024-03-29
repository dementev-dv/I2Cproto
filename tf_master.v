`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:12:24 03/29/2024
// Design Name:   MASTER_I2C
// Module Name:   D:/dementev/lab408/tf_master.v
// Project Name:  lab408
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MASTER_I2C
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tf_master;

	// Inputs
	reg st;
	reg clk;
	reg [7:0] ADR_COM;
	reg [7:0] adr_REG;
	reg [7:0] dat_REG;

	// Outputs
	wire SCL;
	wire SDA_MASTER;
	wire T_start;
	wire T_stop;
	wire [3:0] cb_bit;
	wire T_AC;
	wire en_tx;
	wire ce_tact;
	wire ce_bit;
	wire ce_byte;
	wire ce_AC;
	wire err_AC;
	wire [2:0] cb_byte;
	wire [7:0] sr_rx_SDA;
	wire [7:0] RX_dat;

	// Bidirs
	wire wireSDA;

	// Instantiate the Unit Under Test (UUT)
	MASTER_I2C uut (
		.wireSDA(wireSDA), 
		.st(st), 
		.SCL(SCL), 
		.clk(clk), 
		.SDA_MASTER(SDA_MASTER), 
		.ADR_COM(ADR_COM), 
		.T_start(T_start), 
		.adr_REG(adr_REG), 
		.T_stop(T_stop), 
		.dat_REG(dat_REG), 
		.cb_bit(cb_bit), 
		.T_AC(T_AC), 
		.en_tx(en_tx), 
		.ce_tact(ce_tact), 
		.ce_bit(ce_bit), 
		.ce_byte(ce_byte), 
		.ce_AC(ce_AC), 
		.err_AC(err_AC), 
		.cb_byte(cb_byte), 
		.sr_rx_SDA(sr_rx_SDA), 
		.RX_dat(RX_dat)
	);
	
	always begin
		clk = 0;
		#10;
		clk = 1;
		#10;
	end
	

	initial begin
		// Initialize Inputs
		st = 0;
		ADR_COM = 8'h00;
		adr_REG = 8'h00;
		dat_REG = 8'h00;
		
		#500;
		
		st = 1;
		ADR_COM = 8'h70;
		adr_REG = 8'h70;
		dat_REG = 8'h70;
		
		#20;
		
		st = 0;
		ADR_COM = 8'h70;
		adr_REG = 8'h70;
		dat_REG = 8'h70;
		
	end
      
endmodule

