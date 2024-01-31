localparam WIDTH = 16;

module priority_encoder_top(
  input  logic              clk_i,           // Clock signal
  input  logic              srst_i,          // Syncronous reset
	
  input  logic [WIDTH-1:0]  data_i,          // Input data
  input  logic              data_val_i,      // Confirmation of input
  
  output logic [WIDTH-1:0]  data_left_o,     // Left one
  output logic [WIDTH-1:0]  data_right_o,    // Right one
  output logic              data_val_o       // Confirmation of output
);

logic              srst;

logic [WIDTH-1:0]  data;
logic              data_val_in;

logic [WIDTH-1:0]  data_left;
logic [WIDTH-1:0]  data_right;
logic              data_val_out;

always_ff @( posedge clk_i )
  begin
    srst        <= srst_i;
    data        <= data_i;
    data_val_in <= data_val_i;
  end

priority_encoder #(
  .WIDTH               ( WIDTH             )
) dut (
  .clk_i               ( clk_i             ),
  .srst_i              ( srst              ),
 
  .data_i              ( data              ),
  .data_val_i          ( data_val_in       ),

  .data_left_o         ( data_left         ),
  .data_right_o        ( data_right        ),
  .data_val_o          ( data_val_out      )
);

always_ff @( posedge clk_i )
  begin
    data_left_o  <= data_left;
    data_right_o <= data_right;
    data_val_o   <= data_val_out;
  end

endmodule
