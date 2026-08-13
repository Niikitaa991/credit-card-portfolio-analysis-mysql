
# Credit Card Portfolio Analysis (MySQL)

End-to-end MySQL data analysis project on a credit card portfolio.  
Focus: data cleaning, customer segmentation, product performance, risk monitoring, and actionable business insights.

## Business Problem

The bank wants to:
- Understand which card types, networks, and limit bands are driving the highest active usage and credit exposure.  
- Segment customers into HIGH / MEDIUM / LOW value groups to support targeted marketing and retention.  
- Monitor product performance and risk by analyzing the mix of active vs at-risk cards across card types and limit bands.

## What I Did in This Project

### 1. Data Understanding & Cleaning
- Loaded `Cards_Data.csv` into a MySQL table `cards_data`.  
- Standardized text fields (e.g., `Status_Of_Card`, `Card_Type`).  
- Created derived columns such as:
  - `Limit_band` (e.g., 50k–1L, 1–5L, 5–10L, 10–15L)  
  - `Premiun_Cards` flag (1 = premium, 0 = non-premium)  
- Ensured correct data types and handled inconsistencies to make the data analysis-ready.

### 2. Exploratory Analysis
- Analyzed distribution of cards by:
  - `Card_Type` and `Card_Network`  
  - `Status_Of_Card` (ACTIVE_CARD, AT_RISK, etc.)  
  - `Limit_band` and `Premiun_Cards`  
- Identified top card type–network combinations by number of active cards.

### 3. Top-Performing Cards (Revenue & Growth Focus)
- Identified top card type–network pairs for active cards (e.g., Gold–American Express, Gold–RuPay).  
- Analyzed premium cards by limit band (1–5L vs 5–10L).  
- Ranked limit bands by total credit given and calculated active rate percentages using window functions.

### 4. Customer Segmentation
- Built a `Customer_Segmentation` view to classify customers into:
  - **HIGH**: total credit limit ≥ 1,000,000  
  - **MEDIUM**: total credit limit ≥ 400,000  
  - **LOW**: total credit limit < 400,000  
- For each segment, computed:
  - Number of customers  
  - Average number of cards  
  - Average total credit limit  
  - Average active cards  
  - Total expired and premium cards  
- Used this to highlight differences in behavior and potential across segments.

### 5. Product Performance & Risk Monitoring
- Analyzed status distribution by `Card_Type`:
  - Calculated % of ACTIVE_CARD vs AT_RISK within each card type.  
- Analyzed status distribution by `Limit_band`:
  - Calculated % of active vs at-risk cards in each limit band.  
- Identified that at-risk rates are consistent (~6%) across card types and limit bands, indicating portfolio-wide retention opportunities.

### 6. Insights & Recommendations
- Derived business insights such as:
  - Gold cards (especially with American Express and RuPay) dominate the active portfolio.  
  - LOW-value segment is the largest but has the lowest engagement and credit limits.  
  - At-risk rates are similar across all segments, so retention efforts should be broad but prioritized by volume.  
- Provided actionable recommendations for:
  - Product strategy (focus on Gold, manage Platinum risk)  
  - Marketing & segmentation (targeted campaigns for HIGH/MEDIUM/LOW)  
  - Risk & retention (universal retention tactics with focus on high-volume segments)

## Dataset

- `data/Cards_Data.csv` – credit card portfolio data  
  Key columns:  
  `Card_Type`, `Card_Network`, `Credit_Limit`, `Status_Of_Card`, `Limit_band`, `Premiun_Cards`, etc.

## Repository Structure

- `data/` – raw dataset (`Cards_Data.csv`)  
- `sql/` – SQL scripts  
  - `cards_analysis.sql` – full end-to-end script (cleaning, analysis, segmentation, insights)  
- `report/` – detailed project report (insights, recommendations, methodology)  
- `README.md` – this file

## How to Run

1. Import `Cards_Data.csv` into a MySQL database as table `cards_data`.  
2. Open and run `sql/cards_analysis.sql` in your MySQL client (MySQL Workbench, DBeaver, etc.).  
3. Review query outputs and compare with the insights and recommendations in the `report/` folder.

## Tools & Technologies

- MySQL  
- SQL (CTEs, window functions, views, aggregations)  
- (Optional) Excel / Power BI / Tableau for visualization (if you add any later)

## Author

- Nikita Pawar  
- [LinkedIn](<www.linkedin.com/in/nikita-pawar-a15bb2397>) | [Email](mailto:<nikita18j2@gmail.com>) | 
```

