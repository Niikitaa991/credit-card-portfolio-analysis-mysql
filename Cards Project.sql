
-- ==============================================================================================================================================================================================
-- Project: Credit Card Portfolio Analysis for Business Growth and Customer Insights
-- Author:  <NIKITA PAWAR>
-- Date:    <2026-08>
-- Database: MySQL
-- Dataset: Cards_Data.csv (CREDIT CARD PORTFOLIO DATA)
-- Purpose: End-to-end data analysis project for a data analyst portfolio
--          - Data cleaning and preparation
--          - Exploratory analysis of card types, networks, and status
--          - Advanced analysis to answer business questions
--          - Insights and recommendations for marketing, product, and risk teams
-- SECTION 1: DATA LOADING & CLEANING
-- ----------------------------------------------------------------------------
-- (Create table, import CSV, standardize text, handle nulls, create derived columns)

SELECT * FROM bank.cards_data;
 -- See First Few Rows
 select * from cards_data
 limit 10;
 
 -- Chech the DataType
 describe cards_data;
 
 alter table cards_data
 modify Issue_Date Date,
 modify Expiry_Date Date;
 
 -- Checking the Duplicates
select Card_ID, count(*) as duplicate_count from cards_data
group by Card_ID
having duplicate_count>1;

select Customer_ID, count(*) as duplicate_count from cards_data
group by Customer_ID
having duplicate_count>1;


-- Duplicates where removed
select * from (SELECT 
    Card_ID,
    Customer_ID,
    Card_Type,
    Card_Network,
    Credit_Limit,
    Card_Status,
    Contactless,
    Card_Mode,
    Issue_Date,
    Expiry_Date,
    ROW_NUMBER() OVER (
        PARTITION BY Customer_ID 
        ORDER BY Card_ID
    ) AS row_num
FROM cards_data) as dp
where row_num=1;

--  Check distinct values of key columns
select distinct Card_Type from cards_data;
select distinct Card_Network from cards_data;
select distinct Card_Status from cards_data;
select distinct Contactless from cards_data;
select distinct Card_Mode from cards_data;

-- cleaning messy text,data ,inconsistent cases 
UPDATE Cards_Data
SET Card_Status = TRIM(UPPER(Card_Status));

update cards_data 
set Contactless =trim(upper(Contactless));

update cards_data
set Card_Mode =trim(upper(Card_Mode));

update cards_data
set Card_Type =trim(upper(Card_Type));
-- SECTION 2: EXPLORATORY ANALYSIS
-- ----------------------------------------------------------------------------
-- (Basic counts, distributions, averages by card type, network, status, etc.)

-- Creating useful derived columns
-- 1] Creating card age column so as to get the age of the issued card

alter table cards_data
add column Card_Age int;

UPDATE cards_data 
SET 
    Card_Age = TIMESTAMPDIFF(MONTH,
        Issue_date,
        CURDATE());

-- Added a premimun flag 1=[PLATINUM/GOLD] 0=[SILVER/CLASSIC]
alter table cards_data
add column Premiun_Cards tinyint;

UPDATE cards_data 
SET 
    Premiun_Cards = CASE
        WHEN Card_Type IN ('PLATIMUN ' , 'GOLD') THEN 1
        ELSE 0
    END;   

-- Categorizing card age band 
alter table cards_data
add column Age_Band varchar(20) ;

UPDATE cards_data 
SET 
    Age_band = CASE
        WHEN Card_Age <= 12 THEN '0-12M'
        WHEN Card_Age <= 24 THEN '12-24M'
        WHEN Card_Age <= 36 THEN '24-36M'
        WHEN Card_Age <= 48 THEN '36-48M'
        ELSE '48+'
    END;

-- Creating a column for status of card
alter table cards_data
add column Status_Of_Card varchar(20);

UPDATE cards_data 
SET 
    Status_Of_Card = CASE
        WHEN Card_Status IN ('ACTIVE') THEN 'ACTIVE_CARD'
        WHEN Card_Status IN ('EXPIRED' , 'LOST', 'BLOCKED') THEN 'AT_RISK'
        ELSE 'OTHER'
    END;
SELECT 
    *
FROM
    cards_data;

-- Creadit Limit column categorized
alter table cards_data
add column Limit_band VARCHAR(20);

UPDATE cards_data 
SET 
    Limit_band = CASE
        WHEN Credit_Limit <= 50000 THEN '0-50k'
        WHEN Credit_Limit <= 100000 THEN '50k-1 lacs'
        WHEN Credit_Limit <= 500000 THEN '1-5 lacs'
        WHEN Credit_Limit <= 1000000 THEN '5-10 lacs'
        WHEN Credit_Limit <= 1500000 THEN '10-15 lacs'
        ELSE 'EXCEPTIONAL'
    END;
    
    -- Added a  column name Expering Cards 
