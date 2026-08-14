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

--What is the largest (in terms of population) county which is --
--not included in a CBSA? Report the county name and population.--
select county,population
from fips_county
	inner join population on fips_county.fipscounty=population.fipscounty
	left join cbsa on fips_county.fipscounty=cbsa.fipscounty
where cbsa is null	
order by population desc
limit 1;

--Find all rows in the prescription table where total_claims is at least 3000. 
--Report the drug_name and the total_claim_count.--
select
	drug_name,total_claim_count
from prescription
where total_claim_count>=3000;

--For each instance that you found in part a,--
--add a column that indicates whether the drug is an opioid.--
select
	drug.drug_name,total_claim_count,
	case when opioid_drug_flag='Y' then 'yes'
	else 'no' end as Opioid
from prescription
	inner join drug on prescription.drug_name=drug.drug_name
where total_claim_count>=3000;

--Add another column to you answer from the previous part which gives the prescriber--
--first and last name associated with each row.--
select
	drug.drug_name,total_claim_count,nppes_provider_last_org_name,nppes_provider_first_name,
	case when opioid_drug_flag='Y' then 'yes'
	else 'no' end as Opioid
from prescription
	inner join drug on prescription.drug_name=drug.drug_name
	inner join prescriber on prescriber.npi=prescriber.npi
where total_claim_count>=3000;

