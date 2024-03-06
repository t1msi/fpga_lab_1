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
// CREATED		"Wed Mar  6 10:37:55 2024"

module delay_15(
	clk_i,
	data_i,
	data_delay_i,
	data_o
);


input wire	clk_i;
input wire	data_i;
input wire	[3:0] data_delay_i;
output wire	data_o;

wire	SYNTHESIZED_WIRE_0;
reg	DFFE_inst9;
wire	SYNTHESIZED_WIRE_79;
reg	DFFE_inst10;
reg	DFFE_inst11;
reg	DFFE_inst12;
reg	DFFE_inst13;
reg	DFFE_inst14;
reg	DFFE_inst15;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_80;
wire	SYNTHESIZED_WIRE_81;
reg	DFFE_inst3;
wire	SYNTHESIZED_WIRE_82;
wire	SYNTHESIZED_WIRE_83;
reg	SYNTHESIZED_WIRE_84;
wire	SYNTHESIZED_WIRE_85;
wire	SYNTHESIZED_WIRE_22;
wire	SYNTHESIZED_WIRE_23;
wire	SYNTHESIZED_WIRE_86;
wire	SYNTHESIZED_WIRE_87;
wire	SYNTHESIZED_WIRE_88;
wire	SYNTHESIZED_WIRE_89;
wire	SYNTHESIZED_WIRE_90;
wire	SYNTHESIZED_WIRE_33;
reg	SYNTHESIZED_WIRE_91;
wire	SYNTHESIZED_WIRE_92;
wire	SYNTHESIZED_WIRE_93;
wire	SYNTHESIZED_WIRE_94;
wire	SYNTHESIZED_WIRE_95;
wire	SYNTHESIZED_WIRE_96;
wire	SYNTHESIZED_WIRE_45;
wire	SYNTHESIZED_WIRE_46;
wire	SYNTHESIZED_WIRE_47;
wire	SYNTHESIZED_WIRE_48;
wire	SYNTHESIZED_WIRE_49;
reg	DFFE_inst5;
wire	SYNTHESIZED_WIRE_97;
wire	SYNTHESIZED_WIRE_98;
wire	SYNTHESIZED_WIRE_99;
reg	SYNTHESIZED_WIRE_100;
wire	SYNTHESIZED_WIRE_62;
wire	SYNTHESIZED_WIRE_101;
wire	SYNTHESIZED_WIRE_64;
reg	DFFE_inst6;
wire	SYNTHESIZED_WIRE_66;
wire	SYNTHESIZED_WIRE_67;
wire	SYNTHESIZED_WIRE_69;
wire	SYNTHESIZED_WIRE_70;
wire	SYNTHESIZED_WIRE_71;
wire	SYNTHESIZED_WIRE_72;
wire	SYNTHESIZED_WIRE_73;
wire	SYNTHESIZED_WIRE_74;
wire	SYNTHESIZED_WIRE_75;
reg	DFFE_inst2;
reg	DFFE_inst7;
wire	SYNTHESIZED_WIRE_77;




assign	SYNTHESIZED_WIRE_79 =  ~SYNTHESIZED_WIRE_0;


always@(posedge clk_i)
begin
if (SYNTHESIZED_WIRE_79)
	begin
	DFFE_inst10 <= DFFE_inst9;
	end
end


always@(posedge clk_i)
begin
if (SYNTHESIZED_WIRE_79)
	begin
	DFFE_inst11 <= DFFE_inst10;
	end
end


always@(posedge clk_i)
begin
if (SYNTHESIZED_WIRE_79)
	begin
	DFFE_inst12 <= DFFE_inst11;
	end
end


always@(posedge clk_i)
begin
if (SYNTHESIZED_WIRE_79)
	begin
	DFFE_inst13 <= DFFE_inst12;
	end
end


always@(posedge clk_i)
begin
if (SYNTHESIZED_WIRE_79)
	begin
	DFFE_inst14 <= DFFE_inst13;
	end
end


always@(posedge clk_i)
begin
if (SYNTHESIZED_WIRE_79)
	begin
	DFFE_inst15 <= DFFE_inst14;
	end
end


always@(posedge clk_i)
begin
if (SYNTHESIZED_WIRE_79)
	begin
	SYNTHESIZED_WIRE_84 <= DFFE_inst15;
	end
end

assign	SYNTHESIZED_WIRE_80 =  ~data_delay_i[3];


always@(posedge clk_i)
begin
if (SYNTHESIZED_WIRE_79)
	begin
	DFFE_inst2 <= SYNTHESIZED_WIRE_8;
	end
end

assign	SYNTHESIZED_WIRE_81 =  ~data_delay_i[2];

assign	SYNTHESIZED_WIRE_87 =  ~data_delay_i[1];

assign	SYNTHESIZED_WIRE_98 =  ~data_delay_i[0];


always@(posedge clk_i)
begin
if (SYNTHESIZED_WIRE_79)
	begin
	DFFE_inst3 <= SYNTHESIZED_WIRE_10;
	end
end

assign	SYNTHESIZED_WIRE_77 = data_i & data_delay_i[3];

assign	SYNTHESIZED_WIRE_86 = SYNTHESIZED_WIRE_80 & SYNTHESIZED_WIRE_81;

assign	SYNTHESIZED_WIRE_85 = SYNTHESIZED_WIRE_81 & data_delay_i[3];

assign	SYNTHESIZED_WIRE_83 = SYNTHESIZED_WIRE_80 & data_delay_i[2];

assign	SYNTHESIZED_WIRE_82 = data_delay_i[3] & data_delay_i[2];


always@(posedge clk_i)
begin
if (SYNTHESIZED_WIRE_79)
	begin
	SYNTHESIZED_WIRE_100 <= DFFE_inst3;
	end
