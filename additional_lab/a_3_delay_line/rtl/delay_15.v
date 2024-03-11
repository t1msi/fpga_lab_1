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
// CREATED		"Thu Mar  7 18:00:26 2024"

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
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
reg	DFF_inst9;
reg	DFF_inst10;
reg	DFF_inst11;
reg	DFF_inst12;
reg	DFF_inst13;
reg	DFF_inst14;
reg	DFF_inst15;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_65;
wire	SYNTHESIZED_WIRE_66;
reg	DFF_inst3;
wire	SYNTHESIZED_WIRE_67;
wire	SYNTHESIZED_WIRE_68;
reg	SYNTHESIZED_WIRE_69;
wire	SYNTHESIZED_WIRE_70;
wire	SYNTHESIZED_WIRE_15;
wire	SYNTHESIZED_WIRE_16;
wire	SYNTHESIZED_WIRE_71;
wire	SYNTHESIZED_WIRE_72;
wire	SYNTHESIZED_WIRE_73;
wire	SYNTHESIZED_WIRE_74;
wire	SYNTHESIZED_WIRE_75;
wire	SYNTHESIZED_WIRE_26;
reg	SYNTHESIZED_WIRE_76;
wire	SYNTHESIZED_WIRE_77;
wire	SYNTHESIZED_WIRE_78;
wire	SYNTHESIZED_WIRE_79;
wire	SYNTHESIZED_WIRE_80;
wire	SYNTHESIZED_WIRE_81;
wire	SYNTHESIZED_WIRE_37;
wire	SYNTHESIZED_WIRE_38;
wire	SYNTHESIZED_WIRE_39;
wire	SYNTHESIZED_WIRE_40;
wire	SYNTHESIZED_WIRE_41;
reg	DFF_inst5;
wire	SYNTHESIZED_WIRE_82;
wire	SYNTHESIZED_WIRE_83;
wire	SYNTHESIZED_WIRE_84;
reg	SYNTHESIZED_WIRE_85;
wire	SYNTHESIZED_WIRE_53;
wire	SYNTHESIZED_WIRE_86;
wire	SYNTHESIZED_WIRE_55;
reg	DFF_inst6;
wire	SYNTHESIZED_WIRE_56;
wire	SYNTHESIZED_WIRE_57;
wire	SYNTHESIZED_WIRE_59;
wire	SYNTHESIZED_WIRE_60;
wire	SYNTHESIZED_WIRE_61;
wire	SYNTHESIZED_WIRE_62;
wire	SYNTHESIZED_WIRE_63;
reg	DFF_inst2;
reg	DFF_inst7;
wire	SYNTHESIZED_WIRE_64;




assign	SYNTHESIZED_WIRE_63 = SYNTHESIZED_WIRE_0 | SYNTHESIZED_WIRE_1 | SYNTHESIZED_WIRE_2;


always@(posedge clk_i)
begin
	begin
	DFF_inst10 <= DFF_inst9;
	end
end


always@(posedge clk_i)
begin
	begin
	DFF_inst11 <= DFF_inst10;
	end
end


always@(posedge clk_i)
begin
	begin
	DFF_inst12 <= DFF_inst11;
	end
end


always@(posedge clk_i)
begin
	begin
	DFF_inst13 <= DFF_inst12;
	end
end


always@(posedge clk_i)
begin
	begin
	DFF_inst14 <= DFF_inst13;
	end
end


always@(posedge clk_i)
begin
	begin
	DFF_inst15 <= DFF_inst14;
	end
end


always@(posedge clk_i)
begin
	begin
	SYNTHESIZED_WIRE_69 <= DFF_inst15;
	end
end

assign	SYNTHESIZED_WIRE_2 = data_i & SYNTHESIZED_WIRE_3;

assign	SYNTHESIZED_WIRE_65 =  ~data_delay_i[3];


always@(posedge clk_i)
begin
	begin
	DFF_inst2 <= SYNTHESIZED_WIRE_4;
	end
end

assign	SYNTHESIZED_WIRE_66 =  ~data_delay_i[2];

assign	SYNTHESIZED_WIRE_72 =  ~data_delay_i[1];

assign	SYNTHESIZED_WIRE_83 =  ~data_delay_i[0];


always@(posedge clk_i)
begin
	begin
	DFF_inst3 <= SYNTHESIZED_WIRE_5;
	end
end

assign	SYNTHESIZED_WIRE_64 = data_i & data_delay_i[3];

assign	SYNTHESIZED_WIRE_71 = SYNTHESIZED_WIRE_65 & SYNTHESIZED_WIRE_66;

assign	SYNTHESIZED_WIRE_70 = SYNTHESIZED_WIRE_66 & data_delay_i[3];

assign	SYNTHESIZED_WIRE_68 = SYNTHESIZED_WIRE_65 & data_delay_i[2];

assign	SYNTHESIZED_WIRE_67 = data_delay_i[3] & data_delay_i[2];


always@(posedge clk_i)
begin
	begin
	SYNTHESIZED_WIRE_85 <= DFF_inst3;
	end
end

assign	SYNTHESIZED_WIRE_73 = SYNTHESIZED_WIRE_67 | SYNTHESIZED_WIRE_68;

