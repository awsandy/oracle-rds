--
-- Create table statements
--
-- Generated by datagenerator. www.dominicgiles.com
--
--
-- Create statement for table CALL_CENTER
--
CREATE TABLE call_center (
    cc_call_center_sk   NUMBER NOT NULL,
    cc_call_center_id   CHAR(16) NOT NULL,
    cc_rec_start_date   DATE,
    cc_rec_end_date     DATE,
    cc_closed_date_sk   NUMBER,
    cc_open_date_sk     NUMBER,
    cc_name             VARCHAR2(50),
    cc_class            VARCHAR2(50),
    cc_employees        NUMBER,
    cc_sq_ft            NUMBER,
    cc_hours            CHAR(20),
    cc_manager          VARCHAR2(40),
    cc_mkt_id           NUMBER,
    cc_mkt_class        CHAR(50),
    cc_mkt_desc         VARCHAR2(100),
    cc_market_manager   VARCHAR2(40),
    cc_division         NUMBER,
    cc_division_name    VARCHAR2(50),
    cc_company          NUMBER,
    cc_company_name     CHAR(50),
    cc_street_number    CHAR(10),
    cc_street_name      VARCHAR2(60),
    cc_street_type      CHAR(15),
    cc_suite_number     CHAR(10),
    cc_city             VARCHAR2(60),
    cc_county           VARCHAR2(50),
    cc_state            CHAR(2),
    cc_zip              CHAR(10),
    cc_country          VARCHAR2(20),
    cc_gmt_offset       NUMBER(5),
    cc_tax_percentage   NUMBER(5)
) &compression initrans 16
STORAGE (INITIAL 1M NEXT 1M);

--
-- Create statement for table CATALOG_PAGE
--

CREATE TABLE catalog_page (
    cp_catalog_page_sk       NUMBER NOT NULL,
    cp_catalog_page_id       CHAR(16) NOT NULL,
    cp_start_date_sk         NUMBER,
    cp_end_date_sk           NUMBER,
    cp_department            VARCHAR2(50),
    cp_catalog_number        NUMBER,
    cp_catalog_page_number   NUMBER,
    cp_description           VARCHAR2(100),
    cp_type                  VARCHAR2(100)
) &compression initrans 16
STORAGE (INITIAL 1M NEXT 1M);

--
-- Create statement for table CATALOG_RETURNS
--

CREATE TABLE catalog_returns (
    cr_returned_date_sk        NUMBER,
    cr_returned_time_sk        NUMBER,
    cr_item_sk                 NUMBER NOT NULL,
    cr_refunded_customer_sk    NUMBER,
    cr_refunded_cdemo_sk       NUMBER,
    cr_refunded_hdemo_sk       NUMBER,
    cr_refunded_addr_sk        NUMBER,
    cr_returning_customer_sk   NUMBER,
    cr_returning_cdemo_sk      NUMBER,
    cr_returning_hdemo_sk      NUMBER,
    cr_returning_addr_sk       NUMBER,
    cr_call_center_sk          NUMBER,
    cr_catalog_page_sk         NUMBER,
    cr_ship_mode_sk            NUMBER,
    cr_warehouse_sk            NUMBER,
    cr_reason_sk               NUMBER,
    cr_order_number            NUMBER NOT NULL,
    cr_return_quantity         NUMBER,
    cr_return_amount           NUMBER(7),
    cr_return_tax              NUMBER(7),
    cr_return_amt_inc_tax      NUMBER(7),
    cr_fee                     NUMBER(7),
    cr_return_ship_cost        NUMBER(7),
    cr_refunded_cash           NUMBER(7),
    cr_reversed_charge         NUMBER(7),
    cr_store_credit            NUMBER(7),
    cr_net_loss                NUMBER(7)
) &compression initrans 16
STORAGE (INITIAL 16M NEXT 16M);

--
-- Create statement for table CATALOG_SALES
--

