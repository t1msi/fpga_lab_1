module serializer (
  input logic         clk_i,           // Clock signal
  input logic         srst_i,          // Syncronous reset
	
  input logic [15:0]  data_i,          // Input data
  input logic [3:0]   data_mod_i,      // Quantity of valid bit
  input logic         data_val_i,      // Confirmation of input
  
  output logic        ser_data_o,      // Serialized data
  output logic        ser_data_val_o,  // Confirmation of output
  output logic        busy_o           // Module is busy
);

logic [3:0]  mod_counter;
logic [15:0] data_i_copy;
logic [3:0]  data_mod_i_copy;

always_ff @( posedge clk_i )
  begin
    if (data_val_i)
      begin
        case (data_mod_i)
          0:       data_mod_i_copy <= 4'b1111;
          1:       data_mod_i_copy <= 4'b0000;
          2:       data_mod_i_copy <= 4'b0000;
          default: data_mod_i_copy <= data_mod_i;
        endcase
  
        data_i_copy <= data_i;
      end
  end

always_ff @( posedge clk_i or posedge srst_i )
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
          mod_counter <= mod_counter + 4'b0001;
  end

always_ff @( posedge clk_i or posedge srst_i )
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

  assign ser_data_o = ( ser_data_val_o ) ? ( data_i_copy[16 - mod_counter - 1] ):
                                           ( 1'b0                         );
  assign busy_o = ser_data_val_o;

endmodule