assign	SYNTHESIZED_WIRE_15 = SYNTHESIZED_WIRE_69 & SYNTHESIZED_WIRE_67;

assign	SYNTHESIZED_WIRE_16 = data_i & SYNTHESIZED_WIRE_68;

assign	SYNTHESIZED_WIRE_79 = SYNTHESIZED_WIRE_69 & SYNTHESIZED_WIRE_70;

assign	SYNTHESIZED_WIRE_26 = SYNTHESIZED_WIRE_15 | SYNTHESIZED_WIRE_16;

assign	SYNTHESIZED_WIRE_82 = SYNTHESIZED_WIRE_71 & SYNTHESIZED_WIRE_72;

assign	SYNTHESIZED_WIRE_75 = SYNTHESIZED_WIRE_70 & SYNTHESIZED_WIRE_72;

assign	SYNTHESIZED_WIRE_74 = SYNTHESIZED_WIRE_73 & SYNTHESIZED_WIRE_72;

assign	SYNTHESIZED_WIRE_84 = SYNTHESIZED_WIRE_74 | SYNTHESIZED_WIRE_75;

assign	SYNTHESIZED_WIRE_77 = SYNTHESIZED_WIRE_73 & data_delay_i[1];


always@(posedge clk_i)
begin
	begin
	DFF_inst5 <= SYNTHESIZED_WIRE_26;
	end
end

assign	SYNTHESIZED_WIRE_40 = SYNTHESIZED_WIRE_76 & SYNTHESIZED_WIRE_77;

assign	SYNTHESIZED_WIRE_39 = data_i & SYNTHESIZED_WIRE_78;

assign	SYNTHESIZED_WIRE_37 = SYNTHESIZED_WIRE_76 & SYNTHESIZED_WIRE_74;

assign	SYNTHESIZED_WIRE_41 = SYNTHESIZED_WIRE_79 & SYNTHESIZED_WIRE_80;

assign	SYNTHESIZED_WIRE_78 = SYNTHESIZED_WIRE_71 & data_delay_i[1];

assign	SYNTHESIZED_WIRE_56 = SYNTHESIZED_WIRE_81 & data_delay_i[0];

assign	SYNTHESIZED_WIRE_80 = SYNTHESIZED_WIRE_70 & data_delay_i[1];

assign	SYNTHESIZED_WIRE_38 = SYNTHESIZED_WIRE_79 & SYNTHESIZED_WIRE_75;

assign	SYNTHESIZED_WIRE_86 = SYNTHESIZED_WIRE_37 | SYNTHESIZED_WIRE_38;

assign	SYNTHESIZED_WIRE_5 = SYNTHESIZED_WIRE_39 | SYNTHESIZED_WIRE_40 | SYNTHESIZED_WIRE_41;


always@(posedge clk_i)
begin
	begin
	DFF_inst6 <= DFF_inst5;
	end
end

assign	SYNTHESIZED_WIRE_3 = SYNTHESIZED_WIRE_82 & SYNTHESIZED_WIRE_83;

assign	SYNTHESIZED_WIRE_57 = SYNTHESIZED_WIRE_82 & data_delay_i[0];

assign	SYNTHESIZED_WIRE_81 = SYNTHESIZED_WIRE_78 | SYNTHESIZED_WIRE_80 | SYNTHESIZED_WIRE_77;

assign	SYNTHESIZED_WIRE_59 = SYNTHESIZED_WIRE_84 & data_delay_i[0];

assign	SYNTHESIZED_WIRE_55 = SYNTHESIZED_WIRE_84 & SYNTHESIZED_WIRE_83;

assign	SYNTHESIZED_WIRE_53 = SYNTHESIZED_WIRE_81 & SYNTHESIZED_WIRE_83;

assign	SYNTHESIZED_WIRE_1 = SYNTHESIZED_WIRE_85 & SYNTHESIZED_WIRE_53;

assign	SYNTHESIZED_WIRE_0 = SYNTHESIZED_WIRE_86 & SYNTHESIZED_WIRE_55;


always@(posedge clk_i)
begin
	begin
	DFF_inst7 <= DFF_inst6;
	end
end

assign	SYNTHESIZED_WIRE_61 = SYNTHESIZED_WIRE_85 & SYNTHESIZED_WIRE_56;

assign	SYNTHESIZED_WIRE_60 = data_i & SYNTHESIZED_WIRE_57;

assign	SYNTHESIZED_WIRE_62 = SYNTHESIZED_WIRE_86 & SYNTHESIZED_WIRE_59;

assign	SYNTHESIZED_WIRE_4 = SYNTHESIZED_WIRE_60 | SYNTHESIZED_WIRE_61 | SYNTHESIZED_WIRE_62;

assign	data_o = SYNTHESIZED_WIRE_63 | DFF_inst2;


always@(posedge clk_i)
begin
	begin
	SYNTHESIZED_WIRE_76 <= DFF_inst7;
	end
end


always@(posedge clk_i)
begin
	begin
	DFF_inst9 <= SYNTHESIZED_WIRE_64;
	end
end


endmodule
