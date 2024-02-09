module priority_encoder #(
  parameter WIDTH = 16
) (
  input  logic              clk_i,           // Clock signal
  input  logic              srst_i,          // Syncronous reset
	
  input  logic [WIDTH-1:0]  data_i,          // Input data
  input  logic              data_val_i,      // Confirmation of input
  
  output logic [WIDTH-1:0]  data_left_o,     // Left one
  output logic [WIDTH-1:0]  data_right_o,    // Right one
  output logic              data_val_o       // Confirmation of output
);

localparam COUNT_SIZE = $clog2(WIDTH);

// `define COMB_BASIC              // (+) 1 clock cycle latency, O(n)
`define COMB_KR                 // (+) 1 clock cycle latency, O(n), but faster & lighter
// `define COMB_LOG                // (+) 1 clock cycle latency, O(log n) - heavyweight & slow
// `define COMB_GEN                // TODO: pre-generated LUT. low-level shit. 1 clock cycle latency, O(1), heavyweight?
// `define SEQ_LINEAR              // (+) WIDTH clock cycle latency, O(n), sequential, 1 bit at a time
// `define SEQ_KR_PACKED           // TODO: log(WIDTH) clock cycle latency, O(n + log n)? n is divided by log(WIDTH)
// `define PIPE_LINEAR             // (+-) WIDTH clock cycle latency, O(n), sequential & pipelined, 1 bit at a time
// `define PIPE_KR_PACKED          // TODO: log(WIDTH) clock cycle latency, O(n + log n), sequential & pipelined


`ifdef COMB_BASIC

logic [WIDTH-1:0] data_i_copy;

always_comb
  begin
    data_left_o = (WIDTH)'(0);
    for (int i = WIDTH - 1; i >= 0; i--)
      if (data_i_copy[i])
        begin
          data_left_o[i] = 1'b1;
          break;
        end
  end

always_comb
  begin
    data_right_o = (WIDTH)'(0);
    for (int i = 0; i < WIDTH; i++)
      if (data_i_copy[i])
        begin
          data_right_o[i] = 1'b1;
          break;
        end
  end

assign data_i_copy = data_val_i ? data_i : '0;
assign data_val_o = data_val_i ? 1'b1 : 1'b0;

`endif

`ifdef COMB_KR

function logic [WIDTH-1:0] reverse ( input logic [WIDTH-1:0] _data ) ;
  logic [WIDTH-1:0] rev;
  for (logic [WIDTH-1:0] i = '0; i < WIDTH; i++)
    rev[WIDTH - i - 1] = _data[i];
  
  return rev;
  
endfunction

logic [WIDTH-1:0] data_i_copy;
logic [WIDTH-1:0] data_i_copy_reverse;

always_comb
  begin
    data_i_copy = data_val_i ? data_i : (WIDTH)'(0);
    data_right_o = data_i_copy & (-data_i_copy);
  end

always_comb
  begin
    data_i_copy_reverse = data_val_i ? reverse(data_i) : (WIDTH)'(0);
    data_left_o = reverse( data_i_copy_reverse & (-data_i_copy_reverse) );
  end

assign data_val_o = data_val_i ? 1'b1 : 1'b0;

`endif


`ifdef COMB_LOG

logic [1:0][WIDTH-1:0]   data_i_copy;
logic [COUNT_SIZE - 1:0] lsb;
logic [COUNT_SIZE - 1:0] msb;

logic [WIDTH-1:0]        width_lsb, width_msb;

always_comb
  begin
    data_right_o = '0;
    lsb         = '0;
    width_lsb   = '0;
    data_i_copy[0] = data_val_i ? data_i : (WIDTH)'(0);
    for (int i = COUNT_SIZE - 1; i >= 0; i--)
      begin
        width_lsb = 1 << i;
        if (|(data_i_copy[0] << width_lsb))
          lsb[i] = 1;
        
        data_i_copy[0] = lsb[i] ? data_i_copy[0] << width_lsb : 
                                  data_i_copy[0] & ( ( (WIDTH)'(1) >> width_lsb ) - 1'b1 ) ;
      end
    data_right_o[WIDTH - lsb - 1] = data_i ? 1'b1 : 1'b0;
  end

always_comb
  begin
    data_left_o = '0;
    msb          = '0;
    width_msb    = '0;
    data_i_copy[1] = data_val_i ? data_i : (WIDTH)'(0);
    
    for (int i = COUNT_SIZE - 1; i >= 0; i--)
      begin
        width_msb = 1 << i;
        if (|(data_i_copy[1] >> width_msb))
          msb[i] = 1;
        
        data_i_copy[1] = msb[i] ? data_i_copy[1] >> width_msb :
                                  data_i_copy[1] & ( (1'd1 << width_msb) - 1'd1 );
      end
    data_left_o[msb] = data_i ? 1'b1 : 1'b0;
  end

assign data_val_o = data_val_i ? 1'b1 : 1'b0;

`endif

