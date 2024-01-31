localparam WIDTH      = 16;
localparam COUNT_SIZE = $clog2(WIDTH);

module bit_population_counter_top(
  input  logic                clk_i,           // Clock signal
  input  logic                srst_i,          // Syncronous reset
	  
  input  logic [WIDTH-1:0]    data_i,          // Input data
  input  logic                data_val_i,      // Confirmation of input
  
  output logic [COUNT_SIZE:0] data_o,          // Output data
  output logic                data_val_o       // Confirmation of output
);

logic                srst;
  
logic [WIDTH-1:0]    data;
logic                data_val_in;

logic [COUNT_SIZE:0] data_out;
logic                data_val_out;

always_ff @( posedge clk_i )
  begin
    srst        <= srst_i;
    data        <= data_i;
    data_val_in <= data_val_i;
  end

bit_population_counter #(
  .WIDTH               ( WIDTH             )
) dut (
  .clk_i               ( clk_i             ),
  .srst_i              ( srst              ),
 
  .data_i              ( data              ),
  .data_val_i          ( data_val_in       ),

  .data_o              ( data_out          ),
  .data_val_o          ( data_val_out      )
);

always_ff @( posedge clk_i )
  begin
    data_o        <= data_out;
    data_val_o    <= data_val_out;
  end

endmodule
