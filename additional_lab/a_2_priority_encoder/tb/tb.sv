module tb;

// `define DEBUG                           // Print all testing steps

localparam WIDTH          = 3;
localparam COUNT_SIZE     = $clog2(WIDTH);

localparam TEST_CNT       = 1000;

localparam GEN_RAND_MIN   = 0;
localparam GEN_RAND_MAX   = 2**WIDTH - 1;

localparam SEND_RAND_MIN  = 0;
localparam SEND_RAND_MAX  = WIDTH - 1;

localparam BURST_MODE     = 0;


logic              clk;
logic              rst;
logic              rst_done;

logic [WIDTH-1:0]  data_in;
logic              data_val_in;

logic [WIDTH-1:0]  data_left_out;
logic [WIDTH-1:0]  data_right_out;
logic              data_val_out;

priority_encoder_3 dut (
  .data_i              ( data_in           ),
  .data_val_i          ( data_val_in       ),

  .data_left_o         ( data_left_out     ),
  .data_right_o        ( data_right_out    ),
  .data_val_o          ( data_val_out      )
);

typedef struct packed {
  logic [WIDTH-1:0] gen_data;
  logic [WIDTH-1:0] left;
  logic [WIDTH-1:0] right;
} data_s;

mailbox #( data_s ) generated_data  = new();
mailbox #( data_s ) sended_data     = new();
mailbox #( data_s ) read_data       = new();

data_s              test_data;                   // @TODO: Remove global

task generate_data( mailbox #( data_s ) _data );

data_s data_to_send;
logic [COUNT_SIZE-1:0] min;
logic [COUNT_SIZE-1:0] max;
logic                  min_val;

// corner cases
    _data.put( {(WIDTH)'(0), (WIDTH)'(0), (WIDTH)'(0)} );
    _data.put( {(WIDTH)'(1), (WIDTH)'(1), (WIDTH)'(1)} );
    _data.put( { (WIDTH)'(0) | ((WIDTH)'(1) << WIDTH-1),
                 (WIDTH)'(0) | ((WIDTH)'(1) << WIDTH-1),
                 (WIDTH)'(0) | ((WIDTH)'(1) << WIDTH-1) }
             );
    _data.put( { (WIDTH)'(0) | ((WIDTH)'(1) << WIDTH-1) | (WIDTH)'(1),
                 (WIDTH)'(0) | ((WIDTH)'(1) << WIDTH-1),
                 (WIDTH)'(1) }
             );

// random test cases
  for( int i = 0; i < TEST_CNT; i++ )
    begin
      data_to_send.gen_data = $urandom_range(GEN_RAND_MAX,GEN_RAND_MIN);
      min_val = 0;

      for ( int j = 0; j < WIDTH; j++)
        begin
          if ( data_to_send.gen_data[j] )
            max = j;
          
          if ( data_to_send.gen_data[j] && !min_val )
          begin
            min     = j;
            min_val = 1;
          end
        end
     
      data_to_send.left       = '0;
      data_to_send.right      = '0;
      if (min_val)
        begin
          data_to_send.left[max]  = 1'b1;
          data_to_send.right[min] = 1'b1;
        end

      _data.put( data_to_send );

    end

endtask

task send_data( data_s data_to_send );
  data_in      = data_to_send.gen_data;
  data_val_in  = 1'b1;
  @(posedge clk);

endtask

task fifo_wr( mailbox #( data_s )  _data,
              mailbox #( data_s )  sended_data,
              bit                  burst = 1
            );

  data_s data_to_wr;
  int    pause;
  while( _data.num() )
    begin
      _data.get( data_to_wr );

      if( burst )
        pause = 0;
      else
        pause = $urandom_range(SEND_RAND_MAX,SEND_RAND_MIN);

      sended_data.put( data_to_wr );

      test_data       = data_to_wr;
      test_data.left  = '0;             // Link with "check_data"
      test_data.right = '0;

      send_data(data_to_wr);
      
      if (pause)
        begin
          data_val_in = 1'b0;
          repeat(pause) @(posedge clk);
        end
    end
    data_val_in = 1'b0;
endtask

task check_data( mailbox #( data_s ) watched_data );
  if ( data_val_out )
    begin
      test_data.left  = data_left_out;
      test_data.right = data_right_out;
      watched_data.put( test_data );
    end

endtask

task fifo_rd( mailbox #( data_s ) watched_data );
  while ( watched_data.num() != TEST_CNT + 4 )
    begin
      @(posedge clk);
      check_data(watched_data);
    end
endtask

task compare_data( mailbox #( data_s ) ref_data,
                   mailbox #( data_s ) dut_data
                 );

  data_s ref_data_tmp;
  data_s dut_data_tmp;

  if( ref_data.num() != dut_data.num() )
    begin
      $display( "Size of ref data: %d", ref_data.num() );
      $display( "And sized of dut data: %d", dut_data.num() );
      $display( "Do not match" );
      $stop();
    end
  else
    begin
      while ( dut_data.num() )
        begin
          dut_data.get( dut_data_tmp );
          ref_data.get( ref_data_tmp );

          if( ( ref_data_tmp.left != dut_data_tmp.left ) || ( ref_data_tmp.right != dut_data_tmp.right ) )
            begin
              $display( "Error! Data do not match!" );
              $display( "Reference num = %d", TEST_CNT + 4 - dut_data.num() );
              $display( "Reference data: %x   = %b" , ref_data_tmp.gen_data, ref_data_tmp.gen_data);
              $display( "Gen data:       left = %b, right = %b", ref_data_tmp.left, ref_data_tmp.right );
              $display( "Read data:      left = %b, right = %b", dut_data_tmp.left, dut_data_tmp.right );
              `ifdef DEBUG
              `else
              $stop();
              `endif
            end
        end
    end

endtask

initial
  begin
    clk = 1'b0;
    forever #5ns clk = !clk;
  end

initial
  begin
    generate_data( generated_data );

    fork
      fifo_wr(generated_data, sended_data, BURST_MODE);
      fifo_rd(read_data);
    join

    compare_data(sended_data, read_data);
    $display( "Test done! No errors!" );
    $stop();
  end

endmodule
