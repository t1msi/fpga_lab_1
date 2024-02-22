localparam WIDTH = 16;

module traffic_lights #(
  parameter BLINK_HALF_PERIOD_MS  = 2,
  parameter BLINK_GREEN_TIME_TICK = 5,
  parameter RED_YELLOW_MS         = 10
) (
  input  logic               clk_i,          // Clock signal
  input  logic               srst_i,         // Syncronous reset
	   
  input  logic [2:0]         cmd_type_i,     // Type of command
  input  logic               cmd_valid_i,    // Confirmation of command
  input  logic [WIDTH-1:0]   cmd_data_i,     // Input data for command

  output logic               red_o,          // Red light as output
  output logic               yellow_o,       // Yellow light as output
  output logic               green_o         // Green light as output
);

typedef struct packed {
  logic [WIDTH-1:0] green_time;
  logic [WIDTH-1:0] yellow_time;
  logic [WIDTH-1:0] red_time;
} light_time;

localparam COUNT_TICK_SIZE        = $clog2(BLINK_GREEN_TIME_TICK);
localparam COUNT_HALF_PERIOD_SIZE = $clog2(BLINK_HALF_PERIOD_MS);
localparam COUNT_RED_YELLOW_SIZE  = $clog2(RED_YELLOW_MS);
localparam COUNT_WIDTH            = $clog2(WIDTH);

logic [COUNT_TICK_SIZE-1:0]        counter_tick;
logic [COUNT_HALF_PERIOD_SIZE-1:0] counter_half_period;
logic [COUNT_RED_YELLOW_SIZE-1:0]  counter_red_yellow;
logic [WIDTH-1:0]                  counter_width;

logic                              half_for_tick;

light_time                         time_entity;

enum logic [2:0] {
  NORMAL_CMD       = 3'd0,    // Turn on or Normal mode
  SHUTDOWN_CMD     = 3'd1,    // Turn off
  NOTRANSITION_CMD = 3'd2,    // Turn notransition mode
  SET_GREEN_CMD    = 3'd3,    // Set time for green
  SET_RED_CMD      = 3'd4,    // Set time for red
  SET_YELLOW_CMD   = 3'd5     // Set time for yellow
} command;

enum logic [1:0] {
  IDLE_M,           // Init
  NORMAL_M,         // Normal mode
  NOTRANSITION_M    // Notransition state
} mode, next_mode;

enum logic [2:0] {
  RED_S,            // Red light
  RED_YELLOW_S,     // Red + Yellow "blinking" light
  GREEN_S,          // Green light
  GREEN_BLINK_S,    // Green "blinking" light
  YELLOW_S,         // Yellow light
  YELLOW_BLINK_S    // Yellow "blinking" light
} state, next_state;

// Switch modes + set time to lights | BY COMMANDS

always_comb
  begin
    next_mode = mode;
  
    case( mode )
      IDLE_M:
        begin
          if( cmd_valid_i )
            case ( cmd_type_i )
              NORMAL_CMD      : next_mode = NORMAL_M;
              NOTRANSITION_CMD: next_mode = NOTRANSITION_M;
              default         : next_mode = IDLE_M;
            endcase
        end
    
      NORMAL_M:
        begin
          if( cmd_valid_i )
            case ( cmd_type_i )
              SHUTDOWN_CMD    : next_mode = IDLE_M;
              NOTRANSITION_CMD: next_mode = NOTRANSITION_M;
              default         : next_mode = NORMAL_M;
            endcase
        end
  
      NOTRANSITION_M:
        begin
          if( cmd_valid_i )
            case ( cmd_type_i )
              SHUTDOWN_CMD :  next_mode = IDLE_M;
              NORMAL_CMD   :  next_mode = NORMAL_M;
              
              SET_GREEN_CMD : time_entity.green_time  = ( cmd_data_i )
                                                      ? cmd_data_i : (WIDTH)'(1);
              SET_RED_CMD   : time_entity.red_time    = ( cmd_data_i )
                                                      ? cmd_data_i : (WIDTH)'(1);
              SET_YELLOW_CMD: time_entity.yellow_time = ( cmd_data_i )
                                                      ? cmd_data_i : (WIDTH)'(1);
                 
              default:        next_mode = NOTRANSITION_M;
            endcase
        end

      default:
        begin
          next_mode = IDLE_M;
        end
    endcase
  end

always_ff @( posedge clk_i )
  if( srst_i )   
    mode <= IDLE_M;
    else 
      mode <= next_mode;


// Switch states | BY COMMANDS + in NORMAL_M
always_comb
  begin
    next_state = state;

    case( mode )
      IDLE_M:
        begin
          if( cmd_valid_i )
            case ( cmd_type_i )
              NORMAL_CMD      : next_state = RED_S;
              NOTRANSITION_CMD: next_state = YELLOW_BLINK_S;
              default:
                begin
                  
                end
            endcase
        end
    
      NORMAL_M:
        begin
          if( cmd_valid_i )
            case ( cmd_type_i )
              NOTRANSITION_CMD: next_state = YELLOW_BLINK_S;
              default: 
                begin
                  
                end
            endcase

          case ( state )
            RED_S:
                if ( counter_width == time_entity.red_time - 1 )
                  next_state = RED_YELLOW_S;

            RED_YELLOW_S:
                if ( counter_red_yellow == RED_YELLOW_MS - 1 )
                  next_state = GREEN_S;
            
            GREEN_S:
                if ( counter_width == time_entity.green_time - 1 )
                  next_state = GREEN_BLINK_S;
            
            GREEN_BLINK_S:
                if ( counter_tick == BLINK_GREEN_TIME_TICK - 1 && half_for_tick && counter_half_period )
                  next_state = YELLOW_S;
            
            YELLOW_S:
                if ( counter_width == time_entity.yellow_time - 1 )
                  next_state = RED_S;
              
            default: 
                next_state = RED_S;
          endcase

        end
  
      NOTRANSITION_M:
        begin
          if( cmd_valid_i )
            case ( cmd_type_i )
              NORMAL_CMD: next_state = RED_S;
              default:
                begin
                  
                end
            endcase
        end
    endcase
  end

