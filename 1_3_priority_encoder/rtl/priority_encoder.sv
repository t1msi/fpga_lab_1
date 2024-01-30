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

logic [COUNT_SIZE-1:0] mod_counter;

logic [COUNT_SIZE-1:0] min;
logic [COUNT_SIZE-1:0] max;
logic                  min_val;

logic                  proc;

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      mod_counter <= 1'b0;
      else 
        if ( data_val_o )
          mod_counter <= 1'b0;
      else
        if ( data_val_i )
          begin
            mod_counter <= 1'b0;
            proc        <= 1'b1;
          end
      else 
        mod_counter <= mod_counter + (COUNT_SIZE)'(1);
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      data_val_o <= 1'b0;
      else
        if ( ( mod_counter == WIDTH-1 || !data_i ) && proc )
          begin
            data_val_o <= 1'b1;
            proc       <= 1'b0;
          end
      else 
        if ( data_val_o )
          data_val_o <= 1'b0;
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      min <= '0;
      else
        if ( data_i[mod_counter] == 1'b1 && !min_val )
          begin
            min <= mod_counter;
            min_val <= 1;
          end
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      max <= '0;
      else
        if ( data_i[mod_counter] == 1'b1 )
          max <= mod_counter;
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      begin
        min_val <= 0;
        min     <= '0;
        max     <= '0;
      end
      else
        if ( data_val_i )
          begin
            min_val <= 0;
            min     <= '0;
            max     <= '0;
          end
  end

always_comb
  if ( data_val_o )
    begin
      data_left_o  = (COUNT_SIZE)'(0) | ((COUNT_SIZE)'(1) << max);
      data_right_o = (COUNT_SIZE)'(0) | ((COUNT_SIZE)'(1) << min);
    end

endmodule