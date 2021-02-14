declare
begin
for c1 in (select y1.table_name, y1.constraint_name from user_constraints y1, user_tables x1 where x1.table_name = y1.table_name order by y1.r_constraint_name nulls last) loop
    begin
        dbms_output.put_line('alter table '||c1.table_name||' disable constraint '||c1.constraint_name || ';');
        execute immediate  ('alter table '||c1.table_name||' disable constraint '||c1.constraint_name);
    end;
end loop;
 
-- uncomment to truncate the table after disabling the constraint.
-- for t1 in (select table_name from user_tables) loop
--     begin
--         dbms_output.put_line('truncate table '||t1.table_name || ';');   
--         execute immediate ('truncate table '||t1.table_name);
--     end;
-- end loop;
 
for c2 in (select y2.table_name, y2.constraint_name from user_constraints y2, user_tables x2 where x2.table_name = y2.table_name order by y2.r_constraint_name nulls first) loop
    begin
        dbms_output.put_line('alter table '||c2.table_name||' enable constraint '||c2.constraint_name || ';');       
        execute immediate ('alter table '||c2.table_name||' enable constraint '||c2.constraint_name);
    end;
end loop;
end;