alter table cards_data
add column Expiring_cards varchar(20);

UPDATE cards_data 
SET 
    Expiring_cards = CASE
        WHEN Expiry_Date <= DATE_ADD(CURDATE(), INTERVAL 6 MONTH) THEN 'SOON'
        ELSE 'NOT_SOON'
    END;
    
    -- Added column Issuance Month 
    alter table cards_data
    add column Issued_Month varchar(20);
    
UPDATE cards_data 
SET 
    Issued_Month = DATE_FORMAT(Issue_Date, '%b');
select * FROM cards_data;

--  Basic portfolio overview (EDA)
-- These queries give you the “story” of the portfolio.

-- 1 Total cards and customers
SELECT 
    COUNT(*) AS Total_Cards,
    COUNT(DISTINCT (Customer_ID)) AS Total_Customers
FROM
    cards_data;
 -- 1.1.2 Distinct counts of key fields
SELECT 
    COUNT(DISTINCT Card_Type) AS card_types,
    COUNT(DISTINCT Card_Network) AS card_networks,
    COUNT(DISTINCT Status_Of_Card) AS status_types,
    COUNT(DISTINCT Limit_band) AS limit_bands,
    COUNT(DISTINCT Age_Band) AS age_bands
FROM Cards_Data;
select * from cards_data;
-- Status of card distribution in percentage 
SELECT 
    Status_Of_Card,
    COUNT(*) AS card_count,
    ROUND(COUNT(*) * 100.0 / (SELECT 
                    COUNT(*)
                FROM
                    cards_data),
            2) AS total_prct
FROM
    cards_data
GROUP BY Status_Of_Card
ORDER BY card_count DESC;

-- Age band of card distributio in percentage
select Age_Band,
count(*) as count_age_band,
round(count(*) * 100.0 /(select count(*) from cards_data),2) as total_prct
from cards_data
group by Age_Band
order by count_age_band;

-- Limit band of cards distribution in percentage
select Limit_band,
count(*) as count_of_limits,
round(count(*)* 100.0 /(select count(*) from cards_data),2)as total_prct
from cards_data
group by Limit_band
order by count_of_limits desc;

-- Expiring cards in perecentage
select Expiring_cards,
count(*) as count_expiring_cards,
round(count(*)*100.0 /(select count(*) from cards_data),2) as total_prct
from cards_data
group by Expiring_cards
order by count_expiring_cards;

-- Cards Issued in which month
select Issued_Month,
count(*) as count_of_cards
from cards_data
group by Issued_Month
order by count_of_cards desc;

-- Premium cards distribution in percentage
select Premiun_Cards,
count(*) as count_Prm_cards,
round(count(*)* 100.0 /(select count(*) from cards_data),2)as total_prct
 from cards_data
group by Premiun_Cards;
-- ----------------------------------------------------------------------------
-- SECTION 3: ADVANCED ANALYSIS & BUSINESS QUESTIONS
-- ----------------------------------------------------------------------------
-- (CTEs, window functions, segmentation, revenue/credit-limit analysis, etc.)

-- PROBLEM STATEMENT -1
-- Top-Performing Cards (Revenue & Growth Focus)

-- Top card type–network by total credit limit (Active cards only)
select Card_Type,Card_Network,
count(*) as active_cards
from cards_data
where Status_Of_Card = 'ACTIVE_CARD'
group by Card_Type,Card_Network
order by active_cards desc
limit 10;

-- Key Insights – Top-Performing Cards
-- Gold cards dominate the active portfolio; all top 4 card type–network combinations are Gold.
-- Gold–American Express (2,387) and Gold–RuPay (2,335) have the highest number of active cards.
-- Silver cards are the second most active tier, with similar counts across all networks.
-- Classic cards appear only after Gold and Silver, indicating lower active usage.
-- Within each tier, network distribution (Amex, RuPay, Visa, Mastercard) is fairly balanced.
-- ========================================================================================================================================
-- Recommendations
-- Prioritize Gold cards (especially Amex and RuPay) in marketing and growth campaigns.
-- Create upgrade paths from Silver/Classic to Gold for high-usage customers.
-- Improve Classic card activation with targeted offers or reposition as a digital-first entry product.
-- Leverage Amex and RuPay partnerships for co-branded offers to boost usage.
-- Monitor risk while expanding Gold issuance (track limits, utilization, and delinquencies).


-- Performance by Limit_band and Premiun_Cards
select Limit_band,Premiun_Cards,
count(*) as total_cards
from cards_data
where Premiun_Cards = '1'
group by Limit_band,Premiun_Cards
order by total_cards  desc;

-- Ranking limit bands by total credit limit

