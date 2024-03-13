localparam WIDTH      = 16;

module crc_16_ansi_top (
  input  logic                clk_i,           // Clock signal
  input  logic                rst_i,           // Async reset
	  
  input  logic                data_i,          // Input data

  output logic [WIDTH-1:0]    data_o           // Output data
);

logic                rst;
logic                data_in;

logic [WIDTH-1:0]    data_out;

always_ff @( posedge clk_i )
  begin
    rst          <= rst_i;
    data_in      <= data_i;
  end

crc_16_ansi dut (
  .clk_i               ( clk_i             ),  
  .rst_i               ( rst               ),
  
  .data_i              ( data_in           ),

  .data_o              ( data_out          )
);

always_ff @( posedge clk_i )
  begin
    data_o   <= data_out;
  end

endmodule
