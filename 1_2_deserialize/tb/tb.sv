module tb;

logic        clk;
logic        rst;
logic        rst_done;

logic        data;
logic        data_val;

logic [15:0] deser_data;
logic        deser_data_val;

always #5ns clk = !clk;

deserializer dut (
  .clk_i               ( clk                   ),
  .srst_i              ( rst                   ),
 
  .data_i              ( data                  ),
  .data_val_i          ( data_val              ),

  .deser_data_o        ( deser_data            ),
  .deser_data_val_o    ( deser_data_val        )
);

initial begin
  clk <= 1'b0;
  rst <= 1'b1;
  repeat(3) @(posedge clk);
  rst <= 1'b0;
  rst_done <= 1'b1;
end

task automatic send_data( logic [15:0] _data, logic [3:0] _data_len );
  for (int i = 0; i <= _data_len; i++)
    @(posedge clk)
      begin
        data     <= _data[i];
        data_val <= 1'b1;
      end
    
    @(posedge clk)
      data_val <= 1'b0;
    
endtask

function void test_report ( logic [15:0] _archive [$] );
  logic [15:0] test_archive_tmp;

  $display( "[%x errors] %s", _archive.size,
                            ( _archive.size == 0 ) ? "ALL TESTS PASSED": "THERE ARE ERRORS" );
    while ( _archive.size > 0 )
      begin
        test_archive_tmp = _archive.pop_back;
        $display( "data = 0x%x", test_archive_tmp[15:0] );
      end

endfunction

logic [15:0] ser_data;

initial
// initialization
  begin
    wait(rst_done);

// data generation block
    data = '0;
    data_val = 1'b0;    
    ser_data = '0;

    for ( int i = 4'b1111; i <= 4'b1111; i++ )
      for ( int j = 16'h0000; j <= 16'hffff; j = j + 16'h0001 )
        begin
          send_data(j, i);
          ser_data <= j;
        end
    
// test reports
    $display("Input | Output test report");
    test_report(test_archive);   

    $stop();
  end

// testing block
logic        test_bit;
logic [15:0] test_archive [$];
logic [15:0] deser_data_reverse;

initial
  begin
    test_bit = 0;
    forever
      begin
        @(posedge clk);
        if( deser_data_val )
          begin
            for (int i = 0; i <= 4'b1111; i++)
              deser_data_reverse[i] = deser_data[16 - i - 1];
            
            test_bit = ( ser_data == deser_data_reverse );

            if ( !test_bit )
              test_archive.push_back( { ser_data } );

            $display("%t: ser_data = %b deser_data = %b TEST: %s", $time(),
                                                                   ser_data,
                                                                   deser_data,
                                                                   ( test_bit ) ? "PASSED": "ERROR" );
          end
      end
  end

endmodule
