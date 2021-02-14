
-- Suppress Warnings

ALTER TABLE call_center
    DROP CONSTRAINT cc_d1;

ALTER TABLE call_center
    DROP CONSTRAINT cc_d2;
    

ALTER TABLE catalog_page
    DROP CONSTRAINT cp_d1;
    

ALTER TABLE catalog_page
    DROP CONSTRAINT cp_d2;
    

ALTER TABLE catalog_returns
    DROP CONSTRAINT cr_cc  ;
    

ALTER TABLE catalog_returns
    DROP CONSTRAINT cr_cp ;
    

ALTER TABLE catalog_returns
    DROP CONSTRAINT cr_itm ;
    

ALTER TABLE catalog_returns
    DROP CONSTRAINT cr_r ;
    

ALTER TABLE catalog_returns
    DROP CONSTRAINT cr_a1 ;
    

ALTER TABLE catalog_returns
    DROP CONSTRAINT cr_cd1 ;
    

ALTER TABLE catalog_returns
    DROP CONSTRAINT cr_c1 ;
    

ALTER TABLE catalog_returns
    DROP CONSTRAINT cr_hd1 ;
    

ALTER TABLE catalog_returns
    DROP CONSTRAINT cr_d1 ;
    

ALTER TABLE catalog_returns
    DROP CONSTRAINT cr_i ;
    

ALTER TABLE catalog_returns
    DROP CONSTRAINT cr_a2 ;
    

ALTER TABLE catalog_returns
    DROP CONSTRAINT cr_cd2 ;
    

ALTER TABLE catalog_returns
    DROP CONSTRAINT cr_c2 ;
    

ALTER TABLE catalog_returns
    DROP CONSTRAINT cr_hd2 ;
    

ALTER TABLE catalog_returns
    DROP CONSTRAINT cr_sm ;
    

ALTER TABLE catalog_returns
    DROP CONSTRAINT cr_w2 ;
    

ALTER TABLE catalog_sales
    DROP CONSTRAINT cs_b_a ;
    

ALTER TABLE catalog_sales
    DROP CONSTRAINT cs_b_cd ;
    

ALTER TABLE catalog_sales
    DROP CONSTRAINT cs_b_c ;
    

ALTER TABLE catalog_sales
    DROP CONSTRAINT cs_b_hd ;
    

ALTER TABLE catalog_sales
    DROP CONSTRAINT cs_cc ;
    

ALTER TABLE catalog_sales
    DROP CONSTRAINT cs_cp ;
    

ALTER TABLE catalog_sales
    DROP CONSTRAINT cs_i ;
    

ALTER TABLE catalog_sales
    DROP CONSTRAINT cs_p ;
    

ALTER TABLE catalog_sales
    DROP CONSTRAINT cs_s_a ;
    

ALTER TABLE catalog_sales
    DROP CONSTRAINT cs_s_cd ;
    

ALTER TABLE catalog_sales
    DROP CONSTRAINT cs_s_c ;
    

ALTER TABLE catalog_sales
    DROP CONSTRAINT cs_d1 ;
    

ALTER TABLE catalog_sales
    DROP CONSTRAINT cs_s_hd ;
    

ALTER TABLE catalog_sales
    DROP CONSTRAINT cs_sm ;
    

ALTER TABLE catalog_sales
    DROP CONSTRAINT cs_d2 ;
    

ALTER TABLE catalog_sales
    DROP CONSTRAINT cs_t ;
    

ALTER TABLE catalog_sales
    DROP CONSTRAINT cs_w ;
    

ALTER TABLE customer
    DROP CONSTRAINT c_a ;
    

ALTER TABLE customer
    DROP CONSTRAINT c_cd ;
    

ALTER TABLE customer
    DROP CONSTRAINT c_hd ;
    

ALTER TABLE customer
    DROP CONSTRAINT c_fsd ;
    

ALTER TABLE customer
    DROP CONSTRAINT c_fsd2 ;
    

ALTER TABLE household_demographics
    DROP CONSTRAINT hd_ib ;
    


ALTER TABLE inventory
    DROP CONSTRAINT inv_d ;
    

ALTER TABLE inventory
    DROP CONSTRAINT inv_i ;
    

ALTER TABLE inventory
    DROP CONSTRAINT inv_w ;
    


ALTER TABLE promotion
    DROP CONSTRAINT p_end_date ;
    

ALTER TABLE promotion
    DROP CONSTRAINT p_i ;
    

ALTER TABLE promotion
    DROP CONSTRAINT p_start_date ;
    


ALTER TABLE store
    DROP CONSTRAINT s_close_date ;

ALTER TABLE store_returns
    DROP CONSTRAINT sr_a ;
    

ALTER TABLE store_returns
    DROP CONSTRAINT sr_cd ;
    

ALTER TABLE store_returns
    DROP CONSTRAINT sr_c ;
    

ALTER TABLE store_returns
    DROP CONSTRAINT sr_hd ;
    

ALTER TABLE store_returns
    DROP CONSTRAINT sr_i ;
    

ALTER TABLE store_returns
    DROP CONSTRAINT sr_r ;
    

ALTER TABLE store_returns
    DROP CONSTRAINT sr_ret_d ;
    

ALTER TABLE store_returns
    DROP CONSTRAINT sr_t ;
    

ALTER TABLE store_returns
    DROP CONSTRAINT sr_s ;
    

ALTER TABLE store_sales
    DROP CONSTRAINT ss_a ;
    

ALTER TABLE store_sales
    DROP CONSTRAINT ss_cd ;
    

ALTER TABLE store_sales
    DROP CONSTRAINT ss_c ;
    

