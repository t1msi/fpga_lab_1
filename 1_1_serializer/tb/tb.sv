module tb;

bit clk;
bit rst;
bit rst_done;

bit [15:0] data_i_var;
bit [3:0] data_i_len;
logic ser_data_i_val;

logic ser_data;
logic ser_data_val;
logic ser_data_en;

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

initial begin
  wait(rst_done);
  
  for (int i = 4'b0000; i < 4'b1011; i++)
    for (int j = 16'hb000; j < 16'hc000; j = j + 16'h0100) begin
      ser_data_i_val = 1'b0;

      @(posedge clk) begin
        wait(!ser_data_en);
        data_i_var <= j;
        data_i_len <= i;
        ser_data_i_val <= 1'b1;
      end

    end

  ser_data_i_val = 1'b0;

  $stop();

end

endmodule