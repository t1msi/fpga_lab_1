module tb;

`define DEBUG                           // Print all testing steps

localparam WIDTH          = 16;
localparam COUNT_SIZE     = $clog2(WIDTH);

localparam TEST_CNT       = 10;

localparam GEN_RAND_MIN   = 1;
localparam GEN_RAND_MAX   = 2**WIDTH - 1;

localparam SEND_RAND_MIN  = 0;
localparam SEND_RAND_MAX  = WIDTH - 1;

localparam BURST_MODE     = 1;

localparam INIT_RST_DUR   = 3;

logic                clk;
logic                rst;
logic                rst_done;

logic                data_in;

logic [WIDTH-1:0]    data_out;

crc_16_ansi dut (
  .clk_i               ( clk               ),  
  .rst_i               ( rst               ),

  .data_i              ( data_in           ),
  
  .data_o              ( data_out          )
);

typedef struct packed {
  logic [WIDTH-1:0] gen_data;
  logic [WIDTH-1:0] gen_crc;
  logic [WIDTH-1:0] test_crc;
} data_s;

mailbox #( data_s ) generated_data  = new();
mailbox #( data_s ) sended_data     = new();
mailbox #( data_s ) read_data       = new();

data_s              test_data;                   // @TODO: Remove global

task generate_data( mailbox #( data_s ) _data );

data_s data_to_send;

// random test cases
  for( int i = 0; i < TEST_CNT; i++ )
    begin
      data_to_send.gen_data  = $urandom_range(GEN_RAND_MAX,GEN_RAND_MIN);
      
      // calc crc

      data_to_send.test_crc = '0;

      _data.put( data_to_send );
    end

endtask

task send_data( data_s data_to_send );
  for (int i = 0; i < WIDTH; i++) 
    begin
      data_in = data_to_send.gen_data[i];
      @(posedge clk);
    end
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
      test_data.test_crc    = '0;             // Link with "check_data"

      send_data(data_to_wr);
      
      if ( pause )
        begin
          data_in = 1'b0;
          repeat(pause) @(posedge clk);
        end
      
    end
endtask

task check_data( mailbox #( data_s ) watched_data );
  test_data.test_crc = data_out;

endtask

task fifo_rd( mailbox #( data_s ) watched_data );
  logic [COUNT_SIZE-1:0] iter;
  
  while ( watched_data.num() != TEST_CNT )
    begin
      for ( iter = 0; iter < WIDTH; iter++ )
        begin
          check_data(watched_data);
          @(posedge clk);
        end
      
      watched_data.put( test_data );
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

          if( ref_data_tmp.gen_crc != dut_data_tmp.test_crc )
            begin
              $display( "Error! Data do not match!" );
              $display( "Reference num = %d", TEST_CNT - dut_data.num() );
              $display( "Gen data:     data = %b, gen = %d, test = %d", ref_data_tmp.gen_data, ref_data_tmp.gen_crc, ref_data_tmp.test_crc );
              $display( "Read data:    data = %b, gen = %d, test = %d", dut_data_tmp.gen_data, dut_data_tmp.gen_crc, dut_data_tmp.test_crc );
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
    rst = 1'(1);
    repeat(INIT_RST_DUR) @(posedge clk);
    rst = 1'b0;
    rst_done = 1'(1);
  end

initial
  begin
    generate_data( generated_data );
    data_out = '0;

    wait(rst_done);
    fork
      fifo_wr(generated_data, sended_data, BURST_MODE);
      fifo_rd(read_data);
    join

    compare_data(sended_data, read_data);
    $display( "Test done! No errors!" );
    $stop();
  end

endmodule
