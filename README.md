# Assessment of Mobile Fraud in PaySim, 2016

## 1. Business Problem

Mobile money platforms process large volumes of transactions, making it difficult to identify fraudulent activity using transaction-level monitoring alone.

This project analyzes the **PaySim mobile money transaction dataset** to identify transaction characteristics and behavioral patterns associated with fraud.

### Business Goal

The analysis aims to answer:

- Which transaction types are most exposed to fraud?
- Does transaction amount influence fraud risk?
- When do fraudulent transactions occur most frequently?
- Are fraud events concentrated around particular accounts or transaction segments?

The final output is an **SQL-based fraud analysis pipeline, Python statistical validation, and an interactive Power BI dashboard**.

---

## 2. Data Structure & Overview

### Dataset

PaySim is a simulated mobile money transaction dataset containing approximately **6.36 million transactions**.

### Key Fields

| Column | Description |
|---|---|
| `step` | Simulation time step |
| `type` | Transaction type |
| `amount` | Transaction amount |
| `isFraud` | Fraud indicator (0/1) |

### Data Pipeline

```text
PaySim CSV
    ↓
PostgreSQL Staging
    ↓
Data Cleaning & Feature Engineering
    ↓
SQL Fraud Analysis
    ↓
Python Statistical Validation
    ↓
Power BI Dashboard
```

### Derived Fields

The SQL layer created additional analytical variables including:

- Simulation day
- Hour of day
- Transaction amount bands

---

## 3. Executive Summary

The analysis identified several clear fraud-risk patterns.

### Overall Fraud Exposure

| KPI | Result |
|---|---:|
| Total transactions | **6.36M** |
| Total transaction volume | **₹11.44T** |
| Fraud transactions | **8,197** |
| Overall fraud rate | **0.1288%** |
| Fraud transaction volume | **₹12.06B** |

### Key Findings

**1. Fraud is concentrated in TRANSFER and CASH_OUT transactions**

All observed fraudulent transactions occurred in these two transaction types:

- **CASH_OUT:** 4,100 fraud transactions
- **TRANSFER:** 4,097 fraud transactions

Payment, debit, and cash-in transactions had no observed fraud transactions in the dataset.

**2. Higher-value transactions have substantially higher fraud rates**

The `500K+` transaction segment had a fraud rate of **1.1355%**, compared with **0.0364%** for transactions below `50K`.

This represents approximately a **31× higher fraud rate** in the `500K+` segment.

**3. Fraud is concentrated in specific time periods**

Fraud rates increased substantially during certain overnight hours, particularly the **early-morning period**.

However, these periods also have relatively low transaction volumes. High fraud percentages during low-volume periods should therefore be interpreted alongside the underlying number of transactions.

**4. Fraudulent transaction amounts are materially higher**

| Metric | Non-Fraud | Fraud |
|---|---:|---:|
| Median transaction amount | ₹74.7K | **₹442.3K** |
| Mean transaction amount | ₹178.2K | **₹1.47M** |

Fraudulent transactions therefore have a substantially higher transaction-value distribution than non-fraudulent transactions.

---

## 4. Insights Deep Dive

## 4.1 Fraud by Transaction Type

| Transaction Type | Fraud Transactions | Fraud Rate |
|---|---:|---:|
| CASH_OUT | **4,100** | ~0.18% |
| TRANSFER | **4,097** | ~0.77% |
| PAYMENT | 0 | 0% |
| DEBIT | 0 | 0% |
| CASH_IN | 0 | 0% |

### Interpretation

Although CASH_OUT has the larger absolute number of fraud transactions, **TRANSFER has the higher fraud rate relative to its transaction volume**.

This indicates that transaction type should be an important variable in fraud-monitoring strategies.

---

## 4.2 Fraud by Transaction Amount

