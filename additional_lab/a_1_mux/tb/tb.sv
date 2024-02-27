module tb;

// `define DEBUG                           // Print all testing steps

localparam WIDTH          = 4;
localparam COUNT_SIZE     = $clog2(WIDTH);

localparam CHANNEL_NUM    = 4;
localparam COUNT_CHANNELS = $clog2(CHANNEL_NUM);

localparam TEST_CNT       = 100;

localparam GEN_RAND_MIN   = 0;             // Must be greater than 0
localparam GEN_RAND_MAX   = WIDTH - 1;

localparam SEND_RAND_MIN  = 1;
localparam SEND_RAND_MAX  = WIDTH - 1;

localparam BURST_MODE     = 1;             // No random mode (need valid sig)


logic               clk;

logic [COUNT_SIZE-1:0]       data0;          // Input data
logic [COUNT_SIZE-1:0]       data1;          // Input data
logic [COUNT_SIZE-1:0]       data2;          // Input data
logic [COUNT_SIZE-1:0]       data3;          // Input data
logic [COUNT_CHANNELS-1:0]   direction;      // Select channel

logic [COUNT_SIZE-1:0]       data_out;

mux dut (
  .data0_i             ( data0             ),
  .data1_i             ( data1             ),
  .data2_i             ( data2             ),
  .data3_i             ( data3             ),
  .direction_i         ( direction         ),

  .data_o              ( data_out          )
);

typedef struct packed {
  logic [CHANNEL_NUM-1:0][COUNT_SIZE-1:0]     test_data;
  logic [COUNT_CHANNELS-1:0]                  channel;
  logic [COUNT_SIZE-1:0]                      output_data;
} data_s;

mailbox #( data_s ) generated_data  = new();
mailbox #( data_s ) sended_data     = new();
mailbox #( data_s ) read_data       = new();

data_s              test_data;                   // @TODO: Remove global

task generate_data( mailbox #( data_s ) _data );

data_s data_to_send;

  for( int i = 0; i < TEST_CNT; i++ )
    begin
      for (int j = 0; j < CHANNEL_NUM; j++)
        data_to_send.test_data[j] = $urandom_range(GEN_RAND_MAX,GEN_RAND_MIN);
      
      data_to_send.channel = $urandom_range(CHANNEL_NUM-1, 0);
      data_to_send.output_data = data_to_send.test_data[data_to_send.channel];

      _data.put( data_to_send );

    end

endtask

task send_data( data_s data_to_send );
  data0 = data_to_send.test_data[0];
  data1 = data_to_send.test_data[1];
  data2 = data_to_send.test_data[2];
  data3 = data_to_send.test_data[3];

  direction = data_to_send.channel;
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

      test_data = data_to_wr;
      test_data.output_data = '0;             // Link with "check_data" (data_to_rd)

      send_data(data_to_wr);
      
    end
endtask

task check_data( mailbox #( data_s ) watched_data );
  test_data.output_data = data_out;
    
  watched_data.put( test_data );

endtask

task fifo_rd( mailbox #( data_s ) watched_data );
  while ( watched_data.num() != TEST_CNT )
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

            `ifdef DEBUG
            `else
              if( ref_data_tmp.output_data != dut_data_tmp.output_data )
            `endif
                begin
                  $display( "Error! Data do not match!" );
                  $display( "Reference num = %d", TEST_CNT - dut_data.num() );
                  $display( "Reference data: d0 = %d d1 = %d, d2 = %d, d3 = %d, channel = %d, out = %d"
                                                                , ref_data_tmp.test_data[0]
                                                                , ref_data_tmp.test_data[1]
                                                                , ref_data_tmp.test_data[2]
                                                                , ref_data_tmp.test_data[3]
                                                                , ref_data_tmp.channel
                                                                , ref_data_tmp.output_data
                          );
                  $display( "Read data:      d0 = %d d1 = %d, d2 = %d, d3 = %d, channel = %d, out = %d"
                                                                , dut_data_tmp.test_data[0]
                                                                , dut_data_tmp.test_data[1]
                                                                , dut_data_tmp.test_data[2]
                                                                , dut_data_tmp.test_data[3]
                                                                , dut_data_tmp.channel
                                                                , dut_data_tmp.output_data
                          );
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
    forever #5ns clk = !clk;                         // 2 kHZ = 0.5ms
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
