module tb;

// `define DEBUG                           // Print all testing steps

localparam WIDTH      = 16;
localparam TEST_CNT   = 100;

localparam GEN_RAND_MIN   = 1;             // Must be greater than 0
localparam GEN_RAND_MAX   = WIDTH - 1;

localparam SEND_RAND_MIN  = 1;             // @TODO: Fix BURST_MODE (race cond. wait in check_data, need 1 clk more)
localparam SEND_RAND_MAX  = WIDTH - 1;     // @TODO: Change to 2^WIDTH

localparam NOTRANSITION_TICK = 5;

localparam BURST_MODE     = 0;             // @BUG: Do not work in burst, min latency = 1

localparam BLINK_HALF_PERIOD_MS  = 2;
localparam BLINK_GREEN_TIME_TICK = 5;
localparam RED_YELLOW_MS         = 10;

localparam CHECKSUM_MS           = BLINK_GREEN_TIME_TICK * 2 * BLINK_HALF_PERIOD_MS + RED_YELLOW_MS + 3 * (1 << WIDTH);

localparam COUNT_TICK_SIZE        = $clog2(BLINK_GREEN_TIME_TICK);
localparam COUNT_HALF_PERIOD_SIZE = $clog2(BLINK_HALF_PERIOD_MS);
localparam COUNT_RED_YELLOW_SIZE  = $clog2(RED_YELLOW_MS);
localparam COUNT_WIDTH            = $clog2(WIDTH);
localparam COUNT_CHECKSUM_MS      = $clog2(CHECKSUM_MS);

localparam COUNT_GREEN_BLINKING_MS_SIZE = $clog2(BLINK_GREEN_TIME_TICK * 2 * BLINK_HALF_PERIOD_MS);
localparam COUNT_NOTRANSITION_MS_SIZE   = $clog2(NOTRANSITION_TICK * 2 * BLINK_HALF_PERIOD_MS);

localparam COUNT_NOTRANSITION_TICK      = $clog2(NOTRANSITION_TICK);

localparam INIT_RST_DUR   = 3;

logic               clk;
logic               rst;             // Syncronous reset
logic               rst_done;
	   
logic [2:0]         cmd_type_in;     // Type of command
logic               cmd_valid_in;    // Confirmation of command
logic [WIDTH-1:0]   cmd_data_in;     // Input data for command

logic               red;             // Red light as output
logic               yellow;          // Yellow light as output
logic               green;           // Green light as output

typedef struct packed {
  logic [COUNT_WIDTH:0]   green_time;     // + 1 for green_blink_s
  logic [COUNT_WIDTH-1:0] yellow_time;
  logic [COUNT_WIDTH-1:0] red_time;
} light_time;

enum logic [2:0] {
  NORMAL_CMD       = 3'd0,    // Turn on or Normal mode
  SHUTDOWN_CMD     = 3'd1,    // Turn off
  NOTRANSITION_CMD = 3'd2,    // Turn notransition mode
  SET_GREEN_CMD    = 3'd3,    // Set time for green
  SET_RED_CMD      = 3'd4,    // Set time for red
  SET_YELLOW_CMD   = 3'd5     // Set time for yellow
} command;

enum logic [1:0] {
  NORMAL_T       = 2'd0,    // Normal mode test   (NOTRANS --> SET --> NORMAL_M + SHUTDOWN <-- CHECK_DATA. 1..2 iter)
  NOTRANSITION_T = 2'd1    // Notransition mode test (NOTRANS + SHUTDOWN <-- CHECK_DATA. first light + finish delay)
  // SET_T          = 2'd2     // @TODO: Set in Normal mode ( dynamic change test )
} test_case;

