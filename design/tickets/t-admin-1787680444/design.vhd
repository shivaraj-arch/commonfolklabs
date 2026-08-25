 entity synchronizer is
    port (
        clock: in BIT;
        start: in BIT;
        full: in BIT;
        empty: in BIT;
        reset: in BIT;
        hot: out BIT;
        cold: out BIT;
        drain: out BIT;
        turn: out BIT
    );
end synchronizer;

architecture synchronizer_arch of synchronizer is
 
component loadcount is
    port(ck,I1,I2,rs,dec:in bit;
         zr:out bit);
end component;
              
component wtff is
    port(t,c,r,p:in bit;
         q:out bit);
end component;             
 
component pulsegen is
    port(ck,a:in bit;
         b:out bit);
end component;

        signal chk,stop,res,rese:bit;
        signal cn,ln:bit;
        signal lo,h,sig,de,zero,rr:bit;
        signal load:bit_vector(1 downto 0);

 begin
 
     lo<='0';
     h<='1';    
     rese <= res or reset or stop;
     cn <= clock;
     
     synccall1:pulsegen
               port map(cn,zero,res);
     synccall2:loadcount
     	       port map(cn,load(0),load(1),reset,de,zero);  --second to execute;(de=obtained
     synccall3:wtff					    --from case 00 after first turn)	
               port map(h,res,lo,lo,load(0));
               
            ln<=not load(0);
               	                     
     synccall4:wtff
               port map(h,ln,lo,lo,load(1));
               
     process(rese,h,lo,start,full,empty,zero,load)
                  
      begin
      
          if(rese=lo) then
            if(start=h) then
              if(clock'event and clock='1') then
               
               case(load) is
               
               when "00"=>
                          if(full=lo) then
                            hot<=h;				--first to execute
                            cold<=lo;
                            drain<=lo;
                            turn<=lo;
                          else
                            hot<=lo;
                            turn<=h;
                            de<=h;
                          end if;
               when "01"=>
                          if(empty=lo) then
                            turn<=lo;
                            hot<=lo;
                            cold<=lo;
                            drain<=h;
                          else
                            drain<=lo;
                            de<=h;
                            turn<=h;
                          end if;
               when "10"=>  
                          if(full=lo) then
                            cold<=h;
                            hot<=lo;
                            drain<=lo;
                            turn<=lo;
                          else
                            cold<=lo;
                            turn<=h;
                            de<=h;
                          end if;
               when "11"=>
                          if(empty=lo) then
                            turn<=lo;
                            hot<=lo;
                            cold<=lo;
                            drain<=h;
                          else
                            drain<=lo;
                            de<=h;
                            turn<=h;
                          end if;
               when others=>
                            null;
                            
               end case;
                            
              end if;
            end if;
          else
                                   
            hot<=lo;
            cold<=lo;
            drain<=lo;
            turn<=lo;
            de<=lo;                             		   
            
            if(load(0)='1' and load(1)='1') then
              if(empty='1') then
                stop<='1';
              end if;
            end if;
                         
	  end if;
	  
     end process;      	
   end synchronizer_arch;
