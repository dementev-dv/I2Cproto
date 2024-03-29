`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:36:18 03/29/2024 
// Design Name: 
// Module Name:    const 
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
`define Fclk 50000000 //50 MHz

//---��� COM �����-----------------
`define UART_vel 115200 //115.2kBOD
`define UART_Nt  `Fclk/`UART_vel //434

//---��� I2C------------------------
`define Fvel 1250000 //�������� ������ ���/��� (�� ������� 1)
`define N4vel `Fclk/(4*`Fvel) //50000000/(4*1250000)=10
`define BASE_ADR 8'hE0 //������� ����� ��������� �������� (�� ������� 1)
`define N_REG 8//����� ��������� �������� (�� ������� 1
