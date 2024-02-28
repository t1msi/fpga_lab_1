localparam WIDTH      = 3;

module priority_encoder_3_top (
  input  logic                clk_i,           // Clock signal
	  
  input  logic [WIDTH-1:0]    data_i,          // Input data
  input  logic                data_val_i,      // Confirmation of input
  
  output logic [WIDTH-1:0]    data_left_o,     // Left one
  output logic [WIDTH-1:0]    data_right_o,    // Right one
  output logic                data_val_o       // Confirmation of output
);

logic [WIDTH-1:0]    data;
logic                data_val_in;

logic [WIDTH-1:0]    data_left_out;
logic [WIDTH-1:0]    data_right_out;
logic                data_val_out;

always_ff @( posedge clk_i )
  begin
    data        <= data_i;
    data_val_in <= data_val_i;
  end

priority_encoder_3 dut (
  .data_i              ( data              ),
  .data_val_i          ( data_val_in       ),

  .data_left_o         ( data_left_out     ),
  .data_right_o        ( data_right_out    ),
  .data_val_o          ( data_val_out      )
);

always_ff @( posedge clk_i )
  begin
    data_left_o  <= data_left_out;
    data_right_o <= data_right_out;
    data_val_o   <= data_val_out;
  end

endmodule
