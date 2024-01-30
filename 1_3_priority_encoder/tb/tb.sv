module tb;

localparam WIDTH      = 8;
localparam TEST_CNT   = 100;
localparam COUNT_SIZE = $clog2(WIDTH);

localparam GEN_RAND_MIN   = 0;
localparam GEN_RAND_MAX   = 2**WIDTH - 1;

localparam SEND_RAND_MIN  = 0;
localparam SEND_RAND_MAX  = WIDTH - 1;

localparam INIT_RST_DUR   = 3;

logic              clk;
logic              rst;
logic              rst_done;

logic [WIDTH-1:0]  data;
logic              data_val_in;

logic [WIDTH-1:0]  data_left;
logic [WIDTH-1:0]  data_right;
logic              data_val_out;

initial
  begin
    clk = 1'b0;
    forever #5ns clk = !clk;
  end

priority_encoder #(
  .WIDTH               ( WIDTH             )
) dut (
  .clk_i               ( clk               ),
  .srst_i              ( rst               ),
 
  .data_i              ( data              ),
  .data_val_i          ( data_val_in       ),

  .data_left_o         ( data_left         ),
  .data_right_o        ( data_right        ),
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
  logic [WIDTH-1:0] gen_data;
  logic [WIDTH-1:0] left;
  logic [WIDTH-1:0] right;
} data_s;

mailbox #( data_s ) generated_data  = new();
mailbox #( data_s ) sended_data     = new();
mailbox #( data_s ) read_data       = new();

task generate_data( mailbox #( data_s ) _data );

data_s data_to_send;
logic [COUNT_SIZE-1:0] min;
logic [COUNT_SIZE-1:0] max;
logic                  min_val;

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

     data_to_send.left  = (WIDTH)'(0) | ((WIDTH)'(1) << max);
     data_to_send.right = (WIDTH)'(0) | ((WIDTH)'(1) << min);

      _data.put( data_to_send );

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

      data         <= data_to_wr.gen_data;
      data_val_in  <= 1'b1;
      @(posedge clk);
      
      sended_data.put( data_to_wr );

      data_val_in <= 1'b0;
      repeat(WIDTH + pause) @(posedge clk);
    end
  data_val_in <= 1'b0;
endtask

task fifo_rd( mailbox #( data_s ) watched_data );
  while ( watched_data.num() != TEST_CNT )
    begin
      @(posedge clk);
      if ( data_val_out )
        begin
          watched_data.put( { data, data_left, data_right } );
        end
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
              $display( "Reference data: %b %b", ref_data_tmp.gen_data, dut_data_tmp.gen_data);
              $display( "Gen data: left = %b, right = %b", ref_data_tmp.left, ref_data_tmp.right );
              $display( "Read data: left = %b, right = %b", dut_data_tmp.left, dut_data_tmp.right );
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
      fifo_wr(generated_data, sended_data, 0);
      fifo_rd(read_data);
    join

    compare_data(sended_data, read_data);
    $display( "Test done! No errors!" );
    $stop();
  end

endmodule
