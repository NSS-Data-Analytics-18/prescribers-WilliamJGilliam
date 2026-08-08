--Which prescriber had the highest total number of claims (totaled over all drugs)?--
--Report the npi and the total number of claims--
select 
	prescriber.npi,
	sum(total_claim_count) as total_claims
from prescription
	inner join prescriber on prescription.npi=prescriber.npi
Group by prescriber.npi	
order by total_claims desc
limit 1;

--Repeat the above, but this time report the nppes_provider_first_name, 
--nppes_provider_last_org_name,  specialty_description, and the total number of claims.--
select 
	nppes_provider_first_name as first_name,
	nppes_provider_last_org_name as last_name,
	specialty_description as specialty, 
	sum(total_claim_count) as total_claims
from prescription
	inner join prescriber on prescription.npi=prescriber.npi
Group by nppes_provider_first_name,nppes_provider_last_org_name,specialty_description
order by total_claims desc
limit 1;

--Which specialty had the most total number of claims (totaled over all drugs)?--
select 
	specialty_description as specialty, 
	sum(total_claim_count) as total_claims
from prescription
	inner join prescriber on prescription.npi=prescriber.npi
Group by specialty_description
order by total_claims desc
limit 1;
--Which specialty had the most total number of claims for opioids?--
select 
	specialty_description as specialty, 
	sum(total_claim_count) as total_claims
from prescription
	inner join prescriber on prescription.npi=prescriber.npi
	inner join drug on drug.drug_name=prescription.drug_name
	where opioid_drug_flag='Y'
Group by specialty_description
order by total_claims desc
limit 1;

--**Challenge Question:** Are there any specialties that appear in the prescriber table--
--that have no associated prescriptions in the prescription table?--
select 
	distinct(specialty_description) as specialty,total_claim_count
from prescription
	right join prescriber on prescription.npi=prescriber.npi
	where total_claim_count is null;

--Which drug (generic_name) had the highest total drug cost?--
select
	generic_name,sum(total_drug_cost)as total_cost
from prescription
	inner join drug on prescription.drug_name=drug.drug_name
	group by generic_name
	order by total_cost desc
limit 1;

--Which drug (generic_name) has the hightest total cost per day?--
--**Bonus: Round your cost per day column to 2 decimal places.--
select
	generic_name, round(sum(total_drug_cost/30),2)as total_cost
from prescription
	inner join drug on prescription.drug_name=drug.drug_name
	group by generic_name
	order by total_cost desc
limit 1;

--For each drug in the drug table, return the drug name and then a column named 'drug_type'--
--which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for--
--those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.--
select
	drug_name,
		case when opioid_drug_flag='Y' then 'opioid'
			when antibiotic_drug_flag='Y' then 'antibiotic'
			else 'neither' end as drug_type
from drug;

--Building off of the query you wrote for part a, determine whether--
--more was spent (total_drug_cost) on opioids or on antibiotics.--
--Hint: Format the total costs as MONEY for easier comparision.--
select
		case when opioid_drug_flag='Y' then 'opioid'
			when antibiotic_drug_flag='Y' then 'antibiotic'
			else 'neither' end as drug_type, 
	sum(total_drug_cost)::numeric::money as Total_cost
from drug
	inner join prescription on prescription.drug_name=drug.drug_name
where opioid_drug_flag = 'Y'
    or antibiotic_drug_flag = 'Y'
group by drug_type;

--a. How many CBSAs are in Tennessee?-- 
--**Warning:** The cbsa table contains information for all states, not just Tennessee.--
select Count(*) as csba_in_tn
from cbsa
where cbsaname ilike '%TN%';

--Which cbsa has the largest combined population?--
select 
	cbsaname,sum(population)as total_population
from cbsa
	inner join population on population.fipscounty=cbsa.fipscounty
group by cbsaname
order by total_population desc
limit 1;

--Which has the smallest? Report the CBSA name and total population.--
select 
	cbsaname,sum(population)as total_population
from cbsa
	inner join population on population.fipscounty=cbsa.fipscounty
group by cbsaname
order by total_population
limit 1;