--First, create a list of all npi/drug_name combinations for pain management specialists --
--(specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'),--
--where the drug is an opioid (opioid_drug_flag = 'Y'). **Warning:** Double-check your query before running it.--
--You will only need to use the prescriber and drug tables since you don't need the claims numbers yet--
select 
	npi,drug_name
from prescriber
	cross join drug
where specialty_description = 'Pain Management'
	and nppes_provider_city = 'NASHVILLE'
	and opioid_drug_flag = 'Y';
--Next, report the number of claims per drug per prescriber. Be sure to include all combinations,-- 
--whether or not the prescriber had any claims. --
--You should report the npi, the drug name, and the number of claims (total_claim_count).--	
select 
	prescriber.npi,
	drug.drug_name,total_claim_count
from prescriber
	cross join drug
	left join prescription on prescription.npi = prescriber.npi
	and prescription.drug_name=drug.drug_name
where specialty_description = 'Pain Management'
	and nppes_provider_city = 'NASHVILLE'
	and opioid_drug_flag = 'Y';
	
--Finally, if you have not done so already,-- 
--fill in any missing values for total_claim_count with 0.-- 
--Hint - Google the COALESCE function.--
select 
	prescriber.npi,
	drug.drug_name,
	coalesce(total_claim_count, '0') as claim_count
from prescriber
	cross join drug
	left join prescription on prescription.npi = prescriber.npi
	and prescription.drug_name=drug.drug_name
where specialty_description = 'Pain Management'
	and nppes_provider_city = 'NASHVILLE'
	and opioid_drug_flag = 'Y';

--**Difficult Bonus:** *Do not attempt until you have solved all other problems!* 
--For each specialty, report the percentage of total claims by that specialty which are for opioids.--
--Which specialties have a high percentage of opioids?--
select 
	Specialty_description,
	round(sum(case 
			when opioid_drug_flag = 'Y'
			then total_claim_count 
			else 0
			end)*100.0 / sum(total_claim_count),2) as percentage_of_claims
from prescriber
	inner join prescription on prescription.npi = prescriber.npi
	inner join drug on prescription.drug_name=drug.drug_name
group by specialty_description
order by percentage_of_claims desc;

----README_BONUS-----

--How many npi numbers appear in the prescriber table but not in the prescription table?--
select count (*) as npi 
from (select npi
	from prescriber
	except
	select npi
	from prescription);

--Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.

select 
	generic_name
from prescriber
	inner join prescription on prescription.npi = prescriber.npi
	inner join drug on prescription.drug_name=drug.drug_name
where specialty_description= 'Family Practice'
group by drug.generic_name
order by sum(prescription.total_claim_count) desc
limit 5;
--Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology--
select 
	generic_name
from prescriber
	inner join prescription on prescription.npi = prescriber.npi
	inner join drug on prescription.drug_name=drug.drug_name
where specialty_description= 'Cardiology'
group by generic_name
order by sum(prescription.total_claim_count) desc
limit 5;

--Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists?--
--Combine what you did for parts a and b into a single query to answer this question--
(select 
	generic_name,'Family Practice' as specialty_description 
from prescriber
	inner join prescription on prescription.npi = prescriber.npi
	inner join drug on prescription.drug_name=drug.drug_name
where specialty_description= 'Family Practice'
group by drug.generic_name
order by sum(prescription.total_claim_count) desc
limit 5 ) 
union
(select 
	generic_name,'cardiology'as specialty_description
from prescriber
	inner join prescription on prescription.npi = prescriber.npi
	inner join drug on prescription.drug_name=drug.drug_name
where specialty_description= 'Cardiology'
group by generic_name
order by sum(prescription.total_claim_count) desc
limit 5);

--First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims 
--(total_claim_count) across all drugs.--
--Report the npi, the total number of claims, and include a column showing the city.
select
	prescriber.npi,nppes_provider_city,sum(total_claim_count)as total_claims
from prescriber
inner join prescription on prescriber.npi =prescription.npi
where nppes_provider_city ilike '%nashville%'
group by prescriber.npi,nppes_provider_city
order by total_claims desc
limit 5;

--Now, report the same for Memphis--
select
	prescriber.npi,nppes_provider_city,sum(total_claim_count)as total_claims
from prescriber
inner join prescription on prescriber.npi =prescription.npi
where nppes_provider_city ilike '%memphis%'
group by prescriber.npi,nppes_provider_city
order by total_claims desc
limit 5;

--Combine your results from a and b, along with the results for Knoxville and Chattanooga.--
(select
	prescriber.npi,'Nashville' as nppes_provider_city,sum(total_claim_count)as total_claims
from prescriber
inner join prescription on prescriber.npi =prescription.npi
where nppes_provider_city ilike '%nashville%'
group by prescriber.npi,nppes_provider_city
order by total_claims desc
limit 5)
union
(select
	prescriber.npi,'Memphis' as nppes_provider_city,sum(total_claim_count)as total_claims
from prescriber
inner join prescription on prescriber.npi =prescription.npi
where nppes_provider_city ilike '%memphis%'
group by prescriber.npi,nppes_provider_city
order by total_claims desc
limit 5)
union
(select
	prescriber.npi,'Knoxville' as nppes_provider_city,sum(total_claim_count)as total_claims
from prescriber
inner join prescription on prescriber.npi =prescription.npi
where nppes_provider_city ilike '%knoxville%'
group by prescriber.npi,nppes_provider_city
order by total_claims desc
limit 5)
union
(select
	prescriber.npi,'Chattanooga' as nppes_provider_city,sum(total_claim_count)as total_claims
from prescriber
inner join prescription on prescriber.npi =prescription.npi
where nppes_provider_city ilike '%chattanooga%'
group by prescriber.npi,nppes_provider_city
order by total_claims desc
limit 5)
order by total_claims desc;

--. Find all counties which had an above-average number of overdose deaths.--
--Report the county name and number of overdose deaths--
SELECT
    county,
    SUM(overdose_deaths) AS total_overdose_deaths
FROM overdose_deaths
INNER JOIN fips_county
    ON fips_county.fipscounty::numeric = overdose_deaths.fipscounty
GROUP BY county
HAVING SUM(overdose_deaths) > (
    SELECT AVG(total_deaths)
    FROM (
        SELECT
            SUM(overdose_deaths) AS total_deaths
        FROM overdose_deaths
        GROUP BY fipscounty
    ) AS county_totals
)
ORDER BY total_overdose_deaths DESC;

--Write a query that finds the total population of Tennessee--
select sum(population) as population_TN
from population
	inner join fips_county on fips_county.fipscounty=population.fipscounty
where state = 'TN';	

--Build off of the query that you wrote in part a to write a query that returns for each county that county's name, --
--its population, and the percentage of the total population of Tennessee that is contained in that county.--
select county,population,round((population*100.0)/(select sum(population) as population_TN
from population
	inner join fips_county on fips_county.fipscounty=population.fipscounty
where state = 'TN'),2) as percent_of_TNpop
from population
	inner join fips_county on fips_county.fipscounty=population.fipscounty
where state = 'TN'
order by percent_of_TNpop desc


