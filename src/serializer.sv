module serializer #(
  parameter WIDTH = 16
)(
  input                            clk_i,
  input                            srst_i,
  
  input        [WIDTH-1:0]         data_i,
  input        [$clog2(WIDTH)-1:0] data_mod_i,
  input                            data_val_i,
  
  output logic                     ser_data_o,
  output logic                     ser_data_val_o,
  output logic                     busy_o
);


logic wrk_en;
logic data_mod_valid;

always_comb
  begin
    data_mod_valid = ( data_mod_i > 2 ) ? 1'b1 : 1'b0;
    wrk_en         = data_val_i && data_mod_valid;
  end  


logic [WIDTH-1:0]          input_data;
logic [$clog2(WIDTH)-1:0]  input_data_mod;
logic [$clog2(WIDTH)-1:0]  cntr;


always_ff @( posedge clk_i )
  begin
    if ( wrk_en )
      begin
        input_data     <= data_i;
        input_data_mod <= ( WIDTH - 1'b1 ) - data_mod_i;
      end
  end


always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin
        busy_o         <= '0;
        ser_data_val_o <= '0;
        ser_data_o     <= '0;
      end
    else if( busy_o )
      begin
        cntr       <= cntr- 1'b1;
        ser_data_o <= input_data[cntr];        
        if( cntr == input_data_mod )
          begin
            busy_o         <= 1'b0;
            ser_data_val_o <= 1'b0;
          end
      end
    else if( wrk_en )
      begin        
        cntr           <= WIDTH - 2'd2;
        ser_data_o     <= data_i[WIDTH-1'b1];
        busy_o         <= '1;
        ser_data_val_o <= '1;
      end
  end


endmodule