ALTER TABLE store_sales
    DROP CONSTRAINT ss_hd ;
    

ALTER TABLE store_sales
    DROP CONSTRAINT ss_i ;
    

ALTER TABLE store_sales
    DROP CONSTRAINT ss_p ;
    

ALTER TABLE store_sales
    DROP CONSTRAINT ss_d ;
    

ALTER TABLE store_sales
    DROP CONSTRAINT ss_t ;
    

ALTER TABLE store_sales
    DROP CONSTRAINT ss_s ;
    


ALTER TABLE web_page
    DROP CONSTRAINT wp_ad ;
    

ALTER TABLE web_page
    DROP CONSTRAINT wp_cd ;
    

ALTER TABLE web_returns
    DROP CONSTRAINT wr_i ;
    

ALTER TABLE web_returns
    DROP CONSTRAINT wr_r ;
    

ALTER TABLE web_returns
    DROP CONSTRAINT wr_ref_a ;
    

ALTER TABLE web_returns
    DROP CONSTRAINT wr_ref_cd ;
    

ALTER TABLE web_returns
    DROP CONSTRAINT wr_ref_c ;
    

ALTER TABLE web_returns
    DROP CONSTRAINT wr_ref_hd ;
    

ALTER TABLE web_returns
    DROP CONSTRAINT wr_ret_d ;
    

ALTER TABLE web_returns
    DROP CONSTRAINT wr_ret_t ;
    

ALTER TABLE web_returns
    DROP CONSTRAINT wr_ret_a ;
    

ALTER TABLE web_returns
    DROP CONSTRAINT wr_ret_cd ;
    

ALTER TABLE web_returns
    DROP CONSTRAINT wr_ret_c ;
    

ALTER TABLE web_returns
    DROP CONSTRAINT wr_ret_hd ;
    

ALTER TABLE web_returns
    DROP CONSTRAINT wr_wp ;
    

ALTER TABLE web_sales
    DROP CONSTRAINT ws_b_a ;
    

ALTER TABLE web_sales
    DROP CONSTRAINT ws_b_cd ;
    

ALTER TABLE web_sales
    DROP CONSTRAINT ws_b_c ;
    

ALTER TABLE web_sales
    DROP CONSTRAINT ws_b_hd ;
    

ALTER TABLE web_sales
    DROP CONSTRAINT ws_i ;
    

ALTER TABLE web_sales
    DROP CONSTRAINT ws_p ;
    

ALTER TABLE web_sales
    DROP CONSTRAINT ws_s_a ;
    

ALTER TABLE web_sales
    DROP CONSTRAINT ws_s_cd ;
    

ALTER TABLE web_sales
    DROP CONSTRAINT ws_s_c ;
    

ALTER TABLE web_sales
    DROP CONSTRAINT ws_s_d ;
    

ALTER TABLE web_sales
    DROP CONSTRAINT ws_s_hd ;
    

ALTER TABLE web_sales
    DROP CONSTRAINT ws_sm ;
    

ALTER TABLE web_sales
    DROP CONSTRAINT ws_d2 ;
    

ALTER TABLE web_sales
    DROP CONSTRAINT ws_t ;
    

ALTER TABLE web_sales
    DROP CONSTRAINT ws_w2 ;
    

ALTER TABLE web_sales
    DROP CONSTRAINT ws_wp ;
    

ALTER TABLE web_sales
    DROP CONSTRAINT ws_ws ;
    


ALTER TABLE web_site
    DROP CONSTRAINT web_d1 ;
    

ALTER TABLE web_site
    DROP CONSTRAINT web_d2 ;

ALTER TABLE customer_address
    DROP CONSTRAINT ca_address_pk;


ALTER TABLE customer_demographics
    DROP CONSTRAINT customer_demographics_pk;


ALTER TABLE date_dim
    DROP CONSTRAINT date_dim_pk;


ALTER TABLE warehouse
    DROP CONSTRAINT warehouse_pk;


ALTER TABLE ship_mode
    DROP CONSTRAINT ship_mode_pk;


ALTER TABLE time_dim
    DROP CONSTRAINT time_dim_pk;


ALTER TABLE reason
    DROP CONSTRAINT reason_pk;


ALTER TABLE income_band
    DROP CONSTRAINT income_band_pk;


ALTER TABLE store
    DROP CONSTRAINT store_pk;


ALTER TABLE item
    DROP CONSTRAINT item_pk;


ALTER TABLE catalog_page
    DROP CONSTRAINT catalog_page_pk;




-- I can't guarantee the uniqueness of this key without a lot of work
DROP INDEX inventory_nuk;


ALTER TABLE call_center
    DROP CONSTRAINT call_center_pk;


ALTER TABLE customer
    DROP CONSTRAINT customer_pk;


ALTER TABLE web_page
    DROP CONSTRAINT web_page_pk;


ALTER TABLE promotion
    DROP CONSTRAINT promotion_pk;


ALTER TABLE web_site
    DROP CONSTRAINT web_site_pk;


ALTER TABLE store_returns
    DROP CONSTRAINT store_returns_pk;


ALTER TABLE household_demographics
    DROP CONSTRAINT household_demographics_pk;


ALTER TABLE catalog_returns
    DROP CONSTRAINT catalog_returns_pk;


ALTER TABLE web_returns
    DROP CONSTRAINT web_returns_pk;

ALTER TABLE web_sales
    DROP CONSTRAINT web_sales_pk;

ALTER TABLE catalog_sales
    DROP CONSTRAINT catalog_sales_pk;

ALTER TABLE store_sales
    DROP CONSTRAINT store_sales_pk;

-- End Suppress Warnings

-- End of drop indexes