with Ranking_Limit as
(select 
Limit_band,
count(*) as Total_cards,
sum(case when Status_Of_Card ='ACTIVE_CARD' THEN 1 ELSE 0 end) as active_cards,
sum(Credit_Limit) as Total_Credit_Given
from cards_data
group by Limit_band)
select *, 
Rank() over(order by Total_Credit_Given desc) as rank_by_credit,
round(active_cards *100.0/ Total_cards) as Active_rate_prnt
from Ranking_Limit;

-- Key Insights – Premium Cards & Limit Bands
-- Almost all premium cards (Premiun_Cards = '1') are split evenly between the 1–5 lacs (5,012 cards) and 5–10 lacs (4,961 cards) limit bands.
-- This shows the bank’s premium portfolio is focused on mid-to-high credit limits, with very few premium cards outside these two bands.
-- The near 50–50 split suggests a deliberate strategy to serve both mass-premium (1–5 lacs) and high-premium (5–10 lacs) customers.
-- =============================================================================================================================================================================================================
-- Recommendations
-- Tailor benefits by limit band:
-- For 1–5 lacs: focus on everyday spend rewards, digital offers, and fee waivers to drive usage.
-- For 5–10 lacs: emphasize travel, lifestyle, and high-value perks to justify higher limits and fees.
-- Use this segmentation in marketing: create separate campaigns for “mass-premium” vs “high-premium” customers instead of treating all premium cards the same.
-- Explore gaps: investigate if there’s an opportunity to introduce ultra-premium products (>10 lacs) or strengthen entry-level premium offerings (<1 lac) if aligned with strategy.


-- PROBLEM STATEMENT -2
--  Customer Segmentation (High/Medium/Low Value)
create or replace view Customer_summary as
select Customer_ID ,
count(*) num_cards,
sum(Credit_Limit) as sum_CL,
max(Credit_Limit) as max_CL,
sum(CASE when Card_Status ='ACTIVE' THEN 1 ELSE 0 END) AS Active_Cards,
max(Premiun_Cards) as max_PC,
sum( case when Expiring_Cards= 'SOON' then 1 else 0 end) as sum_EC,
avg(Card_Age) as avg_Age
from cards_data 
group  by Customer_ID;

select * from Customer_Summary;

--  Customer segmentation view (adjust thresholds to your data)
create or replace view Customer_Segmentation as
select *,
case when sum_CL >= 1000000 then 'HIGH'
when sum_CL >= 400000 then 'MEDIUM'
else 'LOW'
end as Value_Segment
from Customer_Summary;

-- Customer Segmentation Logic
-- Built a Customer_Segmentation view on top of Customer_Summary to classify 
-- customers by total credit limit (sum_CL).
-- Segments:
-- HIGH: sum_CL ≥ 1,000,000
-- MEDIUM: sum_CL ≥ 400,000
-- LOW: sum_CL < 400,000
-- This simple rule-based segmentation helps the bank identify high-value 
-- customers for retention and premium offers, and low-value segments for activation or cross-sell campaigns.

-- ===================================================================================================================================
--  Segmentation of customers
select Value_Segment,
count(*) as num_customers,
avg (num_cards) as AVG_NUM_CARDS,
AVG(sum_CL) as AVG_SUM_CL,
AVG (Active_Cards) as AVG_AC,
sum(sum_EC) as SUM_Expired_CARD,
SUM(max_PC) as SUM_PremiumCards
from Customer_Segmentation
group by Value_Segment
order by 
case Value_Segment
when 'HIGH' THEN 1
WHEN 'MEDIUM' THEN 2
ELSE '3'
END;

-- Key Insights – Customer Segmentation
-- LOW segment is the largest (12,041 customers) but has the lowest avg credit limit (~₹2.04L), fewest cards (1.08), and lowest active cards (1.02).
-- HIGH segment (4,675 customers) has the highest avg credit limit (~₹14.4L), more cards (1.77), and more active cards (1.66), but also many expired cards (3,689).
-- MEDIUM segment (8,284 customers) has mid-range limits (~₹6.34L) and the highest number of premium cards (6,438), showing strong upsell potential.
-- Recommendation
-- HIGH: Focus on retention, exclusive offers, and replacing expired cards to maintain activity.
-- MEDIUM: Push upsell/cross-sell (higher limits, additional cards) to move them toward HIGH.
-- LOW: Drive activation and engagement; identify good-behavior customers for controlled upgrades to MEDIUM.

-- =================================================================================================================================


-- PROBLEM STATEMENT - 3
-- Product performance and risk monitoring with new columns
select card_Type,Status_Of_Card,
count(*) as Total_Num_cards,
round(count(*)*100.0 /sum(count(*)) over (partition by Card_Type),2) as prnt_Card_Type
from cards_data
group by Card_Type,Status_Of_Card
order by Card_Type,prnt_Card_Type desc;