traffic_lights #(
  .BLINK_HALF_PERIOD_MS       ( BLINK_HALF_PERIOD_MS   ),
  .BLINK_GREEN_TIME_TICK      ( BLINK_GREEN_TIME_TICK  ),
  .RED_YELLOW_MS              ( RED_YELLOW_MS          )
) dut (
  .clk_i               ( clk              ),
  .srst_i              ( rst              ),
 
  .cmd_type_i          ( cmd_type_in       ),
  .cmd_valid_i         ( cmd_valid_in      ),
  .cmd_data_i          ( cmd_data_in       ),

  .red_o               ( red               ),
  .yellow_o            ( yellow            ),
  .green_o             ( green             )
);

typedef struct packed {
  logic [1:0]                               test_case;
  light_time                                time_entity;

  logic [COUNT_RED_YELLOW_SIZE-1:0]         red_yellow_time_test;

  logic [COUNT_GREEN_BLINKING_MS_SIZE-1:0]  green_blink_time_test;
  logic [COUNT_TICK_SIZE:0]                 green_blink_blink_test;

  logic [COUNT_NOTRANSITION_MS_SIZE:0]      notransition_time_test;
  logic [COUNT_NOTRANSITION_TICK:0]         notransition_blink_test;

  logic [COUNT_CHECKSUM_MS-1:0]             checksum_data;
} data_s;

mailbox #( data_s ) generated_data  = new();
mailbox #( data_s ) sended_data     = new();
mailbox #( data_s ) read_data       = new();

data_s              test_data;                   // @TODO: Remove global