`ifdef SEQ_LINEAR

enum logic {
  IDLE_S,  // waiting for start of message
  PROC_S   // processing
} state, next_state;

logic [COUNT_SIZE-1:0] mod_counter;
logic [WIDTH-1:0]      data_i_copy;

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
          if( mod_counter == WIDTH-1 || !data_i_copy )
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
        if ( ( mod_counter == WIDTH-1 || !data_i_copy ) && state == PROC_S )
          data_val_o <= 1'b1;
      else 
        if ( data_val_o )
          data_val_o <= 1'b0;
  end

logic [COUNT_SIZE-1:0] min;
logic [COUNT_SIZE-1:0] max;
logic                  min_val;

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      begin
        min_val <= 1'b0;
        min     <= '0;
      end
      else
        if ( ( state == IDLE_S ) && ( next_state == PROC_S ) )
          begin
            min_val <= 1'b0;
            min     <= '0;
          end
      else
        if ( data_i_copy[mod_counter] == 1'b1 && !min_val )
          begin
            min_val <= 1'b1;
            min     <= mod_counter;
          end
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      max <= '0;
      else
        if ( ( state == IDLE_S ) && ( next_state == PROC_S ) )
          max <= '0;
      else
        if ( data_i_copy[mod_counter] == 1'b1 )
          max <= mod_counter;
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      data_i_copy <= '0;
      else
        if ( data_val_i )
          data_i_copy <= data_i;
  end

always_comb
  if ( data_val_o && data_i_copy )
    begin
      data_left_o       = '0;
      data_right_o      = '0;
      data_left_o[max]  = 1'b1;
      data_right_o[min] = 1'b1;
    end
  else
    begin
      data_left_o  = (WIDTH)'(0);
      data_right_o = (WIDTH)'(0);
    end

`endif


`ifdef PIPE_LINEAR

localparam PIPE_DEPTH       = WIDTH;
localparam PIPE_DEPTH_COUNT = $clog2(PIPE_DEPTH);

logic [PIPE_DEPTH_COUNT-1:0]            pipe_counter;
logic [PIPE_DEPTH-1:0]                  pipe_val;

logic [PIPE_DEPTH-1:0][WIDTH-1:0]       data_i_copy;
logic                                   cycle;

logic [PIPE_DEPTH-1:0][COUNT_SIZE-1:0]  min;
logic [PIPE_DEPTH-1:0][COUNT_SIZE-1:0]  max;
logic [PIPE_DEPTH-1:0]                  min_val;

always_ff @( posedge clk_i )      // Большая степень параллелизма, можно сразу заполнить всю матрицу и одновременно считать
  begin
    if ( srst_i )
      pipe_counter <= '0;
      else
        if ( pipe_counter == PIPE_DEPTH - 1 )                          // есть проблема с параллельным input и счетом
          pipe_counter <= 0;
      else
        if ( data_val_i )
          pipe_counter <= pipe_counter + (COUNT_SIZE)'(1);
      else
        if ( pipe_val )
          pipe_counter <= pipe_counter + (COUNT_SIZE)'(1);
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      cycle <= '0;
      else
        if ( pipe_counter == PIPE_DEPTH - 1 )                          // -2 это костыль. fix за счет data_val_o comb
          cycle <= 1'b1;
      else
        if ( !pipe_val )
          cycle <= 1'b0;
  end

always_ff @( posedge clk_i )
  if ( srst_i )
    data_val_o <= 1'b0;
    else    
      if ( pipe_val[pipe_counter] && cycle )                         // ? corner case - delay with first number
        data_val_o <= 1'b1;
      else
        data_val_o <= 1'b0;

always_ff @( posedge clk_i )
  if ( srst_i )
    data_i_copy <= '0;
    else
      if ( data_val_i || pipe_val )
        data_i_copy[pipe_counter] <= data_i;
    else
      if ( !data_val_i )
        data_i_copy[pipe_counter] <= '0;

always_ff @( posedge clk_i )
  if ( srst_i )
    pipe_val <= '0;
    else
      if ( data_val_i )
        pipe_val[pipe_counter] <= 1'b1;
    else
        pipe_val[pipe_counter] <= '0;

always_comb    // Проблема в том что min_val всегда ff, надо сбрасывать когда новое значение появляется
  if ( data_val_i || pipe_val )
    begin
      // min_val[pipe_counter] = 1'b0;
      // min[pipe_counter]     = '0;
      for (int i = 0; i < PIPE_DEPTH; i++)
        if ( ( data_i_copy[i][(WIDTH - 1 - i + pipe_counter) % WIDTH] == 1'b1 ) && !min_val[i] )
          begin
            min_val[i] = 1'b1;
            min[i]     = (WIDTH - 1 - i + pipe_counter) % WIDTH;
          end
    end
  else
    if ( !pipe_val )
      begin
        min_val = '0;
        min     = '0;
      end
  else
    begin
      min_val[pipe_counter] = 1'b0;
      min[pipe_counter]     = '0;
    end
      
always_comb
  if ( data_val_i || pipe_val )
    begin
      // max[pipe_counter] = 1'b0;
      for (int i = 0; i < PIPE_DEPTH; i++)
        if ( data_i_copy[i][(WIDTH - 1 - i + pipe_counter) % WIDTH] == 1'b1 )
          max[i] = (WIDTH - 1 - i + pipe_counter) % WIDTH;
    end
  else
    if ( !pipe_val )
      max = '0;
  else
    max[pipe_counter] = 1'b0;


always_ff @( posedge clk_i )                       // можно не занулять, из за data_val_o
  if ( data_val_o && min_val[pipe_counter] )
    begin
      data_left_o       <= '0;
      data_right_o      <= '0;
      data_left_o[max[pipe_counter]]  <= 1'b1;
      data_right_o[min[pipe_counter]] <= 1'b1;
    end
  else
    begin
      data_left_o  <= (WIDTH)'(0);
      data_right_o <= (WIDTH)'(0);
    end

`endif

endmodule