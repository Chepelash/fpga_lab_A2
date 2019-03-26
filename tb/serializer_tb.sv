module serializer_tb;

parameter int CLK_T = 1000;

logic        clk;
logic        rst;

logic [15:0] data_i;
logic [3:0]  data_mod_i;
logic        data_val_i;

logic        ser_data_o;
logic        ser_data_val_o;
logic        busy_o;


bit [15:0] input_values[$];    
bit [3:0]  input_mods[$];      
bit [7:0]  expected_values[$]; 
bit [7:0]  output_value;
int        cntr;

task automatic clk_gen;

  # ( CLK_T / 2 );
  clk <= ~clk;
  
endtask


task automatic apply_rst;
  
  rst <= 1'b1;
  @( posedge clk );
  rst <= 1'b0;
  @( posedge clk );

endtask


task automatic apply_valid_input;

  data_val_i <= 1'b1;
  @( posedge clk );
  data_val_i <= 1'b0;
  @( posedge clk );

endtask



task automatic wait_for_data;
  @( negedge busy_o );
  
endtask

serializer 
  serializer_1    (
  .clk_i          ( clk            ),
  .srst_i         ( rst            ),
  
  .data_i         ( data_i         ),
  .data_mod_i     ( data_mod_i     ),
  .data_val_i     ( data_val_i     ),
  
  .ser_data_o     ( ser_data_o     ),
  .ser_data_val_o ( ser_data_val_o ),
  .busy_o         ( busy_o         )
);


always
  begin
    clk_gen();    
  end
  
initial
  begin
    input_values    = {'b1011_1000_0000_0000, 'b0101_1011_1000_0010};
    input_mods      = {3, 4, 5, 6};
    expected_values = {'b101, 'b1101, 'b11101, 'b011101,    
                       'b010, 'b1010, 'b11010, 'b011010 };
    clk <= 0;
    rst <= 0;
    
    $display("Starting!\n");
    
    apply_rst();
    $display("Testing inputs and outputs!");
    $display("--------------------------------");
    for( int i = 0; i < 2; i++ )
      begin
        for( int j = 0; j < 4; j++ )
          begin
            data_i      <= input_values[i];
            data_mod_i  <= input_mods[j];
            output_value = 'b0;
            apply_valid_input();
            for( int k = 0; k < input_mods[j]; k++ )
              begin                
                output_value[k] = ser_data_o;
                @( posedge clk );
              end
            if( output_value == expected_values[cntr++] )
              begin
                $display("OK! Expected value = %8b; ouput value = %8b;", 
                         expected_values[cntr], output_value);
              end
            else
              begin
                $display("Fail! Expected value = %8b; ouput value = %8b;", 
                         expected_values[cntr], output_value);
                $stop();
              end  
          end
      end
    
    $display("\nEveryting is fine!");
    $stop();
    
  end


endmodule
