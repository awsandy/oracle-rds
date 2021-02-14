CREATE &tablespacemodel TABLESPACE &tablespace 
  DATAFILE &datafile
  SIZE &datafilesize
  AUTOEXTEND ON 
  NEXT 64M 
  MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL 
  UNIFORM SIZE 1M
  SEGMENT SPACE MANAGEMENT AUTO;

/*
-- Add if a separate INDEX tablespace is required
CREATE &tablespacemodel TABLESPACE &indextablespace 
  DATAFILE &indexdatafile
  SIZE &indexdatafilesize
  AUTOEXTEND ON 
  NEXT 64M 
  MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL 
  UNIFORM SIZE 1M
  SEGMENT SPACE MANAGEMENT AUTO;
*/  
 
 -- exit;