CREATE TABLE catalog_sales (
    cs_sold_date_sk            NUMBER,
    cs_sold_time_sk            NUMBER,
    cs_ship_date_sk            NUMBER,
    cs_bill_customer_sk        NUMBER,
    cs_bill_cdemo_sk           NUMBER,
    cs_bill_hdemo_sk           NUMBER,
    cs_bill_addr_sk            NUMBER,
    cs_ship_customer_sk        NUMBER,
    cs_ship_cdemo_sk           NUMBER,
    cs_ship_hdemo_sk           NUMBER,
    cs_ship_addr_sk            NUMBER,
    cs_call_center_sk          NUMBER,
    cs_catalog_page_sk         NUMBER,
    cs_ship_mode_sk            NUMBER,
    cs_warehouse_sk            NUMBER,
    cs_item_sk                 NUMBER NOT NULL,
    cs_promo_sk                NUMBER,
    cs_order_number            NUMBER NOT NULL,
    cs_quantity                NUMBER,
    cs_wholesale_cost          NUMBER(7),
    cs_list_price              NUMBER(7),
    cs_sales_price             NUMBER(7),
    cs_ext_discount_amt        NUMBER(7),
    cs_ext_sales_price         NUMBER(7),
    cs_ext_wholesale_cost      NUMBER(7),
    cs_ext_list_price          NUMBER(7),
    cs_ext_tax                 NUMBER(7),
    cs_coupon_amt              NUMBER(7),
    cs_ext_ship_cost           NUMBER(7),
    cs_net_paid                NUMBER(7),
    cs_net_paid_inc_tax        NUMBER(7),
    cs_net_paid_inc_ship       NUMBER(7),
    cs_net_paid_inc_ship_tax   NUMBER(7),
    cs_net_profit              NUMBER(7)
) &compression initrans 16
STORAGE (INITIAL 16M NEXT 16M);

--
-- Create statement for table CUSTOMER
--

CREATE TABLE customer (
    c_customer_sk            NUMBER NOT NULL,
    c_customer_id            CHAR(16) NOT NULL,
    c_current_cdemo_sk       NUMBER,
    c_current_hdemo_sk       NUMBER,
    c_current_addr_sk        NUMBER,
    c_first_shipto_date_sk   NUMBER,
    c_first_sales_date_sk    NUMBER,
    c_salutation             CHAR(10),
    c_first_name             VARCHAR2(50),
    c_last_name              VARCHAR2(50),
    c_preferred_cust_flag    CHAR(1),
    c_birth_day              NUMBER,
    c_birth_month            NUMBER,
    c_birth_year             NUMBER,
    c_birth_country          VARCHAR2(50),
    c_login                  CHAR(13),
    c_email_address          VARCHAR2(50),
    c_last_review_date       CHAR(10)
)  &compression initrans 16
STORAGE (INITIAL 16M NEXT 16M);

--
-- Create statement for table CUSTOMER_ADDRESS
--

CREATE TABLE customer_address (
    ca_address_sk      NUMBER NOT NULL,
    ca_address_id      CHAR(16) NOT NULL,
    ca_street_number   CHAR(10),
    ca_street_name     VARCHAR2(60),
    ca_street_type     CHAR(15),
    ca_suite_number    CHAR(10),
    ca_city            VARCHAR2(60),
    ca_county          VARCHAR2(50),
    ca_state           CHAR(2),
    ca_zip             CHAR(10),
    ca_country         VARCHAR2(20),
    ca_gmt_offset      NUMBER(5),
    ca_location_type   CHAR(20)
) &compression initrans 16
STORAGE (INITIAL 16M NEXT 16M);
--
-- Create statement for table CUSTOMER_DEMOGRAPHICS
--

CREATE TABLE customer_demographics (
    cd_demo_sk              NUMBER NOT NULL,
    cd_gender               CHAR(1),
    cd_marital_status       CHAR(1),
    cd_education_status     CHAR(20),
    cd_purchase_estimate    NUMBER,
    cd_credit_rating        CHAR(10),
    cd_dep_count            NUMBER,
    cd_dep_employed_count   NUMBER,
    cd_dep_college_count    NUMBER
) &compression initrans 16
STORAGE (INITIAL 16M NEXT 16M);
--
-- Create statement for table DATE_DIM
--

