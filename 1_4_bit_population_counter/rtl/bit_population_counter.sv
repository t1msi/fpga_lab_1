module bit_population_counter #(
  parameter WIDTH = 16
) (
  input  logic                    clk_i,           // Clock signal
  input  logic                    srst_i,          // Syncronous reset
	   
  input  logic [WIDTH-1:0]        data_i,          // Input data
  input  logic                    data_val_i,      // Confirmation of input
  
  output logic [$clog2(WIDTH):0]  data_o,          // Output data
  output logic                    data_val_o       // Confirmation of output
);

localparam COUNT_SIZE = $clog2(WIDTH);

// `define COMB_BASIC              // (+) 1 clock cycle latency, O(n)
`define COMB_HAM_WEIGHT         // (+) 1 clock cycle latency, O(n)
// `define COMB_GEN                // TODO: pre-generated LUT. low-level shit. 1 clock cycle latency, O(1), heavyweight?
// `define SEQ_LINEAR              // (+) WIDTH clock cycle latency, O(n), sequential, 1 bit at a time
// `define PIPE_LINEAR             // TODO: WIDTH/2 clock cycle latency, O(n), sequential & pipelined, 2 bit at a time
// `define PIPE_LOG                // TODO: log(WIDTH) clock cycle latency, O(log n), pipelined

`ifdef COMB_BASIC

logic [WIDTH-1:0] data_i_copy;

always_comb
  begin
    data_o = (WIDTH)'(0);
    for (int i = 0; i < WIDTH; i++)
      if ( data_i_copy[i] )
        begin
          data_o++;
        end
  end

assign data_i_copy = data_val_i ? data_i : '0;
assign data_val_o = data_val_i ? 1'b1 : 1'b0;

`endif

`ifdef COMB_HAM_WEIGHT
localparam POPCOUNT_WIDTH = $clog2(WIDTH) + 1;
localparam IS_ODD         = WIDTH % 2 ? 1'b1 : 1'b0;
localparam PAIR_COUNT     = WIDTH / 2;
localparam PAIR_WIDTH     = PAIR_COUNT * 2;

localparam PAD_WIDTH      = ( POPCOUNT_WIDTH > 2 ) ? POPCOUNT_WIDTH - 2 : POPCOUNT_WIDTH;

logic [PAIR_WIDTH-1:0]                    paircount;
logic [(PAIR_COUNT * POPCOUNT_WIDTH)-1:0] popcount;

logic [1:0] popcount2bits [0:3];

initial
  begin
    popcount2bits[0] = 2'd0;
    popcount2bits[1] = 2'd1;
    popcount2bits[2] = 2'd1;
    popcount2bits[3] = 2'd2;
  end

always_comb
  begin
    paircount[0 +: 2] = popcount2bits[data_i[0 +: 2]];
    popcount[0 +: POPCOUNT_WIDTH] = paircount[0 +: 2];

    for (int i = 1; i < PAIR_COUNT; i++)
      begin
        paircount[2*i +: 2] = popcount2bits[data_i[2*i +: 2]];
        popcount[POPCOUNT_WIDTH*i +: POPCOUNT_WIDTH]  = paircount[2*i +: 2]
                                                      + popcount[POPCOUNT_WIDTH*(i-1) +: POPCOUNT_WIDTH];
      end
    data_o = IS_ODD ? popcount[POPCOUNT_WIDTH*(PAIR_COUNT - 1) +: POPCOUNT_WIDTH] + data_i[WIDTH-1]
                    : popcount[POPCOUNT_WIDTH*(PAIR_COUNT - 1) +: POPCOUNT_WIDTH];
  end

assign data_val_o = data_val_i ? 1'b1 : 1'b0;

`endif

`ifdef SEQ_LINEAR

enum logic [1:0] {
  IDLE_S,  // waiting for start of message
  PROC_S   // processing
} state, next_state;

logic [COUNT_SIZE-1:0] mod_counter;

always_comb
  begin
    next_state = state;
  
    case( state )
      IDLE_S:
        begin
          if( data_val_i )
            next_state = PROC_S;
        end
  
      PROC_S:
        begin
          if( mod_counter == WIDTH-1 || !data_i )
            next_state = IDLE_S;
        end

      default:
        begin
          next_state = IDLE_S;
        end
    endcase
  end

always_ff @( posedge clk_i )
  if( srst_i )   
    state <= IDLE_S;
    else 
      state <= next_state;

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      mod_counter <= 1'b0;
      else
        if ( state == IDLE_S )
          mod_counter <= 1'b0;
      else 
        if ( state == PROC_S )
          mod_counter <= mod_counter + (COUNT_SIZE)'(1);
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      data_val_o <= 1'b0;
      else
        if ( ( mod_counter == WIDTH-1 || !data_i ) && state == PROC_S )
          data_val_o <= 1'b1;
      else 
        if ( data_val_o )
          data_val_o <= 1'b0;
  end

logic [COUNT_SIZE:0] count;

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      count <= '0;
      else
        if ( ( state == IDLE_S ) && ( next_state == PROC_S ) )
          count <= '0;
      else
        if ( data_i[mod_counter] == 1'b1 )
          count <= count + (COUNT_SIZE + 1)'(1);
  end

assign data_o = ( state == data_val_o && data_i ) ? count : '0;

`endif

endmodule