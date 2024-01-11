module tb;

bit          clk;
bit          rst;
bit          rst_done;

logic [15:0] data_i_var;
logic [3:0]  data_i_len;
logic        ser_data_i_val;

logic        ser_data;
logic        ser_data_val;
logic        ser_data_en;

always #5ns clk = !clk;

serializer dut (
  .clk_i               ( clk                   ),
  .srst_i              ( rst                   ),
 
  .data_i              ( data_i_var            ),
  .data_mod_i          ( data_i_len            ),
  .data_val_i          ( ser_data_i_val        ),

  .ser_data_o          ( ser_data              ),
  .ser_data_val_o      ( ser_data_val          ),
  .busy_o              ( ser_data_en           )
);

initial begin
  rst = 1'b1;
  repeat(3) @(posedge clk);
  rst <= 1'b0;
  rst_done = 1'b1;
end

initial
  begin
    wait(rst_done);
    
    ser_data_i_val = 0;
  
    for ( int i = 0; i <= 4'b1111; i++ )
      for (int j = 0; j <= 16'hffff; j++ )
        begin
          
          @(posedge clk)
            begin
              wait(!ser_data_en);
              data_i_var     <= j;
              data_i_len     <= i;
              ser_data_i_val <= 1'b1;
            end      
    
          @( posedge clk )
            begin
              ser_data_i_val <= 1'b0;
            end
        end
  
    $stop();
  
  end

endmodule