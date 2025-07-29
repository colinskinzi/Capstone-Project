--Explore the Fintech data

--From Bigquery Envioronment, there is 2 data set
--Loan Data Table
| Row | loan_id | customer_id                                | loan_status | loan_amount | state | funded_amount | term        | int_rate | installment | grade | issue_d | issue_date   | issue_year | pymnt_plan | application type | application purpose | application description      | application notes |
|-----|---------|---------------------------------------------|-------------|-------------|-------|----------------|-------------|----------|-------------|-------|---------|--------------|-------------|-------------|-------------------|----------------------|------------------------------|-------------------|
| 1   | 25089   | QWW+mlpAqeF0RUozuxD2hi/fGARZCe3XHP+l1zvMRbk= | Current     | 5000        | NY    | 5000           | 36 months  | 0.0531   | 150.56      | A     | Apr-18  | April 2018   | 2018        | false       | Individual         | credit_card          | Credit card refinancing      | desc              |
| 2   | 82474   | m1DtUg34EUQTD8+5flFovzZsNH3OCHUDTPkc+9gwkDs= | Current     | 10000       | GA    | 10000          | 36 months  | 0.0531   | 301.11      | A     | Apr-18  | April 2018   | 2018        | false       | Joint App          | home_improvement      | Home improvement             | desc              |
| 3   | 99461   | 0+fwSz95b3cy/C6t53bzQCXNh6HS87SvFOf888dj2ZI= | Current     | 10000       | MI    | 10000          | 60 months  | 0.0531   | 190.14      | A     | Apr-18  | April 2018   | 2018        | false       | Individual         | credit_card          | Credit card refinancing      | desc              |
| 4   | 109050  | jR6sbnOr9VcMSv9G9cjP/pOORKmRUf0hsoA2R3ed5U4= | Current     | 11000       | NY    | 11000          | 36 months  | 0.0531   | 331.22      | A     | Apr-18  | April 2018   | 2018        | false       | Individual         | credit_card_

--Customer Data Table
| Row | customer_id                                 | emp_title | emp_length | home_ownership | annual_inc | annual_inc_joint | verification_status | zip_code | addr_state | avg_cur_bal | Tot_cur_bal |
|-----|----------------------------------------------|-----------|------------|----------------|------------|------------------|---------------------|----------|------------|--------------|-------------|
| 1   | a09IasaZyPhDgLUWaKTM7TYBeafaeVOS58TnF4bST1E= | null      | n/a        | ANY            | 28000.0    | null             | Not Verified        | 027xx    | MA         | 575          | 10352       |
| 2   | l1tElcblED+YLpHP1HObw8z0m1gDmh0nkBbDTeSyqjs= | null      | n/a        | ANY            | 98000.0    | null             | Not Verified        | 117xx    | NY         | 2793         | 30724       |
| 3   | 6AlfXSLHKvyLkb1t6CqwH3V+0HEPF2oDLfyV7sAQxjk= | null      | n/a        | ANY            | 173005.0   | null             | Not Verified        | 117xx    | NY         | 32031        | 512493      |

--an adiditional data set of US states i.e Region and sub-regions this is useful to track loan data by state or region. 
--Sql code to improt the data 

LOAD DATA OVERWRITE fintech.state_region
state string,
subregion string,
region string
)
FROM FILES (
format = 'CSV',
uris = ['gs://sureskills-lab-dev/future-workforce/da-capstone/temp_35_us/state_region_mapping/state_region_*.csv']);

--Result

| Row | State | Subregion            | Region  |
|-----|-------|----------------------|---------|
| 1   | IL    | East North Central   | Midwest |
| 2   | IN    | East North Central   | Midwest |
| 3   | MI    | East North Central   | Midwest |
| 4   | OH    | East North Central   | Midwest |
| 5   | WI    | East North Central   | Midwest |
| 6   | IA    | West North Central   | Midwest |
| 7   | KS    | West North Central   | Midwest |
| 8   | MN    | West North Central   | Midwest |
| 9   | MO    | West North Central   | Midwest |
| 10  | ND    | West North Central   | Midwest |

-- this creates a **State_region data Table**


--using the data from the tables I create a **Loan_with_region data set** by using a INNER JOIN the 2 table to creat a single report for **loan_id, loan_amount, and region**
-- using CTAS

CREATE OR REPLACE TABLE fintech.loan_with_region AS
SELECT
lo.loan_id,
lo.loan_amount,
sr.region
FROM fintech.loan lo
INNER JOIN fintech.state_region sr
ON lo.state = sr.state;

--Result

| Row | loan_id | loan_amount | Region  |
|-----|---------|-------------|---------|
| 1   | 211133  | 22400       | Midwest |
| 2   | 211080  | 22400       | Midwest |
| 3   | 211163  | 22400       | Midwest |
| 4   | 211191  | 22400       | Midwest |
| 5   | 211220  | 22400       | Midwest |
| 6   | 211236  | 22400       | Midwest |
| 7   | 211160  | 22400       | Midwest |
| 8   | 211111  | 22400       | Midwest |
| 9   | 211266  | 22400       | Midwest |
| 10  | 211121  | 22400       | Midwest |

-- using the table created Open a connected sheets for the Tresury team to be able to access this data. 

--Working with nested data to create a table for Loan Purpose as well as **deduplcate the data** using **DIISTINCT** 

CREATE TABLE fintech.loan_purpose AS
SELECT  DISTINCT(application.purpose)
FROM fintech.loan;

--Result

| Row | Purpose            |
|-----|--------------------|
| 1   | house              |
| 2   | car                |
| 3   | medical            |
| 4   | renewable_energy   |
| 5   | wedding            |
| 6   | moving             |
| 7   | home_improvement   |
| 8   | other              |
| 9   | credit_card        |
| 10  | debt_consolidation |


--Answering the business questions with a report  **'Total amount in loans issued by year'** 
CREATE TABLE fintech.loan_by_year AS
SELECT issue_year, sum(loan_amount) AS total_amount
FROM fintech.loan
GROUP BY issue_year;

--Result

| Row | Issue Year | Total Amount   |
|-----|------------|----------------|
| 1   | 2019       | 852,355,425    |
| 2   | 2018       | 791,875,900    |
| 3   | 2017       | 660,671,850    |
| 4   | 2016       | 638,631,475    |
| 5   | 2015       | 639,434,375    |
| 6   | 2014       | 348,272,975    |
| 7   | 2013       | 199,362,825    |
| 8   | 2012       | 35,467,575     |


--Creating a table that counts loans grouped by year

CREATE TABLE fintech.loan_count_by_year  AS 
SELECT issue_year, COUNT(loan_id) AS loan_count
FROM fintech.loan
GROUP BY issue_year
ORDER BY issue_year DESC;

--Result

| Row | Issue Year | Loan Count |
|-----|------------|------------|
| 1   | 2019       | 51,737     |
| 2   | 2018       | 49,333     |
| 3   | 2017       | 44,435     |
| 4   | 2016       | 43,368     |
| 5   | 2015       | 41,919     |
| 6   | 2014       | 23,453     |
| 7   | 2013       | 13,460     |
| 8   | 2012       | 2,594      |








