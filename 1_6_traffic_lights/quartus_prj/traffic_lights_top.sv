localparam WIDTH_TOP      = 16;

localparam BLINK_HALF_PERIOD_MS  = 2;
localparam BLINK_GREEN_TIME_TICK = 5;
localparam RED_YELLOW_MS         = 10;

localparam COUNT_TICK_SIZE        = $clog2(BLINK_GREEN_TIME_TICK);
localparam COUNT_HALF_PERIOD_SIZE = $clog2(BLINK_HALF_PERIOD_MS);
localparam COUNT_RED_YELLOW_SIZE  = $clog2(RED_YELLOW_MS);
localparam COUNT_WIDTH            = $clog2(WIDTH_TOP);

module traffic_lights_top (
  input  logic                   clk_i,          // Clock signal
  input  logic                   srst_i,         // Syncronous reset
	   
  input  logic [2:0]             cmd_type_i,     // Type of command
  input  logic                   cmd_valid_i,    // Confirmation of command
  input  logic [WIDTH_TOP-1:0]   cmd_data_i,     // Input data for command

  output logic                   red_o,          // Red light as output
  output logic                   yellow_o,       // Yellow light as output
  output logic                   green_o         // Green light as output
);

logic                   srst;            // Syncronous reset
	   
logic [2:0]             cmd_type_in;     // Type of command
logic                   cmd_valid_in;    // Confirmation of command
logic [WIDTH_TOP-1:0]   cmd_data_in;     // Input data for command

logic                   red;             // Red light as output
logic                   yellow;          // Yellow light as output
logic                   green;           // Green light as output

always_ff @( posedge clk_i )
  begin
    srst         <= srst_i;
    cmd_type_in  <= cmd_type_i;
    cmd_valid_in <= cmd_valid_i;
    cmd_data_in  <= cmd_data_i;
  end

traffic_lights #(
  .BLINK_HALF_PERIOD_MS       ( BLINK_HALF_PERIOD_MS   ),
  .BLINK_GREEN_TIME_TICK      ( BLINK_GREEN_TIME_TICK  ),
  .RED_YELLOW_MS              ( RED_YELLOW_MS          )
) dut (
  .clk_i               ( clk_i             ),
  .srst_i              ( srst              ),
 
  .cmd_type_i          ( cmd_type_in       ),
  .cmd_valid_i         ( cmd_valid_in      ),
  .cmd_data_i          ( cmd_data_in       ),

  .red_o               ( red               ),
  .yellow_o            ( yellow            ),
  .green_o             ( green             )
);

always_ff @( posedge clk_i )
  begin
    red_o        <= red;
    yellow_o     <= yellow;
    green_o      <= green;
  end

endmodule
