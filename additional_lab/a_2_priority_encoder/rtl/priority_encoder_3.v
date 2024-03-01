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
// CREATED		"Fri Mar  1 11:16:42 2024"

module priority_encoder_3(
	data_val_i,
	data_i,
	data_val_o,
	data_left_o,
	data_right_o
);


input wire	data_val_i;
input wire	[2:0] data_i;
output wire	data_val_o;
output wire	[2:0] data_left_o;
output wire	[2:0] data_right_o;

wire	SYNTHESIZED_WIRE_21;
wire	SYNTHESIZED_WIRE_22;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_23;
wire	SYNTHESIZED_WIRE_24;
wire	SYNTHESIZED_WIRE_25;
wire	SYNTHESIZED_WIRE_26;
wire	SYNTHESIZED_WIRE_27;
wire	SYNTHESIZED_WIRE_28;
wire	SYNTHESIZED_WIRE_12;

assign	data_val_o = data_val_i;



assign	SYNTHESIZED_WIRE_28 =  ~data_i[0];

assign	SYNTHESIZED_WIRE_22 =  ~data_i[2];

assign	SYNTHESIZED_WIRE_12 = data_i[0] & SYNTHESIZED_WIRE_21 & SYNTHESIZED_WIRE_22;

assign	data_left_o[2] = SYNTHESIZED_WIRE_2 | SYNTHESIZED_WIRE_23 | SYNTHESIZED_WIRE_24 | SYNTHESIZED_WIRE_25;

assign	data_left_o[1] = SYNTHESIZED_WIRE_26 | SYNTHESIZED_WIRE_27;

assign	data_right_o[1] = SYNTHESIZED_WIRE_23 | SYNTHESIZED_WIRE_27;

assign	SYNTHESIZED_WIRE_27 = SYNTHESIZED_WIRE_28 & data_i[1] & SYNTHESIZED_WIRE_22;

assign	data_right_o[0] = SYNTHESIZED_WIRE_12 | SYNTHESIZED_WIRE_25 | SYNTHESIZED_WIRE_24 | SYNTHESIZED_WIRE_26;

assign	SYNTHESIZED_WIRE_26 = data_i[0] & data_i[1] & SYNTHESIZED_WIRE_22;

assign	SYNTHESIZED_WIRE_2 = SYNTHESIZED_WIRE_28 & SYNTHESIZED_WIRE_21 & data_i[2];

assign	SYNTHESIZED_WIRE_25 = data_i[2] & SYNTHESIZED_WIRE_21 & data_i[0];

assign	SYNTHESIZED_WIRE_23 = data_i[2] & data_i[1] & SYNTHESIZED_WIRE_28;

assign	SYNTHESIZED_WIRE_24 = data_i[2] & data_i[1] & data_i[0];

assign	SYNTHESIZED_WIRE_21 =  ~data_i[1];


endmodule