end

assign	SYNTHESIZED_WIRE_88 = SYNTHESIZED_WIRE_82 | SYNTHESIZED_WIRE_83;

assign	SYNTHESIZED_WIRE_22 = SYNTHESIZED_WIRE_84 & SYNTHESIZED_WIRE_82;

assign	SYNTHESIZED_WIRE_23 = data_i & SYNTHESIZED_WIRE_83;

assign	SYNTHESIZED_WIRE_94 = SYNTHESIZED_WIRE_84 & SYNTHESIZED_WIRE_85;

assign	SYNTHESIZED_WIRE_33 = SYNTHESIZED_WIRE_22 | SYNTHESIZED_WIRE_23;

assign	SYNTHESIZED_WIRE_97 = SYNTHESIZED_WIRE_86 & SYNTHESIZED_WIRE_87;

assign	SYNTHESIZED_WIRE_90 = SYNTHESIZED_WIRE_85 & SYNTHESIZED_WIRE_87;

assign	SYNTHESIZED_WIRE_89 = SYNTHESIZED_WIRE_88 & SYNTHESIZED_WIRE_87;

assign	SYNTHESIZED_WIRE_99 = SYNTHESIZED_WIRE_89 | SYNTHESIZED_WIRE_90;

assign	SYNTHESIZED_WIRE_92 = SYNTHESIZED_WIRE_88 & data_delay_i[1];


always@(posedge clk_i)
begin
if (SYNTHESIZED_WIRE_79)
	begin
	DFFE_inst5 <= SYNTHESIZED_WIRE_33;
	end
end

assign	SYNTHESIZED_WIRE_48 = SYNTHESIZED_WIRE_91 & SYNTHESIZED_WIRE_92;

assign	SYNTHESIZED_WIRE_47 = data_i & SYNTHESIZED_WIRE_93;

assign	SYNTHESIZED_WIRE_45 = SYNTHESIZED_WIRE_91 & SYNTHESIZED_WIRE_89;

assign	SYNTHESIZED_WIRE_49 = SYNTHESIZED_WIRE_94 & SYNTHESIZED_WIRE_95;

assign	SYNTHESIZED_WIRE_93 = SYNTHESIZED_WIRE_86 & data_delay_i[1];

assign	SYNTHESIZED_WIRE_66 = SYNTHESIZED_WIRE_96 & data_delay_i[0];

assign	SYNTHESIZED_WIRE_95 = SYNTHESIZED_WIRE_85 & data_delay_i[1];

assign	SYNTHESIZED_WIRE_46 = SYNTHESIZED_WIRE_94 & SYNTHESIZED_WIRE_90;

assign	SYNTHESIZED_WIRE_101 = SYNTHESIZED_WIRE_45 | SYNTHESIZED_WIRE_46;

assign	SYNTHESIZED_WIRE_10 = SYNTHESIZED_WIRE_47 | SYNTHESIZED_WIRE_48 | SYNTHESIZED_WIRE_49;


always@(posedge clk_i)
begin
if (SYNTHESIZED_WIRE_79)
	begin
	DFFE_inst6 <= DFFE_inst5;
	end
end

assign	SYNTHESIZED_WIRE_0 = SYNTHESIZED_WIRE_97 & SYNTHESIZED_WIRE_98;

assign	SYNTHESIZED_WIRE_67 = SYNTHESIZED_WIRE_97 & data_delay_i[0];

assign	SYNTHESIZED_WIRE_96 = SYNTHESIZED_WIRE_93 | SYNTHESIZED_WIRE_95 | SYNTHESIZED_WIRE_92;

assign	SYNTHESIZED_WIRE_69 = SYNTHESIZED_WIRE_99 & data_delay_i[0];

assign	SYNTHESIZED_WIRE_64 = SYNTHESIZED_WIRE_99 & SYNTHESIZED_WIRE_98;

assign	SYNTHESIZED_WIRE_62 = SYNTHESIZED_WIRE_96 & SYNTHESIZED_WIRE_98;

assign	SYNTHESIZED_WIRE_73 = SYNTHESIZED_WIRE_100 & SYNTHESIZED_WIRE_62;

assign	SYNTHESIZED_WIRE_74 = SYNTHESIZED_WIRE_101 & SYNTHESIZED_WIRE_64;


always@(posedge clk_i)
begin
if (SYNTHESIZED_WIRE_79)
	begin
	DFFE_inst7 <= DFFE_inst6;
	end
end

assign	SYNTHESIZED_WIRE_71 = SYNTHESIZED_WIRE_100 & SYNTHESIZED_WIRE_66;

assign	SYNTHESIZED_WIRE_70 = data_i & SYNTHESIZED_WIRE_67;

assign	SYNTHESIZED_WIRE_72 = SYNTHESIZED_WIRE_101 & SYNTHESIZED_WIRE_69;

assign	SYNTHESIZED_WIRE_8 = SYNTHESIZED_WIRE_70 | SYNTHESIZED_WIRE_71 | SYNTHESIZED_WIRE_72;

assign	SYNTHESIZED_WIRE_75 = SYNTHESIZED_WIRE_73 | SYNTHESIZED_WIRE_74;

assign	data_o = SYNTHESIZED_WIRE_75 | DFFE_inst2;


always@(posedge clk_i)
begin
if (SYNTHESIZED_WIRE_79)
	begin
	SYNTHESIZED_WIRE_91 <= DFFE_inst7;
	end
end


always@(posedge clk_i)
begin
if (SYNTHESIZED_WIRE_79)
	begin
	DFFE_inst9 <= SYNTHESIZED_WIRE_77;
	end
end


endmodule
