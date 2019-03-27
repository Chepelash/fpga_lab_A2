module serializer_tb;

parameter int CLK_T = 1000;
parameter int WIDTH = 16;

logic                     clk;
logic                     rst;

logic [WIDTH-1:0]         data_i;
logic [$clog2(WIDTH)-1:0] data_mod_i;
logic                     data_val_i;

logic                     ser_data_o;
logic                     ser_data_val_o;
logic                     busy_o;


bit   [WIDTH-1:0]         input_values[$];    
bit   [WIDTH-1:0]         output_values[$];
int                       cntr;

task automatic clk_gen;

  forever
    begin
      # ( CLK_T / 2 );
      clk <= ~clk;
    end
  
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


task automatic init_queue_values;

  for( int i = 3; i < 16; i++ )
    begin
      for( bit [15:0] j = 0; j < 2**i; j++ )
        begin
          input_values.push_back({<<{j}});
        end
    end
  output_values = input_values;
endtask


task automatic checking_output;

  bit [15:0] cur_value;
  @( posedge ser_data_val_o );
  for( int i = 3; i < 16; i++ )
    begin
      for( int j = 0; i < 2**i; j++ )
        begin
          cur_value = output_values.pop_front();
          $display("checking_output : cur_value = %16b", cur_value);
          for( int k = 15; k > ( 15 - i ); k-- )
            begin
              $display("checking_output : cur_value[k] %b; ser_data_o %b", 
                        cur_value[k], ser_data_o);
              if( cur_value[k] == ser_data_o )
                begin
                  $display("ok");
                end
              else
                begin
                  $display("fail");
                  $stop();
                end
              
              @( negedge clk );
            end
          @( posedge ser_data_val_o );
          @( negedge clk );
        end        
    end 

endtask


task automatic send_values;

  bit [15:0] cur_value;
  for( int i = 3; i < 16; i++ )
    begin
      for( int j = 0; j < 2**i; j++ )
        begin
          cur_value   = input_values.pop_front();
          $display("send_values : cur_value = %16b", cur_value);
          data_i     <= cur_value;
          data_mod_i <= i;
          apply_valid_input();
          data_i     <= '0;
          data_mod_i <= '0;
          @( negedge busy_o );
          @( posedge clk );
        end
    end

endtask



serializer       #(
  .WIDTH          ( WIDTH          )
) serializer_1    (
  .clk_i          ( clk            ),
  .srst_i         ( rst            ),
  
  .data_i         ( data_i         ),
  .data_mod_i     ( data_mod_i     ),
  .data_val_i     ( data_val_i     ),
  
  .ser_data_o     ( ser_data_o     ),
  .ser_data_val_o ( ser_data_val_o ),
  .busy_o         ( busy_o         )
);


//always
//  begin
//    clk_gen();    
//  end
//  
initial
  begin
    init_queue_values();
    
    clk <= 0;
    rst <= 0;
    
    fork
      clk_gen();
    join_none
    
    $display("Starting!\n");
    
    apply_rst();
    $display("Testing inputs and outputs!");
    $display("--------------------------------");
    
    fork 
      checking_output();
    join_none
    
    fork
      send_values();
    join
    
    
    
//    for( int i = 0; i < 2; i++ )
//      begin
//        for( int j = 0; j < 4; j++ )
//          begin
//            data_i      <= input_values[i];
//            data_mod_i  <= input_mods[j];
//            output_value = 'b0;
//            apply_valid_input();
//            for( int k = 0; k < input_mods[j]; k++ )
//              begin                
//                output_value[k] = ser_data_o;
//                @( posedge clk );
//              end
//            if( output_value == expected_values[cntr] )
//              begin
//                $display("OK! Expected value = %8b; ouput value = %8b;", 
//                         expected_values[cntr], output_value);
//              end
//            else
//              begin
//                $display("Fail! Expected value = %8b; ouput value = %8b;", 
//                         expected_values[cntr], output_value);
//                $stop();
//              end 
//            cntr++;   
//          end
//      end
    
    $display("\nEveryting is fine!");
    $stop();
    
  end


endmodule