CREATE TABLE date_dim (
    d_date_sk             NUMBER NOT NULL,
    d_date_id             CHAR(16) NOT NULL,
    d_date                DATE,
    d_month_seq           NUMBER,
    d_week_seq            NUMBER,
    d_quarter_seq         NUMBER,
    d_year                NUMBER,
    d_dow                 NUMBER,
    d_moy                 NUMBER,
    d_dom                 NUMBER,
    d_qoy                 NUMBER,
    d_fy_year             NUMBER,
    d_fy_quarter_seq      NUMBER,
    d_fy_week_seq         NUMBER,
    d_day_name            CHAR(9),
    d_quarter_name        CHAR(6),
    d_holiday             CHAR(1),
    d_weekend             CHAR(1),
    d_following_holiday   CHAR(1),
    d_first_dom           NUMBER,
    d_last_dom            NUMBER,
    d_same_day_ly         NUMBER,
    d_same_day_lq         NUMBER,
    d_current_day         CHAR(1),
    d_current_week        CHAR(1),
    d_current_month       CHAR(1),
    d_current_quarter     CHAR(1),
    d_current_year        CHAR(1)
) &compression initrans 16
STORAGE (INITIAL 1M NEXT 1M);

--
-- Create statement for table HOUSEHOLD_DEMOGRAPHICS
--

CREATE TABLE household_demographics (
    hd_demo_sk          NUMBER NOT NULL,
    hd_income_band_sk   NUMBER,
    hd_buy_potential    CHAR(15),
    hd_dep_count        NUMBER,
    hd_vehicle_count    NUMBER
) &compression initrans 16
STORAGE (INITIAL 1M NEXT 1M);

--
-- Create statement for table INCOME_BAND
--

CREATE TABLE income_band (
    ib_income_band_sk   NUMBER NOT NULL,
    ib_lower_bound      NUMBER,
    ib_upper_bound      NUMBER
) &compression initrans 16
STORAGE (INITIAL 1M NEXT 1M);

--
-- Create statement for table INVENTORY
--

CREATE TABLE inventory (
    inv_date_sk            NUMBER NOT NULL,
    inv_item_sk            NUMBER NOT NULL,
    inv_warehouse_sk       NUMBER NOT NULL,
    inv_quantity_on_hand   NUMBER
) &compression initrans 16
STORAGE (INITIAL 16M NEXT 16M);

--
-- Create statement for table ITEM
--

CREATE TABLE item (
    i_item_sk          NUMBER NOT NULL,
    i_item_id          CHAR(16) NOT NULL,
    i_rec_start_date   DATE,
    i_rec_end_date     DATE,
    i_item_desc        VARCHAR2(200),
    i_current_price    NUMBER(7),
    i_wholesale_cost   NUMBER(7),
    i_brand_id         NUMBER,
    i_brand            CHAR(50),
    i_class_id         NUMBER,
    i_class            CHAR(50),
    i_category_id      NUMBER,
    i_category         CHAR(50),
    i_manufact_id      NUMBER,
    i_manufact         CHAR(50),
    i_size             CHAR(20),
    i_formulation      CHAR(20),
    i_color            CHAR(20),
    i_units            CHAR(10),
    i_container        CHAR(10),
    i_manager_id       NUMBER,
    i_product_name     CHAR(50)
) &compression initrans 16
STORAGE (INITIAL 1M NEXT 1M);

--
-- Create statement for table PROMOTION
--

