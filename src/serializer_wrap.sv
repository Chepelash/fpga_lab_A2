module serializer_wrap (
  input               clk_i,
  input               srst_i,
  
  input        [15:0] data_i,
  input        [3:0]  data_mod_i,
  input               data_val_i,
  
  output logic        ser_data_o,
  output logic        ser_data_val_o,
  output logic        busy_o
);

logic        srst_i_wrap;

logic [15:0] data_i_wrap;
logic [3:0]  data_mod_i_wrap;
logic        data_val_i_wrap;

logic        ser_data_o_wrap;
logic        ser_data_val_o_wrap;
logic        busy_o_wrap;

serializer 
  serializer_1    (
  .clk_i          ( clk_i               ),
  .srst_i         ( srst_i_wrap         ),
  
  .data_i         ( data_i_wrap         ),
  .data_mod_i     ( data_mod_i_wrap     ),
  .data_val_i     ( data_val_i_wrap     ),
  
  .ser_data_o     ( ser_data_o_wrap     ),
  .ser_data_val_o ( ser_data_val_o_wrap ),
  .busy_o         ( busy_o_wrap         )
);

always_ff @( posedge clk_i )
  begin
    srst_i_wrap <= srst_i;
    
    data_i_wrap     <= data_i;
    data_mod_i_wrap <= data_mod_i;
    data_val_i_wrap <= data_val_i;
    
    ser_data_o     <= ser_data_o_wrap;
    ser_data_val_o <= ser_data_val_o_wrap;
    busy_o         <= busy_o_wrap;
  end


endmodule
