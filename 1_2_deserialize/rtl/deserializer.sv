module deserializer #(
  parameter DATA_W = 16
) (
  input  logic              clk_i,           // Clock signal
  input  logic              srst_i,          // Syncronous reset
	
  input  logic              data_i,          // Input data
  input  logic              data_val_i,      // Confirmation of input
  
  output logic [DATA_W-1:0] deser_data_o,    // Deserialized data
  output logic              deser_data_val_o // Confirmation of output
);

localparam COUNT_SIZE = $clog2(DATA_W);

logic [COUNT_SIZE-1:0] mod_counter;

always_ff @( posedge clk_i or posedge srst_i )
  begin
    if ( srst_i )
      mod_counter <= 1'b0;
      else
        if ( mod_counter == DATA_W-1 )
          mod_counter <= 1'b0;
      else 
        if ( deser_data_val_o )
          mod_counter <= 1'b0;
      else 
        if ( data_val_i )
          mod_counter <= mod_counter + (COUNT_SIZE)'(1);
  end

always_ff @( posedge clk_i or posedge srst_i )
  begin
    if ( srst_i )
      deser_data_val_o <= 1'b0;
      else 
        if ( deser_data_val_o )
          deser_data_val_o <= 1'b0;
      else
        if ( mod_counter == DATA_W-1 )
          deser_data_val_o <= 1'b1;
  end

always_ff @( posedge clk_i or posedge srst_i )
begin
    if ( srst_i )
      deser_data_o <= '0;
      else 
        if ( deser_data_val_o )
          deser_data_o <= '0;
      else 
        if ( data_val_i )
          deser_data_o[DATA_W - mod_counter - 1] <= data_i;
end

endmodule