| Amount Band | Total Transactions | Fraud Transactions | Fraud Rate |
|---|---:|---:|---:|
| `<50K` | 2,805,931 | 1,022 | **0.0364%** |
| `50K–100K` | 719,309 | 669 | **0.0930%** |
| `100K–200K` | 1,163,794 | 1,035 | **0.0889%** |
| `200K–500K` | 1,333,286 | 1,607 | **0.1205%** |
| `500K+` | 340,284 | **3,864** | **1.1355%** |

### Interpretation

The `500K+` segment has a disproportionately high fraud rate.

It contains only a relatively small share of all transactions but accounts for a large share of fraud events, making high-value transactions an important segment for enhanced monitoring.

---

## 4.3 Transaction Amount Distribution

The Python analysis found substantial differences between fraudulent and non-fraudulent transaction amounts.

### Median Transaction Amount

- Non-fraud: **₹74.7K**
- Fraud: **₹442.3K**

### Mean Transaction Amount

- Non-fraud: **₹178.2K**
- Fraud: **₹1.47M**

The large gap between the mean and median also demonstrates the **right-skewed nature of transaction values**, particularly among fraudulent transactions.

---

## 4.4 Fraud by Time

Analysis of transaction hour and simulation day showed that fraud activity varies considerably across time.

The strongest fraud-rate concentrations occurred during **overnight and early-morning hours**, with some day/hour combinations producing very high percentages.

However, these percentages must be interpreted carefully because some combinations contain relatively few transactions.

### Business Implication

Time-based transaction monitoring could assign additional risk to unusual overnight activity, particularly when combined with:

- High transaction amounts
- TRANSFER transactions
- CASH_OUT transactions

---

## 4.5 Fraud by Day and Amount Segment

The dashboard analysis showed that fraud risk varies by the combination of:

- Day of week
- Hour of day
- Transaction amount

High-value segments, particularly `500K+`, showed the largest fluctuations in fraud rate across different periods.

This supports using **multi-dimensional risk segmentation** instead of relying on a single rule such as transaction amount alone.

---

## 5. Statistical Validation

Python was used to statistically validate the patterns identified through SQL and Power BI.

### Mann–Whitney U Test

The transaction amount distributions of fraud and non-fraud transactions were compared using the **Mann–Whitney U test**.

**Result:**

```text
p < 0.0001
```

### Interpretation

There is strong statistical evidence that fraudulent and non-fraudulent transactions have different transaction-amount distributions.

This supports the observed difference in median transaction amounts.

### Chi-Square Test: Transaction Type vs Fraud

A Chi-square test was used to test whether fraud occurrence is associated with transaction type.

**Result:**

```text
p < 0.0001
```

Therefore, fraud occurrence is statistically associated with transaction type.

### Effect Size

Cramér's V:

```text
0.059
```

This indicates that the association is **weak**, despite being statistically significant.

### Chi-Square Test: Amount Band vs Fraud

A second Chi-square test evaluated the relationship between transaction amount band and fraud.

**Result:**

```text
p < 0.0001
```

Cramér's V:

```text
0.067
```

Again, the association is statistically significant but **weak in overall effect size**.

### Interpretation

The very large dataset means relatively small differences can produce extremely small p-values. Therefore, statistical significance should not be interpreted as strong predictive power or causation.

---

## 6. Power BI Dashboard

The Power BI dashboard contains three analytical pages.

### Page 1 — Transaction Volume

- Transaction volume by day of week
- Transaction volume by hour
- Transaction volume by simulation day
- Overall transaction and fraud KPIs
  
<img width="372" height="266" alt="1a" src="https://github.com/user-attachments/assets/74727440-8053-495c-bde6-f7d0d25c9b29" />
<img width="845" height="394" alt="1b" src="https://github.com/user-attachments/assets/b8f3cd3a-a21a-412c-9d6d-1e72dbc0e380" />
<img width="847" height="389" alt="1c" src="https://github.com/user-attachments/assets/2774118a-4d1e-4ef4-98e3-d47222f73194" />

### Page 2 — Fraud Distribution

