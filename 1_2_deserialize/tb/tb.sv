module tb;

localparam DATA_W         = 16;
localparam TEST_CNT       = 100;
localparam COUNT_SIZE     = $clog2(DATA_W);

localparam GEN_RAND_MIN   = 0;
localparam GEN_RAND_MAX   = 2**DATA_W - 1;

localparam SEND_RAND_MIN  = 0;
localparam SEND_RAND_MAX  = 10;

localparam INIT_RST_DUR   = 3;

logic              clk;
logic              rst;
logic              rst_done;

logic              data;
logic              data_val;

logic [DATA_W-1:0] deser_data;
logic              deser_data_val;

initial
  begin
    clk = 1'b0;
    forever #5ns clk = !clk;
  end

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
  rst = 1'b1;
  repeat(INIT_RST_DUR) @(posedge clk);
  rst = 1'b0;
  rst_done = 1'b1;
end

mailbox #( logic [DATA_W-1:0] ) generated_data = new();
mailbox #( logic [DATA_W-1:0] ) sended_data    = new();
mailbox #( logic [DATA_W-1:0] ) read_data      = new();

task gen_data( mailbox #( logic [DATA_W-1:0] ) _data );

  logic [DATA_W-1:0] data_to_send;

  for( int i = 0; i <= TEST_CNT-1; i++ )
    begin
      data_to_send = $urandom_range(GEN_RAND_MAX,GEN_RAND_MIN);
      _data.put( data_to_send );
    end

endtask

task automatic send_data( logic [DATA_W-1:0] _data,
                          int                pause = 0
                        );

  for (int i = 0; i <= DATA_W-1; i++)
    begin
      data     <= _data[i];
      data_val <= 1'b1;
      @(posedge clk);
  
      if( pause != 0 )
        begin
          data_val <= 1'b0;
          repeat(pause) @(posedge clk);
        end
    end

endtask

task fifo_wr( mailbox #( logic [DATA_W-1:0] ) _data,
              mailbox #( logic [DATA_W-1:0] ) sended_data
            );

  logic [DATA_W-1:0] word_to_wr;
  int                bit_pause;
  int                packet_pause;
  int                mode_iter;
  
  mode_iter = -1;

  while( _data.num() )
    begin
      mode_iter += ( ( _data.num() % (TEST_CNT / 4) ) == 0 );
      _data.get(word_to_wr);
      
      case ( mode_iter )
        0:
          begin
             bit_pause    = 0;
             packet_pause = 0;
          end
        1:
          begin
             bit_pause    = 0;
             packet_pause = $urandom_range(SEND_RAND_MAX,SEND_RAND_MIN);
          end
        2:
          begin
             bit_pause    = $urandom_range(SEND_RAND_MAX,SEND_RAND_MIN);
             packet_pause = 0;
          end
        3: 
          begin
             bit_pause    = $urandom_range(SEND_RAND_MAX,SEND_RAND_MIN);
             packet_pause = $urandom_range(SEND_RAND_MAX,SEND_RAND_MIN);
          end
        default: 
          begin
             bit_pause    = 0;
             packet_pause = 0;
          end
      endcase

      send_data(word_to_wr, bit_pause);
      sended_data.put( word_to_wr );

      if( packet_pause != 0 )
      begin
        data_val <= 1'b0;
        repeat(packet_pause) @(posedge clk);
      end

    end

  data_val <= 1'b0;
endtask

task fifo_rd( mailbox #( logic [DATA_W-1:0] ) watched_data );
  while ( watched_data.num() != TEST_CNT )
    begin
      @(posedge clk);
      if ( deser_data_val === 1'b1 )
        watched_data.put( deser_data );
    end
endtask

task compare_data( mailbox #( logic [DATA_W-1:0] ) ref_data,
                   mailbox #( logic [DATA_W-1:0] ) dut_data
                 );

  logic [DATA_W-1:0] ref_data_tmp;
  logic [DATA_W-1:0] dut_data_tmp;
  logic [DATA_W-1:0] deser_data_reverse;
  
  int                mode_iter;
  
  mode_iter = -1;

  if( ref_data.num() != dut_data.num() )
    begin
      $display( "Size of ref data:      %d", ref_data.num() );
      $display( "And sized of dut data: %d", dut_data.num() );
      $display( "Do not match" );
      $stop();
    end
  else
    while ( dut_data.num() )
      begin
        mode_iter += ( ( dut_data.num() % (TEST_CNT / 4) ) == 0 );
        
        dut_data.get( dut_data_tmp );
        ref_data.get( ref_data_tmp );
        
        for (int j = 0; j <= DATA_W-1; j++)
            deser_data_reverse[j] = dut_data_tmp[DATA_W - j - 1];
        
        if( ref_data_tmp != deser_data_reverse )
          begin
            $display( "Error! Data do not match!" );
            case ( mode_iter )
              0:       $display( "Mode:  %s", "0: Full Burst" );
              1:       $display( "Mode:  %s", "1: Bit - Burst    Packet - Random" );
              2:       $display( "Mode:  %s", "2: Bit - Random   Packet - Burst" );
              3:       $display( "Mode:  %s", "3: Full Random" );
              default: $display("Unknown mode");
            endcase
            $display( "Reference data: %b", ref_data_tmp );
            $display( "Read data:      %b", deser_data_reverse );
            $stop();
          end
      end

endtask

initial
  begin
    data     = '0;
    data_val = 1'b0;

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
