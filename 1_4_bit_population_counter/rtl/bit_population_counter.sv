module bit_population_counter #(
  parameter WIDTH = 16
) (
  input  logic                    clk_i,           // Clock signal
  input  logic                    srst_i,          // Syncronous reset
	   
  input  logic [WIDTH-1:0]        data_i,          // Input data
  input  logic                    data_val_i,      // Confirmation of input
  
  output logic [$clog2(WIDTH):0]  data_o,          // Output data
  output logic                    data_val_o       // Confirmation of output
);

localparam COUNT_SIZE = $clog2(WIDTH);

logic [COUNT_SIZE-1:0] mod_counter;

logic [COUNT_SIZE:0]   count;

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      mod_counter <= 1'b0;
      else 
        if ( data_val_o )
          mod_counter <= 1'b0;
      else
        if ( data_val_i )
          mod_counter <= 1'b0;
      else 
        mod_counter <= mod_counter + (COUNT_SIZE)'(1);
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      data_val_o <= 1'b0;
      else
        if ( mod_counter == WIDTH-1 || !data_i )
          data_val_o <= 1'b1;
      else 
        if ( data_val_o )
          data_val_o <= 1'b0;
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      count <= '0;
      else
        if ( data_val_i )
          count <= '0;
      else
        if ( data_i[mod_counter] == 1'b1 )
          count <= count + (COUNT_SIZE + 1)'(1);
  end

assign data_o = ( data_val_o ) ? count : '0;

endmodule