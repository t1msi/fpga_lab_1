// Copyright (C) 2018  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"
// CREATED		"Tue Feb 27 17:52:38 2024"

module mux(
	data0_i,
	data1_i,
	data2_i,
	data3_i,
	direction_i,
	data_o
);


input wire	[1:0] data0_i;
input wire	[1:0] data1_i;
input wire	[1:0] data2_i;
input wire	[1:0] data3_i;
input wire	[1:0] direction_i;
output wire	[1:0] data_o;

wire	SYNTHESIZED_WIRE_16;
wire	SYNTHESIZED_WIRE_17;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_11;
wire	SYNTHESIZED_WIRE_12;
wire	SYNTHESIZED_WIRE_13;




assign	SYNTHESIZED_WIRE_3 = data0_i[0] & SYNTHESIZED_WIRE_16 & SYNTHESIZED_WIRE_17;

assign	SYNTHESIZED_WIRE_4 = data2_i[0] & direction_i[1] & SYNTHESIZED_WIRE_16;

assign	data_o[0] = SYNTHESIZED_WIRE_3 | SYNTHESIZED_WIRE_4 | SYNTHESIZED_WIRE_5 | SYNTHESIZED_WIRE_6;

assign	SYNTHESIZED_WIRE_10 = data0_i[1] & SYNTHESIZED_WIRE_16 & SYNTHESIZED_WIRE_17;

assign	SYNTHESIZED_WIRE_11 = data2_i[1] & direction_i[1] & SYNTHESIZED_WIRE_16;

assign	SYNTHESIZED_WIRE_16 =  ~direction_i[0];

assign	data_o[1] = SYNTHESIZED_WIRE_10 | SYNTHESIZED_WIRE_11 | SYNTHESIZED_WIRE_12 | SYNTHESIZED_WIRE_13;

assign	SYNTHESIZED_WIRE_17 =  ~direction_i[1];

assign	SYNTHESIZED_WIRE_6 = data1_i[0] & direction_i[0] & SYNTHESIZED_WIRE_17;

assign	SYNTHESIZED_WIRE_5 = data3_i[0] & direction_i[0] & direction_i[1];

assign	SYNTHESIZED_WIRE_13 = data1_i[1] & direction_i[0] & SYNTHESIZED_WIRE_17;

assign	SYNTHESIZED_WIRE_12 = data3_i[1] & direction_i[0] & direction_i[1];


endmodule