CREATE TABLE promotion (
    p_promo_sk          NUMBER NOT NULL,
    p_promo_id          CHAR(16) NOT NULL,
    p_start_date_sk     NUMBER,
    p_end_date_sk       NUMBER,
    p_item_sk           NUMBER,
    p_cost              NUMBER(15),
    p_response_target   NUMBER,
    p_promo_name        CHAR(50),
    p_channel_dmail     CHAR(1),
    p_channel_email     CHAR(1),
    p_channel_catalog   CHAR(1),
    p_channel_tv        CHAR(1),
    p_channel_radio     CHAR(1),
    p_channel_press     CHAR(1),
    p_channel_event     CHAR(1),
    p_channel_demo      CHAR(1),
    p_channel_details   VARCHAR2(100),
    p_purpose           CHAR(15),
    p_discount_active   CHAR(1)
) &compression initrans 16
STORAGE (INITIAL 1M NEXT 1M);

--
-- Create statement for table REASON
--

CREATE TABLE reason (
    r_reason_sk     NUMBER NOT NULL,
    r_reason_id     CHAR(16) NOT NULL,
    r_reason_desc   CHAR(100)
) &compression initrans 16
STORAGE (INITIAL 1M NEXT 1M);

--
-- Create statement for table SHIP_MODE
--

CREATE TABLE ship_mode (
    sm_ship_mode_sk   NUMBER NOT NULL,
    sm_ship_mode_id   CHAR(16) NOT NULL,
    sm_type           CHAR(30),
    sm_code           CHAR(10),
    sm_carrier        CHAR(20),
    sm_contract       CHAR(20)
) &compression initrans 16
STORAGE (INITIAL 1M NEXT 1M);

--
-- Create statement for table STORE
--

CREATE TABLE store (
    s_store_sk           NUMBER NOT NULL,
    s_store_id           CHAR(16) NOT NULL,
    s_rec_start_date     DATE,
    s_rec_end_date       DATE,
    s_closed_date_sk     NUMBER,
    s_store_name         VARCHAR2(50),
    s_number_employees   NUMBER,
    s_floor_space        NUMBER,
    s_hours              CHAR(20),
    s_manager            VARCHAR2(40),
    s_market_id          NUMBER,
    s_geography_class    VARCHAR2(100),
    s_market_desc        VARCHAR2(100),
    s_market_manager     VARCHAR2(40),
    s_division_id        NUMBER,
    s_division_name      VARCHAR2(50),
    s_company_id         NUMBER,
    s_company_name       VARCHAR2(50),
    s_street_number      VARCHAR2(10),
    s_street_name        VARCHAR2(60),
    s_street_type        CHAR(15),
    s_suite_number       CHAR(10),
    s_city               VARCHAR2(60),
    s_county             VARCHAR2(40),
    s_state              CHAR(2),
    s_zip                CHAR(10),
    s_country            VARCHAR2(20),
    s_gmt_offset         NUMBER(5),
    s_tax_precentage     NUMBER(5)
) &compression initrans 16
STORAGE (INITIAL 1M NEXT 1M);

--
-- Create statement for table STORE_RETURNS
--

CREATE TABLE store_returns (
    sr_returned_date_sk     NUMBER,
    sr_return_time_sk       NUMBER,
    sr_item_sk              NUMBER NOT NULL,
    sr_customer_sk          NUMBER,
    sr_cdemo_sk             NUMBER,
    sr_hdemo_sk             NUMBER,
    sr_addr_sk              NUMBER,
    sr_store_sk             NUMBER,
    sr_reason_sk            NUMBER,
    sr_ticket_number        NUMBER NOT NULL,
    sr_return_quantity      NUMBER,
    sr_return_amt           NUMBER(7),
    sr_return_tax           NUMBER(7),
    sr_return_amt_inc_tax   NUMBER(7),
    sr_fee                  NUMBER(7),
    sr_return_ship_cost     NUMBER(7),
    sr_refunded_cash        NUMBER(7),
    sr_reversed_charge      NUMBER(7),
    sr_store_credit         NUMBER(7),
    sr_net_loss             NUMBER(7)
) &compression initrans 16
STORAGE (INITIAL 16M NEXT 16M);

--
-- Create statement for table STORE_SALES
--

