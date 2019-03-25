module serializer(
  input               clk_i,
  input               srst_i,
  
  input        [15:0] data_i,
  input        [3:0]  data_mod_i,
  input               data_val_i,
  
  output logic        ser_data_o,
  output logic        ser_data_val_o,
  output logic        busy_o
);

logic [0:15] input_data;
logic [3:0]  input_data_mod;
logic        input_data_valid;
logic        ser_end;


always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      begin
        input_data       <= '0;
        input_data_mod   <= '0;
        input_data_valid <= '0;
        ser_end          <= '0;
        busy_o           <= '0;
      end
    else if ( data_val_i ) // init block
      begin
        input_data       <= data_i;
        input_data_mod   <= data_mod_i;        
        input_data_valid <= 1'b1;
      end
    else if ( ser_end ) // ending block
      begin
        input_data_valid <= 1'b0;
        busy_o           <= 1'b0;
        ser_data_val_o   <= 1'b0;
        ser_end          <= 1'b0;
      end
    else if ( input_data_valid && ( input_data_mod > 2 ) ) // work block
      begin        
        busy_o         <= 1'b1;
        ser_data_val_o <= 1'b1;
        for( int i = 0; i < input_data_mod; i++ )
          begin
            ser_data_o <= input_data[i];    
            
            if ( i == ( input_data_mod - 1 ) )
              begin
                ser_end <= 1'b1;
              end
          end
      end
    else // idle block
      begin
        busy_o         <= 1'b0;
        ser_data_val_o <= 1'b0;
      end
  end  

  
//always_comb
//  begin : always_comb_block
//    if ( input_data_mod < 3 )
//      begin
//        // do not work
//      end
//    else
//      begin : else_block
//        for( int i = 0; i < 16; i++ )
//          begin : for_block
//            
//          end : for_block
//      end : else_block 
//  end : always_comb_block

endmodule


