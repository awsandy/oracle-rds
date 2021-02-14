/*
|| Output OBJECTs and TYPEs
*/
CREATE OR REPLACE TYPE integer_return_array
    IS
      VARRAY(25) OF INTEGER;
/
CREATE OR REPLACE PACKAGE pkg_tpce_transactions
/*
|| Package:         PKG_TPCE_TRANSACTIONS
|| Version:         1.0
|| Description:     Generates various complex transactions against an Oracle database
||                  containing the standard TPC-E schema for evaluation of advanced
||                  SQL tuning tools and strategies
|| Author:          Jim Czuprynski
|| Last Updated On: 2019-09-27 16:00 CDT
*/
IS
    FUNCTION QryBrokerVolume(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array;
    FUNCTION QryCustomerPosition(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array;
    FUNCTION QryMarketWatch(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array;
    FUNCTION QrySecurityDetail(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array;
    FUNCTION QryTradeLookup(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array;
    FUNCTION QryTradeStatus(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array;
    FUNCTION MntMarketFeed(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array;
    FUNCTION MntTradeOrder(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array;
    FUNCTION MntTradeResult(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array;
    FUNCTION MntTradeUpdate(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array;
    FUNCTION MntDataMaintenance(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array;
    FUNCTION MntTradeCleanup(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array;
END pkg_tpce_transactions;
/