CREATE TABLE store_sales (
    ss_sold_date_sk         NUMBER,
    ss_sold_time_sk         NUMBER,
    ss_item_sk              NUMBER NOT NULL,
    ss_customer_sk          NUMBER,
    ss_cdemo_sk             NUMBER,
    ss_hdemo_sk             NUMBER,
    ss_addr_sk              NUMBER,
    ss_store_sk             NUMBER,
    ss_promo_sk             NUMBER,
    ss_ticket_number        NUMBER NOT NULL,
    ss_quantity             NUMBER,
    ss_wholesale_cost       NUMBER(7),
    ss_list_price           NUMBER(7),
    ss_sales_price          NUMBER(7),
    ss_ext_discount_amt     NUMBER(7),
    ss_ext_sales_price      NUMBER(7),
    ss_ext_wholesale_cost   NUMBER(7),
    ss_ext_list_price       NUMBER(7),
    ss_ext_tax              NUMBER(7),
    ss_coupon_amt           NUMBER(7),
    ss_net_paid             NUMBER(7),
    ss_net_paid_inc_tax     NUMBER(7),
    ss_net_profit           NUMBER(7)
) &compression initrans 16
STORAGE (INITIAL 16M NEXT 16M);

--
-- Create statement for table TIME_DIM
--

CREATE TABLE time_dim (
    t_time_sk     NUMBER NOT NULL,
    t_time_id     CHAR(16) NOT NULL,
    t_time        NUMBER,
    t_hour        NUMBER,
    t_minute      NUMBER,
    t_second      NUMBER,
    t_am_pm       CHAR(2),
    t_shift       CHAR(20),
    t_sub_shift   CHAR(20),
    t_meal_time   CHAR(20)
) &compression initrans 16
STORAGE (INITIAL 1M NEXT 1M);

--
-- Create statement for table WAREHOUSE
--

CREATE TABLE warehouse (
    w_warehouse_sk      NUMBER NOT NULL,
    w_warehouse_id      CHAR(16) NOT NULL,
    w_warehouse_name    VARCHAR2(20),
    w_warehouse_sq_ft   NUMBER,
    w_street_number     CHAR(10),
    w_street_name       VARCHAR2(60),
    w_street_type       CHAR(15),
    w_suite_number      CHAR(10),
    w_city              VARCHAR2(60),
    w_county            VARCHAR2(50),
    w_state             CHAR(2),
    w_zip               CHAR(10),
    w_country           VARCHAR2(20),
    w_gmt_offset        NUMBER(5)
) &compression initrans 16
 STORAGE (INITIAL 1M NEXT 1M);

--
-- Create statement for table WEB_PAGE
--

CREATE TABLE web_page (
    wp_web_page_sk        NUMBER NOT NULL,
    wp_web_page_id        CHAR(16) NOT NULL,
    wp_rec_start_date     DATE,
    wp_rec_end_date       DATE,
    wp_creation_date_sk   NUMBER,
    wp_access_date_sk     NUMBER,
    wp_autogen_flag       CHAR(1),
    wp_customer_sk        NUMBER,
    wp_url                VARCHAR2(100),
    wp_type               CHAR(50),
    wp_char_count         NUMBER,
    wp_link_count         NUMBER,
    wp_image_count        NUMBER,
    wp_max_ad_count       NUMBER
) &compression initrans 16
 STORAGE (INITIAL 1M NEXT 1M);

--
-- Create statement for table WEB_RETURNS
--