-- Key Insights – Product Performance & Risk
-- Across all card types (Classic, Gold, Platinum, Silver), ~93–94% of cards are active, showing a generally healthy portfolio.
-- At-risk cards are low but consistent (≈5.9–6.5%) across all tiers; Platinum has the highest at-risk rate (6.49%), Classic the lowest (5.89%).
-- No single card type shows a dramatically higher risk rate, suggesting risk is spread evenly rather than concentrated in one product.
-- Recommendations
-- Focus retention on at-risk customers across all tiers (targeted offers, fee waivers, engagement campaigns) since at-risk rates are similar everywhere.
-- Monitor Platinum closely, as it has the highest at-risk percentage despite being a premium tier; investigate reasons (fees, benefits, usage).
-- Use this baseline to track changes over time (e.g., after new campaigns or policy changes) to see if at-risk rates improve.

-- =============================================================================================================================================================================
--  Status distribution by Limit_band
select Limit_band,Status_Of_Card,
count(*) as Total_Num_Cards,
round(count(*) *100.0/sum(count(*)) over (partition by Limit_band),2) as prnt_Of_cards
from cards_data
group by Limit_band,Status_Of_Card
order by limit_band,prnt_Of_cards desc;

-- Key Insights – Risk by Limit Band
-- Across all limit bands (50k–1L, 1–5L, 5–10L, 10–15L), active cards are consistently ~93.6–94%, and at-risk cards are ~6.0–6.4%.
-- Risk is very evenly distributed by credit limit; no band shows a significantly higher or lower at-risk rate.
-- The largest book is in 1–5 lacs (16,642 active cards), so even a small % change here has the biggest portfolio impact.
-- Recommendations
-- Since at-risk rates are similar across bands, focus on universal retention tactics (engagement campaigns, timely renewals, proactive support) rather than limit-band-specific policies.
-- Prioritize 1–5 lacs segment for retention programs because it has the highest volume; small improvements here will reduce the most at-risk cards in absolute terms.
-- =========================================================================================================================================================================================================

--  Expiring cards overview
select Age_Band,
count(*) as total_cards,
sum(case when Expiring_cards ='Soon' then 1 else 0 end) as Exprining_card,
 ROUND(SUM(CASE 
WHEN LOWER(TRIM(Expiring_cards)) = 'SOON' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0),2)
 AS expiring_rate_pct
from cards_data
group by  Age_Band,Expiring_cards
order by 
    CASE Age_Band
        WHEN '0-12M' THEN 1
        WHEN '12-24M' THEN 2
        ELSE 3
    END desc;
    
 -- 5.4 Premium vs non-premium: active and risk rate
 select Status_Of_Card,Premiun_Cards,
 count(*) as total_cards,
 sum(Premiun_Cards) as sum_PC,
 round(sum(Premiun_Cards) *100.0/count(*),2) as prnt_of_PremiumCard
 from cards_data
 group by Status_Of_Card,Premiun_Cards
 order by Status_Of_Card,prnt_of_PremiumCard desc;
 
 -- Monthly issuance and pipeline (using Issued_Month)
 --  Cards issued per month
 select Issued_Month,
 count(*) as total_cards,
 count(distinct Customer_ID) as unique_cust
 from cards_data
 group by Issued_Month
 order by Issued_Month desc;
 
 SELECT
    CardType,
    CardNetwork,
    COUNT(*) AS total_cards,
   SUM(CASE WHEN CardStatus = 'Active' THEN 1 ELSE 0 END) AS active_cards,
    SUM(CASE WHEN CardStatus IN ('Expired', 'Lost', 'Blocked') THEN 1 ELSE 0 END) AS inactive_or_risky_cards,
   ROUND(SUM(CASE WHEN CardStatus IN ('Expired', 'Lost', 'Blocked') THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2
    ) AS inactive_risk_percentage
FROM Cards_Data
GROUP BY CardType, CardNetwork
ORDER BY inactive_risk_percentage DESC;


-- Inactive cards for risk monitering
select * from cards_data;
select Card_Type,Card_Network,
count(*)  as total_cards,
sum(case when Status_Of_Card='ACTIVE_CARD' then 1 else 0 end) as sum_ActiveCard,
sum(case when Status_Of_Card = 'AT_RISK' then 1 else 0 end) as sum_INactiveCards,
round(sum(case when(Status_Of_Card) = 'AT_RISK' then 1 else 0 end) * 100.0/count(*) ,2) 
as prnt_InactiveCards
from cards_data
group by Card_Type,Card_Network
order by prnt_InactiveCards desc;
-- ============================================================================
-- END OF SCRIPT
-- ============================================================================
