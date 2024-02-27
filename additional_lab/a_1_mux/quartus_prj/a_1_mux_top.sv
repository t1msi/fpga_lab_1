localparam WIDTH      = 4;
localparam COUNT_SIZE = $clog2(WIDTH);

module a_1_mux_top (
  input  logic                     clk_i,            // Clock signal
	  
  input  logic [COUNT_SIZE-1:0]    data0_i,          // Input data
  input  logic [COUNT_SIZE-1:0]    data1_i,          // Input data
  input  logic [COUNT_SIZE-1:0]    data2_i,          // Input data
  input  logic [COUNT_SIZE-1:0]    data3_i,          // Input data
  input  logic [1:0]               direction_i,      // Select channel
  
  output logic [COUNT_SIZE-1:0]    data_o            // Output data
);

logic [COUNT_SIZE-1:0]    data0;          // Input data
logic [COUNT_SIZE-1:0]    data1;          // Input data
logic [COUNT_SIZE-1:0]    data2;          // Input data
logic [COUNT_SIZE-1:0]    data3;          // Input data
logic [1:0]               direction;      // Select channel

logic [COUNT_SIZE-1:0]    data_out;

always_ff @( posedge clk_i )
  begin
    data0        <= data0_i;
    data1        <= data1_i;
    data2        <= data2_i;
    data3        <= data3_i;
    direction    <= direction_i;
  end

mux dut (
  .data0_i             ( data0             ),
  .data1_i             ( data1             ),
  .data2_i             ( data2             ),
  .data3_i             ( data3             ),
  .direction_i         ( direction         ),

  .data_o              ( data_out          )
);

always_ff @( posedge clk_i )
  begin
    data_o        <= data_out;
  end

endmodule
