/*-------------------------------------------------------------------*/
/*                                                                   */
/* Table NTP-Logging                                                 */
/*                                                                   */
/*----------------*                                                  */
/* R.Ross 05.2025 *                                                  */
/*-------------------------------------------------------------------*/

   create or replace table NTPLOG00 (
    Id             int           generated always as identity,
    Date           timestamp     not null default '0001-01-01',
    User           char(10)      not null default,
    Program        char(10)      not null default,
    Type           smallint      not null default,
    Runtime        dec(9, 3)     not null default,
    Message        char(256)     not null default
   );

/*-------------------------------------------------------------------*/
/* Column Label                                                      */
/*-------------------------------------------------------------------*/

   Label on Column NTPLOG00 (
    Id             is 'Id',
    Date           is 'Date',
    User           is 'User',
    Program        is 'Program',
    Type           is 'Type',
    Runtime        is 'Runtime',
    Message        is 'Message'
   );

/*-------------------------------------------------------------------*/
/* Text Label                                                        */
/*-------------------------------------------------------------------*/

   Label on Column NTPLOG00 (
    Id             text is 'Id',
    Date           text is 'Date',
    User           text is 'User',
    Program        text is 'Program',
    Type           text is 'Type',
    Runtime        text is 'Runtime',
    Message        text is 'Message'
   );

/*-------------------------------------------------------------------*/
/* Label                                                             */
/*-------------------------------------------------------------------*/

   Label on Table NTPLOG00 is 'Table NTP-Logging';

/*-------------------------------------------------------------------*/ 
