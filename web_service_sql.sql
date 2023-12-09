--gap_agecomp
declare  
  l_cur  sys_refcursor;
begin
metadata.app_audit_pkg.audit_record_web_svc(p_app_user => :CURRENT_USER, p_env_id => 2); 
open l_cur for 
select * from gap_products.akfin_agecomp
where area_id in nvl(:area_id,1)
and species_code in nvl(:species_code, 21740)
and survey_definition_id in nvl(:survey_definition_id,98)
and year between nvl(:start_year, 1990)and nvl(:end_year, 3000) 
;
         :ret := l_cur;

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
/*
-- parameters output
declare  
  l_cur  sys_refcursor;    
begin 
metadata.app_audit_pkg.audit_record_web_svc(p_app_user => :CURRENT_USER, p_env_id => 2); 
  open l_cur for  
 select * from gap_products.akfin_catch
 --where species_code in (select * from table(apex_string.split(nvl(:species_code,species_code),',')));
 where species_code in nvl(:species_code, 21740);
         :ret := l_cur;  --oracle takes care of, don't bother me. This requires ret output parameter.
end; */

--update
declare  
  l_cur  sys_refcursor;    
begin 
metadata.app_audit_pkg.audit_record_web_svc(p_app_user => :CURRENT_USER, p_env_id => 2); 
  open l_cur for  
select ca.*, h.stratum, cr.survey_definition_id, cr.year, s.area_id
from gap_products.akfin_catch ca
inner join gap_products.akfin_haul h on
ca.hauljoin=h.hauljoin
inner join gap_products.akfin_cruises cr on
h.cruisejoin=cr.cruisejoin
inner join gap_products.akfin_stratum_groups s on
h.stratum=s.stratum and cr.survey_definition_id = s.survey_definition_id
where ca.species_code in nvl(:species_code, 21740)
and year between nvl(:start_year, 1990) and nvl(:end_year, 1990)
and cr.survey_definition_id in nvl(:survey_definition_id, 98)
and s.area_id in nvl(:area_id, 1)
;
         :ret := l_cur;  --oracle takes care of, don't bother me. This requires ret output parameter.
end;

--gap_cpue
declare  
  l_cur  sys_refcursor;    
begin 
metadata.app_audit_pkg.audit_record_web_svc(p_app_user => :CURRENT_USER, p_env_id => 2); 
  open l_cur for  
select cp.*, h.stratum, cr.survey_definition_id, cr.year, s.area_id
from gap_products.akfin_cpue cp
inner join gap_products.akfin_haul h on
cp.hauljoin=h.hauljoin
inner join gap_products.akfin_cruises cr on
h.cruisejoin=cr.cruisejoin
inner join gap_products.akfin_stratum_groups s on
h.stratum=s.stratum and cr.survey_definition_id = s.survey_definition_id
where cp.species_code in nvl(:species_code, 21740)
and year between nvl(:start_year, 1990) and nvl(:end_year, 1990)
and cr.survey_definition_id in nvl(:survey_definition_id, 98)
and s.area_id in nvl(:area_id, 1)
;
         :ret := l_cur;  --oracle takes care of, don't bother me. This requires ret output parameter.
end;


--gap_cruises
declare  
  l_cur  sys_refcursor;
begin
metadata.app_audit_pkg.audit_record_web_svc(p_app_user => :CURRENT_USER, p_env_id => 2); 
open l_cur for 
select * from gap_products.akfin_cruises
where survey_definition_id in nvl(:survey_definition_id,98)
and year between nvl(:start_year, 1990)and nvl(:end_year, 3000) 
;
         :ret := l_cur;

end;

--gap_haul
declare  
  l_cur  sys_refcursor;
begin
metadata.app_audit_pkg.audit_record_web_svc(p_app_user => :CURRENT_USER, p_env_id => 2); 
open l_cur for 
select * from gap_products.akfin_haul
;
         :ret := l_cur;

