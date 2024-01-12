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

task automatic send_data( logic [15:0] _data, logic [3:0] _data_len );
  @(posedge clk)
    begin
      wait(!ser_data_en);
      data_i_var     <= _data;
      data_i_len     <= _data_len;
      ser_data_i_val <= 1'b1;
    end

  @(posedge clk)
    ser_data_i_val <= 1'b0;

endtask

logic [19:0] test_archive_tmp;

initial
// initialization
  begin
    wait(rst_done);

// recieve data block    
    ser_data_i_val = 0;

    for ( int i = 0; i <= 4'b1111; i++ )
      for ( int j = 0; j <= 16'hffff; j++ )
        send_data(j, i);
    
// test report
    $display( "[%x errors] %s", test_archive.size,
                              ( test_archive.size == 0 ) ? "ALL TESTS PASSED": "THERE ARE ERRORS" );
    while ( test_archive.size > 0 )
      begin
        test_archive_tmp = test_archive.pop_back;
        $display( "data = 0x%x len = 0x%x", test_archive_tmp[19:4]
                                          , test_archive_tmp[3:0] );
      end

    $stop();
  end

// recieve data block
logic [3:0] ser_data_counter;
logic [3:0] data_i_len_copy;

always_comb begin
  if ( data_i_len == 0 )
    data_i_len_copy = 4'b1111;
  else 
    if ( ( data_i_len == 1 ) || ( data_i_len == 2 ) )
      data_i_len_copy = 4'b0000;
  else
    data_i_len_copy = data_i_len;
end

initial
  begin
    ser_data_counter = 0;
  
    forever
      begin
        @(posedge clk);
          if ( ser_data_val )
            if ( ser_data_counter == data_i_len_copy )
              ser_data_counter <= 0;
            else
              ser_data_counter <= ser_data_counter + 1;
      end
  end

// testing block
logic        test_bit;
logic [19:0] test_archive [$];

initial
  begin
    forever
      begin
        @(posedge clk);
        if ( ser_data_val )
          begin
            test_bit = data_i_var[16 - ser_data_counter - 1] ^ ser_data;
            
            if ( test_bit )
              test_archive.push_back( { data_i_var, data_i_len } );
      
            $display("%t: data = 0x%x len = 0x%x i = %d data[i] = %x ser_data = %x TEST: %s", $time(),
                                                                                              data_i_var,
                                                                                              data_i_len,
                                                                                              ser_data_counter,
                                                                                              data_i_var[16 - ser_data_counter - 1],
                                                                                              ser_data,
                                                                                              ( !test_bit ) ? "PASSED": "ERROR" );
          end
      end
  end

endmodule