* LAB01
version 04 works however it has rule mismatched issues
also version 04 doesn't go past one lexeme

version 05 should be an updated version where 
unified identifier rule to match both keywords and normal identifiers 
UNFORTUNATELY< VER05 doesn't do the job>
errors: cc1plus.exe: fatal error: y.tab.c: No such file or directory

version 06 on the way: VOILA


    The problem is that our keyword rules are being placed after the general {id} rule, which matches any identifier. Since Flex uses the "longest match" rule and processes patterns in order, the {id} pattern will always match keywords before the specific keyword rules can be applied.


* LAB02 


```
rm -f y.tab.c y.tab.h y.output lex.yy.c a.out y.o l.o my_log.txt
``` 


 _____                         _  _  _    _                 _____                           _  _             
|  ___|                       | |(_)| |  (_)               /  __ \                         (_)| |            
| |__  __  __ _ __    ___   __| | _ | |_  _   ___   _ __   | /  \/  ___   _ __ ___   _ __   _ | |  ___  _ __ 
|  __| \ \/ /| '_ \  / _ \ / _` || || __|| | / _ \ | '_ \  | |     / _ \ | '_ ` _ \ | '_ \ | || | / _ \| '__|
| |___  >  < | |_) ||  __/| (_| || || |_ | || (_) || | | | | \__/\| (_) || | | | | || |_) || || ||  __/| |   
\____/ /_/\_\| .__/  \___| \__,_||_| \__||_| \___/ |_| |_|  \____/ \___/ |_| |_| |_|| .__/ |_||_| \___||_|   
             | |                                                                    | |                      
             |_|                                                                    |_|                      

        Expedition Compiler – For All Those Who Come After
                Created by TahmidRaven & MehediTorno


https://github.com/TahmidRaven/Expedition_Compiler 