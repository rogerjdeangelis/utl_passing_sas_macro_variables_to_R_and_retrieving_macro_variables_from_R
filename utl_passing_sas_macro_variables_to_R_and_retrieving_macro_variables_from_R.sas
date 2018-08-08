Passing macro variables to R and retrieving macro variables from R

Macro utl_submit_r64 is on the end of this messsage

see github
https://tinyurl.com/y7fn6lhz
https://github.com/rogerjdeangelis/utl_passing_sas_macro_variables_to_R_and_retrieving_macro_variables_from_R

In the code below I pass macro variables to R and retrieve 'R' created sas macro
variables.

I compute the squares of SAS integers 1, 2 and 3 in R and convert R numerics to SAS macro variables.

  TWO SOLUTIONS

       1. Using a datastep
       2. Using a macro

see
https://tinyurl.com/y76us34t
https://stackoverflow.com/questions/51721473/how-to-pass-an-let-argument-into-a-sas-script-from-r

other repositories
https://github.com/rogerjdeangelis/utl_dosubl_subroutine_interfaces
or just search DOSUBL


INPUT
=====

  1. Using a macro

    %do num= 1 %to 3;

  2. Using a datastep

    do num=1,2,3;

OUTPUT
======

 MACRO VARIABLES

   %put &=sq;
   sq=  1
   sq=  4
   sq=  9


 DATASTEP VARIABLES

   put sq=;

   sq=  1
   sq=  4
   sq=  9


PROCESS
=======

 1. Using a datastep
 -------------------

  %symdel num sq / nowarn; * just in case;
  Data log;

    do num=1,2,3;

       call symputx("num",num);

       rc=dosubl('
          %utl_submit_r64("
             sq<-&num.^2.;
             sq;
             writeClipboard(as.character(sq));
       ",returnVar=sq)');

       sq=symget('sq');

       put sq=;

    end;

  run;quit;


 2. Using a Macro
 -------------------

  %macro sq(dummy);

    %local num;

    %do num=1 %to 3;

      %utl_submit_r64("
         sq<-&num.^2.;
         sq;
         writeClipboard(as.character(sq));
      ");

      %put &=sq;

    %end;

  %mend sq;

  %sq;


*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

 * dat ais internally generated

  Macro
    %do num= 1 %to 3;

  Datastep
    do num=1,2,3;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

see process

*      _   _               _               _ _             __   _  _
 _   _| |_| |    ___ _   _| |__  _ __ ___ (_) |_     _ __ / /_ | || |
| | | | __| |   / __| | | | '_ \| '_ ` _ \| | __|   | '__| '_ \| || |_
| |_| | |_| |   \__ \ |_| | |_) | | | | | | | |_    | |  | (_) |__   _|
 \__,_|\__|_|___|___/\__,_|_.__/|_| |_| |_|_|\__|___|_|   \___/   |_|
           |_____|                             |_____|
;
%macro utl_submit_r64(
      pgmx
     ,returnVar=N           /* set to Y if you want a return SAS macro variable from python */
     )/des="Semi colon separated set of R commands - drop down to R";
  * write the program to a temporary file;
  %utlfkil(d:/txt/r_pgm.txt);
  filename r_pgm "d:/txt/r_pgm.txt" lrecl=32766 recfm=v;
  data _null_;
    length pgm $32756;
    file r_pgm;
    pgm=&pgmx;
    put pgm;
    putlog pgm;
  run;
  %let __loc=%sysfunc(pathname(r_pgm));
  * pipe file through R;
  filename rut pipe "c:\Progra~1\R\R-3.3.2\bin\x64\R.exe --vanilla --quiet --no-save < &__loc";
  data _null_;
    file print;
    infile rut recfm=v lrecl=32756;
    input;
    put _infile_;
    putlog _infile_;
  run;
  filename rut clear;
  filename r_pgm clear;

  * use the clipboard to create macro variable;
  %if %upcase(%substr(&returnVar.,1,1)) ne N %then %do;
    filename clp clipbrd ;
    data _null_;
     length txt $200;
     infile clp;
     input;
     putlog "macro variable &returnVar = " _infile_;
     call symputx("&returnVar.",_infile_,"G");
    run;quit;
  %end;

%mend utl_submit_r64;


