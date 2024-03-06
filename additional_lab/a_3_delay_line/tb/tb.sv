module tb;

// `define DEBUG                           // Print all testing steps

localparam WIDTH          = 4;
localparam COUNT_SIZE     = $clog2(WIDTH);

localparam TEST_CNT       = 1000;

localparam GEN_RAND_MIN   = 1;
localparam GEN_RAND_MAX   = 2**WIDTH - 1;

localparam SEND_RAND_MIN  = 0;
localparam SEND_RAND_MAX  = WIDTH - 1;

localparam BURST_MODE     = 1;


logic              clk;
// logic              rst;
// logic              rst_done;

logic                data_in;
logic [WIDTH-1:0]    data_delay_in;

logic                data_out;

delay_15 dut (
  .clk_i                 ( clk               ),

  .data_i                ( data_in           ),
  .data_delay_i          ( data_delay_in     ),

  .data_o                ( data_out          )
);

typedef struct packed {
  logic [WIDTH-1:0] gen_data;
  logic [WIDTH-1:0] test_delay;
} data_s;

mailbox #( data_s ) generated_data  = new();
mailbox #( data_s ) sended_data     = new();
mailbox #( data_s ) read_data       = new();

data_s              test_data;                   // @TODO: Remove global
logic [WIDTH-1:0]   iter_inner;

task generate_data( mailbox #( data_s ) _data );

data_s data_to_send;

// random test cases
  for( int i = 0; i < TEST_CNT; i++ )
    begin
      data_to_send.gen_data = $urandom_range(GEN_RAND_MAX,GEN_RAND_MIN);

      _data.put( data_to_send );
    end

endtask

task send_data( data_s data_to_send );
  data_in            = 1'b1;
  data_delay_in      = data_to_send.gen_data;

  @(posedge clk);
  data_in = 1'b0;

  repeat(2**WIDTH-1) @(posedge clk);
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

      test_data             = data_to_wr;
      test_data.test_delay  = '0;             // Link with "check_data"

      send_data(data_to_wr);
      
      if ( pause )
        begin
          data_delay_in = '0;
          repeat(pause) @(posedge clk);
        end
      
    end
    data_delay_in = '0;
endtask

task check_data( mailbox #( data_s ) watched_data );

  if ( data_out )
    begin
      test_data.test_delay = iter_inner;
      watched_data.put( test_data );
    end

endtask

task fifo_rd( mailbox #( data_s ) watched_data );
  while ( watched_data.num() != TEST_CNT )
    begin
      if ( iter_inner === 2**WIDTH - 1 ) iter_inner = '0;
      check_data(watched_data);
      @(posedge clk);
      iter_inner++;
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

          if( ref_data_tmp.gen_data != dut_data_tmp.test_delay )
            begin
              $display( "Error! Data do not match!" );
              $display( "Reference num = %d", TEST_CNT - dut_data.num() );
              $display( "Gen data:       gen = %d, test = %d", ref_data_tmp.gen_data, ref_data_tmp.test_delay );
              $display( "Read data:      gen = %d, test = %d", dut_data_tmp.gen_data, dut_data_tmp.test_delay );
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
