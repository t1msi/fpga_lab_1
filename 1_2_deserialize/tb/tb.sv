module tb;

localparam DATA_W     = 16;
localparam TEST_CNT   = 100;
localparam COUNT_SIZE = $clog2(DATA_W);

logic              clk;
logic              rst;
logic              rst_done;

logic              data;
logic              data_val;

logic [DATA_W-1:0] deser_data;
logic              deser_data_val;

always #5ns clk = !clk;

deserializer #(
  .DATA_W              ( DATA_W                )
) dut (
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

mailbox #( logic [DATA_W-1:0] ) generated_data = new();
mailbox #( logic [DATA_W-1:0] ) sended_data    = new();
mailbox #( logic [DATA_W-1:0] ) read_data      = new();

task gen_data( mailbox #( logic [DATA_W-1:0] ) _data );

logic [DATA_W-1:0] data_to_send;

  for( int i = 0; i < TEST_CNT; i++ )
    begin
      data_to_send = $urandom_range(2**DATA_W-1,0);
      _data.put( data_to_send );
    end

endtask

task automatic send_data( logic [DATA_W-1:0] _data );
  for (int i = 0; i <= DATA_W-1; i++)
    @(posedge clk)
      begin
        data     <= _data[i];
        data_val <= 1'b1;
      end
    
    @(posedge clk)
      data_val <= 1'b0;

endtask

task fifo_wr( mailbox #( logic [DATA_W-1:0] ) _data,
              mailbox #( logic [DATA_W-1:0] ) sended_data,
              bit                             burst = 1
            );

  logic [DATA_W-1:0] word_to_wr;
  int                pause;
  while( _data.num() )
    begin
      _data.get(word_to_wr);
      if( burst )
        pause = 0;
      else
        pause = $urandom_range(10,0);

      send_data(word_to_wr);
      sended_data.put( word_to_wr );

      if( pause != 0 )
        begin
          data_val <= 1'b0;
          repeat(pause) @(posedge clk);
        end
    end
  data_val <= 1'b0;
endtask

task fifo_rd( mailbox #( logic [DATA_W-1:0] ) watched_data );
  while ( watched_data.num() != TEST_CNT )
    begin
      @(posedge clk);
      if ( deser_data_val )
        watched_data.put( deser_data );
    end
endtask

task compare_data( mailbox #( logic [DATA_W-1:0] ) ref_data,
                   mailbox #( logic [DATA_W-1:0] ) dut_data
                 );

logic [DATA_W-1:0] ref_data_tmp;
logic [DATA_W-1:0] dut_data_tmp;
logic [DATA_W-1:0] deser_data_reverse;

  if( ref_data.num() != dut_data.num() )
    begin
      $display( "Size of ref data: %d", ref_data.num() );
      $display( "And sized of dut data: %d", dut_data.num() );
      $display( "Do not match" );
      $stop();
    end
  else
    begin
      for( int i = 0; i < dut_data.num(); i++ )
        begin
          dut_data.get( dut_data_tmp );
          ref_data.get( ref_data_tmp );

          for (int i = 0; i <= DATA_W-1; i++)
              deser_data_reverse[i] = dut_data_tmp[DATA_W - i - 1];

          if( ref_data_tmp != deser_data_reverse )
            begin
              $display( "Error! Data do not match!" );
              $display( "Reference data: %b", ref_data_tmp );
              $display( "Read data: %b", dut_data_tmp );
              $stop();
            end
        end
    end

endtask

initial
  begin
    data     <= '0;
    data_val <= 1'b0;   

    gen_data( generated_data );

    wait( rst_done );

    fork
      fifo_wr(generated_data, sended_data);
      fifo_rd(read_data);
    join

    compare_data(sended_data, read_data);
    $display( "Test done! No errors!" );
    $stop();
  end

endmodule
