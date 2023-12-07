--gap_biomass
declare  
  l_cur  sys_refcursor;
begin
metadata.app_audit_pkg.audit_record_web_svc(p_app_user => :CURRENT_USER, p_env_id => 2); 
open l_cur for 
select * from gap_products.akfin_biomass
--where instr(nvl(:area_id, to_char(area_id)), to_char(area_id)) > 0
--and instr(nvl(:species_code, to_char(species_code)), to_char(species_code)) > 0 
--and instr(nvl(:survey_definition_id, to_char(survey_definition_id)), to_char(survey_definition_id)) > 0 
--and year between nvl(:start_year, 1990)and nvl(:end_year, 3000) 

where area_id in nvl(:area_id,1)
and species_code in nvl(:species_code, 21740)
and survey_definition_id in nvl(:survey_definition_id,98)
and year between nvl(:start_year, 1990)and nvl(:end_year, 3000) 
;
         :ret := l_cur;

end;

--parameters: area_id, start_year, end_year, species_code, survey_dfinition_id

-- gap_catch
-- parameters output
declare  
  l_cur  sys_refcursor;    
begin 
metadata.app_audit_pkg.audit_record_web_svc(p_app_user => :CURRENT_USER, p_env_id => 2); 
  open l_cur for  
 select * from gap_products.akfin_catch; 
         :ret := l_cur;  --oracle takes care of, don't bother me. This requires ret output parameter.
end;


-- gap_area
declare  
  l_cur  sys_refcursor;
begin
metadata.app_audit_pkg.audit_record_web_svc(p_app_user => :CURRENT_USER, p_env_id => 2); 
open l_cur for 
select * from gap_products.akfin_area
;
         :ret := l_cur;

end;
--

--gap_taxonomics
declare  
  l_cur  sys_refcursor;
begin
metadata.app_audit_pkg.audit_record_web_svc(p_app_user => :CURRENT_USER, p_env_id => 2); 
open l_cur for 
select * from gap_products.akfin_taxonomics_worms
;
         :ret := l_cur;

end;