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

enum logic [2:0] {
  IDLE_S  = 3'b001,  // waiting for start of message
  PROC_S  = 3'b010,  // processing
  SEND_S  = 3'b100   // send message to output
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
            next_state = SEND_S;
        end
  
      SEND_S:
        begin
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
        if ( data_i[mod_counter] == 1'b1 && !min_val )
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
        if ( data_i[mod_counter] == 1'b1 )
          max <= mod_counter;
  end

always_comb
  if ( state == SEND_S && data_i )
    begin
      data_left_o  = (WIDTH)'(0) | ((WIDTH)'(1) << max);
      data_right_o = (WIDTH)'(0) | ((WIDTH)'(1) << min);
    end
  else
    begin
      data_left_o  = (WIDTH)'(0);
      data_right_o = (WIDTH)'(0);
    end

endmodule