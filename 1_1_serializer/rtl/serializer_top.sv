module serializer_top(
  input               clk_i,           // Clock signal
  input               srst_i,          // Syncronous reset
	
  input logic [15:0]  data_i,          // Input data
  input logic [3:0]   data_mod_i,      // Quantity of valid bit
  input logic         data_val_i,      // Confirmation of input
  
  output logic        ser_data_o,      // Serialized data
  output logic        ser_data_val_o,  // Confirmation of output
  output logic        busy_o           // Module is busy
);

bit              srst;

logic [15:0]     data;
logic [3:0]      data_mod;
logic            data_val;

logic            ser_data;
logic            ser_data_val;
logic            busy;

always_ff @( posedge clk_i )
  begin
    srst     <= srst_i;
    data     <= data_i;
    data_mod <= data_mod_i;
    data_val <= data_val_i;
  end

serializer dut (
  .clk_i               ( clk_i             ),
  .srst_i              ( srst_             ),
 
  .data_i              ( data_i            ),
  .data_mod_i          ( data_mod_i        ),
  .data_val_i          ( data_val_i        ),

  .ser_data_o          ( ser_data_o        ),
  .ser_data_val_o      ( ser_data_val_o    ),
  .busy_o              ( busy_o            )
);

always_ff @( posedge clk_i )
  begin
    ser_data     <= ser_data_o;
    ser_data_val <= ser_data_val_o;
    busy         <= busy_o;
  end

endmodule
