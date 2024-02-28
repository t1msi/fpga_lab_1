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
// CREATED		"Wed Feb 28 18:47:15 2024"

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

wire	SYNTHESIZED_WIRE_66;
wire	SYNTHESIZED_WIRE_67;
wire	SYNTHESIZED_WIRE_68;
wire	SYNTHESIZED_WIRE_69;
wire	SYNTHESIZED_WIRE_70;
wire	SYNTHESIZED_WIRE_71;
wire	SYNTHESIZED_WIRE_72;
wire	SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_73;
wire	SYNTHESIZED_WIRE_74;
wire	SYNTHESIZED_WIRE_15;
wire	SYNTHESIZED_WIRE_16;
wire	SYNTHESIZED_WIRE_18;
wire	SYNTHESIZED_WIRE_19;
wire	SYNTHESIZED_WIRE_20;
wire	SYNTHESIZED_WIRE_22;
wire	SYNTHESIZED_WIRE_75;
wire	SYNTHESIZED_WIRE_76;
wire	SYNTHESIZED_WIRE_77;
wire	SYNTHESIZED_WIRE_78;
wire	SYNTHESIZED_WIRE_79;
wire	SYNTHESIZED_WIRE_80;
wire	SYNTHESIZED_WIRE_43;
wire	SYNTHESIZED_WIRE_44;
wire	SYNTHESIZED_WIRE_46;
wire	SYNTHESIZED_WIRE_47;
wire	SYNTHESIZED_WIRE_48;
wire	SYNTHESIZED_WIRE_49;
wire	SYNTHESIZED_WIRE_57;
wire	SYNTHESIZED_WIRE_58;
wire	SYNTHESIZED_WIRE_60;

assign	data_val_o = data_val_i;



assign	SYNTHESIZED_WIRE_66 =  ~data_i[0];

assign	SYNTHESIZED_WIRE_71 = SYNTHESIZED_WIRE_66 & SYNTHESIZED_WIRE_67 & SYNTHESIZED_WIRE_68;

assign	SYNTHESIZED_WIRE_68 =  ~data_i[2];

assign	SYNTHESIZED_WIRE_60 =  ~SYNTHESIZED_WIRE_69;

assign	SYNTHESIZED_WIRE_57 =  ~SYNTHESIZED_WIRE_70;

assign	SYNTHESIZED_WIRE_58 =  ~SYNTHESIZED_WIRE_71;

assign	data_right_o[0] = data_val_i & SYNTHESIZED_WIRE_72 & SYNTHESIZED_WIRE_7 & data_val_i & SYNTHESIZED_WIRE_8 & SYNTHESIZED_WIRE_9;

assign	SYNTHESIZED_WIRE_80 = data_i[0] & SYNTHESIZED_WIRE_67 & SYNTHESIZED_WIRE_68;

assign	SYNTHESIZED_WIRE_9 =  ~SYNTHESIZED_WIRE_71;

assign	SYNTHESIZED_WIRE_7 =  ~SYNTHESIZED_WIRE_73;

assign	SYNTHESIZED_WIRE_8 =  ~SYNTHESIZED_WIRE_74;

assign	data_right_o[1] = SYNTHESIZED_WIRE_15 & SYNTHESIZED_WIRE_16 & SYNTHESIZED_WIRE_73 & data_val_i & data_val_i & SYNTHESIZED_WIRE_18;

assign	data_right_o[2] = data_val_i & SYNTHESIZED_WIRE_19 & SYNTHESIZED_WIRE_20 & data_val_i & SYNTHESIZED_WIRE_74 & SYNTHESIZED_WIRE_22;

assign	SYNTHESIZED_WIRE_16 =  ~SYNTHESIZED_WIRE_72;

assign	SYNTHESIZED_WIRE_15 =  ~SYNTHESIZED_WIRE_74;

assign	SYNTHESIZED_WIRE_69 = SYNTHESIZED_WIRE_74 | SYNTHESIZED_WIRE_75 | SYNTHESIZED_WIRE_76 | SYNTHESIZED_WIRE_77;

assign	SYNTHESIZED_WIRE_70 = SYNTHESIZED_WIRE_78 | SYNTHESIZED_WIRE_79;

assign	SYNTHESIZED_WIRE_73 = SYNTHESIZED_WIRE_75 | SYNTHESIZED_WIRE_79;

assign	SYNTHESIZED_WIRE_79 = SYNTHESIZED_WIRE_66 & data_i[1] & SYNTHESIZED_WIRE_68;

assign	SYNTHESIZED_WIRE_72 = SYNTHESIZED_WIRE_80 | SYNTHESIZED_WIRE_77 | SYNTHESIZED_WIRE_76 | SYNTHESIZED_WIRE_78;

assign	SYNTHESIZED_WIRE_18 =  ~SYNTHESIZED_WIRE_71;

assign	SYNTHESIZED_WIRE_22 =  ~SYNTHESIZED_WIRE_71;

assign	SYNTHESIZED_WIRE_20 =  ~SYNTHESIZED_WIRE_73;

assign	SYNTHESIZED_WIRE_19 =  ~SYNTHESIZED_WIRE_72;

assign	data_left_o[1] = data_val_i & SYNTHESIZED_WIRE_43 & SYNTHESIZED_WIRE_44 & data_val_i & SYNTHESIZED_WIRE_70 & SYNTHESIZED_WIRE_46;

assign	data_left_o[2] = data_val_i & SYNTHESIZED_WIRE_47 & SYNTHESIZED_WIRE_48 & data_val_i & SYNTHESIZED_WIRE_49 & SYNTHESIZED_WIRE_69;

assign	SYNTHESIZED_WIRE_46 =  ~SYNTHESIZED_WIRE_69;

assign	SYNTHESIZED_WIRE_44 =  ~SYNTHESIZED_WIRE_80;

assign	SYNTHESIZED_WIRE_43 =  ~SYNTHESIZED_WIRE_71;

assign	SYNTHESIZED_WIRE_78 = data_i[0] & data_i[1] & SYNTHESIZED_WIRE_68;

assign	SYNTHESIZED_WIRE_49 =  ~SYNTHESIZED_WIRE_70;

assign	SYNTHESIZED_WIRE_47 =  ~SYNTHESIZED_WIRE_71;

assign	data_left_o[0] = SYNTHESIZED_WIRE_57 & SYNTHESIZED_WIRE_58 & SYNTHESIZED_WIRE_80 & data_val_i & data_val_i & SYNTHESIZED_WIRE_60;

assign	SYNTHESIZED_WIRE_48 =  ~SYNTHESIZED_WIRE_80;

assign	SYNTHESIZED_WIRE_74 = SYNTHESIZED_WIRE_66 & SYNTHESIZED_WIRE_67 & data_i[2];

assign	SYNTHESIZED_WIRE_77 = data_i[2] & SYNTHESIZED_WIRE_67 & data_i[0];

assign	SYNTHESIZED_WIRE_75 = data_i[2] & data_i[1] & SYNTHESIZED_WIRE_66;

assign	SYNTHESIZED_WIRE_76 = data_i[2] & data_i[1] & data_i[0];

assign	SYNTHESIZED_WIRE_67 =  ~data_i[1];


endmodule
