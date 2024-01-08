module serializer (
  input bit           clk_i,       // Тактовый сигнал
  input bit           srst_i,      // Синхронный сброс
	
  input bit [15:0]    data_i,      // Входные данные
  input bit [3:0]     data_mod_i,  // Кол-во валидных бит
  input logic         data_val_i,  // Подтверждение валидности input
  
  output logic        ser_data_o,      // Сериализованные данные
  output logic        ser_data_val_o,  // Подтверждение валидности output
  output logic        busy_o           // Модуль занят
);

logic [3:0] mod_counter;
logic [3:0] data_mod_i_copy;

always_comb 
if      (data_mod_i == 4'b0000)                          data_mod_i_copy = 4'b1111;
else if (data_mod_i == 4'b0001 || data_mod_i == 4'b0010) data_mod_i_copy = 4'b0000;
else                                                     data_mod_i_copy = data_mod_i;


always_ff @( posedge clk_i )
  begin
    if ( srst_i || !data_val_i || mod_counter == data_mod_i_copy ) begin
	  mod_counter <= 1'b0;
	end else begin
	  mod_counter <= mod_counter + 1;
	end
  end

always_comb begin
  if ( srst_i || !data_val_i || mod_counter == data_mod_i_copy ) begin
      ser_data_o = 1'b0;
	  ser_data_val_o = 1'b0;
	  busy_o = 1'b0;
    end else begin
    ser_data_o = data_i[16 - mod_counter - 1];
    ser_data_val_o = 1'b1;
    busy_o = 1'b1;
  end
end

endmodule