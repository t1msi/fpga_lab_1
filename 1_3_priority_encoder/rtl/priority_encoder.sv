module priority_encoder #(
  parameter WIDTH = 16
) (
  input  logic              clk_i,           // Clock signal
  input  logic              srst_i,          // Syncronous reset
	
  input  logic [WIDTH-1:0]  data_i,          // Input data
  input  logic              data_val_i,      // Confirmation of input
  
  output logic [WIDTH-1:0]  data_left_o,     // Left one
  output logic [WIDTH-1:0]  data_right_o,    // Right one
  output logic              data_val_o       // Confirmation of output
);

localparam COUNT_SIZE = $clog2(WIDTH);

logic [WIDTH-1:0] data_i_copy;

always_comb
  begin
    data_left_o = (WIDTH)'(0);
    for (int i = WIDTH - 1; i >= 0; i--)
      if (data_i_copy[i])
        begin
          data_left_o[i] = 1'b1;
          break;
        end
  end

always_comb
  begin
    data_right_o = (WIDTH)'(0);
    for (int i = 0; i < WIDTH; i++)
      if (data_i_copy[i])
        begin
          data_right_o[i] = 1'b1;
          break;
        end
  end

assign data_i_copy = data_val_i ? data_i : '0;
assign data_val_o = data_val_i ? 1'b1 : 1'b0;

endmodule