- Fraud by transaction amount
- Fraud by transaction type
- Fraud distribution by day
- Fraud distribution by time period
- Fraud-risk segmentation by amount and transaction type

<img width="458" height="131" alt="2a" src="https://github.com/user-attachments/assets/68c594aa-1432-4408-b6b4-e225e3a20ff4" /><img width="195" height="330" alt="2c" src="https://github.com/user-attachments/assets/fd5285b8-37f2-4257-be9b-890824312567" />
<img width="459" height="203" alt="2b" src="https://github.com/user-attachments/assets/c168347f-a967-41e5-a384-d3a2735725ff" />

### Page 3 — Fraud Percentage Matrix

- Fraud rate by day and hour
- Comparison of high-value transaction risk across time
  
<img width="650" height="333" alt="3a" src="https://github.com/user-attachments/assets/d0e95c04-4f48-498f-ae17-bd9101e5e98d" />

---

## 7. Recommendations

Based on the analysis, the following areas warrant greater attention in transaction monitoring:

1. **Prioritize TRANSFER and CASH_OUT transactions** for enhanced fraud monitoring.
2. Apply additional scrutiny to **high-value transactions**, particularly those above `₹500K`.
3. Consider **time-of-day risk factors**, especially unusual overnight activity.
4. Combine transaction type, amount, and time rather than relying on a single fraud rule.
5. Use transaction volume alongside fraud rate to avoid overreacting to high percentages generated from very small populations.

---

## 8. Next Steps

### 1. Evaluate Transaction-Monitoring Thresholds

Test thresholds such as:

```text
₹50K
₹100K
₹200K
₹300K
₹500K
₹1M
```

and calculate:

- Transactions flagged
- Fraud transactions captured
- Precision
- Recall
- Percentage of transactions flagged

This would help determine whether a monetary threshold can be used effectively as a fraud-screening rule.

### 2. Build a Predictive Fraud Model

A future phase could evaluate models such as:

- Logistic Regression
- Random Forest
- XGBoost

using transaction amount, type, time, balance changes, and account behavior as predictors.

### 3. Add Real-World Transaction Monitoring Metrics

Future analysis could include:

- False-positive rate
- False-negative rate
- Cost of investigation
- Financial loss avoided
- Alert volume

---

## 9. Limitations

- **PaySim is simulated data**, so the observed relationships may not represent real-world mobile-money fraud behavior.
- The dataset's `step` variable represents simulation time rather than an actual calendar date.
- The Monday–Sunday grouping used in the dashboard assumes a starting weekday and is therefore an analytical convention rather than a confirmed real-world calendar mapping.
- Fraud is extremely rare relative to legitimate transactions, creating a highly imbalanced classification problem.
- Statistical significance does not imply causation.
- Cramér's V indicates that the associations between fraud and both transaction type and amount band are relatively weak overall.
- Account-level patterns may be limited by the structure of the simulated dataset.

---

## 10. Tools Used

- **PostgreSQL** — data ingestion, cleaning, transformation, aggregation, and analysis
- **Python** — statistical analysis and validation
- **Pandas / NumPy** — data manipulation
- **SciPy** — statistical testing
- **Matplotlib / Seaborn** — exploratory visualization
- **Power BI** — interactive dashboard and business reporting
- **SQL** — fraud segmentation, time analysis, and KPI generation

---

## Project Outcome

This project demonstrates an end-to-end fraud analytics workflow:

```text
Raw Data
   ↓
Data Cleaning
   ↓
Exploratory Analysis
   ↓
SQL Fraud Segmentation
   ↓
Statistical Validation
   ↓
Power BI Visualization
   ↓
Business Insights & Recommendations
```

The analysis shows that **fraud risk is disproportionately concentrated in TRANSFER and CASH_OUT transactions, particularly within high-value transactions, with additional variation across time periods**. These findings provide a basis for more targeted transaction-monitoring strategies while highlighting the need to consider transaction volume and statistical effect size when interpreting fraud patterns.
