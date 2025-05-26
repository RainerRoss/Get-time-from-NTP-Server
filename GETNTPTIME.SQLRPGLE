         ctl-opt main(main) dftactgrp(*no);
      //------------------------------------------------------------------//
      //                                                                  //
      // Test - Get Time from NTP-Server ptbtime1.ptb.de                  //
      //                                                                  //
      //-----------------                                                 //
      // R.Ross 05.2025 *                                                 //
      //------------------------------------------------------------------//
      // SQL-Options                                                      //
      //------------------------------------------------------------------//

         exec sql set option datfmt=*iso,    timfmt=*iso, commit=*none,
                             decmpt=*period, closqlcsr=*endactgrp;

      //------------------------------------------------------------------//
      // Internet Address                                                 //
      //------------------------------------------------------------------//

         dcl-pr inet_addr         uns(10) extproc(*dclcase);
                 String           pointer value options(*string);
         end-pr;

      //------------------------------------------------------------------//
      // GetHostbyName                                                    //
      //------------------------------------------------------------------//

         dcl-pr gethostbyname  pointer extproc(*dclcase);
                 host          pointer value options(*string);
         end-pr;

      //------------------------------------------------------------------//
      // Transform Internet Address to a dottet decimal Format            //
      //------------------------------------------------------------------//

         dcl-pr transform    pointer extproc('inet_ntoa');
                 address     uns(10) value;
         end-pr;

      //------------------------------------------------------------------//
      // Socket                                                           //
      //------------------------------------------------------------------//

         dcl-pr socket       int(10) extproc(*dclcase);
                 Address     int(10) value;
                 Type        int(10) value;
                 Protocol    int(10) value;
         end-pr;

      //------------------------------------------------------------------//
      // Connect - Establish Socket Connection                            //
      //------------------------------------------------------------------//

         dcl-pr connect      int(10) extproc(*dclcase);
                 Descriptor  int(10) value;
                 Address     pointer value;
                 AddressLen  int(10) value;
         end-pr;

      //------------------------------------------------------------------//
      // Send Data to Socket                                              //
      //------------------------------------------------------------------//

         dcl-pr send         int(10) extproc(*dclcase);
                 Descriptor  int(10) value;
                 Buffer      pointer value;
                 BufferLen   int(10) value;
                 Flags       int(10) value;
         end-pr;

      //------------------------------------------------------------------//
      // Receive Data from Socket                                         //
      //------------------------------------------------------------------//

         dcl-pr recv         int(10) extproc(*dclcase);
                 Descriptor  int(10) value;
                 Buffer      pointer value;
                 BufferLen   int(10) value;
                 Flags       int(10) value;
         end-pr;

      //------------------------------------------------------------------//
      // Close Socket                                                     //
      //------------------------------------------------------------------//

         dcl-pr close        int(10) extproc(*dclcase);
                 Descriptor  int(10) value;
         end-pr;

      //------------------------------------------------------------------//
      // Array - HostEntry                                                //
      //------------------------------------------------------------------//

         dcl-s   GblHost_p   pointer;

         dcl-ds  DsHost      based(GblHost_p);
                  Name       pointer;
                  Alias      pointer;
                  Addrtyp    int(10);
                  Length     int(10);
                  Addrlist   pointer;
         end-ds;

         dcl-s   Addr_p      pointer based(Addrlist);
         dcl-s   HostAddr    uns(10) based(Addr_p);

      //------------------------------------------------------------------//
      // Array - Socket                                                   //
      //------------------------------------------------------------------//

         dcl-s   Sockadd_p   pointer;

         dcl-ds  DsSockAdd   qualified based(SockAdd_p);
                  Family     int(05);
                  Data       char(14);
         end-ds;

         dcl-ds  DsSockAddin qualified based(SockAdd_p);
                  Family     int(05);
                  Port       uns(05);
                  Addr       uns(10);
                  Zero       char(08);
         end-ds;

      //------------------------------------------------------------------//
      // Convert Character to Hex                                         //
      //------------------------------------------------------------------//

         dcl-pr cvthc        extproc(*dclcase);
                 char        pointer value;
                 hex         pointer value;
                 length      uns(10) value;
         end-pr;

      //------------------------------------------------------------------//
      // Convert Hex to Character                                         //
      //------------------------------------------------------------------//

         dcl-pr cvtch        extproc(*dclcase);
                 hex         pointer value;
                 char        pointer value;
                 length      uns(10) value;
         end-pr;

      //------------------------------------------------------------------//
      // Get UTC-Time                                                     //
      //------------------------------------------------------------------//

         dcl-pr CEEUTCO      extproc(*dclcase);
                 Hours       like(UTCHours)    const;
                 Minutes     like(UTCMinutes)  const;
                 Seconds     like(UTCSeconds)  const;
                 Feedback    char(12)          options(*omit);
         end-pr;

         dcl-s   UTCHours    int(10);
         dcl-s   UTCMinutes  int(10);
         dcl-s   UTCSeconds  float(08);

      //------------------------------------------------------------------//
      // Retrieve string from SYSVAL QDATETIME                            //
      //------------------------------------------------------------------//

         dcl-pr RTVSYSTIME   extpgm;
                 String      char(20);
         end-pr;

      //------------------------------------------------------------------//
      // Array Programm Status                                            //
      //------------------------------------------------------------------//

         dcl-ds DsPgms       psds qualified;
                 Program     *proc;
                 Job         char(10)  pos(244);
                 User        char(10)  pos(254);
                 Nbr         zoned(06) pos(264);
         end-ds;

      //------------------------------------------------------------------//
      // Array Data                                                       //
      //------------------------------------------------------------------//

         dcl-ds  DsData      qualified inz;
                  Host       char(40);
                  Port       uns(10);
                  IP         uns(10);
                  IPChar     char(15);
                  NTPTime    timestamp;
                  SYSTime    timestamp;
         end-ds;

      //------------------------------------------------------------------//
      // Constants                                                        //
      //------------------------------------------------------------------//

         dcl-c   INADDR_NONE 4294967295;              // Result -> inet_addr
         dcl-c   AF_INET     2;                       // Address Family
         dcl-c   SOCK_STREAM 1;                       // TCP Protocol
         dcl-c   SOCK_DGRAM  2;                       // UDP Protocol
         dcl-c   PROTOCOL    0;

      //------------------------------------------------------------------//
      // Variables                                                        //
      //------------------------------------------------------------------//

         dcl-s   GblTime     timestamp;               // Timestamp
         dcl-s   GblHex      char(96);                // Hex string

      //------------------------------------------------------------------//
      // Main                                                             //
      //------------------------------------------------------------------//
         dcl-proc main;

         dcl-s   LocDays     int(10);
         dcl-s   LocHours    int(10);
         dcl-s   LocMinutes  int(10);
         dcl-s   LocSeconds  int(10);
         dcl-s   LocMicrosec int(10);

           clear DsData;

           DsData.Host = 'ptbtime1.ptb.de';           // NTP Server Germany
           DsData.Port = 123;                         // NTP Port 123

           if get_time_from_ntp_server(DsData) = *on; // *on=error/*off=ok
              return;
           endif;

           LocDays     = %diff(DsData.SYSTime:DsData.NTPTime:*days);
           LocHours    = %diff(DsData.SYSTime:DsData.NTPTime:*hours);
           LocMinutes  = %diff(DsData.SYSTime:DsData.NTPTime:*minutes);
           LocSeconds  = %diff(DsData.SYSTime:DsData.NTPTime:*seconds);
           LocMicrosec = %diff(DsData.SYSTime:DsData.NTPTime:*mseconds);

           dsply ('SYS  Time........: ' + %char(DsData.SYSTIME));
           dsply ('NTP  Time........: ' + %char(DsData.NTPTIME));
           dsply ('Diff Days........: ' + %char(LocDays));
           dsply ('Diff Hours.......: ' + %char(LocHours));
           dsply ('Diff Minutes.....: ' + %char(LocMinutes));
           dsply ('Diff Seconds.....: ' + %char(LocSeconds));
           dsply ('Diff Microseconds: ' + %char(LocMicrosec));

         end-proc;
      //------------------------------------------------------------------//
      // get time from NTP server                                         //
      //------------------------------------------------------------------//
         dcl-proc get_time_from_ntp_server;
         dcl-pi *n           ind;
                 PiData      likeds(DsData);
         end-pi;

         dcl-s   LocMessage  char(48) inz(*allx'00');
         dcl-s   LocResult   char(48);                // Data
         dcl-s   LocHex      like(GblHex);            // Hex string

         dcl-s   LocSocket   int(10);                 // Socket
         dcl-s   LocCd       int(10);                 // Connection Descriptor
         dcl-s   LocConn_p   pointer;                 // Connection Pointer
         dcl-s   LocAddrlen  int(10);                 // Address Length
         dcl-s   LocRi       uns(10);                 // Return Inet
         dcl-s   LocRc       int(10);                 // Return Code
         dcl-s   LocBytes    int(10);                 // Bytes

           GblTime = %timestamp();

           ceeutco(UTCHours:UTCMinutes:UTCSeconds:*omit);  // get GMT time

           %subst(LocMessage:1:1) = x'1B';

           writelog(GblTime:0:'Start communication');

      // check Internet Address

           LocRi = inet_addr(%trim(PiData.Host));

           if LocRi <> INADDR_NONE;
              writelog(GblTime:2:'inet_addr() failed: ' + %trim(DsData.Host));
              return *on;
            else;
              writeLog(GblTime:0:'inet_addr() successful');
           endif;

      // check Internet Host and get Host IP

           GblHost_p = gethostbyname(%trim(PiData.Host));

           if GblHost_p = *null;
              writelog(GblTime:2:
                      'gethostbyname() failed: ' + %trim(DsData.Host));
              return *on;
            else;
              writeLog(GblTime:0:'gethostbyname() successful');
           endif;

           PiData.IP     = HostAddr;                    // Host IP
           PiData.IPChar = %str(transform(PiData.IP));  // IP to String

           LocSocket = socket(AF_INET:SOCK_DGRAM:PROTOCOL);

      // establish Connection

           LocAddrlen = %size(DsSockAdd);
           LocConn_p  = %alloc(LocAddrlen);

           Sockadd_p  = LocConn_p;

           DsSockAddin.Family = Af_Inet;
           DsSockAddin.Addr   = PiData.IP;
           DsSockAddin.Port   = PiData.Port;
           DsSockAddin.Zero   = *allx'00';

           LocCd = connect(LocSocket:%addr(DsSockAddin):%size(DsSockAddin));

           if LocSocket = -1;
              writeLog(GblTime:2:'socket open() failed -> ' + %char(LocCd));
              return *on;
            else;
              writeLog(GblTime:0:'socket open() successful');
           endif;

           dealloc(n) LocConn_p;

      // send Message to Socket

           LocCd = send(LocSocket:%addr(LocMessage):%size(LocMessage):0);

           if LocCd = -1;
              writeLog(GblTime:2:'socket send() failed - message: ' +
                       LocMessage);
              return *on;
            else;
              writeLog(GblTime:0:'socket send() successful');
           endif;

      // receive Message from Socket

           LocBytes = recv(LocSocket:%addr(LocResult):%size(LocResult):0);

           if LocBytes <= 0;
              writeLog(GblTime:2:'socket recv() failed');
              return *on;
            else;
              cvthc(%addr(LocHex):%addr(LocResult):96); // convert message to hex
              convert_hex_to_timestamp(LocHex);         // convert hex to timestamp
              DsData.SYSTime = %timestamp();            // get time from IBM i

              writeLog(GblTime:0:'socket recv() successful -> message: ' +
                       LocHex);
           endif;

       // Close Socket

           LocRc = close(LocSocket);

           if LocCd = -1;
              writeLog(GblTime:2:'socket close() failed');
              return *on;
            else;
              writeLog(GblTime:0:'socket close() successful');
           endif;

           return *off;

         end-proc;
      //------------------------------------------------------------------//
      // convert hex to timestamp                                         //
      //------------------------------------------------------------------//
         dcl-proc convert_hex_to_timestamp;
         dcl-pi *n;
                 PiHex       like(GblHex);
         end-pi;

         dcl-s   LocHexSec   char(08);                // hex seconds
         dcl-s   LocHexFract char(08);                // hex fraction
         dcl-s   LocSec      uns(10);                 // seconds
         dcl-s   LocMSec     uns(10);                 // microseconds
         dcl-s   LocFract    uns(10);                 // fraction
         dcl-s   LocDiv      uns(10) inz(*hival);     // divide

         dcl-s   LocStart    timestamp;
         dcl-s   LocTime     timestamp;

           LocStart    = %timestamp('1900-01-01-00.00.00.000000');

           LocHexSec   = %subst(PiHex:81:8);            // hex seconds
           LocHexFract = %subst(PiHex:89:8);            // hex fraction

           cvtch(%addr(LocSec):%addr(LocHexSec):8);     // hex to seconds
           cvtch(%addr(LocFract):%addr(LocHexFract):8); // hex to fraction

           LocMSec = LocFract * 1000000 / LocDiv;       // microseconds

           LocTime = LocStart + %seconds(LocSec) +
                     %seconds(%int(UTCSeconds))  + %mseconds(LocMSec);

           DsData.NTPTime = LocTime;                  // NTP Time

         end-proc;
      //------------------------------------------------------------------//
      // Write Log                                                        //
      //------------------------------------------------------------------//
         dcl-proc writeLog;
         dcl-pi *n;
                 PiTime      timestamp    const;
                 PiType      int(10)      const;      // 0=ok/1=Warning/2=Error
                 PiMessage   varchar(256) const;
         end-pi;

         dcl-s   LocRuntime  packed(9:3);

           LocRuntime = %diff(%timestamp():PiTime:*ms) / 1000000;

           exec sql
            insert into NTPLOG00 values(
             default, current_timestamp, current_user,
             :DsPgms.Program, :PiType, :LocRuntime, :PiMessage
            ) with nc;

         end-proc;
      //------------------------------------------------------------------// 
