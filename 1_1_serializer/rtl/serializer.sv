module serializer (
  input               clk_i,           // Clock signal
  input               srst_i,          // Syncronous reset
	
  input logic [15:0]  data_i,          // Input data
  input logic [3:0]   data_mod_i,      // Quantity of valid bit
  input logic         data_val_i,      // Confirmation of input
  
  output logic        ser_data_o,      // Serialized data
  output logic        ser_data_val_o,  // Confirmation of output
  output logic        busy_o           // Module is busy
);

logic [3:0] mod_counter;
logic [3:0] data_mod_i_copy;

always_comb 
  if      ( data_mod_i == 0 )                                 data_mod_i_copy = 15;
  else if ( ( data_mod_i == 1 ) || ( data_mod_i == 2) )       data_mod_i_copy = 0;
  else                                                        data_mod_i_copy = data_mod_i;

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      mod_counter <= 1'b0;
    else 
      if ( data_val_i )
        mod_counter <= 1'b0;
    else
      if ( mod_counter == data_mod_i_copy )
        mod_counter <= 1'b0;
    else
      if ( ser_data_val_o )
        mod_counter <= mod_counter + 1;
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      ser_data_val_o <= 1'b0;
    else 
      if ( data_val_i )
        ser_data_val_o <= 1'b1;
    else
      if ( mod_counter == data_mod_i_copy )
        ser_data_val_o <= 1'b0;
    else
      if ( ser_data_val_o )
        ser_data_val_o <= 1'b1; 
  end


  assign ser_data_o = ( ser_data_val_o ) ? ( data_i[16 - mod_counter - 1] ):
                                           ( 1'b0                         );
  assign busy_o = data_val_i || ser_data_val_o;

endmodule