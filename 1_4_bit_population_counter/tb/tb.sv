module tb;

localparam WIDTH      = 8;
localparam TEST_CNT   = 100;
localparam COUNT_SIZE = $clog2(WIDTH);

localparam GEN_RAND_MIN   = 0;
localparam GEN_RAND_MAX   = 2**WIDTH - 1;

localparam SEND_RAND_MIN  = 0;
localparam SEND_RAND_MAX  = WIDTH - 1;

localparam BURST_MODE     = 1;

localparam INIT_RST_DUR   = 3;

logic                 clk;
logic                 rst;
logic                 rst_done;
   
logic [WIDTH-1:0]     data;
logic                 data_val_in;

logic [COUNT_SIZE:0]  data_out;
logic                 data_val_out;

initial
  begin
    clk = 1'b0;
    forever #5ns clk = !clk;
  end

bit_population_counter #(
  .WIDTH               ( WIDTH             )
) dut (
  .clk_i               ( clk               ),
  .srst_i              ( rst               ),
 
  .data_i              ( data              ),
  .data_val_i          ( data_val_in       ),

  .data_o              ( data_out          ),
  .data_val_o          ( data_val_out      )
);

initial
  begin
    rst = 1'(1);
    repeat(INIT_RST_DUR) @(posedge clk);
    rst = 1'b0;
    rst_done = 1'(1);
  end

typedef struct packed {
  logic [WIDTH-1:0]    gen_data;
  logic [COUNT_SIZE:0] test_data;
} data_s;

mailbox #( data_s ) generated_data  = new();
mailbox #( data_s ) sended_data     = new();
mailbox #( data_s ) read_data       = new();

task generate_data( mailbox #( data_s ) _data );

data_s data_to_send;
logic [COUNT_SIZE:0] count;

// corner cases
  _data.put( {(WIDTH)'(0), (COUNT_SIZE + 1)'(0)} );
  _data.put( {(WIDTH)'(1), (COUNT_SIZE + 1)'(1)} );
  _data.put( { (WIDTH)'(0) | ((WIDTH)'(1) << WIDTH-1)              , (COUNT_SIZE + 1)'(1) } );
  _data.put( { (WIDTH)'(0) | ((WIDTH)'(1) << WIDTH-1) | (WIDTH)'(1), (COUNT_SIZE + 1)'(2) } );

// random test cases
  for( int i = 0; i < TEST_CNT; i++ )
    begin
      data_to_send.gen_data = $urandom_range(GEN_RAND_MAX,GEN_RAND_MIN);
      count = 0;

      for ( int j = 0; j < WIDTH; j++)
        if (data_to_send.gen_data[j] === 1'b1)
          count++;

     data_to_send.test_data = count;

      _data.put( data_to_send );
    end

endtask

task send_data( logic [WIDTH-1:0] data_to_send );
  data         <= data_to_send;
  data_val_in  <= 1'b1;
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

      send_data(data_to_wr.gen_data);
      sended_data.put( data_to_wr );

      if (pause)
        begin
          data_val_in <= 1'b0;
          repeat(pause) @(posedge clk);
        end
    end
  data_val_in <= 1'b0;
endtask

task check_data( mailbox #( data_s ) watched_data );
  data_s data_to_rd;
  if ( data_val_out )
    begin
      data_to_rd = { data, data_out };
      watched_data.put( data_to_rd );
    end
endtask

task fifo_rd( mailbox #( data_s ) watched_data );
  while ( watched_data.num() != TEST_CNT + 4 )
    begin
      check_data(watched_data);
      @(posedge clk);
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

          if( ref_data_tmp.test_data != dut_data_tmp.test_data )
            begin
              $display( "Error! Data do not match!" );
              $display( "Reference num = %d", TEST_CNT + 4 - dut_data.num() );
              $display( "Reference data: %b %d", ref_data_tmp.gen_data, ref_data_tmp.test_data);
              $display( "Read data       %b %d", dut_data_tmp.gen_data, dut_data_tmp.test_data);
              $stop();
            end
        end
    end

endtask

initial
  begin
    data         = '0;
    data_val_in  = 1'b0;   

    generate_data( generated_data );

    wait( rst_done );

    fork
      fifo_wr(generated_data, sended_data, BURST_MODE);
      fifo_rd(read_data);
    join

    compare_data(sended_data, read_data);
    $display( "Test done! No errors!" );
    $stop();
  end

endmodule
