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
// CREATED		"Wed Mar 13 21:17:05 2024"

module crc_16_ansi(
	data_i,
	rst_i,
	clk_i,
	data_o
);


input wire	data_i;
input wire	rst_i;
input wire	clk_i;
output reg	[15:0] data_o;

wire	SYNTHESIZED_WIRE_18;
wire	SYNTHESIZED_WIRE_1;
reg	DFF_inst;
reg	DFF_inst9;
reg	DFF_inst10;
reg	DFF_inst11;
reg	DFF_inst12;
wire	SYNTHESIZED_WIRE_8;
reg	SYNTHESIZED_WIRE_19;
reg	DFF_inst1;
reg	DFF_inst13;
wire	SYNTHESIZED_WIRE_10;
reg	DFF_inst2;
reg	DFF_inst3;
reg	DFF_inst4;
reg	DFF_inst5;
reg	DFF_inst6;
reg	DFF_inst7;
reg	DFF_inst8;





always@(posedge clk_i or negedge SYNTHESIZED_WIRE_18)
begin
if (!SYNTHESIZED_WIRE_18)
	begin
	DFF_inst <= 0;
	end
else
	begin
	DFF_inst <= SYNTHESIZED_WIRE_1;
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_18)
begin
if (!SYNTHESIZED_WIRE_18)
	begin
	DFF_inst1 <= 0;
	end
else
	begin
	DFF_inst1 <= DFF_inst;
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_18)
begin
if (!SYNTHESIZED_WIRE_18)
	begin
	DFF_inst10 <= 0;
	end
else
	begin
	DFF_inst10 <= DFF_inst9;
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_18)
begin
if (!SYNTHESIZED_WIRE_18)
	begin
	DFF_inst11 <= 0;
	end
else
	begin
	DFF_inst11 <= DFF_inst10;
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_18)
begin
if (!SYNTHESIZED_WIRE_18)
	begin
	DFF_inst12 <= 0;
	end
else
	begin
	DFF_inst12 <= DFF_inst11;
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_18)
begin
if (!SYNTHESIZED_WIRE_18)
	begin
	DFF_inst13 <= 0;
	end
else
	begin
	DFF_inst13 <= DFF_inst12;
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_18)
begin
if (!SYNTHESIZED_WIRE_18)
	begin
	SYNTHESIZED_WIRE_19 <= 0;
	end
else
	begin
	SYNTHESIZED_WIRE_19 <= SYNTHESIZED_WIRE_8;
	end
end

assign	SYNTHESIZED_WIRE_1 = SYNTHESIZED_WIRE_19 ^ data_i;

assign	SYNTHESIZED_WIRE_10 = SYNTHESIZED_WIRE_19 ^ DFF_inst1;

assign	SYNTHESIZED_WIRE_8 = SYNTHESIZED_WIRE_19 ^ DFF_inst13;

assign	SYNTHESIZED_WIRE_18 =  ~rst_i;


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_18)
begin
if (!SYNTHESIZED_WIRE_18)
	begin
	DFF_inst2 <= 0;
	end
else
	begin
	DFF_inst2 <= SYNTHESIZED_WIRE_10;
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_18)
begin
if (!SYNTHESIZED_WIRE_18)
	begin
	DFF_inst3 <= 0;
	end
else
	begin
	DFF_inst3 <= DFF_inst2;
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_18)
begin
if (!SYNTHESIZED_WIRE_18)
	begin
	DFF_inst4 <= 0;
	end
else
	begin
	DFF_inst4 <= DFF_inst3;
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_18)
begin
if (!SYNTHESIZED_WIRE_18)
	begin
	DFF_inst5 <= 0;
	end
else
	begin
	DFF_inst5 <= DFF_inst4;
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_18)
begin
if (!SYNTHESIZED_WIRE_18)
	begin
	DFF_inst6 <= 0;
	end
else
	begin
	DFF_inst6 <= DFF_inst5;
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_18)
begin
if (!SYNTHESIZED_WIRE_18)
	begin
	DFF_inst7 <= 0;
	end
else
	begin
	DFF_inst7 <= DFF_inst6;
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_18)
begin
if (!SYNTHESIZED_WIRE_18)
	begin
	DFF_inst8 <= 0;
	end
else
	begin
	DFF_inst8 <= DFF_inst7;
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_18)
begin
if (!SYNTHESIZED_WIRE_18)
	begin
	DFF_inst9 <= 0;
	end
else
	begin
	DFF_inst9 <= DFF_inst8;
	end
end


endmodule
