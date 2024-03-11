module tb;

// `define DEBUG                           // Print all testing steps

localparam WIDTH          = 4;
localparam DATA_WIDTH     = 16;

localparam TEST_CNT       = 100;

localparam GEN_RAND_MIN   = 0;
localparam GEN_RAND_MAX   = 2**DATA_WIDTH - 1;

localparam SEND_RAND_MIN  = 0;
localparam SEND_RAND_MAX  = 2**WIDTH - 1;

localparam BURST_MODE     = 1;


logic                clk;

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
  logic [DATA_WIDTH-1:0] gen_data;
  logic [WIDTH-1:0]      gen_delay;

  logic [DATA_WIDTH-1:0] test_data;  
  logic [WIDTH-1:0]      test_delay;
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
      data_to_send.gen_delay = $urandom_range(SEND_RAND_MAX,SEND_RAND_MIN);
      
      data_to_send.test_data  = '0;
      data_to_send.test_delay = '0;

      _data.put( data_to_send );
    end

endtask

task send_data( data_s data_to_send );
  data_delay_in      = data_to_send.gen_delay;

  for (int i = 0; i < DATA_WIDTH; i++) 
    begin
      data_in = data_to_send.gen_data[i];
      @(posedge clk);
    end

  data_in = '0;
  repeat(data_to_send.gen_delay + 1) @(posedge clk);
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

      test_data = data_to_wr;

      send_data(data_to_wr);
      sended_data.put( data_to_wr );

      if ( pause )
        begin
          // data_delay_in = '0;
          repeat(pause) @(posedge clk);
        end
      
    end
    data_delay_in = '0;
endtask

task fifo_rd( mailbox #( data_s ) watched_data );

  logic [DATA_WIDTH:0]   iter_inner;
  logic [DATA_WIDTH:0]   iter_ex;

  while ( watched_data.num() != TEST_CNT )
    begin
      iter_inner = 0;
      iter_ex    = 0;
      do                                                          // Пропуск delay тактов
        begin
          @(posedge clk);                                         // Смена старого значения test_data
          iter_inner++;
          iter_ex++;
        end
      while (iter_inner < test_data.gen_delay);

      if ( test_data.gen_delay )
        begin
          test_data.test_delay = iter_inner;
          iter_inner = 0;
        end
      else
        begin                                                     // delay = 0
          test_data.test_data[0] = data_out;
        end

      for ( ; iter_inner < DATA_WIDTH; iter_inner++, iter_ex++ )  // Получение обратного сигнала
        begin
          @(posedge clk);
          test_data.test_data[iter_inner] = data_out;
        end
        
      watched_data.put( test_data );                              // Запись в mailbox
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

          if( ref_data_tmp.gen_delay != dut_data_tmp.test_delay || ref_data_tmp.gen_data != dut_data_tmp.test_data )
            begin
              $display( "Error! Data do not match!" );
              $display( "Reference num = %d", TEST_CNT - dut_data.num() );
              $display( "Gen data:       data = %b, delay = %x", ref_data_tmp.gen_data, ref_data_tmp.gen_delay );
              $display( "Read data:      data = %b, delay = %x : %b %x" , dut_data_tmp.test_data, dut_data_tmp.test_delay
                                                                        , dut_data_tmp.gen_data, dut_data_tmp.gen_delay
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
