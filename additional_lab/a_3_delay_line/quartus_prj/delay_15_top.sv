localparam WIDTH      = 4;

module delay_15_top (
  input  logic                clk_i,           // Clock signal
	  
  input  logic                data_i,          // Input data
  input  logic [WIDTH-1:0]    data_delay_i,    // Input data_delay

  output logic                data_o           // Output data (delayed)
);

logic                data;
logic [WIDTH-1:0]    data_delay;

logic                data_out;

always_ff @( posedge clk_i )
  begin
    data         <= data_i;
    data_delay   <= data_delay_i;
  end

delay_15 dut (
  .clk_i               ( clk_i             ),
  
  .data_i              ( data              ),
  .data_delay_i        ( data_delay        ),

  .data_o              ( data_out          )
);

always_ff @( posedge clk_i )
  begin
    data_o   <= data_out;
  end

endmodule