end;

--gap_length
declare  
  l_cur  sys_refcursor;    
begin 
metadata.app_audit_pkg.audit_record_web_svc(p_app_user => :CURRENT_USER, p_env_id => 2); 
  open l_cur for  
select ln.*, h.stratum, cr.survey_definition_id, cr.year, s.area_id
from gap_products.akfin_lengths ln
inner join gap_products.akfin_haul h on
ln.hauljoin=h.hauljoin
inner join gap_products.akfin_cruises cr on
h.cruisejoin=cr.cruisejoin
inner join gap_products.akfin_stratum_groups s on
h.stratum=s.stratum and cr.survey_definition_id = s.survey_definition_id
where ln.species_code in nvl(:species_code, 21740)
and year between nvl(:start_year, 1990) and nvl(:end_year, 1990)
and cr.survey_definition_id in nvl(:survey_definition_id, 98)
and s.area_id in nvl(:area_id, 1)
;
         :ret := l_cur;  --oracle takes care of, don't bother me. This requires ret output parameter.
end;

--gap_metadata_column
declare  
  l_cur  sys_refcursor;
begin
metadata.app_audit_pkg.audit_record_web_svc(p_app_user => :CURRENT_USER, p_env_id => 2); 
open l_cur for 
select * from gap_products.akfin_metadata_column
;
         :ret := l_cur;

end;

--gap_sizecomp
declare  
  l_cur  sys_refcursor;
begin
metadata.app_audit_pkg.audit_record_web_svc(p_app_user => :CURRENT_USER, p_env_id => 2); 
open l_cur for 
select * from gap_products.akfin_sizecomp
where area_id in nvl(:area_id,1)
and species_code in nvl(:species_code, 21740)
and survey_definition_id in nvl(:survey_definition_id,98)
and year between nvl(:start_year, 1990)and nvl(:end_year, 3000) 
;
         :ret := l_cur;

end;

--gap_specimen
declare  
  l_cur  sys_refcursor;    
begin 
metadata.app_audit_pkg.audit_record_web_svc(p_app_user => :CURRENT_USER, p_env_id => 2); 
  open l_cur for  
select sp.*, h.stratum, cr.survey_definition_id, cr.year, s.area_id
from gap_products.akfin_specimen sp
inner join gap_products.akfin_haul h on
sp.hauljoin=h.hauljoin
inner join gap_products.akfin_cruises cr on
h.cruisejoin=cr.cruisejoin
inner join gap_products.akfin_stratum_groups s on
h.stratum=s.stratum and cr.survey_definition_id = s.survey_definition_id
where sp.species_code in nvl(:species_code, 21740)
and year between nvl(:start_year, 1990) and nvl(:end_year, 1990)
and cr.survey_definition_id in nvl(:survey_definition_id, 98)
and s.area_id in nvl(:area_id, 1)
;
         :ret := l_cur;  --oracle takes care of, don't bother me. This requires ret output parameter.
end;

--gap_split_fractions
declare  
  l_cur  sys_refcursor;
begin
metadata.app_audit_pkg.audit_record_web_svc(p_app_user => :CURRENT_USER, p_env_id => 2); 
open l_cur for 
select * from gap_products.akfin_split_fractions
;
         :ret := l_cur;

end;

--gap_stratum_groups
declare  
  l_cur  sys_refcursor;
begin
metadata.app_audit_pkg.audit_record_web_svc(p_app_user => :CURRENT_USER, p_env_id => 2); 
open l_cur for 
select * from gap_products.akfin_stratum_groups
;
         :ret := l_cur;

end;

--gap_survey_deign
declare  
  l_cur  sys_refcursor;
begin
metadata.app_audit_pkg.audit_record_web_svc(p_app_user => :CURRENT_USER, p_env_id => 2); 
open l_cur for 
select * from gap_products.akfin_survey_design
;
         :ret := l_cur;

end;
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

