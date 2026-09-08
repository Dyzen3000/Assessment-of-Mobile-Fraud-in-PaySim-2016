# Mobile Money Fraud Analytics(In Progress)

An end-to-end fraud analytics project analyzing 6M+ simulated mobile-money transactions using **PostgreSQL, Python, and Power BI** to identify fraudulent transaction patterns, evaluate existing fraud-monitoring controls, and quantify transaction-level risk.

---

## Project Overview

Fraud detection in digital financial services requires identifying unusual transaction patterns while minimizing false alerts.

This project analyzes the **PaySim mobile money transaction dataset**, a synthetic dataset based on real mobile-money transaction patterns. The analysis focuses on understanding fraudulent behavior as well as identifying high-risk transaction segments.

### Business Objective

> Identify transaction patterns associated with fraudulent activity and evaluate how effectively existing transaction-monitoring controls detect fraudulent transactions.

---

## Business Questions

The analysis aims to answer:

- What proportion of transactions are fraudulent?
- Which transaction types have the highest fraud rates?
- How does transaction amount differ between fraudulent and non-fraudulent transactions?
- At what times does fraudulent activity occur most frequently?
- How concentrated is fraud among customers and recipients?
- How effective is the existing `isFlaggedFraud` rule?
- How many fraudulent transactions are missed by the existing rule?
- What transaction characteristics could be used to improve fraud monitoring?

---

## Dataset

The project uses the **PaySim** synthetic mobile-money transaction dataset.

The dataset contains approximately **6.3 million transactions** across a simulated period of approximately 30 days.

### Key Columns

| Column | Description |
|---|---|
| `step` | Time step; each step represents 1 hour |
| `type` | Transaction type |
| `amount` | Transaction amount |
| `nameOrig` | Customer initiating the transaction |
| `nameDest` | Recipient of the transaction |
| `isFraud` | Indicates whether the transaction was fraudulent |
| `isFlaggedFraud` | Indicates whether the existing monitoring rule flagged the transaction |

### Transaction Types

- `PAYMENT`
- `TRANSFER`
- `CASH_OUT`
- `CASH_IN`
- `DEBIT`

---

## Data Leakage Consideration

The dataset documentation states that fraudulent transactions are cancelled. Therefore, the following balance-related columns are **excluded from fraud-detection features**:

- `oldbalanceOrg`
- `newbalanceOrig`
- `oldbalanceDest`
- `newbalanceDest`

These fields may contain information that would not be available at the point when a fraud-detection decision needs to be made.

The columns are retained in the raw dataset for reference and data-quality analysis but are not used as predictive features.

---

## Tools & Technologies

### SQL
- PostgreSQL
- Data cleaning
- Aggregations
- CTEs
- Window functions
- CASE statements
- Fraud metrics
- Customer-level analysis

### Python
- Pandas
- NumPy
- Matplotlib
- Seaborn
- Exploratory Data Analysis
- Feature Engineering
- Statistical Analysis
- Machine Learning

### Visualization
- Microsoft Power BI
- DAX
- Interactive dashboards

---

## Analysis

### 1. Transaction Analysis

Analyze transaction volume and value across:

- Transaction types
- Time periods
- Transaction amount ranges
- Hour of day

### 2. Fraud Analysis

Compare fraudulent and non-fraudulent transactions based on:

- Transaction type
- Transaction amount
- Time of transaction
- Customer activity
- Recipient activity

### 3. Customer & Recipient Analysis

Investigate:

- High-volume customers
- High-value customers
- Customers involved in multiple fraudulent transactions
- Recipients associated with suspicious activity
- Repeated originator-recipient relationships

### 4. Fraud Monitoring Effectiveness

Evaluate the existing `isFlaggedFraud` rule against the actual fraud label.

The analysis includes:

- True Positives
- False Positives
- True Negatives
- False Negatives
- Precision
- Recall
- False Positive Rate
- Fraud Miss Rate

---

## Power BI Dashboard

The Power BI dashboard is organized into three analytical areas:

### Executive Fraud Overview

Provides a high-level view of:

- Total transactions
- Total transaction value
- Fraud transactions
- Fraud rate
- Fraud value
- Fraud value as a percentage of total transaction value

### Fraud Behavior

Explores:

- Fraud by transaction type
- Fraud by transaction amount
- Fraud over time
- Fraud by hour
- Fraudulent transaction patterns

### Monitoring Effectiveness

Evaluates:

- Existing fraud flags
- Detection rate
- Missed fraud
- False alerts
- Performance of the existing transaction-monitoring rule

---

## Advanced Analysis

The project may also include a fraud-risk analysis using transaction-level behavioral features such as:

- Transaction amount
- Transaction type
- Hour of transaction
- Customer transaction frequency
- Recipient transaction frequency
- Previous transaction behavior
- Transaction velocity

Any predictive modeling will account for the severe class imbalance and avoid temporal/data leakage.

---

## Project Structure

```text
Mobile-Money-Fraud-Analytics/
│
├── data/
│   └── README.md
│
├── sql/
│   ├── 01_data_quality.sql
│   ├── 02_transaction_analysis.sql
│   ├── 03_fraud_analysis.sql
│   ├── 04_customer_analysis.sql
│   └── 05_monitoring_effectiveness.sql
│
├── python/
│   ├── 01_eda.ipynb
│   ├── 02_feature_engineering.ipynb
│   └── 03_fraud_model.ipynb
│
├── powerbi/
│   └── fraud_analytics.pbix
│
├── screenshots/
│   ├── executive_overview.png
│   ├── fraud_behavior.png
│   └── monitoring_effectiveness.png
│
├── README.md
└── requirements.txt