always_ff @( posedge clk_i )
  state <= next_state;


// Switch lights by states
always_ff @ ( posedge clk_i )
  begin
    if ( srst_i )
      begin
        red_o    <= 1'b0;
        green_o  <= 1'b0;
        yellow_o <= 1'b0;
      end
      else
        if ( next_mode != IDLE_M )
          begin
            if ( mode != NOTRANSITION_M && next_mode == NOTRANSITION_M )
              begin
                red_o    <= 1'b0;
                green_o  <= 1'b0;
                yellow_o <= 1'b1;
              end
              
            case( next_state )
            RED_S:
              begin
                red_o    <= 1'b1;
                green_o  <= 1'b0;
                yellow_o <= 1'b0;
              end
          
            RED_YELLOW_S:
              begin
                red_o    <= 1'b1;
                green_o  <= 1'b0;
                yellow_o <= 1'b1;
              end
        
            GREEN_S:
              begin
                red_o    <= 1'b0;
                green_o  <= 1'b1;
                yellow_o <= 1'b0;
              end
            
            GREEN_BLINK_S:             // On the 1st clk_i is already green 
              begin
                red_o    <= 1'b0;
                if ( counter_half_period == BLINK_HALF_PERIOD_MS - 1 ) green_o <= ~green_o; // лишний такт горит
                yellow_o <= 1'b0;
              end
      
            YELLOW_S:
              begin
                red_o    <= 1'b0;
                green_o  <= 1'b0;
                yellow_o <= 1'b1;
              end
            
            YELLOW_BLINK_S: 
              begin
                red_o    <= 1'b0;
                green_o  <= 1'b0;
                if ( counter_half_period == BLINK_HALF_PERIOD_MS - 1 ) yellow_o <= ~yellow_o;
              end
            default:
              begin
                red_o    <= 1'b0;
                green_o  <= 1'b0;
                yellow_o <= 1'b0;
              end
          endcase
          end
        else
          begin
            red_o    <= 1'b0;
            green_o  <= 1'b0;
            yellow_o <= 1'b0;
          end
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      counter_tick <= 1'b0;
      else
        if ( next_mode == NORMAL_M && mode != NORMAL_M )
          counter_tick <= 1'b0;
      else
        if ( counter_tick == BLINK_GREEN_TIME_TICK - 1 && half_for_tick && counter_half_period )
          counter_tick <= 1'b0;
      else 
        if ( mode == NORMAL_M && counter_half_period == BLINK_HALF_PERIOD_MS - 1 && half_for_tick && state == GREEN_BLINK_S )
          counter_tick <= counter_tick + (COUNT_TICK_SIZE)'(1);
      else 
        if ( mode == NOTRANSITION_M && counter_half_period == BLINK_HALF_PERIOD_MS - 1 && half_for_tick && state == YELLOW_BLINK_S )
          counter_tick <= counter_tick + (COUNT_TICK_SIZE)'(1);
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      half_for_tick <= 1'b0;
      else
        if ( next_state == GREEN_BLINK_S && state != GREEN_BLINK_S )
          half_for_tick <= 1'b0;
      else
        if ( counter_half_period == BLINK_HALF_PERIOD_MS - 1 )
          half_for_tick <= ~half_for_tick;
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      counter_half_period <= 1'b0;
      else
        if ( ( next_mode == NORMAL_M  && mode != NORMAL_M ) || ( next_mode == NOTRANSITION_M && mode != NOTRANSITION_M ) )
          counter_half_period <= 1'b0;
      else
        if ( counter_half_period == BLINK_HALF_PERIOD_MS - 1 )
          counter_half_period <= 1'b0;
      else 
        if ( mode == NOTRANSITION_M && state == YELLOW_BLINK_S )
          counter_half_period <= counter_half_period + (COUNT_HALF_PERIOD_SIZE)'(1);
      else 
        if ( mode == NORMAL_M && state == GREEN_BLINK_S )
          counter_half_period <= counter_half_period + (COUNT_HALF_PERIOD_SIZE)'(1);
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      counter_red_yellow <= 1'b0;
      else  
        if ( next_state == RED_YELLOW_S && state != RED_YELLOW_S )
          counter_red_yellow <= 1'b0;
      else
        if ( counter_red_yellow == RED_YELLOW_MS - 1 )
          counter_red_yellow <= 1'b0;
      else 
        if ( mode == NORMAL_M && state == RED_YELLOW_S )
          counter_red_yellow <= counter_red_yellow + (COUNT_RED_YELLOW_SIZE)'(1);
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      counter_width <= 1'b0;
      else  
        if ( ( next_state == RED_S && state != RED_S ) || ( next_state == GREEN_S  && state != GREEN_S ) || ( next_state == YELLOW_S  && state != YELLOW_S ) )
          counter_width <= 1'b0;
      else
        if ( state == RED_S && counter_width == time_entity.red_time - 1 )
          counter_width <= 1'b0;
      else
        if ( state == GREEN_S && counter_width == time_entity.green_time - 1 )
          counter_width <= 1'b0;
      else
        if ( state == YELLOW_S && counter_width == time_entity.yellow_time - 1 )
          counter_width <= 1'b0;
      else 
        if ( mode == NORMAL_M && ( state == RED_S || state == GREEN_S || state == YELLOW_S ) )
          counter_width <= counter_width + (COUNT_WIDTH)'(1);
  end

endmodule