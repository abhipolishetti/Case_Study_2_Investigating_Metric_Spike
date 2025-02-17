# Case Study: Investigating Metric Spike

## 📌 Project Overview
This SQL-based case study investigates unexpected metric spikes in user engagement, email interactions, and product usage using MySQL. The analysis involves data processing, transformations, and querying to extract key business insights.

## 🚀 Technologies Used
- **MySQL**: Database design, queries, and performance optimization
- **SQL Queries**: Aggregations, joins, indexing, and data transformations
- **Data Analysis**: User engagement, retention, and email analytics

## 📂 Dataset & Tables
### 1️⃣ **Users Table**
Stores user information, including creation and activation timestamps.
```sql
CREATE TABLE users (
    user_id INT,
    created_at DATETIME,
    company_id INT,
    language VARCHAR(50),
    activated_at DATETIME,
    state VARCHAR(50)
);