CREATE TABLE web_returns (
    wr_returned_date_sk        NUMBER,
    wr_returned_time_sk        NUMBER,
    wr_item_sk                 NUMBER NOT NULL,
    wr_refunded_customer_sk    NUMBER,
    wr_refunded_cdemo_sk       NUMBER,
    wr_refunded_hdemo_sk       NUMBER,
    wr_refunded_addr_sk        NUMBER,
    wr_returning_customer_sk   NUMBER,
    wr_returning_cdemo_sk      NUMBER,
    wr_returning_hdemo_sk      NUMBER,
    wr_returning_addr_sk       NUMBER,
    wr_web_page_sk             NUMBER,
    wr_reason_sk               NUMBER,
    wr_order_number            NUMBER NOT NULL,
    wr_return_quantity         NUMBER,
    wr_return_amt              NUMBER(7),
    wr_return_tax              NUMBER(7),
    wr_return_amt_inc_tax      NUMBER(7),
    wr_fee                     NUMBER(7),
    wr_return_ship_cost        NUMBER(7),
    wr_refunded_cash           NUMBER(7),
    wr_reversed_charge         NUMBER(7),
    wr_account_credit          NUMBER(7),
    wr_net_loss                NUMBER(7)
) &compression initrans 16
 STORAGE (INITIAL 16M NEXT 16M);

--
-- Create statement for table WEB_SALES
--

CREATE TABLE web_sales (
    ws_sold_date_sk            NUMBER,
    ws_sold_time_sk            NUMBER,
    ws_ship_date_sk            NUMBER,
    ws_item_sk                 NUMBER NOT NULL,
    ws_bill_customer_sk        NUMBER,
    ws_bill_cdemo_sk           NUMBER,
    ws_bill_hdemo_sk           NUMBER,
    ws_bill_addr_sk            NUMBER,
    ws_ship_customer_sk        NUMBER,
    ws_ship_cdemo_sk           NUMBER,
    ws_ship_hdemo_sk           NUMBER,
    ws_ship_addr_sk            NUMBER,
    ws_web_page_sk             NUMBER,
    ws_web_site_sk             NUMBER,
    ws_ship_mode_sk            NUMBER,
    ws_warehouse_sk            NUMBER,
    ws_promo_sk                NUMBER,
    ws_order_number            NUMBER NOT NULL,
    ws_quantity                NUMBER,
    ws_wholesale_cost          NUMBER(7),
    ws_list_price              NUMBER(7),
    ws_sales_price             NUMBER(7),
    ws_ext_discount_amt        NUMBER(7),
    ws_ext_sales_price         NUMBER(7),
    ws_ext_wholesale_cost      NUMBER(7),
    ws_ext_list_price          NUMBER(7),
    ws_ext_tax                 NUMBER(7),
    ws_coupon_amt              NUMBER(7),
    ws_ext_ship_cost           NUMBER(7),
    ws_net_paid                NUMBER(7),
    ws_net_paid_inc_tax        NUMBER(7),
    ws_net_paid_inc_ship       NUMBER(7),
    ws_net_paid_inc_ship_tax   NUMBER(7),
    ws_net_profit              NUMBER(7)
) &compression initrans 16
 STORAGE (INITIAL 16M NEXT 16M);

--
-- Create statement for table WEB_SITE
--

CREATE TABLE web_site (
    web_site_sk          NUMBER NOT NULL,
    web_site_id          CHAR(16) NOT NULL,
    web_rec_start_date   DATE,
    web_rec_end_date     DATE,
    web_name             VARCHAR2(50),
    web_open_date_sk     NUMBER,
    web_close_date_sk    NUMBER,
    web_class            VARCHAR2(50),
    web_manager          VARCHAR2(40),
    web_mkt_id           NUMBER,
    web_mkt_class        VARCHAR2(50),
    web_mkt_desc         VARCHAR2(100),
    web_market_manager   VARCHAR2(40),
    web_company_id       NUMBER,
    web_company_name     CHAR(50),
    web_street_number    CHAR(10),
    web_street_name      VARCHAR2(60),
    web_street_type      CHAR(15),
    web_suite_number     CHAR(10),
    web_city             VARCHAR2(60),
    web_county           VARCHAR2(40),
    web_state            CHAR(2),
    web_zip              CHAR(10),
    web_country          VARCHAR2(20),
    web_gmt_offset       NUMBER(5),
    web_tax_percentage   NUMBER(5)
) &compression initrans 16
 STORAGE (INITIAL 1M NEXT 1M);

 -- Exit