task generate_data( mailbox #( data_s ) _data );

data_s data_to_send;

// random test cases (NORMAL_T)
  for( int i = 0; i < TEST_CNT; i++ )
    begin

      data_to_send.time_entity.green_time           = $urandom_range(GEN_RAND_MAX,GEN_RAND_MIN);
      data_to_send.time_entity.yellow_time          = $urandom_range(GEN_RAND_MAX,GEN_RAND_MIN);
      data_to_send.time_entity.red_time             = $urandom_range(GEN_RAND_MAX,GEN_RAND_MIN);
      
      data_to_send.red_yellow_time_test = RED_YELLOW_MS;

      data_to_send.green_blink_time_test             = BLINK_GREEN_TIME_TICK * 2 * BLINK_HALF_PERIOD_MS;
      data_to_send.green_blink_blink_test            = BLINK_GREEN_TIME_TICK;

      data_to_send.notransition_time_test            = NOTRANSITION_TICK * 2 * BLINK_HALF_PERIOD_MS;
      data_to_send.notransition_blink_test           = NOTRANSITION_TICK;

      data_to_send.checksum_data        = BLINK_GREEN_TIME_TICK * 2 * BLINK_HALF_PERIOD_MS + RED_YELLOW_MS
                                        + data_to_send.time_entity.green_time + data_to_send.time_entity.yellow_time
                                        + data_to_send.time_entity.red_time;
      
      data_to_send.test_case = NORMAL_T;

      _data.put( data_to_send );

    end

// corner case (NOTRANSITION_T)

    begin
      data_to_send = '0;

      data_to_send.notransition_time_test            = NOTRANSITION_TICK * 2 * BLINK_HALF_PERIOD_MS;
      data_to_send.notransition_blink_test           = NOTRANSITION_TICK;

      data_to_send.test_case = NOTRANSITION_T;

      _data.put( data_to_send );
    end

endtask

task send_data( data_s data_to_send );
  wait( !green && !yellow && !red );
    case ( data_to_send.test_case )
      NORMAL_T: 
        begin
          cmd_type_in  = NOTRANSITION_CMD;
          cmd_valid_in = 1'b1;
          cmd_data_in  = '0;
          @(posedge clk);
      
          cmd_type_in  = SET_GREEN_CMD;
          cmd_valid_in = 1'b1;
          cmd_data_in  = data_to_send.time_entity.green_time;
          if ( !cmd_data_in && cmd_valid_in )
            $display("Warning: green_time is 0. Value will be accurated to 1");
          @(posedge clk);
      
          cmd_type_in  = SET_RED_CMD;
          cmd_valid_in = 1'b1;
          cmd_data_in  = data_to_send.time_entity.red_time;
          if ( !cmd_data_in && cmd_valid_in )
            $display("Warning: red_time is 0. Value will be accurated to 1");
          @(posedge clk);
      
          cmd_type_in  = SET_YELLOW_CMD;
          cmd_valid_in = 1'b1;
          cmd_data_in  = data_to_send.time_entity.yellow_time;
          if ( !cmd_data_in && cmd_valid_in )
            $display("Warning: yellow_time is 0. Value will be accurated to 1");
          @(posedge clk);

          cmd_valid_in = 1'b0;
          repeat(data_to_send.notransition_time_test - 4) @(posedge clk);

          cmd_type_in  = NORMAL_CMD;
          cmd_valid_in = 1'b1;
          cmd_data_in  = '0;
          @(posedge clk);

          cmd_valid_in = 1'b0;
          repeat(data_to_send.checksum_data) @(posedge clk);

          cmd_type_in  = SHUTDOWN_CMD;
          cmd_valid_in = 1'b1;
          @(posedge clk);
        end
      
      NOTRANSITION_T: 
        begin
          cmd_type_in  = NOTRANSITION_CMD;
          cmd_valid_in = 1'b1;
          @(posedge clk);

          cmd_valid_in = 1'b0;
          repeat(data_to_send.notransition_time_test - 1) @(posedge clk);

          cmd_type_in  = SHUTDOWN_CMD;
          cmd_valid_in = 1'b1;
          @(posedge clk);
        end
        
      default: 
        begin
          
        end
    endcase

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

      test_data = '0;
      test_data.test_case = data_to_wr.test_case;             // Link with "check_data" (data_to_rd)

      send_data(data_to_wr);
      
      if ( pause )
        begin
          cmd_valid_in = 1'b0;
          repeat(pause) @(posedge clk);
        end
    end
  
  cmd_valid_in = 1'b0;
endtask

task check_data( mailbox #( data_s ) watched_data );
  data_s      data_to_rd;
  logic [1:0] seq_detect;

  wait ( cmd_valid_in && cmd_type_in == NOTRANSITION_CMD );
  
  data_to_rd = '0;
  data_to_rd.test_case = test_data.test_case;

  seq_detect = '0;
    
  case ( data_to_rd.test_case )
    NORMAL_T: 
      begin
        // NOTRANSITION_M + YELLOW_BLINKING_S
        while ( !red )                                 // @BUG: Counting from cmd_valid_i in NORMAL_T
          begin
            if ( yellow )
              seq_detect++;
            else if ( seq_detect == 2'd2 )
              begin
                data_to_rd.notransition_blink_test++;
                seq_detect = 2'd0;
              end
            data_to_rd.notransition_time_test++;
            @(posedge clk);
          end

        // NORMAL_M + RED_S
        while ( red && !yellow )
          begin
            data_to_rd.time_entity.red_time++;
            @(posedge clk);
          end

        // NORMAL_M + RED_YELLOW_S
        while ( red && yellow )
          begin
            data_to_rd.red_yellow_time_test++;
            @(posedge clk);
          end

        // NORMAL_M + GREEN_S
        while ( green )
          begin
            data_to_rd.time_entity.green_time++;     // Transition to blinking
            @(posedge clk);
          end
          
        // NORMAL_M + GREEN_BLINKING_S
        seq_detect = '0;
        while ( !yellow )
          begin
            if ( green )
              seq_detect++;
            else if ( seq_detect == 2'd2 )
              begin
                data_to_rd.green_blink_blink_test++;
                seq_detect = 2'd0;
              end
            data_to_rd.green_blink_time_test++;
            @(posedge clk);
          end
          
        // NORMAL_M + YELLOW_S
        while ( yellow && !red )
          begin
            data_to_rd.time_entity.yellow_time++;
            @(posedge clk);
          end

        data_to_rd.checksum_data  = data_to_rd.green_blink_time_test + data_to_rd.red_yellow_time_test
                                  + data_to_rd.time_entity.green_time + data_to_rd.time_entity.yellow_time
                                  + data_to_rd.time_entity.red_time;
      end

    NOTRANSITION_T:
      begin
        while ( !(cmd_valid_in && cmd_type_in == SHUTDOWN_CMD) )                               
          begin
            if ( yellow )
              seq_detect++; 
              else
                if ( seq_detect == 2'd2 )
                  begin
                    data_to_rd.notransition_blink_test++;
                    seq_detect = 2'd0;
                  end

            data_to_rd.notransition_time_test++;
            @(posedge clk);
          end

        if ( seq_detect == 2'd2 )                     // @TODO: Move to upper loop
          data_to_rd.notransition_blink_test++;
      end
      
    default: 
      begin
        
      end

  endcase
    
  watched_data.put( data_to_rd );

endtask

task fifo_rd( mailbox #( data_s ) watched_data );
  while ( watched_data.num() != TEST_CNT + 1 )
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

          case ( dut_data_tmp.test_case )
            NORMAL_T:
            `ifdef DEBUG
            `else
              if( ref_data_tmp.checksum_data != dut_data_tmp.checksum_data )
            `endif
                begin
                  $display( "Error! Data do not match!" );
                  $display( "Reference num = %d", TEST_CNT - dut_data.num() );
                  $display( "Reference data: r = %d ms, r+y = %d ms, g = %d ms, g(blink time) = %d ms, y = %d ms, checksum = %d ms"
                                                                                              , ref_data_tmp.time_entity.red_time
                                                                                              , ref_data_tmp.red_yellow_time_test
                                                                                              , ref_data_tmp.time_entity.green_time
                                                                                              , ref_data_tmp.green_blink_time_test
                                                                                              , ref_data_tmp.time_entity.yellow_time
                                                                                              , ref_data_tmp.checksum_data
                          );
                  $display( "Read data:      r = %d ms, r+y = %d ms, g = %d ms, g(blink time) = %d ms, y = %d ms, checksum = %d ms"
                                                                                              , dut_data_tmp.time_entity.red_time
                                                                                              , dut_data_tmp.red_yellow_time_test
                                                                                              , dut_data_tmp.time_entity.green_time
                                                                                              , dut_data_tmp.green_blink_time_test
                                                                                              , dut_data_tmp.time_entity.yellow_time
                                                                                              , dut_data_tmp.checksum_data
                          );
                  `ifdef DEBUG
                  `else
                    $stop();
                  `endif
                end
            
            NOTRANSITION_T:
            `ifdef DEBUG
            `else
              if( ref_data_tmp.notransition_time_test != dut_data_tmp.notransition_time_test )
            `endif
                begin
                  $display( "Error! Data do not match!" );
                  $display( "Reference num = %d", TEST_CNT - dut_data.num() );
                  $display( "Reference data: y(blink) = %d, y = %d ms" , ref_data_tmp.notransition_blink_test
                                                                       , ref_data_tmp.notransition_time_test
                          );
                  $display( "Read data:      y(blink) = %d, y = %d ms" , dut_data_tmp.notransition_blink_test
                                                                       , dut_data_tmp.notransition_time_test
                          );

                  `ifdef DEBUG
                  `else
                    $stop();
                  `endif
                end
            
            default:
              begin
                
              end
          endcase
        end
    end

endtask

initial
  begin
    clk = 1'b0;
    forever #0.5ms clk = !clk;                         // 2 kHZ = 0.5ms
  end

initial
  begin
    rst = 1'(1);
    repeat(INIT_RST_DUR) @(posedge clk);
    rst = 1'b0;
    rst_done = 1'b1;
  end

initial
  begin
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
